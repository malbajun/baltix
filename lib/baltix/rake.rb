# used in digest-crc gem as an extension compiler
#
require 'baltix/loader'

class Baltix::Rake
   extend ::Baltix::Loader

   class InvalidRakefileError < StandardError; end

   TYPE = 'Rake::Application'
   PRELOAD_MATCHER = { /\/rakefile(.rb)?$/i => :preload }

   attr_reader :app, :rakefile, :options

   def blank?
      !@app
   end

   def present?
      !!@app
   end

   def tasks
      @tasks ||= @app&.tasks || []
   end

   # Executes one task using its real build libraries in the current Ruby process.
   # @param task_name [String] task name, optionally carrying the legacy @ marker
   # @return [Array<String>] the executed task name without a legacy marker
   def run_task task_name
      run_tasks([task_name])
   end

   # Loads the complete Rakefile and invokes tasks in their requested order.
   # @param task_names [Array<String>] task names, with optional legacy @ markers
   # @param mode [Symbol, nil] :if_defined skips names absent from this Rakefile
   # @return [Array<String>] executed task names, with duplicates removed
   # Legacy markers are stripped without starting a separate Ruby interpreter.
   # Real libraries supply plugin tasks; metadata adapters are restored afterward.
   # Task failures propagate, and the previous Rake application and directory are
   # restored after parallel workers finish, even when a task fails. Metadata imported
   # from the project is invalidated so generated files are seen by later actors.
   # Rake cleaning tasks are reloaded when cached, or required normally otherwise; the
   # caller's CLEAN/CLOBBER lists and cleaning-library require state are restored.
   def run_tasks task_names, mode = nil
      previous_application = ::Rake.application
      previous_directory = Dir.pwd
      clean_constants = %i(CLEAN CLOBBER)
      previous_clean = {}
      clean_constants.each {|name| previous_clean[name] = Object.const_get(name, false) if Object.const_defined?(name, false) }
      clean_library = $LOADED_FEATURES.find {|file| file.end_with?('/rake/clean.rb') }
      names = task_names.map {|name| name.to_s.delete_prefix('@') }.reject(&:empty?).uniq

      self.class.with_task_libraries do
         Dir.chdir(File.dirname(rakefile))
         @app = ::Rake::Application.new
         @tasks = nil
         ::Rake.application = @app
         @app.init('rake', ['--rakefile', rakefile])
         clean_constants.each {|name| Object.send(:remove_const, name) if Object.const_defined?(name, false) }
         clean_library ? Kernel.load(clean_library) : require('rake/clean')
         @app.load_rakefile
         names = names.select {|name| @app.lookup(name) } if mode == :if_defined
         begin
            names.each {|name| @app.invoke_task(name) }
         ensure
            @app.thread_pool.join
         end
      end

      names
   ensure
      ::Rake.application = previous_application
      Dir.chdir(previous_directory)
      clean_constants.each do |name|
         Object.send(:remove_const, name) if Object.const_defined?(name, false)
         Object.const_set(name, previous_clean[name]) if previous_clean.key?(name)
      end
      $LOADED_FEATURES.delete_if {|file| file.end_with?('/rake/clean.rb') } unless clean_library
      root = File.dirname(rakefile) + '/'
      self.class.mods.delete_if {|file, _| File.expand_path(file).start_with?(root) }
   end

   # Creates a Rakefile reader or a deferred task runner.
   # @param rakefile [String] path to an existing Rakefile
   # @param options [Hash] :runtime skips metadata import before task execution
   # @return [Baltix::Rake] the initialized reader or runner
   # Missing files raise InvalidRakefileError. Runtime runners load the actual
   # build libraries when run_tasks is called; other readers retain metadata mode.
   def initialize rakefile, options = {}
      raise InvalidRakefileError unless File.file?(rakefile)

      @rakefile = File.expand_path(rakefile)
      @options = options
      @app = self.class.load(@rakefile).objects.first unless options[:runtime]
   end

   class << self
      # Temporarily exposes real task libraries in place of metadata adapters.
      # @yield executes Rakefile loading and task invocation in the library scope
      # @return [Object] the block's return value
      # Takes no parameters. Adapter constants and autoloads are restored even
      # when the block raises. Previously required real libraries are reused so
      # Ruby's require cache does not leave an adapter active during later runs.
      def with_task_libraries
         previous = {}
         libraries = @task_libraries ||= {}
         adapters = @metadata_libraries ||= {}
         adapter_root = File.join(__dir__, 'extensions') + '/'

         Baltix::METADATA_LIBRARIES.each_key do |name|
            autoload = Object.autoload?(name)
            previous[name] = if autoload
               [:autoload, autoload]
            elsif Object.const_defined?(name, false)
               [:constant, Object.const_get(name, false)]
            else
               [:absent, nil]
            end

            location = Object.const_source_location(name)&.first
            if previous[name].first == :constant
               adapter = adapters[name].equal?(previous[name].last) || location&.start_with?(adapter_root)
               next unless adapter

               adapters[name] = previous[name].last
            end

            Object.send(:remove_const, name) if Object.const_defined?(name, false)
            Object.const_set(name, libraries[name]) if libraries.key?(name)
         end

         yield
      ensure
         previous.each do |name, (kind, value)|
            if Object.const_defined?(name, false) && !Object.autoload?(name)
               location = Object.const_source_location(name)&.first
               libraries[name] = Object.const_get(name, false) unless location&.start_with?(adapter_root)
            end
            Object.send(:remove_const, name) if Object.const_defined?(name, false)
            Object.const_set(name, value) if kind == :constant
            Object.autoload(name, value) if kind == :autoload
         end
      end

      # Clears cached build metadata before a Rakefile is imported.
      # Takes no parameters.
      # @return [nil] the cleared Rake application
      # If the loaded Hoe implementation supports resetting, its project state
      # is cleared too.
      # An unused Hoe autoload is left untouched.
      def preload
         ::Hoe.reset if Object.const_defined?(:Hoe) && !Object.autoload?(:Hoe) && ::Hoe.respond_to?(:reset)
         Rake.instance_variable_set(:@application, nil)
      end

      def load rakefile
         app_file(rakefile)
      end
   end
end
