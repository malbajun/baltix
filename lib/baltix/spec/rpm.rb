require "erb"

require 'baltix/spec'
require 'baltix/i18n'

class Baltix::Spec::Rpm
   attr_reader :comment, :space, :host

   %w(Name Parser Secondary SpecCore).reduce({}) do |types, name|
     autoload(:"#{name}", File.dirname(__FILE__) + "/rpm/#{name.snakeize}")
   end

   OPTIONS = %w(source conflicts uri vcs maintainer
                source_files patches build_pre_requires context comment
                readme executables ignored_names ignored_path_tokens regarded_path_tokens main_source dependencies
                valid_sources available_gem_list rootdir aliased_names
                time_stamp devel_dep_setup use_gem_version_list use_gem_obsolete_list)

   HAS_PARTS = {
      lib: nil,
      exec: :has_executables?,
      doc: :has_docs?,
      devel: :has_devel?,
   }

   STATE_CHANGE_NAMES = %w(name version summaries licenses group uri vcs
      packager build_arch source_files build_pre_requires descriptions secondaries
      prep build install check file_list)

   CHANGES_MAJORITY = {
      fix: :minor,
      explicit_deps: :minor,
      rename: :major,
      upgrade: :version,
      new: :new,
   }

   STATE = {
      name: {
         seq: %w(of_options of_state of_source of_default >_name >_global_rename -_post_name),
         default: "",
      },
      pre_name: {
         seq: %w(of_options of_state of_default >_pre_name),
         default: "",
      },
      epoch: {
         seq: %w(of_options of_source of_state),
         default: nil,
      },
      version: {
         seq: %w(of_options of_source of_state of_default >_version_of_secondaries >_reversion >_version -_post_version),
         default: ->(this) { this.options.time_stamp || Time.now.strftime("%Y%m%d") },
      },
      release: {
         seq: %w(of_options of_state >_release),
         default: "alt1",
      },
      build_arch: {
         seq: %w(of_options of_state of_source),
         default: "noarch",
      },
      summaries: {
         seq: %w(of_options of_state of_source of_default >_summaries),
         default: ""
      },
      group: {
         seq: %w(of_options of_state of_source),
         default: ->(this) { Baltix::I18n.t("spec.rpm.#{this.kind}.group") },
      },
      requires: {
         seq: %w(of_options of_state of_default >_filter_out_obsolete >_requires_plain_only >_requires_ruby >_requires_rubygems |_host_require |_kind_deps >_render_bottom_dep),
         default: [],
      },
      conflicts: {
         seq: %w(of_options of_state of_default >_conflicts_plain_only |_conflicts_ruby |_kind_deps >_render_top_dep),
         default: [],
      },
      provides: {
         seq: %w(of_options of_state of_default >_provides |_find_provides |_lib_provide -_post_provides >_render_bottom_dep),
         default: [],
      },
      obsoletes: {
         seq: %w(of_options of_state of_default >_obsoletes >_find_obsoletes),
         default: [],
      },
      file_list: {
         seq: %w(of_options of_state of_source),
         default: "",
      },
      licenses: {
         seq: %w(of_options of_state >_licenses),
         default: [],
      },
      uri: {
         seq: %w(of_options of_state of_source),
         default: nil,
      },
      vcs: {
         seq: %w(of_options of_state of_source >_vcs),
         default: nil,
      },
      packager: {
         seq: %w(of_options of_state),
         default: ->(this) do
            OpenStruct.new(
               name: this.options.maintainer&.name || "Spec Author",
               email: this.options.maintainer&.email || "author@example.org"
            )
         end
      },
      maintainer: {
         seq: %w(of_options of_state),
         default: ->(this) do
            OpenStruct.new(
               name: this.options.maintainer&.name || "Spec Author",
               email: this.options.maintainer&.email || "author@example.org"
            )
         end
      },
      source_files: {
         seq: %w(of_options of_state of_default >_source_files),
         default: { "0": "%name-%version.tar" }.to_os,
      },
      patches: {
         seq: %w(of_options of_state),
         default: {}.to_os,
      },
      devel_dependencies: {
         seq: %w(of_options of_state of_default >_prepare_dependencies >_devel_dependencies >_fix_dependencies_groups >_replace_versioning_dependencies >_dependencies_sort),
         default: [],
      },
      binary_dependencies: {
         seq: %w(of_options of_state of_default >_prepare_dependencies >_binary_dependencies >_replace_versioning_dependencies >_dependencies_sort),
         default: [],
      },
      runtime_dependencies: {
         seq: %w(of_options of_state of_default >_prepare_dependencies >_runtime_dependencies >_dependencies_sort),
         default: [],
      },
      build_dependencies: {
         seq: %w(of_options of_state of_default >_prepare_dependencies >_build_dependencies >_fix_dependencies_groups >_build_dependencies_filter >_replace_versioning_dependencies >_dependencies_sort),
         default: [],
      },
      check_dependencies: {
         seq: %w(of_options of_state of_default >_prepare_dependencies >_check_dependencies >_fix_dependencies_groups >_check_dependencies_filter >_replace_versioning_dependencies >_dependencies_sort),
         default: [],
      },
      build_requires: {
         seq: %w(of_options of_state of_default >_filter_out_build_auto_requires >_filter_out_obsolete |_build_requires),
         default: [],
      },
      check_requires: {
         seq: %w(of_options of_state of_default |_check_requires),
         default: [],
      },
      build_conflicts: {
         seq: %w(of_options of_state of_default |_build_conflicts),
         default: [],
      },
      check_conflicts: {
         seq: %w(of_options of_state of_default |_check_conflicts),
         default: [],
      },
      build_pre_requires: {
         seq: %w(of_options of_state of_default >_build_pre_requires),
         default: [ "rpm-macros-ruby setup-rb rake" ],
      },
      changes: {
         seq: %w(of_options of_state of_source of_default >_collect_changes >_changes),
         default: []
      },
      prep: {
         seq: %w(of_options of_state),
         default: "%setup",
      },
      build: {
         seq: %w(of_options of_state),
         default: "%ruby_build",
      },
      install: {
         seq: %w(of_options of_state),
         default: "%ruby_install",
      },
      check: {
         seq: %w(of_options of_state),
         default: "%ruby_test",
      },
      secondaries: {
         seq: %w(of_options of_state of_default >_secondaries),
         default: [],
      },
      context: {
         seq: %w(of_options of_state),
         default: {}.to_os,
      },
      comment: {
         seq: %w(of_options of_state),
         default: nil,
      },
      spec_template: {
         seq: %w(of_options of_state),
         default: ->(_) { IO.read(File.join(File.dirname(__FILE__), "rpm.erb")) },
      },
      compilables: {
         seq: %w(of_options of_state of_source),
         default: [],
      },
      descriptions: {
         seq: %w(of_options of_state of_source of_default >_proceed_description >_descriptions >_format_descriptions),
         default: {}.to_os
      },
      valid_sources: {
         seq: %w(of_state of_space of_default),
         default: []
      },
      readme: {
         seq: %w(of_options of_source >_readme of_state),
         default: nil,
      },
      executables: {
         seq: %w(of_options of_source of_state),
         default: [],
      },
      docs: {
         seq: %w(of_options >_docs of_state),
         default: nil,
      },
      all_docs: {
         seq: %w(of_options >_sub_docs of_state),
         default: [],
      },
      devel: {
         seq: %w(of_options >_devel of_state),
         default: nil,
      },
      devel_requires: {
         seq: %w(of_options of_state >_devel_requires),
         default: nil,
      },
      devel_conflicts: {
         seq: %w(of_options of_state >_devel_conflicts),
         default: nil,
      },
      devel_sources: {
         seq: %w(of_options >_devel_sources of_state),
         default: [],
      },
      files: {
         seq: %w(of_options >_files of_state),
         default: []
      },
      allfiles: {
         seq: %w(of_options of_source of_state),
         default: []
      },
      dependencies: {
         seq: %w(of_options of_state of_source),
         default: []
      },
      development_dependencies: {
         seq: %w(of_options of_state of_source),
         default: []
      },
      ruby_alias_names: {
         seq: %w(of_options of_state >_ruby_alias_names >_ruby_alias_names_local),
         default: []
      },
      gem_versionings: {
         seq: %w(of_options of_state >_gem_versionings_with_use),
         default: []
      },
      # Persist explicit path settings; built-in defaults remain in Space.
      ignored_path_tokens: {
         seq: %w(of_options |of_state),
         default: []
      },
      regarded_path_tokens: {
         seq: %w(of_options |of_state),
         default: []
      },
      ignored_names: {
         seq: %w(of_options |of_state),
         default: []
      },
      aliased_names: {
         seq: %w(of_options |of_state),
         default: []
      },
      available_gem_list: {
         seq: %w(of_options of_state >_available_gem_list),
         default: {}.to_os
      },
      versioned_gem_list: {
         seq: %w(of_options of_state >_versioned_gem_list),
         default: {}.to_os
      },
      available_gem_ranges: {
         seq: %w(of_options of_state >_available_gem_ranges),
         default: {}.to_os
      },
      use_gem_version_list: {
         seq: %w(of_options of_state >_use_gem_version_list),
         default: {}.to_os
      },
      use_gem_obsolete_list: {
         seq: %w(of_options of_state),
         default: {}.to_os
      },
      rootdir: {
         seq: %w(of_options of_state),
         default: nil
      },
      rake_build_tasks: {
         seq: %w(of_options of_source of_state of_default >_rake_build_tasks),
         default: ""
      }
   }.to_os(hash: true)

   include Baltix::Spec::Rpm::SpecCore
   include Baltix::I18n

   def render spec = nil
      b = binding

      ERB.new(spec || spec_template, trim_mode: "<>-", eoutvar: "@spec").result(b).strip
   end

   def macros name
      [ context.__macros[name] ].flatten(1).map { |x| "%#{name} #{x}" }.join("\n")
   end

   # Formats explicit path tokens for an RPM macro and the directory-token CLI.
   # @param tokens [Array<String, Regexp>] configured source path tokens
   # @return [String] comma-separated tokens retaining their matching behavior
   # If a token is a regexp, partial-directory wildcards and embedded regexp
   # flags retain its semantics when the macro is read back as string tokens.
   # String tokens are emitted unchanged.
   def path_tokens_for_macro tokens
      tokens.map { |token| token.is_a?(Regexp) ? "[^/]*#{token}[^/]*" : token }.join(",")
   end

   def is_same_source? source_in
      source_in && source == source_in
   end

   def kind
      @kind ||= source.is_a?(Baltix::Source::Gem) && :lib || :app
   end

   def state_kind
      @state_kind ||= pre_name&.kind || state['file_list'].blank? && default_state_kind
   end

   def default_state_kind
      "app"
   end

   def assign_space space
      @space = space

      #TODO clean variables

      space
   end

   def doc
      @doc ||= self
   end

   def names
      @names ||= [name.to_s] | secondaries.map {|sec| sec.name.to_s }.uniq
   end

   # +has_any_docs?+ returns true if self or child source has any doc
   #
   def has_any_docs?
      all_docs.any?
   end

   # Checks this package's native extensions and, optionally, its subpackages.
   # The compilables list itself remains local to the main package. With
   # :with_children, emitted library subpackages are also checked; without it,
   # only the local list is checked for file ownership.
   # @param mode [Symbol, nil] :with_children includes library subpackages;
   #   nil checks only this package
   # @return [Boolean] false when compilables_dep_setup is :skip; otherwise,
   #   true when the local list or an included library subpackage has compilables
   def has_compilables? mode = nil
      options["compilables_dep_setup"] != :skip &&
         (!compilables.blank? || (mode == :with_children && valid_secondaries.any? do |secondary|
            secondary.is_lib? && secondary.has_compilables?
         end))
   end

   def pure_build_requires
      build_requires.select {|r| r !~ /^gem\(.*\)/ }
   end

   def pure_build_conflicts
      build_conflicts.select {|r| r !~ /^gem\(.*\)/ }
   end

   def gem_build_requires
      build_requires.select {|r| r =~ /^gem\(.*\)/ }
   end

   def gem_build_conflicts
      build_conflicts.select {|r| r =~ /^gem\(.*\)/ }
   end

   def has_gem_build_requires?
      gem_build_requires.any?
   end

   def has_gem_build_conflicts?
      gem_build_conflicts.any?
   end

   def source
      @source ||= space&.main_source || sources.find {|source_in| pre_name == source_in.name } || Baltix::Source::Fake.new({
         "name" => state.name&.fullname,
         "version" => state.version,
         "kind" => state.kind || state.name&.kind,
         "valid" => true})
   end

   # +sources+ infers sources from the space if any. filtered out by the ignore names filter 
   def sources
      @sources ||=
         space&.valid_sources.reject do |source_in|
            ignored_names.any? { |x| x === source_in.name }
         end
   end

   def valid_secondaries
     @valid_secondaries ||= secondaries.select do |s|
        s.source&.source_file
     end
   end

   def _sub_docs _in = []
      (of_source(:docs) || []) | secondaries.map {|s| s.docs }.flatten.compact
   end

   protected

   def ruby_build
      @ruby_build ||= variables.ruby_build&.split(/\s+/) || []
   end

   def _global_rename value_in
      # binding.pry
      case source
      when Baltix::Source::Gem
         value_in.class.parse(value_in, prefix: value_in.class.default_prefix)
      when Baltix::Source::Gemfile, Baltix::Source::Rakefile, Baltix::Source::Fake
         value_in.class.parse(value_in, prefix: nil, kind: "app", name: value_in.original_fullname)
      else
         value_in
      end
   end

   def _collect_changes value_in
      %i(name version provides).each {|x| send(x) }

      value_in
   end

   def _version_of_secondaries value_in
      vers = secondaries.group_by { |sec| sec.source&.version }.select {|k,_| k}.map {|v, arr| [v, arr.size] }.to_h

      if source.is_a?(Baltix::Source::Gemfile)
         vers.sort {|(_, sizes)| sizes }.last&.first
      end || value_in
   end

   # Selects dependency overrides required by any packaged source.
   # @param _value_in [OpenStruct, Hash, nil] historical overrides, superseded by current inputs
   # @return [OpenStruct] override requirements keyed by dependency name
   # An override is retained when it changes a dependency of the main source or
   # another packaged source, so secondary gems also receive a build-time macro.
   # If a gem is itself packaged from these sources, it is excluded from external
   # version overrides and retains its source version.
   def _versioned_gem_list _value_in
      packaged_sources = Array(sources) | [source].compact
      packaged_names = packaged_sources.grep(Baltix::Source::Gem).map(&:name)
      dependencies = packaged_sources.flat_map(&:all_dependencies)

      available_gem_ranges.reduce({}.to_os) do |result, name, available|
         next result if packaged_names.include?(name.to_s)

         matching = dependencies.select { |dep| dep.name == name.to_s }
         next result if matching.empty?

         override = _available_dependency_override(available, matching)
         if override && matching.any? { |dep| combine_deps(dep, override).requirement.requirements != dep.requirement.expand.requirements }
            result[name] = override
         end

         result
      end
   end

   # Builds an availability override without lowering any source minimum.
   # @param available [Gem::Dependency] range inferred from the available gem list
   # @param dependencies [Array<Gem::Dependency>] current source requirements for this gem
   # @return [Gem::Dependency, nil] the corrected range, or nil when all available versions are too old
   # The lower bound is the greatest source minimum, independent of availability.
   # The source upper bound is the least source maximum; availability may raise
   # it, but cannot narrow it. If sources have no maximum, it stays unbounded.
   # If a source uses >, its exclusive minimum is preserved; = and ~> supply
   # inclusive minimums. If no available version reaches the source minimum,
   # no override is produced. Historical spec macros do not participate.
   def _available_dependency_override available, dependencies
      minimums = dependencies.flat_map do |dependency|
         dependency.requirement.requirements.filter_map do |operator, version|
            case operator
            when '>=', '>' then [operator, version]
            when '=', '~>' then ['>=', version]
            end
         end
      end
      minimum = minimums.max_by { |operator, version| [version, operator == '>' ? 1 : 0] } || ['>=', Gem::Version.new(0)]
      versions = Array(available_gem_list[available.name]).map { |version| Gem::Version.new(version.to_s) }
      return nil unless versions.any? { |version| minimum[0] == '>' ? version > minimum[1] : version >= minimum[1] }

      maximums = dependencies.flat_map do |dependency|
         dependency.requirement.requirements.filter_map do |operator, version|
            case operator
            when '<', '<=' then [operator, version]
            when '=' then ['<=', version]
            when '~>' then ['<', version.bump]
            end
         end
      end
      maximum = maximums.min_by { |operator, version| [version, operator == '<' ? 0 : 1] }
      requirements = [minimum]
      if maximum
         available_maximums = available.requirement.requirements.select { |operator, _| %w(< <=).include?(operator) }
         requirements << ([maximum] + available_maximums).max_by { |operator, version| [version, operator == '<=' ? 1 : 0] }
      end
      Gem::Dependency.new(available.name, Gem::Requirement.new(requirements.map { |pair| pair.join(' ') }))
   end

   def _gem_versionings_with_use value_in
      dep_list_merge(_gem_versionings(value_in), use_gem_version_list)
   end

   def autoaliases
      @autoaliases =
         secondaries.map do |sec|
            case sec.kind
            when :exec, :app
               sec.name.alias_for(sec.name.kind)
            when :lib
               sec.name.alias_for(sec.name.kind)
            end
         end.compact.flatten
   end

   def _ruby_alias_names value_in
      @ruby_alias_names ||= (value_in || []) | ruby_build.reduce([]) do |res, line|
         case line
         when /--use=(.*)/
            res << [ $1 ]
         when /--alias=(.*)/
            res.last << $1
         end

         res
      end.map do |aliases|
         aliases |
            [ aliased_names, [ autoaliases ]].map do |a|
               a.reject { |x| (x & aliases).blank? }
            end.flatten
      end
   end

   def _ruby_alias_names_local value_in
      return @ruby_alias_names_local if @ruby_alias_names_local

      names =
         if source.kind_of?(Baltix::Source::Gem)
            [source&.name, name&.name, name.alias_map["app"]].flatten
         else
            [source&.name, name&.fullname]
         end.compact.uniq

    #    binding.pry
      @ruby_alias_names_local = value_in | (names.size > 1 && [ names ] || [])
   end

   def _use_gem_version_list value_in
      value_in && value_in.map do |name, v|
         Gem::Dependency.new(name.to_s, Gem::Requirement.new(v))
      end
   end

   def _secondaries value_in
      names = value_in.map { |x| x.name }
      #context_in = { context: context }.to_os
      secondaries_in = of_state(:secondaries) || []

      # binding.pry
      # Match the main source through RPM aliases so its repository metadata
      # cannot produce a second package with the same normalized name.
      main_name = source && Name.parse(source.name)
      to_ignore = ([main_name] | ignored_names).flatten.compact
      secondaries = valid_sources.reject do |source_in|
         to_ignore.any? { |i| i === source_in.name }
      end.map do |source|
         state =
            secondaries_in.find do |osec|
               osec.name === source.name&&
                  %w(app lib).include?(osec.name.kind || osec.name.approximate_kind)
            end

         sec = Secondary.new(source: source,
                             doc: self,
                             state: state,
                             options: { name_prefix: name.prefix,
                                        gem_versionings: gem_versionings,
                                        available_gem_list: available_gem_list })

         secondary_parts_for(sec, source)
      end.concat(secondary_parts_for(self, source, )).flatten.uniq {|x| x.name.fullname }

      # binding.pry
      secondaries =
         names.reduce(secondaries) do |secs, an|
            next secs if secs.find { |sec| sec.name == an }
            sec = value_in.find { |sec| sec.name == an }
      # binding.pry if sec

            if sec.is_a?(Secondary)
               secs | [sec]
            elsif sec.is_a?(OpenStruct)
               #source = sources.find { |s| sec.name == s.name } || Baltix::Source::Fake.new
               source = Baltix::Source::Fake.new
               host = secs.find { |sec_in| sec_in.name.eql_by?(:name, sec.name) }

               secs | [Secondary.new(doc: self,
                             kind: sec.name.kind,#an.kind
                             host: host,
                             state: sec,
                             source: source,
                             options: { name: sec.name,
                                        gem_versionings: gem_versionings,
                                        available_gem_list: available_gem_list })]
            else
               secs
            end
         end

      # binding.pry
      secondaries =
         secondaries.select do |sec|
            sec.kind != :devel || options.devel_dep_setup != :skip
         end

      secondaries
   end

   def secondary_parts_for object, source
      context_in = { context: context }.to_os
      secondaries_in = of_state(:secondaries) || []

      HAS_PARTS.map do |(kind, func)|
         next object.is_a?(Secondary) && object || nil if !func

            state =
               secondaries_in.find do |osec|
                  kinds = [osec.name.kind || osec.name.approximate_kind, osec.kname&.kind || osec.kname&.approximate_kind].compact

                  if source.respond_to?(:spec) && source.spec.respond_to?(:executables)
                     (source.executables | [source.name]).any? {|s| osec.name === s }
                  else
                     osec.name === source.name
                  end && kinds.include?(kind.to_s)
               end

         if object.send(func) || state
            presec =
               Secondary.new(source: source,
                             doc: self,
                             kind: kind,
                             host: object,
                             state: state,
                             options: { name_prefix: kind != :exec && name.prefix || nil,
                                        gem_versionings: gem_versionings,
                                        available_gem_list: available_gem_list })

            unless presec.state
               state = secondaries_in.find { |osec| osec.name == presec.name }
               presec.state = state if state
            end

            presec
         end
      end.compact
   end

   def _build_dependencies value_in
      dep_hash = value_in.group_by {|x|x.name}.map {|n, x| [n, x.reduce {|res, y| res.merge(y) } ] }.to_h
 
      dep_hash.values | space.all_dependencies_for(kinds_in: :build)
   end

   def _build_dependencies_filter value_in
      #binding.pry
      value_in.select do |dep|
         Baltix::DSL.match_kind_dep(dep, :build)
      end
   end

   def _check_dependencies value_in
      dep_hash = value_in.group_by {|x|x.name}.map {|n, x| [n, x.reduce {|res, y| res.merge(y) } ] }.to_h

      dep_hash.values | space.all_dependencies_for(kinds_in: :test)
   end

   # Adjusts test groups for dependencies declared as build requirements.
   # @param value_in [Array<Gem::Dependency>] dependencies with Bundler group metadata
   # @return [Array<Gem::Dependency>] dependencies with copied entries where groups change
   # If default dependency priority is disabled and the input spec names a
   # dependency as a build requirement, its copy omits groups used for tests.
   # Otherwise the original entry is retained. Source dependency objects and
   # their group arrays are never modified.
   def _fix_dependencies_groups value_in
      state_build_requires_names = state.build_requires&.select {|x| x.is_a?(Gem::Dependency) }&.map {|x| x.name } || []

      value_in.map do |dep|
         if !options.high_default_dependencies_priority && state_build_requires_names.include?(dep.name)
            dep.dup.tap do |dependency|
               dependency.groups = dep.groups - Baltix::DSL.defined_groups_for(:test)
            end
         else
            dep
         end
      end
   end

   def _check_dependencies_filter value_in
      #binding.pry
      value_in.reject do |dep|
         Baltix::DSL.match_kind_dep(dep, :build)
      end
   end

   # Retains external gem build requirements while reconstructing known gems.
   # @param value_in [Array<Gem::Dependency, String>] parsed RPM build requirements
   # @return [Array<String>] requirements retained before source reconstruction
   # If a gem is declared in source metadata or provided by this spec, its old
   # requirement is removed for reconstruction, including ignored platform gems.
   # Other gems retain their explicit bounds as RPM declarations. Ruby-prefixed
   # package strings are removed except for separate -headers-devel packages;
   # unrelated package strings are retained.
   def _filter_out_build_auto_requires value_in
      known_names = space.dependencies.map(&:name) | space.valid_sources.flat_map do |source|
         [source.name] | source.dsl.dsl.dependencies.map(&:name)
      end

      value_in.flat_map do |value|
         if value.is_a?(Gem::Dependency)
            if known_names.include?(value.name)
               []
            else
               value.requirement.requirements.map { |relation, version| "#{prefix}(#{value.name}) #{relation} #{version}" }
            end
         elsif value.is_a?(String) && /^(#{Baltix::Spec::Rpm::Name::PREFICES.join('|')})[\-(]/ =~ value &&
            !value.match?(/\A\S+-headers-devel(?:\s|\z)/)
            []
         else
            [value]
         end
      end
   end

   def _build_requires value_in
      render_deps(build_dependencies)
   end

   def _check_requires value_in
      render_deps(check_dependencies)
   end

   def _build_conflicts value_in
      render_deps(build_dependencies, :negate)
   end

   def _check_conflicts value_in
      render_deps(check_dependencies, :negate)
   end

   def _vcs value_in
      pre = URL_MATCHER.reduce(value_in) do |res, (rule, e)|
         vcs = res || uri
         vcs && (match = vcs.match(rule)) && e[match] || res
      end

      pre && "#{pre}#{/\.git/ !~ pre && ".git" || ""}".downcase || nil
   end

   def _source_files value_in
      source_files = value_in.dup
      defaults = of_default(:source_files)[:"0"]

      source_files[:"0"] = defaults if source_files[:"0"] != defaults

      source_files
   end

   # Normalizes Ruby build prerequisites while retaining explicit version constraints.
   # @param value_in [Array<String>, nil] grouped or individually parsed prerequisites
   # @return [Array<String>] canonical prerequisite lines without duplicate Ruby entries
   # Obsolete Ruby Policy 2.0's rpm-build-ruby is replaced with the Ruby Policy 2.1
   # prerequisites rpm-macros-ruby, setup-rb and rake. If that legacy prerequisite
   # is present or the package prefix changes, missing
   # defaults are added. If a default package already has a versioned requirement,
   # that requirement is kept instead of adding an unversioned one. Remaining
   # unversioned defaults are grouped so parsing and rendering stay consistent.
   def _build_pre_requires value_in
      build_pre_requires = Array(value_in).flat_map { |line| line.scan(/[^\s]+(?:\s+[<=>]+\s+[^\s]+)?/) }.uniq
      stated_name = of_state(:name)
      defaults = of_default(:build_pre_requires)[0].split

      legacy_ruby = build_pre_requires.delete("rpm-build-ruby")
      if legacy_ruby || stated_name && stated_name.prefix != name.prefix
         defaults.each do |dependency|
            unless build_pre_requires.any? { |entry| entry == dependency || entry.start_with?("#{dependency} ") }
               build_pre_requires << dependency
            end
         end
      end

      plain_defaults = defaults.select { |dependency| build_pre_requires.delete(dependency) }
      plain_defaults.reject! do |dependency|
         build_pre_requires.any? { |entry| entry.start_with?("#{dependency} ") }
      end
      grouped_defaults = plain_defaults.empty? ? [] : [plain_defaults.join(' ')]
      grouped_defaults + build_pre_requires
   end

   def _licenses value_in
      list =
         sources.map do |source|
            source.licenses
         end.flatten.uniq.map do |l|
            Baltix::License.parse(l)
         end

      !list.blank? && list || value_in.blank? && ["Unlicense"] || value_in
   end

   def state_changed?
      @state_changed = STATE_CHANGE_NAMES.any? do |property|
         if property == "secondary"
            [ of_state(property), self.send(property) ].transpose.any? do |(first, second)|
               first.name != second.name
            end
         else
            of_state(property) != self.send(property)
         end
#
#         when String, Name, Gem::Version, NilClass,
#         binding.prya
#         when Array
#         binding.pry
#            of_state(property) == self.send(property)
#         when OpenStruct
#         binding.pry
#            of_state(property) == self.send(property)
#         else
#         binding.pry
#         end
#
#         true
      end
   end

         #aif change_list.any?
   def _changes value_in
      new_change =
         if change_list.any?
            previous_version = of_state(:version)
            version, release = evr_from_changes

            OpenStruct.new(
               date: Date.today.strftime("%a %b %d %Y"),
               author: options.maintainer&.name || packager.name,
               email: options.maintainer&.email || packager.email,
               epoch: epoch,
               version: version,
               release: release,
               description: descriptions_from_changes(binding))
         end

      value_in | [ new_change ].compact
   end

   def descriptions_from_changes b
      change_list.sort_by {|x| -CHANGES_MAJORITY.keys.index(x) }.map do |ch|
         Baltix::I18n.t("spec.rpm.change.#{ch}", binding: b)
      end.join("\n")
   end

   def evr_from_changes
      chgs = change_list.map {|c| CHANGES_MAJORITY[c] }.uniq

      if chgs.include?(:new)
         [self.version, of_state(:release) || of_options(:release) || "alt1"]
      elsif chgs.include?(:version)
         [self.version, of_options(:release) || "alt1"]
      elsif chgs.include?(:major)
         /alt(?<release_version>.*)/ =~ of_state(:release)
         release_major_bump = Gem::Version.new(release_version.split(/[\._]/).first).bump.to_s

         [self.version, "alt#{release_major_bump}"]
      else
         /alt(?<release_version>.*)/ =~ of_state(:release)
         parts = release_version.split(/[\._]/)
         release_minor_bump = Gem::Version.new(parts[1] || "0").bump.to_s

         [self.version, "alt#{parts[0]}.#{release_minor_bump}"]
      end
   end

   def _release value_in
      changes.last ? changes.last.release : nil
   end

   # Preserves rake tasks configured in options or an existing spec.
   # @param value_in [String, Array<String>, nil] tasks supplied by options or source state
   # @return [Array<String>] unique configured task names in their original order
   # If the spec uses ruby_on_build_rake_tasks, its values are retained. If it
   # uses the legacy ruby_build --pre option, those tasks are retained as well.
   # Missing declarations contribute no tasks; duplicates are emitted once.
   def _rake_build_tasks value_in
      /--pre=(?<list>[^\s]*)/ =~ Array(variables.ruby_build).join(' ')

      [value_in, of_state(:ruby_on_build_rake_tasks), variables.ruby_on_build_rake_tasks, list].flatten.compact.flat_map do |tasks|
         tasks.to_s.split(',')
      end.reject(&:empty?).uniq
   end

   def initialize state: {}, options: {}, space: nil
      @state = state.to_os
      @options = options.to_os.merge(space.options)
      @space = space || raise
      @doc = self
   end

   class << self
      def match? source_in
         Parser.match?(source_in)
      end

      def parse source_in, options = {}.to_os, space = nil
         state = Parser.new.parse(source_in, options)
         space ||= options[:space]

         Baltix::Spec::Rpm.new(state: state, options: options, space: space)
      end

      def render space, spec_in = nil
         spec = space.spec || self.new(space: space)

         spec.render(spec_in)
      end
   end
end
