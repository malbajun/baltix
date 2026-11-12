require 'bundler'
require 'fileutils'
require 'tempfile'

require 'baltix'

# DSL service for baltix.
class Baltix::DSL
   # default group = binary, devel, test
   #
   # group to kinds mapping
   GROUP_MAPPING = {
      default: [:devel, :runtime, :binary, :test],
      gemfile: [:devel, :binary, :test],
      integration: [:devel, :test],
      development: [:devel, :test],
      test: [:test, :devel],
      build: [:build, :devel],
      debug: [:devel, :test],
      runtime: [:runtime, :test],
      production: [:binary, :runtime],
      true => [:runtime, :binary]
   }.reduce(Hash.new([:devel, :test])) {|r,(k,v)| r.merge(k => v) }

   PLATFORMS = {
      ruby: true,
      jruby: false,
      mingw: false,
   }

   DSL_CONT_EXCEPTIONS = %w(LoadError SyntaxError TypeError Bundler::GemNotFound Bundler::VersionConflict
      Bundler::GemfileNotFound Bundler::VersionConflic Bundler::Dsl::DSLError Bundler::GemspecError
      Errno::ENOENT Gem::InvalidSpecificationException)

   # attributes
   attr_reader :source_file, :replace_list, :skip_list, :append_list, :spec

   def gemfiles
      return @gemfiles if @gemfiles

      gemfiles = dsl.instance_variable_get(:@gemfiles) || []

      @gemfiles = gemfiles.map {|g| g.is_a?(Pathname) && g || Pathname.new(g) }
   end

   def gemfile
      gemfiles.first || original_gemfile || fake_gemfile_path
   end

   def original_gemfile
      @original_gemfile ||= is_source_gemfile && Pathname.new(source_file) || find_gemfile
   end

   def is_source_gemfile
      source_file =~ /Gemfile$/i
   end

   def find_gemfile
      gemfile = source_file && Dir[File.join(File.dirname(source_file), '{Gemfile,gemfile}')].first

      gemfile && Pathname.new(gemfile) || nil
   end

   def fake_gemfile_path
      if !@fake_gemfile && @fake_gemfile ||= Tempfile.create('Gemfile')
         @fake_gemfile_path = @fake_gemfile.path

         Bundler::SharedHelpers.set_env "BUNDLE_GEMFILE", @fake_gemfile_path
         @fake_gemfile.close
      end

      @fake_gemfile_path
   end

   def fake_gemlock_path
      if !@fake_gemlock && @fake_gemlock ||= Tempfile.create('Gemfile.lock')
         @fake_gemlock_path = @fake_gemlock.path

         @fake_gemlock.close
      end

      @fake_gemlock_path
   end

   def default_dsl
      dsl = Bundler::Dsl.new
      dsl.instance_variable_set(:@gemfiles, [Pathname.new(fake_gemfile_path)])
      dsl.to_definition(fake_gemlock_path, {})
      Bundler::SharedHelpers.set_env "BUNDLE_GEMFILE", nil

      dsl
   end

   def source_file_dsl
      dsl =
         Dir.chdir(File.dirname(source_file)) do
            dsl = Bundler::Dsl.new
            dsl.eval_gemfile(original_gemfile)
            dsl
         end
   rescue Exception => e
      unless DSL_CONT_EXCEPTIONS.find {|ec| ec == e.class.to_s }
         debug("dsl error: #{e.class} #{e.message}")

         raise e
      end
   end

   def dsl
      @dsl ||= source_file_dsl || default_dsl
   end

   def edsl
      @edsl ||= (
         begin
            edsl = dsl.dup
            edsl.dependencies = deps_but(self.class.merge_dependencies(dsl.dependencies, additional_dependencies))
            edsl
         end)
   end

   def definition
      @definition ||=
         Dir.mktmpdir do
            FileUtils.touch("Gemfile")

            edsl.to_definition("./Gemfile", {})
         end
   end

   def external_dependencies
      return [] unless source_file

      dir = File.dirname(source_file)

      (Gem::DependencyInstaller.instance_variable_get(:@deps) || []).map do |(path, dep)|
         if path[0...dir.size] == dir
            Bundler::Dependency.new(dep.name, dep.requirement, "group" => :development)
         end
      end.compact
   end

   def spec_dependencies
      gemspecs.flat_map(&:dependencies).map do |dep|
         group_in = :test
         options = {
            "group" => dep.type == :development ? [group_in] : [:runtime, group_in],
            "platforms" => dep.respond_to?(:platforms) ? dep.platforms : []
         }

         Bundler::Dependency.new(dep.name, dep.requirement, options)
      end
   end

   # Selects original dependencies for the requested package kinds.
   # @param kinds_in [Symbol, Array<Symbol>, nil] runtime, development or other kinds
   # @return [Array<Bundler::Dependency>] matching dependencies on supported platforms
   # Custom groups use the default development/test mapping.
   def original_deps_for kinds_in = nil
      original_deps.select do |dep|
         self.class.match_kind_dep(dep, kinds_in) &&
         (dep.platforms.blank? || dep.platforms.any? {|p| PLATFORMS[p] })
      end
   end

   # Merges dependencies after excluding unsupported platform declarations.
   # Takes no parameters.
   # @return [Array<Bundler::Dependency>] constraints from supported platforms
   # Platform filtering precedes merging: a repeated JRuby-only declaration must
   # not become an unrestricted dependency when its groups and bounds are merged.
   def all_dependencies
      lists = [additional_dependencies, external_dependencies, gemfile_dependencies, spec_dependencies].map do |dependencies|
         Array(dependencies).select { |dependency| self.class.platform_allowed?(dependency) }
      end
      Baltix::DSL.merge_dependencies(*lists)
   end

   # Returns Gemfile dependencies with groups appropriate to the project type.
   # Takes no parameters and returns an Array of Bundler::Dependency objects.
   # If a gemspec is present, default Gemfile dependencies are copied into the
   # gemfile group for development, binaries and tests; explicit groups are
   # preserved. If there is no gemspec,
   # returns the original dependencies so application runtime groups are kept.
   # If every inferred platform of a dependency is ignored by skip_platforms,
   # that Gemfile dependency is omitted before dependencies are merged.
   def gemfile_dependencies
      return dsl.dependencies if gemspecs.empty?

      dsl.dependencies.filter_map do |dep|
         platforms = @dependency_platforms[dep.name]
         next if platforms && !platforms.empty? && platforms.all? { |platform| ignored_dependency_platform?(platform) }

         dep.dup.tap do |dependency|
            dependency.groups = dep.groups.map { |group| group == :default ? :gemfile : group }.uniq
         end
      end
   end

   # Checks an inferred gemspec platform against the configured ignore list.
   # @param platform [Gem::Platform] a platform declared by a gemspec variant
   # @return [Boolean] true when the platform matches an ignored OS or platform
   # If an entry is jruby, it matches the Java OS. Other entries match an OS
   # prefix (mingw includes mingw32) or the complete platform string.
   def ignored_dependency_platform? platform
      @skip_platforms.any? do |ignored|
         name = ignored.to_s
         if name == 'jruby'
            platform.os == 'java'
         else
            platform.os.to_s.start_with?(name) || platform.to_s == name
         end
      end
   end

   # Selects merged dependencies by included and excluded package kinds.
   # @param kinds_in [Symbol, Array<Symbol>] kinds to include
   # @param kinds_out [Symbol, Array<Symbol>] kinds whose dependencies are excluded
   # @return [Array<Bundler::Dependency>] matching dependencies on supported platforms
   # Custom groups use the default development/test mapping; exclusions take priority.
   def all_dependencies_for kinds_in: [], kinds_out: []
      all_dependencies.select do |dep|
         self.class.match_kind_dep(dep, kinds_in) && !self.class.match_kind_dep(dep, kinds_out) &&
         (dep.platforms.blank? || dep.platforms.any? {|p| PLATFORMS[p] })
      end
   end

   def original_deps
      @original_deps ||= all_dependencies.map do |dep|
         type = dep.groups.map {|g| GROUP_MAPPING[g]}.compact.flatten.uniq.sort.first || dep.type
         dep.instance_variable_set(:@type, type)
         valid = !dep.source.is_a?(Bundler::Source::Path)

         valid && dep || nil
      end.compact
   end

   def gemspecs
      spec ? [spec] : dsl.gemspecs
   end

   def extracted_gemspec_deps
      gemspecs.map { |gs| gs.dependencies }.flatten.uniq
   end

   def extracted_gemspec_runtime_deps
      gemspecs.map do |gs|
         gs.dependencies.select {|dep|dep.runtime?}
      end.flatten.uniq
   end

   def runtime_deps kind = :gemspec
      if kind == :gemspec
         deps_but(extracted_gemspec_runtime_deps)
      else
         deps_but(original_deps_for(:runtime))
      end
   end

   def development_deps kind = :gemspec
      deps_but(original_deps_for(:devel))
   end

   class << self
      # Checks a dependency's actual groups against requested package kinds.
      # @param dep [Bundler::Dependency] the dependency whose groups are classified
      # @param kinds_in [Array<Symbol, Array<Symbol>>] runtime, development or other kinds
      # @return [Boolean] whether any group maps to a requested kind
      # Custom groups use GROUP_MAPPING's default development/test kinds.
      def match_kind_dep dep, *kinds_in
         kinds = kinds_in.flatten
         dep.groups.any? { |group| (GROUP_MAPPING[group] & kinds).any? }
      end

      def defined_groups_for *kinds_in
         kinds_in.flatten.map do |k|
            GROUP_MAPPING.map do |(g, k_in)|
               [k_in].flatten.include?(k) && g || nil
            end.compact
         end.flatten.select {|x| x.is_a?(Symbol) }
      end

      def retype type_in
         if %i(development runtime).include?(type_in)
            type_in
         else
            :development
         end
      end

      # Excludes declarations explicitly disabled by the platform policy before merging.
      # @param dependency [Gem::Dependency, Bundler::Dependency] declaration to check
      # @return [Boolean] whether an unrestricted or supported-platform declaration is usable
      # Missing platform metadata is unrestricted. If platforms are declared, at
      # least one must not be disabled in PLATFORMS. Other declarations, including
      # MRI-specific platforms, remain available; no second platform list is created.
      def platform_allowed? dependency
         platforms = dependency.respond_to?(:platforms) ? Array(dependency.platforms) : []
         platforms.empty? || platforms.any? { |platform| PLATFORMS.fetch(platform.to_sym, true) }
      end

      def merge_dependencies *depses
         depses.reduce({}) do |res, deps|
            deps&.reduce(res.dup) do |r, x|
               r[x.name] =
                  if r[x.name]
                     req = r[x.name].requirement.merge(x.requirement)
                     group = (x.groups || []) | (r[x.name].groups || [])

                     Bundler::Dependency.new(x.name, req, "type" => retype(r[x.name].type), "group" => group)
                  else
                     x
                  end

               r
            end || res
         end.values
      end

      def filter_dependencies type, *depses
         depses.map { |deps| deps.select {|x|x.type == type }}
      end
   end

   def dependencies type = nil
      if type
         self.class.merge_dependencies(*self.class.filter_dependencies(type, definition.dependencies, spec&.dependencies))
      else
         self.class.merge_dependencies(definition.dependencies, spec&.dependencies)
      end
   end

   def deps
      deps_but(original_deps) | gemspec_deps
   end

   def gemspec_deps
      gemspecs.map do |gs|
         version = gs.version || Gem::Version.new(0)
         Gem::Dependency.new(gs.name, Gem::Requirement.new(["= #{version}"]), :devel)
      end
   end

   def deps_for kinds_in = nil
      deps_but(original_deps_for(kinds_in)) | gemspec_deps
   end

   # Reads every declared version bound for a Gemfile's interpreter engine.
   # @param dsl_ruby [Bundler::RubyVersion, Object] the Gemfile Ruby declaration
   # @return [Gem::Requirement] the complete interpreter version requirement
   # Bundler declarations may contain several bounds; legacy declarations already
   # expose a requirement object and are returned unchanged.
   def engine_version dsl_ruby
      if dsl_ruby.is_a?(Bundler::RubyVersion)
         Gem::Requirement.new(dsl_ruby.engine_versions)
      else
         dsl_ruby.engine_version
      end
   end

   # Intersects Ruby language and engine constraints from the gemspec and Gemfile.
   # @return [Hash<String, Gem::Requirement>] requirements keyed by interpreter name
   # If both sources constrain Ruby, all bounds are retained by the shared merger.
   # An alternate engine keeps its own bounds alongside the Ruby language bounds.
   # Missing declarations contribute no additional constraints.
   def required_rubies
      return @required_rubies if @required_rubies

      rubies = {}
      rubies["ruby"] = spec.required_ruby_version if spec
      dsl_ruby = dsl.instance_variable_get(:@ruby_version)
      if dsl_ruby
         declared = {dsl_ruby.engine.to_s => engine_version(dsl_ruby)}
         declared['ruby'] = Gem::Requirement.new(dsl_ruby.versions) if dsl_ruby.is_a?(Bundler::RubyVersion)
         rubies = rubies.merge(declared) { |_name, existing, incoming| existing.merge(incoming) }
      end

      @required_rubies = rubies
   end

   def required_rubygems
      return @required_rubygems if @required_rubygems

      rubygems = spec.required_rubygems_version if spec
      dsl_rubygems = dsl.instance_variable_get(:@rubygems_version)
      rubygems = rubygems ? rubygems.merge(dsl_rubygems) : dsl_rubygems if dsl_rubygems

      @required_rubygems = rubygems || Gem::Requirement.new([">= 0"])
   end
 
   def ruby
      { type: required_ruby, version: required_ruby_version }
   end

   def rubygems
      { version: required_rubygems_version }
   end

   def valid?
      gemfiles.any? {|g| g.eql?(original_gemfile) }
   end

   def to_ruby
      spec = self.spec.dup
      deps_in = deps_but(extracted_gemspec_deps)
      deps = spec.dependencies.map {|x| deps_in.find {|a| a.name == x.name }}.compact
      spec.dependencies.replace(deps)
      spec.to_ruby
   end

   def to_gemfile
      deps_but(original_deps).group_by { |d| d.name }.map do |name, deps|
         reqs = deps.map do |dep|
            reqs = dep.requirement.requirements.map {|r| "'#{r[0]} #{r[1]}'" }.join(", ")
         end.join(", ")

         dep = deps.first
         autoreq = dep.respond_to?(:autorequire) &&
                   dep.autorequire &&
                   "require: #{dep.autorequire.any? &&
                             "[" + dep.autorequire.map { |r| r.inspect }.join(', ') + "]" ||
                             "false"}" || nil
         groups = dep.respond_to?(:groups) && dep.groups || []
         g = groups - [ :default ]
         group_list = g.any? && "group: %i(#{groups.join("\n")})" || nil

         [ "gem '#{name}'", reqs, autoreq, group_list ].compact.join(', ')
      end.join("\n")
   end

   def required_rubygems_version
      ">= 0"
   end

   def required_ruby_version
      @required_ruby_version ||= Gem::Requirement.new(dsl.instance_variable_get(:@ruby_version)&.engine_versions || ">= 0")
   end

   def required_ruby
      @required_ruby ||= dsl.instance_variable_get(:@ruby_version)&.engine || "ruby"
   end

   # Merges another source's dependencies into this DSL and refreshes derived data.
   # @param other_dsl [Baltix::DSL] the source whose dependencies are imported
   # @return [Baltix::DSL] self, including the imported dependency requirements and groups
   # If both sources read the same existing Gemfile, no merge is needed. Otherwise,
   # including when neither source has a Gemfile, dependencies are retained as
   # additional dependencies and cached dependency views are invalidated.
   def merge_in other_dsl
      if !original_gemfile || original_gemfile.to_s != other_dsl.original_gemfile.to_s
         @additional_dependencies = self.class.merge_dependencies(additional_dependencies, other_dsl.all_dependencies)
         @original_deps = @edsl = @definition = nil
      end

      self
   end

   def additional_dependencies
      @additional_dependencies ||= []
   end

   def assign_dependencies deps
      @additional_dependencies = additional_dependencies| deps
   end

   protected

   def deps_but deps
      deps.map do |dep|
         next if skip_list.include?(dep.name)

         new_req = replace_list.reduce(nil) do |s, (name, req)|
            s || name == dep.name && req
         end

         if new_req
            dep.dup.tap do |replacement|
               replacement.instance_variable_set(:@requirement, Gem::Requirement.new([new_req]))
            end
         else
            dep
         end
      end.compact | append_list
   end

   #
   def initialize source_file, options = {}
      # TODO source_file is null for Fake source
      # raise unless source_file && File.file?(source_file)

      @source_file = source_file
      @spec = options[:spec]
      @dependency_platforms = options[:dependency_platforms] || {}
      @skip_platforms = options[:skip_platforms] || []
      @replace_list = options[:replace_list] || {}
      @skip_list = options[:skip_list] || []
      @append_list = options[:append_list] || []
   end
end
