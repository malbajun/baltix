require 'rubygems'
require 'pathname'

require 'baltix/version'
require 'baltix/log'
require 'baltix/source'
require 'baltix/spec'
require 'baltix/cli'

class Baltix::Space
   include Baltix::Log

   class InvalidSpaceFileError < StandardError; end

   SERIALIZE_NAMES = %i(spec_type rootdir stat_sources)

   TYPES = {
      sources: Baltix::Source
   }

   STATES = {
      invalid: ->(_, source, _, _) { !source.valid? },
      disabled: ->(space, source, _, _) { space.is_disabled?(source) },
      obsoleted: ->(_, _, dup, obsoleted) { !dup && obsoleted },
      duplicated: ->(_, _, dup, _) { dup },
   }

   TYPE_CHARS = {
      fake: '·',
      gem: '*',
      gemfile: '&',
      rakefile: '^',
   }

   STATUS_CHARS = {
      invalid: 'X',
      disabled: '-',
      obsoleted: '\\',
      duplicated: '=',
      regarded: 'R',
      valid: 'V',
   }

   DEFAULT_IGNORE_PATH_TOKES =
      %w(templates example examples sample samples spec test features
         fixtures doc docs contrib demo acceptance conformance myapp website benchmarks benchmark
         gemfiles misc steep)

   PLATFORMS = {
      ruby: true,
      jruby: false,
      mingw: false,
   }

   VERSIONS = {
      /nonrelease/ => false
   }

   # tags:
   # default,test,development,production,etc for gemfile
   # runtime,development for gemspec
   #
   # for spec:
   # library: gemspec:runtime
   # binary: gemfile:default
   # devel: gemfile:* + gemspec:runtime + gemspec:development
   # build: 1) marked as required from extconf 2) marked by macro as build in spec
   # check: devel - build

   @@space = {}
   @@options = {}

   # +options+ property returns the hash of the loaded options if any
   #
   # options #=> {...}
   #
   attr_reader :options, :state

   def options= options
      @options = Baltix::CLI::DEFAULT_OPTIONS.merge(options || {}.to_os)
   end


   # +name+ returns a default name of the space with a prefix if any. It returns name of a source when
   # its root is the same as the space's root, or returns name defined in the spec if any.
   # If no spec defined returns name of last folder in rootdir or "root" as a default main source name.
   #
   # space.name # => space-name
   #
   def name
      return @name if @name

      @name = spec&.name || main_source.name
   end

   # +version+ returns a default version for the space. Returns version of a source when
   # its root is the same as the space's root, or returns version defined in the spec if any,
   # or returns default one.
   #
   # space.version # => 2.1.1
   #
   def version
      return @version if @version

      @version ||= main_source.version || spec&.version
   end

   attr_writer :rootdir

   # +rootdir+ returns the root dir for the space got from the options,
   # defaulting to the current folder.
   #
   # rootdir #=> /root/dir/for/the/space
   #
   def rootdir
      @rootdir ||=
         if rootdir = read_attribute(:rootdir)
            path = Pathname.new(rootdir)
            path.absolute? ? rootdir : File.join(Dir.pwd, rootdir)
         else
            Dir.pwd
         end
   end

   # +select_sources+ selects the sources matching their by name, types, and status etc combining found by arguments conjunctively.
   # The statuses are: :valid, :obsoleted, :duplicated, :disabled, and the specific one is :active
   # nil value is to just ignore argument
   # examples:
   # select_sources "name", :Gem, :valid # selects by name, type, and valid only
   # select_sources /name/ # selects by name with the regexp, and both valid and invalid
   # select_sources nil # selects all the source ignoring the name match
   #
   def select_sources *args
      params = prepare_find_args(args)

      stat_source_tree.reduce([]) do |res, (path_in, stated_sources)|
         stated_sources.reduce(res) do |res, (source, status)|
            next res unless params.all? do |param|
               case param.type
               when :match
                  param.value === source.name
               when :attribute
                  anot, avalue = /not_(.*)/ =~ param.value ? [true, $1] : [false, param.value]

                  ares =
                     if avalue == :active
                        !%i(disabled invalid obsoleted duplicated).include?(status)
                     else
                        avalue.to_sym == status
                     end

                  anot ? !ares : ares
               when :class
                  param.value === source
               end
            end

            res | [source]
         end
      end
   end

   # Selects the main source without changing the repository root directory.
   # Takes no parameters and returns a source, or nil when no candidate exists.
   # If the loaded spec names a real source, that source takes precedence;
   # a gem is preferred over repository metadata matching the same name.
   # If the root source is not a gem, a nested gem matching its RPM name aliases
   # is preferred. If the root is synthetic and no matching gem exists, the sole
   # real source is used. Otherwise the root source is retained. A previously
   # selected source is returned from the cache.
   #
   def main_source
      return @main_source if @main_source

      reals = valid_sources.select { |source| !source.is_a?(Baltix::Source::Fake) }

      if spec && !spec.state.blank?
         specen_source = (reals.grep(Baltix::Source::Gem) | reals).find { |real| spec.state["name"] === real.name }
      end

      root_source ||= valid_sources.sort {|x, y| x.name.size <=> y.name.size }.find { |source| source.rootdir == rootdir }

      if root_source && !root_source.is_a?(Baltix::Source::Gem)
         repository_name = Baltix::Spec::Rpm::Name.parse(root_source.name)
         nested_source = reals.find { |source| source.is_a?(Baltix::Source::Gem) && repository_name === source.name }
      end

      @main_source =
         specen_source || nested_source || root_source.is_a?(Baltix::Source::Fake) && reals.size == 1 && reals.first || root_source
   end

   def default_fake_source
      Baltix::Source::Fake.new(source_file: File.join(rootdir, ".fake"))
   end

   def time_stamp
      Time.now.strftime("%Y%m%d")
   end

   # +changes+ returns a list of open-struct formatted changes in the space or
   # spec defined if any, otherwise returns blank array.
   #
   # space.changes # => []
   #
   def changes
      @changes ||= spec&.changes || main_source&.respond_to?(:changes) && main_source.changes || []
   end

   # +summaries+ returns an open-struct formatted summaries with locales as keys
   # in the space or spec defined if any, otherwise returns blank open struct.
   #
   # space.summaries # => #<OpenStruct en_US.UTF-8: ...>
   #
   def summaries
      return @summaries if @summaries

      if summaries = spec&.summaries || state.summaries
         summaries
      elsif summary = main_source&.summary
         { Baltix::I18n.default_locale => summary }.to_os
      end
   end

   # +licenses+ returns license list defined in all the valid sources found in the space.
   #
   # space.licenses => # ["MIT"]
   #
   def licenses
      return @licenses if @licenses

      licenses = valid_sources.map { |source| source.licenses rescue [] }.flatten.uniq

      @licenses = !licenses.blank? && licenses || spec&.licenses || []
   end

   def grouped_dependencies
      @grouped_dependencies ||= all_dependencies.group_by {|x| x.groups }.to_h
   end

   # +dependencies+ returns all the valid source dependencies list as an array of Gem::Dependency
   # objects, otherwise returning blank array.
   def dependencies
      @dependencies ||=
         valid_sources.reduce({}) do |res, source|
            source.dsl.all_dependencies.reduce(res) do |r, dep|
               r.merge(dep.name => r[dep.name] ? r[dep.name].merge(dep) : dep)
            end
         end.values.sort_by {|dep| dep.name }
   end

   # Collects valid sources' dependencies for included package kinds.
   # @param kinds_in [Symbol, Array<Symbol>] kinds to include
   # @param kinds_out [Symbol, Array<Symbol>] kinds whose dependencies are excluded
   # @return [Array<Bundler::Dependency>] merged dependencies on supported platforms
   # Custom groups map to development/test kinds; exclusions take priority.
   def all_dependencies_for kinds_in: [], kinds_out: []
      valid_sources.reduce([]) do |deps,x|
         deps_in = x.all_dependencies
         Baltix::DSL.merge_dependencies(deps, deps_in).sort_by {|x| x.name }
      end.select do |dep|
         Baltix::DSL.match_kind_dep(dep, kinds_in) && !Baltix::DSL.match_kind_dep(dep, kinds_out) &&
         (dep.platforms.blank? || dep.platforms.any? {|p| PLATFORMS[p.to_sym] })
      end
   end

   # Filters the space's dependency list by included and excluded package kinds.
   # @param kinds_in [Symbol, Array<Symbol>] kinds to include
   # @param kinds_out [Symbol, Array<Symbol>] kinds whose dependencies are excluded
   # @return [Array<Bundler::Dependency>] matching dependencies on supported platforms
   # Custom groups map to development/test kinds; exclusions take priority.
   def dependencies_for kinds_in: [], kinds_out: []
      dependencies.select do |dep|
         Baltix::DSL.match_kind_dep(dep, kinds_in) && !Baltix::DSL.match_kind_dep(dep, kinds_out) &&
         (dep.platforms.blank? || dep.platforms.any? {|p| PLATFORMS[p.to_sym] })
      end
   end

   def match_platform? dep
      if dep.respond_to?(:platforms)
         (dep.platforms & options.skip_platforms).any?
      end
   end

   def files
      @files ||= valid_sources.map { |s| s.files rescue [] }.flatten.uniq
   end

   def executables
      @executables ||= valid_sources.map { |s| s.executables rescue [] }.flatten.uniq
   end

   def docs
      @docs ||= valid_sources.map { |s| s.docs rescue [] }.flatten.uniq
   end

   def compilables
      @compilables ||= valid_sources.map { |s| s.compilables rescue [] }.flatten.uniq
   end

   # +sources+ returns all the sources in the space. It will load from the space sources,
   # or by default will search sources in the provided folder or the current one.
   #
   # space.sources => # [#<Baltix::Source:...>, #<...>]
   #
   def sources
      @sources ||= stat_sources.map { |x| x.first }
   end

   # +valid_sources+ returns all the valid sources based on the current source list.
   #
   # space.valid_sources => # [#<Baltix::Source:...>, #<...>]
   #
   def valid_sources
      @valid_sources ||=
         begin
            sources = stat_sources.map {|(source, status)| %i(valid regarded).include?(status) ? source : nil }.compact
            main = sources.find { |source| source.rootdir == rootdir }
            main && main.valid? ? sources : sources | [default_fake_source]
         end
   end

#   def is_regarded? source
#      regarded_names.any? {|i| i === source.name } ||
#         !ignored_names.any? {|i| i === source.name } &&
#         !ignored_path_tokens.any? {|t| /\/#{t}\// =~ source.source_file }
#   end

   def ignored_names
      @ignored_names ||= (read_attribute(:ignored_names) || [])
   end

   def regarded_names
      @regarded_names ||= read_attribute(:regarded_names) || []
   end

   def ignored_path_tokens
      @ignored_path_tokens ||= (read_attribute(:ignored_path_tokens) || []) | DEFAULT_IGNORE_PATH_TOKES
   end

   def regarded_path_tokens
      @regarded_path_tokens ||= (read_attribute(:regarded_path_tokens) || [])
   end

   def spec_type
      @spec_type ||= read_attribute(:spec_type) || spec && spec.class.to_s.split("::").last.downcase
   end

   def read_attribute attr
      options.send(attr) || state.respond_to?(attr) && state.send(attr)
   end

   def options_for type
      @@options[type] = type::OPTIONS.map do |option|
         value = self.options[option] || self.respond_to?(option) && self.send(option) || nil

         [ option, value ]
      end.compact.to_os
   end

   # +spec+ property returns the hash of the loaded spec if any, it can be freely
   # reassigned.
   #
   # spec #=> {...}
   #
   def spec
      @spec ||= gen_spec
   end

   def spec= value
      gen_spec(value)
   end

   def is_platform_allowed? platform
      case platform
      when Gem::Platform
         PLATFORMS.any? {|(name, valid)| platform === name ? valid : nil }
      when String
         !!PLATFORMS[platform.to_sym]
      when NilClass
         true
      else
         false
      end
   end

   def is_version_allowed? version
      return true if version.nil?

      if /^[0-9\.]+(\.(?<post>[a-z]*|))?$/ =~ version
         !post || VERSIONS.reduce(true) {|res, (re, v)| res && (re =~ post ? v : false) }
      end
   end

   def is_disabled? source
      source_path = source.source_file && "/#{Pathname.new(source.source_file).relative_path_from(Pathname.new(rootdir))}"
      !is_platform_allowed?(source.platform) || !is_version_allowed?(source.version) ||
         regarded_path_tokens.map do |t|
            t.is_a?(Regexp) && %r{/[^/]*#{t}[^/]*/} || %r{/#{t}/}
         end.all? do |t|
            t !~ source_path
         end &&
         ignored_path_tokens.map do |t|
            t.is_a?(Regexp) && %r{/[^/]*#{t}[^/]*/} || %r{/#{t}/}
         end.any? do |t|
            t =~ source_path
         end ||
         options.regarded_names.all? { |i| !i.match?(source.name) } &&
         options.ignored_names.any? { |i| i === source.name }
   end

   def store filename = '.space'
      state = SERIALIZE_NAMES.reduce({}.to_os) {|res, name| res.merge(name => send(name)) }

      File.open(filename, "w+") {|f| f.puts(state.to_yaml) }

      self
   end

   protected

   # symbols like: valid, disabled, duplicated, obsoleted
   # active: valid + !disabled + !duplicated + !obsoleted
   def prepare_find_args args
      args.map do |arg|
         case arg
         when Regexp, String
            { type: :match, value: arg }.to_os
         when Symbol
            if arg.to_s == arg.to_s.downcase
               { type: :attribute, value: arg }.to_os
            else
               { type: :class, value: "Baltix::Source::#{arg}".constantize }.to_os
            end
         when NilClass
            nil
         end
      end.compact
   end

   def gen_spec spec_in = nil
      spec_pre = spec_in || state.spec

      @spec =
         if spec_pre.is_a?(Baltix::Spec::Rpm)
            spec_pre
         elsif spec_pre.is_a?(String)
            Baltix.load(spec_pre)
         elsif options&.spec_file
            Baltix::Spec.load_from(source: IO.read(options.spec_file), options: options, space: self)
         elsif @spec_type || options&.spec_type
            Baltix::Spec.find(@spec_type || options.spec_type).new(options: options, space: self)
         end

      @spec.assign_space(self) if @spec

      @spec
   end

   def initialize state_in: {}.to_os, options: {}.to_os
      self.options = options
      @state = (state_in || {}.to_os)

      baltix_log
   end

   # init log
   def baltix_log
      ios = DEFAULT_IO_NAMES.merge(%i(error warn info debug).map {|k| [k, options["#{k}_io"]]}.to_h)

      Baltix::Log.setup([options.log_level].flatten.first.to_sym, ios)
   end

   def show_tree
      info("Sources:")
      stat_source_tree.each do |(path_in, stated_sources)|
         stated_sources.each do |(source, status)|
            path = source.source_file_from(rootdir) if source.source_file
            stat = [STATUS_CHARS[status], TYPE_CHARS[source.type.to_sym]].join(" ")
            namever = [source.name, source.version, source.platform.to_s].compact.join(":")
            info_in = "#{stat}#{namever} [#{path}]"

            info(info_in)
         end
      end
   end

   def pre_sources
      @pre_sources ||=
         Baltix::Source.search_in(rootdir, options).group_by do |x|
            [x.name, x.version].compact.join(":")
         end
   end

   # returns all the sources with their statuses, and sorted by a its rootdir value
   #
   def stat_sources &block
      return @stat_sources if @stat_sources

      @stat_sources = read_attribute(:stat_sources) || proceed_sources

      show_tree

      @stat_sources
   end

   def proceed_sources
      pre =
         pre_sources.reduce([[],[],[]]) do |(r, used_in, deps_in), (_full_name, v)|
            sorten =
               v.sort do |x,y|
                  c0 = ::Baltix::Source.loaders.index(x.loader) <=> ::Baltix::Source.loaders.index(y.loader)
                  c1 = c0 == 0 && x.name <=> y.name || c0
                  c2 = c1 == 0 && y.version <=> x.version || c1
                  c3 = c2 == 0 && y.platform.to_s <=> x.platform.to_s || c2
                  c4 = c3 == 0 && y.source_names.grep(/gemspec/).count <=> x.source_names.grep(/gemspec/).count

                  c2 == 0 && c3 == 0 && c4 == 0 && x.rootdir.size <=> y.rootdir.size || c4 != 0 && c4 || c3 != 0 && c3 || c2
               end.reduce([[], 0]) do |(res, index, base), source|
                  dup = used_in.include?(source.name) && base && base.platform.to_s == source.platform.to_s && base.version == source.version && base.class == source.class
                  dup_index = dup ? index + 1 : index
                  obs = used_in.include?(source.name) && !dup
                  if source.valid? && !is_disabled?(source)
                     base = source
                     used_in = used_in | [source.name]
                  end

                  [res | [[source, source_status(source, dup, obs)]], dup_index, base]
               end.first

            deps = deps_in | sorten.map {|source, status| status == :valid ? source.dependencies : [] }.flatten

            sorten[1..-1].each { |x| sorten.first.first.alias_to(x.first) }

            [r|[sorten], used_in, deps]
         end

      pre.first.flatten(1).map do |(source, status)|
            if status == :disabled &&
               pre[2].any? do |dep|
                  dep.name == source.name && source.is_a?(Baltix::Source::Gem) &&
                  dep.requirement.satisfied_by?(source.provide.requirement.requirements.last.last)
               end
               [source, :regarded]
            else
               [source, status]
            end
         end.sort_by {|(x, _)| x.rootdir.size }.each do |(source, status)|
            block[source, status] if block_given?
         end
   end

   # returns source tree, and sorted, and then grouped by a its rootdir value
   #
   def stat_source_tree
      @stat_source_tree ||=
         stat_sources.group_by {|(x, _)| x.rootdir }.map do |(path, sources)|
            [File.join('.', path[rootdir.size..-1] || ''), sources]
         end.to_h
   end

   # returns status for the source for the project
   #
   def source_status source, dup, obs
      %i(valid duplicated obsoleted disabled invalid).reduce() do |res, status|
         STATES[status][self, source, dup, obs] && status || res
      end
   end

   def context
      @context ||= options[:context] || spec&.context || {}
   end

   def method_missing method, *args
      value =
         instance_variable_get(:"@#{method}") ||
         (spec.send(method) rescue nil) ||
         options&.[](method) ||
         spec&.options&.[](method.to_s) ||
         state[method]

      instance_variable_set(:"@#{method}", value || super)

      value
   end

   class << self
      def load_from! state: Dir[".space"].first, options: {}
#         system_path_check # TODO required to generate spec rubocop

         state_tmp =
            case state
            when IO, StringIO
               Baltix.load(state.readlines.join(""))
            when String
               raise InvalidSpaceFileError.new(state: state) if !File.file?(state)

               Baltix.load(IO.read(state))
            when NilClass
            else
               raise InvalidSpaceFileError
            end.to_os

         @@space[state_tmp.name] = self.new(state_in: state_tmp, options: options)
      end

      def load_from state: Dir[".space"].first, options: {}
         load_from!(state: state, options: options)
      rescue InvalidSpaceFileError
         @@space[nil] = new(nil, options)
      end
   end
end

require 'baltix/space/spec'
