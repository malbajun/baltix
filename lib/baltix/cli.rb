require 'optparse'
require 'ostruct'
require 'yaml'
require 'shellwords'

require 'baltix'
require 'baltix/space'
require 'baltix/actor'
require 'baltix/log'
require 'baltix/rake'

class Baltix::CLI
   include Baltix::Log

   DEFAULT_OPTIONS = {
      rootdir: nil,
      spec_type: "rpm",
      ignored_names: [].freeze,
      regarded_names: [].freeze,
      aliased_names: [].freeze,
      ignored_path_tokens: [].freeze,
      regarded_path_tokens: [].freeze,
      spec_file: nil,
      available_gem_list: {}.to_os.freeze,
      gem_dependency_mode: :redep,
      maintainer: {}.to_os.freeze,
      packager: {}.to_os.freeze,
      devel_dep_baltix: :include,
      use_gem_version_list: {}.to_os.freeze,
      use_gem_obsolete_list: {}.to_os.freeze,
      log_level: :info,
      warn_io: 'stderr',
      error_io: 'stderr',
      info_io: 'stdout',
      debug_io: 'stderr',
      high_default_dependencies_priority: false,
      autorender_name: false,
      rake_task_before: [].freeze,
      skip_platforms: %i(jruby mingw mswin).freeze
   }.to_os.freeze

   def option_parser *default_argv
      @option_parser ||=
         OptionParser.new do |opts|
            opts.banner = "Usage: baltix.rb [options & actions]"

            opts.on("-d", "--rootdir=FOLDER", String, "Root folder to scan the sources") do |folder|
               options[:rootdir] = folder
            end

            opts.on("--source-lib-folders=FOLDERS", Array, "Lib directories for the current source or at whole") do |list|
               options[:source_lib_folders] = list.compact
            end

            opts.on("--rake-task-before=LIST", Array, "Run comma-separated Rake tasks before the next Baltix action") do |list|
               options.rake_task_before = list.compact.reject(&:empty?)
            end

            opts.on("-I", "--ignore-names=LIST", Array, "Source names comma-separated ignore list") do |list|
               options.ignored_names |= list.compact.map do |x|
                  m = /^\/(?<re>.*)/.match(x)
                  m && /#{m[:re]}/ || x
               end
            end

            opts.on("-R", "--regard-names=LIST", Array, "Source names comma-separated regard list") do |list|
               options.regarded_names |= list.compact.map do |x|
                  m = /^\/(?<re>.*)/.match(x)
                  m && /#{m[:re]}/ || x
               end
            end

            opts.on("-A", "--alias-names=[LIST]", Array, "Source names comma-separated alias list") do |list|
               options.aliased_names << list.compact
            end

            opts.on("-o", "--output-file=FILE", String, "Output file for a spec action") do |file|
               options.output_file = file
            end

            opts.on("-s", "--spec-file=FILE", String, "Spec file for covering the baltix space") do |file|
               options.spec_file = file
            end

            opts.on("-i", "--ignore-path-tokens=LIST", Array, "Ignore sources by a contained in its path token, and passed as a comma-separated list") do |list|
               options.ignored_path_tokens.concat(list.compact)
            end

            opts.on("-r", "--regard-path-tokens=LIST", Array, "Regard sources by a contained in its path token, and passed as a comma-separated list") do |list|
               options.regarded_path_tokens.concat(list.compact)
            end

            opts.on("--maintainer-name=NAME", String, "Name of the maintainer to use on spec generation") do |name|
               options.maintainer.name = name
            end

            opts.on("--maintainer-email=EMAIL", String, "Email of the maintainer to use on spec generation") do |email|
               options.maintainer.email = email
            end

            opts.on("--packager-name=NAME", String, "Name of the packager to use on spec generation") do |name|
               options.packager.name = name
            end

            opts.on("--packager-email=EMAIL", String, "Email of the packager to use on spec generation") do |email|
               options.packager.email = email
            end

            opts.on("--devel-dep-baltix=<TYPE>", %i(include skip), "Apply baltix type for devel dependencies to use with, defaulting to 'include'") do |type|
               options.devel_dep_baltix = type
            end

            opts.on("-g", "--available-gem-list-file=[FILE]", String, "Path to a YAML-formatted file with the list of available gems to replace in dependencies") do |file|
               options.available_gem_list = Baltix.load(IO.read(file)).to_os
            end

            opts.on("--gem-dependency-mode=MODE", %i(regular redep all), "Gem upper bounds: regular, redep (overrides only), all (all gem conflicts)") do |mode|
               options.gem_dependency_mode = mode
            end

            opts.on("--debug-io=[FILE|IO| |-|--]", String, "IO for debug level. Value is file name, or --/stderr for stderr, or -/stdout for stdout, or blank to disable") do |str|
               options.debug_io = str
            end

            opts.on("-V", "--use-gem-version=[LIST]", Array, "Comma separated gem version pair list to forcely use in the baltix") do |gem_version|
               hash = gem_version.map {|gv| gv.split(":") }.to_h
               options.use_gem_version_list = options.use_gem_version_list.merge(hash)
            end

            opts.on("-O", "--use-gem-obsolete=[LIST]", Array, "Comma separated gem obsolete list to forcely use in the baltix") do |gem_obsolete|
               hash = gem_obsolete.map {|gv| gv.split(":") }.map {|(x, y)| [x, y.split(/,/)] }.to_h
               options.use_gem_obsolete_list = options.use_gem_obsolete_list.merge(hash)
            end

            opts.on("-D", "--[no-]use-high-default-dependencies-priority", "Deprecated: gem dependencies always use current source metadata") do |d|
               options.high_default_dependencies_priority = d
            end

            opts.on("-N", "--[no-]autorender-name", "Autorendering name of a source when draw a spec") do |d|
               options.autorender_name = d
            end

            opts.on("-v", "--verbose=[LEVEL]", String, "Run verbosely with levels: none, error, warn, info, or debug") do |v|
               options.log_level = v
            end

            opts.on("-h", "--help", "This help") do |v|
               puts opts
               exit
            end
         end

      if @argv
         @option_parser.default_argv.replace(@argv)
      else
         unless default_argv.empty?
            @option_parser.default_argv |= default_argv
         end

         if @option_parser.default_argv.empty?
            @option_parser.default_argv << "-h"
         end
      end

      @option_parser
   end

   def default_options
      file = File.join(ENV["HOME"], ".baltix.yaml")

      if File.file?(file)
         Baltix.load_file(file)
      else
         {}
      end.to_os(hash: true, array: true)
   end

   def options
      @options ||= DEFAULT_OPTIONS.deep_dup.deep_merge(default_options)
   end

   def actions
      @actions ||= parse.actions.select { |a| Baltix::Actor.kinds.include?(a) }
   end

   # Parses options and commands in their original order.
   # Takes no parameters.
   # @return [OpenStruct] final options, action names and per-action option snapshots
   # Each recognized action consumes rake_task_before. Later options affect later
   # actions only, and repeated actions remain distinct. A task list without a
   # following action raises OptionParser::MissingArgument; invalid options raise.
   def parse!
      return @parse if @parse

      action_names = []
      invocations = []
      option_parser.order! do |name|
         action_names << name
         if Baltix::Actor.kinds.include?(name)
            invocations << { name: name, options: options.deep_dup }
            options.rake_task_before = []
         end
      end

      unless Array(options.rake_task_before).empty?
         raise OptionParser::MissingArgument, 'following command for --rake-task-before'
      end

      @parse = OpenStruct.new(options: options, actions: action_names, invocations: invocations)
   end

   def parse
      parse!
   end

   def space
      @space ||= Baltix::Space.load_from(options: parse.options)
   end

   def space= value
      @space = value
   end

   # Executes the parsed stream of actions and their associated Rake tasks.
   # Takes no parameters.
   # @return [Array<Object>] actor results in command-line order, including repeats
   # If an action has preceding Rake tasks, they run before its sources are read.
   # Every action receives its own options and space. Failures are logged and
   # propagated so the actor and subsequent actions do not run after a failed task.
   def run
      parse.invocations.map do |invocation|
         @space = Baltix::Space.load_from(options: invocation[:options])
         run_rake_tasks_before(Array(space.options.rake_task_before))
         actor = Baltix::Actor.for!(invocation[:name], space)
         actor.apply_to(space)
      end
   rescue StandardError => e
      error("[#{e.class}]: #{e.message}\n\t#{e.backtrace.join("\n\t")}")
      raise
   end

   # Creates a CLI from process arguments or an explicit argument sequence.
   # @param argv [Array<String>, String, nil] tokens, a shell-style string, or ARGV
   # @return [Baltix::CLI] the unparsed command interface
   # Nil leaves OptionParser's process arguments in use; strings preserve quoted
   # arguments through Shellwords, and arrays are copied without reordering.
   def initialize argv = nil
      @argv = argv.is_a?(String) ? Shellwords.split(argv) : argv&.dup
   end

   private

   # Finds project Rakefiles and runs the task list attached to the next action.
   # @param task_names [Array<String, Symbol>] ordered names, including legacy @ markers
   # @return [Array<String>] unique executed task names; an empty list when none are requested
   # If a root Rakefile exists it owns the tasks. Otherwise nested Rakefiles are
   # searched using the space's source filters, with one default Rakefile per folder.
   # Missing Rakefiles or tasks raise before the actor reads or writes its outputs.
   def run_rake_tasks_before task_names
      return [] if task_names.empty?

      defaults = ::Rake::Application::DEFAULT_RAKEFILES
      root_file = defaults.map {|name| File.join(space.rootdir, name) }.find {|file| File.file?(file) }
      files = if root_file
         [root_file]
      else
         Dir.glob(File.join(space.rootdir, '**', "{#{defaults.join(',')}}"), File::FNM_DOTMATCH).
            select {|file| File.file?(file) }.group_by {|file| File.dirname(file) }.values.map do |candidates|
               candidates.min_by {|file| defaults.index(File.basename(file)) }
            end.sort.reject do |file|
               source = Baltix::Source::Rakefile.new(source_file: file)
               space.is_disabled?(source)
            end
      end
      raise Baltix::Rake::InvalidRakefileError, "No Rakefile in #{space.rootdir}" if files.empty?

      executed = files.flat_map do |file|
         Baltix::Rake.new(file, runtime: true).run_tasks(task_names, :if_defined)
      end.uniq
      missing = task_names.map {|name| name.to_s.delete_prefix('@') }.uniq - executed
      raise ArgumentError, "Rake tasks not found: #{missing.join(', ')}" unless missing.empty?

      executed
   end
end
