require "json"
require "pathname"

module Baltix::Spec::Rpm::SpecCore
   README_FILE_RE = /\Areadme(?:\.(?:md|markdown|rdoc|txt|rst|adoc|asciidoc|textile))?\z/i

   RUBY_CONFLICT_OPERATORS = {
      '>=' => '<', '>' => '<=', '<=' => '>', '<' => '>=', '=' => '!=', '!=' => '='
   }.freeze

   URL_MATCHER = {
      /(?<proto>https?:\/\/)?(?<user>[^\.]+).github.io\/(?<page>[^\/#]+)/ => ->(m) do
         "https://github.com/#{m["user"]}/#{m["page"]}.git"
      end,
      /(?<proto>https?:\/\/)?bogomips.org\/(?<page>[^\/#]+)/ => ->(m) do
         "https://bogomips.org/#{m["page"]}.git"
      end,
      /(?<proto>https?:\/\/)?github.com\/(?<user>[^\/]+)\/(?<page>[^\/\.#]+)/ => ->(m) do
         "https://github.com/#{m["user"]}/#{m["page"]}.git"
      end,
      /(?<proto>https?:\/\/)?gitlab.com\/(?<user>[^\/]+)\/(?<page>[^\/\.#]+)/ => ->(m) do
         "https://gitlab.com/#{m["user"]}/#{m["page"]}.git"
      end
   }

   def of_source name
      source.send(name) || nil
   rescue NameError
      nil
   end

   def of_state name
      state[name.to_s] || state[name.to_sym]
   end

   def of_options name
      options[name]
   end

   def of_space name
      space.respond_to?(name) ? space.send(name) : nil
   end

   def of_default name
      default = self.class::STATE[name][:default]

      default.is_a?(Proc) ? default[self] : default
   end

   def [] name
      instance_variable_get(:"@#{name}")
   end

   def []= name, value
      instance_variable_set(:"@#{name}", value)
   end

   def read_attribute name, seq = nil
      method = :copy
      aa = (seq || self.class::STATE[name][:seq]).reduce(nil) do |value_in, func|
       # binding.pry if name == :context
         /(?<method>[\-|>])*(?<mname>.*)/ =~ func

         value =
         if mname[0] == "_"
            if method(mname).arity == 0
               send(mname)
            else
               send(mname, value_in)
            end
         else
            send(mname, name)
         end

         case method
         when "|"
            [value_in].compact.flatten(1) | [value].compact.flatten(1)
         when "-"
            value_in
         when ">"
            value
         else #||
            value_in.present? && value_in || value
         end
      end
      # binding.pry if name == :context
      aa
   end

   def options= options
      @options = options.to_os
   end

   def options
      @options ||= {}.to_os
   end

   def state
      @state ||= {}.to_os
   end

   def state= value
      if value.name
         @name = name.merge(value.name)
      end

      @state = value.to_os
   end

   def evr
      "#{epoch ? "#{epoch}:" : ""}#{version}-#{release}"
   end

   def summary
      summaries[Baltix::I18n.default_locale]
   end

   # +executable_name+ returns a name of the executable package, based on
   # the all the sources executables.
   #
   # spec.executable_name # => foo
   #
   def executable_name
      # TODO make smart selection of executable name
      @executable_name =
         if executables.size > 1
            max = executables.map { |x| x.size }.max
            exec_map = executables.map {|exec| (exec + " " * (max - exec.size)).unpack("U*") }
            filter = [45, 46, 95]

            exec_map.transpose.reverse.reduce([]) do |r, chars|
               if (chars | filter).size == chars.size || ([ chars.first ] | chars).size == 1
                  r.concat([ chars.first ])
               else
                  []
               end
            end.reverse.pack("U*").sub(/[-_\.]+$/, '')
         else
            executables.first&.gsub(/[_\.]/, '-') || ""
         end
   end

   def prefix
      name.class.default_prefix
   end

   protected

   def change_list
      @change_list ||= []
   end

   def change key
      change_list << key
   end

   def _name value_in
      (name, aliases, kind, su) =
         if is_exec?
            if doc.space.options.autorender_name && doc.source.is_a?(Baltix::Source::Gem)
               [ source.name, executables, self.kind ]
            else
               if state.name
                  [ state.name.to_s, executables, self.kind ]
               elsif executable_name.size >= 3
                  [ executable_name, executables, self.kind ]
               else
                  [ value_in, executables, self.kind ]
               end
            end
         elsif value_in.is_a?(Baltix::Spec::Rpm::Name)
            if source.is_a?(Baltix::Source::Gem)
               [ source.name, value_in.aliases, value_in.kind, value_in.support_name ]
            else
               if value_in.alias_map[self.kind.to_s]
                   [ value_in.alias_map[self.kind.to_s].first, [], value_in.kind, value_in.support_name ]
               else
                  [ value_in.name, value_in.aliases, value_in.kind, value_in.support_name ]
               end
            end
         else
            [ value_in, [], self.kind ]
         end

      Baltix::Spec::Rpm::Name.parse(name, kind: kind, prefix: options[:name_prefix], aliases: aliases, support_name: su)
   end

   def _post_name value_in
      state_name = of_state(:name)&.alias_map&.[](nil)&.first

      change(:rename) if state_name && of_state(:name) != value_in
      #change(:rename) if state_name && value_in != state_name

      value_in
   end

   def _post_version value_in
      case of_state(:version)
      when value_in
      when nil
         change(:new)
      else
         change(:upgrade)
      end

      value_in
   end

   # Applies the selected host relationship and package-type prefix to an RPM name.
   # @param value_in [Name] selected package name before host normalization
   # @return [Name] name retaining its host and a single generated packaging prefix
   # Gem hosts supply the standard prefix for non-executable packages. Gemfile and
   # Rakefile hosts keep the original full form unless its prefix would be added
   # again by name rendering; in that case the base name is used. Other names remain.
   def _local_rename value_in
      value_in.support_name = host.name if host

      if host&.source&.kind_of?(Baltix::Source::Gem) && !is_exec?
         value_in.class.parse(value_in, prefix: value_in.class.default_prefix, support_name: value_in.support_name)
      elsif host && (host.source.kind_of?(Baltix::Source::Gemfile) || host.source.kind_of?(Baltix::Source::Rakefile))
         base_name = if value_in.prefix && value_in.prefix == value_in.autoprefix
            value_in.name
         else
            value_in.original_fullname
         end
         value_in.class.parse(value_in, support_name: value_in.support_name, name: base_name)
      else
         value_in
      end
   end

   # returns list of depencecies and devel sources without dep to itself
   def _devel _in = nil
      source.all_dependencies.reject { |x| x.name === source.name } | devel_sources
   end

   def _devel_sources _in = nil
      files.grep(/.*\.h(pp)?$/)
   end

   def _docs _in = nil
      of_source(:docs) || of_default(:docs)
   end

   def _summaries value_in
      return value_in if source.is_a?(Baltix::Source::Fake) && of_state(:summaries).present?

      source_name = source&.name
      summaries_in = @host && host.summaries || of_source(:summaries) || {}.to_os

      Baltix::I18n.locales.map do |locale_in|
         locale = locale_in.blank? && Baltix::I18n.default_locale || locale_in
         summary_pre = !%i(lib app).include?(self.kind) && summaries_in[locale_in] || value_in[locale] || value_in[locale_in] || nil
         summary = summary_pre&.match("(.*?)[\-\.,_\s]*?$")&.[](1)
         default = Baltix::I18n.t(:"spec.rpm.#{self.kind}.summary", locale: locale, binding: binding)

      #binding.pry
         if source.is_a?(Baltix::Source::Gem) or source.is_a?(Baltix::Source::Gemfile)
            [ locale_in, default ]
         else
            [ locale_in, summary ]
         end
      end.to_os.compact
   end

   def _devel_requires value_in
      value_tmp = value_in || source&.dependencies(:development) || []
      deps_versioned = replace_versioning(value_tmp)

      render_deps(append_versioning(deps_versioned))
   end

   def _devel_conflicts value_in
      value_tmp = value_in || source&.dependencies(:development) || []
      deps_versioned = replace_versioning(value_tmp)

      render_deps(append_versioning(deps_versioned), :negate)
   end

   def _files _in
      source&.files || []
   rescue
      []
   end

   def _proceed_description value_in
      value_in.map { |_locale, desc| desc.is_a?(Array) ? desc.join("\n") : desc }
   end

   def _descriptions value_in
      source_name = of_source(:name)
      summary = of_source(:summary)&.match("(.*?)[\.,-_\s]+$")&.[](1) # NOTE required for eval
      summaries_in = @host && summaries || { Baltix::I18n.default_locale => summary }
      descriptions_in = @host && host.descriptions || of_source(:descriptions) || of_source(:summaries) || {}.to_os

      Baltix::I18n.locales.map do |locale|
         sum = Baltix::I18n.t(:"spec.rpm.#{self.kind}.description", locale: locale, binding: binding)

         [ locale, sum ]
      end.to_os.map do |locale_in, summary_in|
         if locale_in.to_s == Baltix::I18n.default_locale
            if (source.is_a?(Baltix::Source::Gem) || source.is_a?(Baltix::Source::Gemfile)) && !%i(lib app).include?(self.kind)
               summary_in = summaries_in[locale_in]
               first = summary_in && (summary_in + ".")
               rest_in = descriptions_in[locale_in]
               /(?<re>.*)\.$/ =~ rest_in
               rest = first&.include?(re || rest_in || "") ? nil : rest_in
               [ first, rest ].compact.join("\n\n")
            else
               value_in[locale_in] || descriptions_in[locale_in]
            end
         else
            summary_in = summaries_in[locale_in]
            if source.is_a?(Baltix::Source::Gem) or source.is_a?(Baltix::Source::Gemfile)
               /(?<s>.+)\.?$/ =~ summary_in && s && "#{s}." || value_in[locale_in]
            else
               value_in[locale_in]
            end
         end
      end.compact
   end

   def _format_descriptions value_in
      value_in.map do |name, desc|
         tdesc = desc.gsub(/\n{2,}/, "\x1F\x1F").gsub(/\n([\*\-])/, "\x1F\\1").gsub(/\n/, "\s")
         new_desc =
            tdesc.split(/ +/).reduce([]) do |res, token|
               line = res.last
               uptoken = token.gsub(/(\n[^\-\*])/, "\n\\1").strip
               temp = [ line, uptoken ].reject { |x| x.blank? }.join(" ")

               if temp.size > 80 || !line
                  res << uptoken
               else
                  line.replace(temp)
               end

               postline = res.last.split(/\x1F/, -1)
               if postline.size > 1
                  res.last.replace(postline[0].strip)
                  res.concat(postline[1..-1].map(&:strip))
               end

               res
            end.join("\n")

         new_desc
      end
   end

   def _reversion value_in
      # TODO move reversion to space/sources
      # here is a workaround only
      # reversion to support newer ones
      source_name = source&.provide&.name
      reversion = source_name && gem_versionings[source_name] ||
         gem_versionings.select {|n,v| name.eql?(n, true) }.to_h.values.first

      reversion || value_in
   end

   # Normalizes the selected source or explicitly packaged gem version.
   # @param value_in [Gem::Version, Gem::Dependency, Array, String] selected version
   # @return [Gem::Version] package version, including explicit packaging suffixes
   # Main and library packages retain the selected version. Auxiliary packages
   # inherit their host's version; source-less secondaries inherit the document's.
   def _version value_in
      v =
         case value_in
         when Gem::Version
            value_in
         when Gem::Dependency
            value_in.requirement.requirements.first.last
         when Array
            Gem::Version.new(value_in.first.to_s)
         else
            Gem::Version.new(value_in.to_s)
         end

      if name.support_name.blank? # || name.support_name == name
         if is_dochost?
            (count, (version, sources_tmp)) =
               sources.group_by do |s|
                  s.version ? Gem::Version.new(s.version) : v
               end.map do |(x, y)|
                  [y.count, [x, y]]
               end.sort do |(x1, (v1, _)), (x2, (v2, _))|
                  s = x1 <=> x2

                  s == 0 ? v1 <=> v2 : s
               end.last

            v
         elsif source.respond_to?(:spec)
            v
         elsif doc
            doc.version # TODO как отличить?
         end
      elsif is_aux?
         # name.support_name == name
         host.version
      else
         v
      end
   end

   def is_dochost?
      self.respond_to?(:space)
   end

   def is_host?
      !self.respond_to?(:host)
   end

   def is_aux?
      %i(devel doc exec).include?(self.kind)
   end

   # Selects documentation entries and resolves existing files from their source root.
   # @param _in [Object] unused value from the property pipeline
   # @return [String] space-separated documentation paths relative to the repository root
   # If an entry exists under its source directory, its emitted path includes
   # that directory relative to the repository. Root-level paths remain unchanged.
   # Otherwise the declaration is retained for shared root files and metadata-only
   # inputs. If the main gem is nested and declares no README, repository README
   # documents supplement its entries, including its auxiliary packages. Sibling
   # gems retain their own documentation. Entries with the same basename retain
   # the first declaration.
   def _readme _in
      candidates = files
      source_root = source && File.expand_path(source.rootdir)
      repository_root = File.expand_path(doc.space.rootdir)
      if source.is_a?(Baltix::Source::Gem) && source.equal?(doc.source) &&
         source_root.start_with?(File.join(repository_root, '')) && candidates.grep(README_FILE_RE).empty?
         readmes = doc.space.default_fake_source.default_files.grep(README_FILE_RE).select do |file|
            File.file?(File.join(repository_root, file))
         end
         candidates |= readmes
      end

      candidates.grep(/^[^\/]*(#{Baltix::Source::Base::DEFAULT_FILES.join("|")})/i).group_by do |x|
         File.basename(x)
      end.map do |(name, a)|
         file = a.first
         source_path = source && File.join(source.rootdir, file)
         source_path && File.exist?(source_path) ?
            Pathname.new(source_path).relative_path_from(Pathname.new(doc.space.rootdir)).to_s : file
      end.join(" ")
   end

   # Selects RPM requirements that are not regenerated from package metadata.
   # @param value_in [Array<Gem::Dependency, String>] parsed requirements
   # @return [Array<String>] retained non-gem RPM requirements
   # Gem requirements are reconstructed from sources. For an auxiliary package
   # of an application, its host RPM requirement is also reconstructed so a prior
   # exact release cannot survive alongside the host's current release.
   def _requires_plain_only value_in
      @requires_plain_only ||= value_in&.reject do |dep|
         dep.is_a?(Gem::Dependency) ||
            (is_aux? && host&.is_app? && dep.is_a?(String) && dep.match?(/\A#{Regexp.escape(host.name.to_s)}(?:\s|\z)/))
      end
   end

   def _conflicts_plain_only value_in
      @conflicts_plain_only ||= value_in&.reject {|dep| dep.is_a?(Gem::Dependency) }
   end

   def _pre_name value_in
      return value_in if value_in.is_a?(Baltix::Spec::Rpm::Name)

      name = @name ||
         of_options(:name) ||
         of_state(:name) ||
         rootdir && rootdir.split("/").last ||
         value_in

      if name.is_a?(Baltix::Spec::Rpm::Name)
         name
      else
         Baltix::Spec::Rpm::Name.parse(name, prefix: options[:name_prefix])
      end
   end

   # Replaces parsed numeric interpreter and RubyGems minimums with merged requirements.
   # @param value_in [Array<String>] retained non-gem RPM requirements
   # @return [Array<String, Hash>] opaque requirements and combined Ruby/RubyGems bounds
   # Numeric Ruby and RubyGems constraints are merged; unrelated packages and RPM
   # macros remain unchanged. Rendering selects the strictest lower boundary for each interpreter.
   # Merged bounds occupy the first numeric interpreter entry's position. If none
   # exists, they are appended so source-only generation and updates keep the same order.
   def _requires_ruby value_in
      dependencies = Array(value_in)
      position = dependencies.index { |dependency| ruby_dependency(dependency) } || dependencies.length
      dependencies.reject { |dependency| ruby_dependency(dependency) }.insert(position, ruby_requirements).uniq
   end

   # Replaces numeric interpreter and RubyGems conflicts with merged requirements.
   # @param value_in [Array<String>] retained non-gem RPM conflicts
   # @return [Array<String, Hash>] opaque conflicts and combined Ruby/RubyGems bounds
   # Numeric Ruby and RubyGems conflicts are merged; unrelated RPM entries remain
   # unchanged. Rendering selects the strictest upper boundary for each interpreter.
   def _conflicts_ruby value_in
      Array(value_in).reject { |dependency| ruby_dependency(dependency) } | [ruby_requirements]
   end

   # Parses one numeric interpreter constraint without expanding RPM expressions.
   # @param dependency [Object] an imported RPM dependency
   # @return [Array<String>, nil] package name, operator and version, or no match
   # Ruby, RubyGems and engines declared by this library/application are recognized.
   # Other packages, non-string inputs and opaque versions are left untouched.
   def ruby_dependency dependency
      return unless dependency.is_a?(String)

      match = /\A(?<name>\S+)\s+(?<operator>!=|>=|<=|=|>|<)\s+(?<version>\S+)\z/.match(dependency)
      engines = ['ruby', 'rubygems'] | (%i(lib app).include?(kind) ? source.dsl.required_rubies.keys : [])
      return unless match && engines.include?(match[:name]) && Gem::Version.correct?(match[:version])

      match.values_at(:name, :operator, :version)
   end

   # Intersects this package's source and imported interpreter/RubyGems requirements.
   # @return [Hash<String, Gem::Requirement>] merged interpreter and RubyGems requirements
   # Libraries and applications include interpreter and RubyGems source declarations,
   # excluding implicit unconstrained defaults. Other packages use only imported
   # constraints. Explicit options take precedence over parsed RPM tags.
   # Parsed conflicts are inverted into allowed bounds before the shared merger is
   # used; macros and unrelated dependencies are preserved by the caller.
   def ruby_requirements
      @ruby_requirements ||= begin
         declarations = if %i(lib app).include?(kind)
            source.dsl.required_rubies.merge('rubygems' => source.dsl.required_rubygems)
         else
            {}
         end
         requirements = declarations.reject { |_name, requirement| requirement == Gem::Requirement.default }
         %i(requires conflicts).each do |tag|
            value = of_options(tag)
            value = of_state(tag) unless value.present?
            Array(value).each do |dependency|
               parsed = ruby_dependency(dependency)
               next unless parsed

               name, operator, version = parsed
               operator = RUBY_CONFLICT_OPERATORS.fetch(operator) if tag == :conflicts
               incoming = Gem::Requirement.new("#{operator} #{version}")
               requirements[name] = requirements[name] ? requirements[name].merge(incoming) : incoming
            end
         end
         requirements
      end
   end

   def _host_require value_in
      if is_aux?
         [ host.is_app? ? "#{host.name} = #{host.evr}" : source.is_a?(Baltix::Source::Fake) ? host.provide_dep : provide_dep ].compact
      end
   end

   def _render_bottom_dep value_in
      render_deps(value_in)
   end

   def _kind_deps
      case self.kind
      when :app
         main = doc.space.main_source.dsl.all_dependencies_for(kinds_in: :runtime)
         depended = doc.space.valid_sources.map {|x| x != doc.space.main_source ? x.provide : nil}.compact

         Baltix::DSL.merge_dependencies(main, depended).sort
      when :lib
         runtime_dependencies
      when :devel
         if host.is_app? && host == doc
            host.space.dependencies_for(kinds_in: :devel)
         else
            devel_dependencies
         end
      when :exec
         binary_dependencies
      else
         []
      end
   end

   def _render_top_dep value_in
      render_deps(value_in, :negate)
   end

   def _prepare_dependencies value_in
      value_in.map do |dep|
         if m = dep.match(/gem\((.*)\) ([>=<]+) ([\w\d\.\-]+)/)
            Gem::Dependency.new(m[1], Gem::Requirement.new(["#{m[2]} #{m[3]}"]), :runtime)
         else
            dep
         end
      end.compact
   end

   def _dependencies_sort value_in
      value_in.sort
   end

   def _replace_versioning_dependencies value_in
      provide_names = doc.secondaries.filter_map { |x| x.source&.provide&.name }.uniq

      replace_versioning(value_in).reject do |dep|
         if dep.is_a?(Gem::Dependency)
            dep.type == :development && options.devel_dep_setup == :skip || provide_names.include?(dep.name)
         end
      end
   end

#   def _append_versioning_dependencies value_in
#      append_versioning(value_in).reject do |n_in|
#         n = n_in.is_a?(Gem::Dependency) && n_in.name || n_in
#
#         name.eql?(n, true)
#      end
#   end

   # Merges runtime requirements and applies effective gem version overrides.
   # @param value_in [Array<Gem::Dependency>] runtime dependencies from existing state
   # @return [Array<Gem::Dependency>] merged runtime dependencies with effective bounds
   # If a dependency already exists, its source requirements are merged. External
   # overrides are applied when available; dependencies on gems packaged in the
   # same spec retain their source requirements.
   def _runtime_dependencies value_in
      dep_hash = value_in.group_by {|x|x.name}.map {|n, x| [n, x.reduce {|res, y| res.merge(y) } ] }.to_h

      dependencies = source.dsl.all_dependencies_for(kinds_in: :runtime).reduce(dep_hash.dup) do |r, x|
         r[x.name] = r[x.name] ? r[x.name].merge(x) : x

         r
      end.values

      replace_versioning(dependencies)
   end

   def _devel_dependencies value_in
      dep_hash = value_in.group_by {|x|x.name}.map {|n, x| [n, x.reduce {|res, y| res.merge(y) } ] }.to_h

      a=source.dsl.all_dependencies_for(kinds_in: :devel, kinds_out: :runtime).reduce(dep_hash.dup) do |r, x|
         r[x.name] = r[x.name] ? r[x.name].merge(x) : x

         r
      end.values
     #binding.pry
     a
   end

   def _binary_dependencies value_in
      dep_hash = value_in.group_by {|x|x.name}.map {|n, x| [n, x.reduce {|res, y| res.merge(y) } ] }.to_h

      source.dsl.all_dependencies_for(kinds_in: :binary).reduce(dep_hash.dup) do |r, x|
         r[x.name] = r[x.name] ? r[x.name].merge(x) : x

         r
      end.values
   end

   # Applies the same dependency requirements that are emitted in override macros.
   # @param deps_in [Array<Gem::Dependency, String>] dependencies to render
   # @return [Array<Gem::Dependency, String>] dependencies with effective requirements
   # If an external gem has an override, its dependency is copied with that exact
   # requirement. Otherwise it is retained. Non-gem entries and the current
   # package's own provided gem are retained without replacement.
   def replace_versioning deps_in
      versioning_list = doc.versioned_gem_list

      deps_in.map do |dep_in|
         if dep_in.is_a?(Gem::Dependency) && provide_dep&.name != dep_in.name
            dep = versioning_list[dep_in.name]

            if dep
               dep_in.dup.tap { |replacement| replacement.instance_variable_set(:@requirement, dep.requirement) }
            else
               dep_in
            end
         else
            dep_in
         end
      end
   end

   # +combine_deps+ method combines dependenies' requirements passed with arguments +base_dep+, and +dep+ base on
   # the operators in +base_dep+
   # Example:
   #    combine_deps(base_dep, dep)
   #
   def combine_deps base_dep, dep
      dep_ver = Gem::Dependency.new(base_dep.name, base_dep.requirement | dep.requirement)
      ops = base_dep.requirement.requirements.map {|x| x.first }.join(" ").gsub(/\A(~>|=)\z/, ">= < =").split(" ").uniq
      reqs = dep_ver.requirement.requirements.select {|x| ops.include?(x[0]) }

      dep_ver.requirement.requirements.replace(reqs)

      dep_ver
   end

   def append_versioning deps_in
      gem_versionings.reduce(deps_in) do |deps, name, dep|
         index = deps.index { |dep_in| dep_in.is_a?(Gem::Dependency) && dep_in.name == name.to_s }

         #binding.pry
         index && deps || deps | [ dep ]
      end
   end

   def variables
      @variables ||= context.__macros || {}.to_os
   end

   # Renders gem capabilities without resolving them as requirements.
   # @param value_in [Array<Gem::Dependency, String>] provided capabilities
   # @return [Array<String>] RPM Provides declarations with their selected versions
   # Capability rendering bypasses the internal-requirement map to avoid recursive
   # collection of Provides while dependencies are being rendered.
   def _render_provided_deps value_in
      render_deps(value_in, :provide)
   end

   # Collects exact gem capabilities supplied by packages in this generated spec.
   # Takes no parameters.
   # @return [Hash<String, String>] gem names mapped to their actual Provides versions
   # Only exact rendered gem capabilities participate; non-gem aliases and
   # unversioned or ranged capabilities are ignored. The current package and its
   # host, when present, also participate so custom templates rendering saved
   # metadata retain their own exact host requirements. Results are cached per package.
   def provided_gem_versions
      return @provided_gem_versions if @provided_gem_versions

      packages = ([doc] + doc.valid_secondaries) | [self]
      packages |= [host].compact if respond_to?(:host)
      @provided_gem_versions = packages.each_with_object({}) do |package, result|
         package.provides.each do |capability|
            match = capability.match(/\Agem\(([^)]+)\)\s+=\s+(\S+)\z/)
            result[match[1]] = match[2] if match
         end
      end
   end

   # Renders requirements, conflicts or provided gem capabilities as RPM strings.
   # @param deps_in [Array<Gem::Dependency, Hash, String>] constraints to render
   # @param mode [Symbol] :debound for minimums, :negate for conflicts, :provide for capabilities
   # @return [Array<String>] rendered dependency tags without duplicates
   # Internal requirements use the exact version actually provided by this spec;
   # internal conflicts are omitted. Capability rendering preserves its own bounds.
   # External equality requirements become inclusive minimums. Strict external
   # minimums and conflict boundaries retain >; provided capabilities and non-gem
   # constraints retain their normal bound conversion.
   def render_deps deps_in, mode = :debound
      func = mode == :negate ? :upper_negate_to_rpm : :lower_to_rpm

      deps_in.reduce([]) do |deps, dep|
         deps |
            if dep.is_a?(Gem::Dependency)
               supplied_version = provided_gem_versions[dep.name] unless mode == :provide
               deph = if supplied_version
                  mode == :negate ? [] : ['=', supplied_version]
               else
                  boundary = Baltix::Deps.send(func, dep.requirement)
                  mode == :debound && boundary.first == '=' ? ['>=', boundary.last] : boundary
               end

               deph.blank? ? [] : ["#{prefix}(#{dep.name}) #{deph.first} #{deph.last}"]
            elsif dep.is_a?(Hash)
               dep.map do |name, req|
                  deph = Baltix::Deps.send(func, req)

                  deph.blank? ? nil : "#{name} #{deph.first} #{deph.last}"
               end.compact
            else
               [dep]
            end
      end
   end

   # Builds the gem capability with its original name and selected package version.
   # @return [Gem::Dependency] the provided gem with an exact version requirement
   # If a source exists, its literal name is retained even when legacy RPM aliases
   # or version overrides also match another gem. Without a source, the space name
   # supplies the capability. A previously built dependency is returned unchanged.
   def provide_dep
      return @provide_dep if @provide_dep

      provide_dep_pre = source&.provide || space.name

      @provide_dep = Gem::Dependency.new(provide_dep_pre.name, version)
   end

   # Retains explicit capabilities without converting gems into plain RPM aliases.
   # @param value_in [Array<Gem::Dependency, String>] capabilities from configuration or state
   # @return [Array<Gem::Dependency, String>] explicit capabilities awaiting rendering
   # Packaged gems' capabilities are regenerated with their selected versions.
   # Other gem capabilities retain their type and bounds. Plain aliases matching
   # the current gem's literal name are removed, with or without version bounds.
   # Other RPM aliases retain the existing deduplication and implicit EVR behavior.
   # Packaged sources are queried only when a parsed gem capability needs handling.
   # The current gem's name is also checked when no typed gem capability was given.
   def _provides value_in
      packaged_names = value_in.any? { |value| value.is_a?(Gem::Dependency) } ?
         (Array(doc.sources) | [source]).grep(Baltix::Source::Gem).map(&:name) : []
      gem_name = source.name if source.is_a?(Baltix::Source::Gem)
      value_in.reduce([]) do |res, o|
         if o.is_a?(Gem::Dependency)
            packaged_names.include?(o.name) ? res : res | [o]
         else
            names.include?(o) || o.split.first == gem_name ?
               res : o =~ /^[^\s]+$/ ? res | [o + " = %EVR"] : res | [o]
         end
      end.compact
   end

   def _post_provides value_in
      change(:explicit_deps) if value_in.present? && !state.provides
   end

   def _lib_provide
      render_deps([provide_dep].compact, :provide) if self.kind == :lib
   end

   # Builds a compatibility capability when an imported RPM package is renamed.
   # @return [Array<String>] the old RPM name with EVR, or an empty list
   # No alias is emitted without a renamed input package. For a real gem source,
   # its literal name is also excluded: the typed gem capability represents it.
   # Other legacy RPM names retain their compatibility alias.
   def _find_provides
      return [] unless state.name && state.name.original_fullname != name.fullname
      return [] if source.is_a?(Baltix::Source::Gem) && state.name.original_fullname == source.name

      [state.name.original_fullname + " = %EVR"]
   end

   def _obsoletes value_in
      obsoletes =
         value_in.reduce([]) do |res, o|
            names.include?(o) ? res : o =~ /^[^\s]+$/ ? res | [o + " < %EVR"] : res | [o]
         end.compact
   end

   def _find_obsoletes value_in
      obsolete = state.name && state.name.original_fullname != name.fullname ? [state.name.original_fullname + " < %EVR"] : []

      value_in | obsolete
   end

   def _available_gem_list value_in
      value_in || options.available_gem_list
   end

   def _available_gem_ranges value_in
      available_gem_list.reduce({}.to_os) do |res, name, version_in|
         low = [ version_in ].flatten.map {|v| Gem::Version.new(v) }.min
         bottom = [ version_in ].flatten.map {|v| Gem::Version.new(v.to_s.split(".")[0..1].join(".")).bump }.max
         reqs = [ ">= #{low}", "< #{bottom}" ]

         res[name] = Gem::Dependency.new(name.to_s, Gem::Requirement.new(reqs))

         res
      end
   end

   def _filter_out_obsolete value_in
      value_in.reject do |value|
        value.is_a?(Gem::Dependency) || !use_gem_obsolete_list.[](value.match(/^(?<name>[^\s]+)/)[:name]).nil?
      end
   end

   def dep_list_merge first_in, second_in
      first = first_in || {}.to_os
      second = second_in || {}.to_os

      first.reduce(second.dup) do |r, name, req|
         if r[name]
            r[name] = r[name].merge(req)

            r
         else
            r.merge({ name => req }.to_os)
         end
      end
   end

   def dep_list_intersect *lists_in
      lists = lists_in.map {|list| list.to_os }

      lists.reduce do |r_list, list|
         list.reduce(r_list) do |r, name, req|
            if r[name]
               r[name] = Gem::Dependency.new("rake", req.requirement | r[name].requirement)

               r
            else
               r.merge({ name => req }.to_os)
            end
         end
      end
   end

   def _gem_versionings value_in
      pre_vers =
      [ variables.gem_replace_version ].flatten.compact.reduce({}.to_os) do |res, gemver|
         /^(?<name>[^\s]+)(?:\s(?<rel>[<=>~]+)\s(?<version>[^\s]+))?/ =~ gemver

         if res[name]
            res[name].requirement.requirements << [rel, Gem::Version.new(version)]
         else
            res[name] = Gem::Dependency.new(name, Gem::Requirement.new(["#{rel} #{version}"]))
         end

         res
      end

      dep_list_merge(value_in, pre_vers)
   end

   class << self
      def included obj
         obj::STATE.each do |name, opts|
            obj.define_method(name) { self[name] ||= read_attribute(name, opts[:seq]) || of_default(name) }
            #obj.define_method("_#{name}") { of_state[name] }
            obj.define_method("has_#{name}?") do
               options["#{name}_dep_setup"] != :skip && !read_attribute(name, opts["seq"]).blank?
            end
         end

         %w(lib exec doc devel app).each do |name|
            obj.define_method("is_#{name}?") { self.kind.to_s == name }
         end
      end
   end
end
