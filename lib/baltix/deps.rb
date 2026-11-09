require 'baltix'

class Baltix::Deps
   attr_reader :space

   REQS = {
      'lib' => {
         proc { |target| target.source.compilable? }               => proc { |this| this.deps_ruby_version },
         proc { |target| target.source.valid? }                    => proc { |this, target| this.deps_dyno(target.source, 'lib', :dsl) },
      },
      'bin' => {
         proc { |target| target.public_executables.any? }          => proc { |this, target| this.deps_ruby_exec(target) },
         proc { |target| target.source.exefiles.any? &&
                         target.source.is_a?(Baltix::Source::Gem) } => proc { |this, target| this.deps_dyno(target.source, 'bin', :dsl) },
      },
      'doc' => {
         proc { |target| target.source.is_a?(Baltix::Source::Gem) } => proc { |this, target| this.deps_dyno(target.source, 'doc') },
      },
      'devel' => {
         proc { |target|
            target.source.is_a?(Baltix::Source::Gem) &&
           (target.source.inctree.any? ||
            target.source.dsl.original_deps.any?) }                => proc { |this, target| this.deps_dyno(target.source, 'devel', :dsl) },
      }
   }

   PROVS = {
      'lib' => {
         proc { |target| target.source.is_a?(Baltix::Source::Gem) } => proc { |this, target| this.deps_gem_ext(target.source) },
      },
      'bin' => {
         proc { |target| target.public_executables.any? }          => proc { |this, target| this.deps_execs(target) },
      },
   }

   def targets
      if name = space.config.current_package_name
         space.targets.select { |target| target.source.has_name?(name) }
      else
         space.targets
      end
   end

   def target_provs target, sets_in = nil
      sets = sets_in && [ sets_in ].flatten || PROVS.keys

      PROVS.select { |set, _| sets.include?(set) }.map do |set, data|
         provs = data.map do |cond_in, prov_in|
            cond = cond_in.is_a?(Proc) ? cond_in[target] : cond_in
            cond && (prov_in.is_a?(Proc) && prov_in[self, target] || prov_in) || []
         end.flatten

         [ set, provs ]
      end.to_h
   end

   def target_reqs target, sets_in = nil
      sets = sets_in && [ sets_in ].flatten || REQS.keys

      #require 'pry'; binding.pry
      REQS.select { |set, _| sets.include?(set) }.map do |set, data|
         reqs = data.map do |cond_in, req_in|
            cond = cond_in.is_a?(Proc) ? cond_in[target] : cond_in
            cond && (req_in.is_a?(Proc) && req_in[self, target] || req_in) || []
         end.flatten

         [ set, reqs.uniq ]
      end.to_h
   end

   ## deps
   def deps_gem_dsl dsl, set = 'lib'
      deps =
         case set
         when 'bin'
            dsl.runtime_deps(:gemfile)
         when 'devel'
            dsl.development_deps(:gemspec)
         else
            dsl.runtime_deps(:gemspec)
         end

      list = []

      deps.each do |dep|
         list << (["#{prefix}(#{dep.name})"] | self.class.lower_to_rpm(dep.requirement)).join(" ")
      end

      if /lib|bin/ =~ set
         list |=
            dsl.required_ruby_version.requirements.map do |(cond, ver)|
               self.class.lower_to_rpm(Gem::Requirement.new("#{cond} #{ver}"))
            end.reject {|x| x.blank? }.map do |req|
               [dsl.required_ruby] | req
            end.map {|x| x.join(" ") }
         list << "rubygems #{dsl.required_rubygems_version}"
      end

      list
   end

   def deps_ruby_version
      # TODO enable when fix for new version ruby rebuld
      #"ruby(#{RbConfig::CONFIG['ruby_version']})"
      ""
   end

   def deps_gem source
      ["gem(#{source.name})", source.version].compact.join(' = ')
   end

   def deps_gem_ext source
      %w(gem).map do |kind|
         "#{kind}(#{source.name}) = #{source.version}"
      end
   end

   def deps_dyno source, set, kind = nil
      root = space.config.dep_sources[set]
      name = (root[source.name] || root[nil]).first
      if name == 'auto'
         kind == :dsl && deps_gem_dsl(source.dsl, set) || deps_gem(source)
      else
         space.select_source(name).map do |source|
            deps_gem_dsl(source.dsl)
         end
      end
   end

   def deps_ruby_exec target
      target.public_executables.map do |file|
         File.join(target.root, file)
      end.map do |file|
         if File.symlink?(file)
            realfile = File.readlink(file)
            IO.read(File.join(target.root, realfile), mode: 'rb').split("\n").first
         elsif File.exist?(file)
            IO.read(file, mode: 'rb').split("\n").first
         end
      end.compact.uniq.map do |line|
         if match = /#!\s*(?<exec>\S+)/.match(line)
            match[:exec]
         else
            $stderr.puts "Invalid shebang line '#{line}'"
            nil
         end
      end.uniq
   end

   def deps_execs target
      target.public_executables
   end

   # common
   def deps type, set = nil
      $stderr.puts "* #{type} ->"

      method = method("target_#{type}")

      deps = targets.map do |target|
         $stderr.puts "  - [#{target.source.name}]"

         target_deps = method[target, set].each do |set, deps|
            if !deps.empty?
               $stderr.puts "    [#{set}]:"
               deps.each do |dep|
                  $stderr.puts "      #{dep}"
               end
            end
         end

         [ target.source.name, target_deps ]
      end.to_h
   end

   def reqs
      deps 'reqs', space.config.current_set
   end

   def provs
      deps 'provs', space.config.current_set
   end

   class << self
      # Converts a gem requirement to its strictest RPM lower bound.
      # @param req [Gem::Requirement] the combined source constraints
      # @return [Array] lower-bound operator and version, or an empty array for empty input
      # If no lower bound is given, an inclusive zero minimum keeps the gem
      # required while maximums and excluded versions become conflicts.
      # Excluded versions do not raise the minimum; they narrow the maximum.
      def lower_to_rpm req
         minimum = req.requirements.reduce([]) do |res, r|
            merge(res, debound(r))
         end

         minimum.empty? && !req.requirements.empty? ? ['>=', Gem::Version.new(0)] : minimum
      end

      # Converts the strictest source maximum into an RPM conflict boundary.
      # @param req [Gem::Requirement] combined dependency requirements
      # @return [Array] conflict operator and version, or an empty array without a maximum
      # If several upper bounds exist, the lowest version is selected. At equal
      # versions an inclusive conflict wins because it excludes the stricter range.
      def upper_negate_to_rpm req
         req.requirements.filter_map { |requirement| negate(requirement) }.min_by do |operator, version|
            [version, operator == '>=' ? 0 : 1]
         end || []
      end

      # TODO for requirement
      # +debound+ crop upper limitation bound from the requirement rule
      #
      def debound req
         ver = Gem::Version.new("#{req[1]}".gsub(/x/, '0'))

         case req[0]
         when "~>"
            ['>=', ver.release]
         when ">=", ">", "="
            [req[0], ver.release]
         else
            nil
         end
      end

      # TODO for requirement
      # +negate+ megates requirement rule
      #
      def negate req
         ver = Gem::Version.new("#{req[1]}".gsub(/x/, '0'))

         case req[0]
         when "~>"
            ['>=', ver.bump]
         when "<", "!="
            ['>=', ver.release]
         when "<="
            ['>', ver.release]
         else
            nil
         end
      end

      # TODO for requirement
      # +merge+ enstricts requirement
      # >= 4 & >= 5 => >= 5
      # > 5 ^ > 4 => > 5
      #
      # > 5 & >= 4 => > 5
      # > 4 & >= 4 => > 4
      # > 4 & >= 4.x => >= 4.x
      #
      # >= 4 & > 4 => > 4
      # >= 4 & > 5 => > 5
      # >= 5 & > 4 => >= 5
      #
      MERGE_CONDS = {
         ">=" => {
            code: -1,
         }
      }

      # Selects the strongest of two lower dependency boundaries.
      # @param req1 [Array<String, Gem::Version>, nil] first =, >= or > boundary
      # @param req2 [Array<String, Gem::Version>, nil] second =, >= or > boundary
      # @return [Array<String, Gem::Version>, nil] the selected boundary
      # If either boundary is empty, the other is returned. The greater version
      # wins; at equal versions > takes priority over = and >=. Exact equality
      # otherwise takes priority over >=. Neither argument is modified.
      def merge req1, req2
         return req1 if req2.blank?
         return req2 if req1.blank?

         [req1, req2].max_by do |operator, version|
            [version, operator == '>' ? 2 : operator == '=' ? 1 : 0]
         end
      end

   end

   protected

   def initialize space: raise, options: {}
      @space = space
      @options = options
   end
end
