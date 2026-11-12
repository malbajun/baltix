require 'tmpdir'
require 'fileutils'
require 'baltix/rake'

Given('a temporary Rake project') do
   @rake_project = Dir.mktmpdir('baltix-rake-')
end

Given('the Rake project file {string} is:') do |file, contents|
   path = File.join(@rake_project, file)
   FileUtils.mkdir_p(File.dirname(path))
   File.write(path, contents + "\n")
end

Given('the Hoe metadata adapter is loaded') do
   require 'baltix/extensions/hoe'
   @metadata_hoe = ::Hoe
end

Given('the Rake project library directory is on the load path') do
   $LOAD_PATH.unshift(@rake_project)
   @rake_library_directory = @rake_project
end

Given('the caller has already loaded Rake cleaning tasks') do
   require 'rake/clean'
   @caller_clean_list = CLEAN
end

When('the project Rake task {string} is executed') do |name|
   @caller_rake_application = ::Rake.application
   @caller_rake_directory = Dir.pwd
   @rake_error = nil
   begin
      @rake_runner = Baltix::Rake.new(File.join(@rake_project, 'Rakefile'), runtime: true)
      @rake_runner.run_task(name)
   rescue StandardError => error
      @rake_error = error
   end
end

Then('the Rake task succeeds') do
   expect(@rake_error).to be_nil
end

Then('the project task result is generated inside the current Ruby process') do
   expect(File.read(File.join(@rake_project, 'result.txt'))).to eql("prepare\ngenerate:#{Process.pid}\n")
end

Then('the caller\'s Rake application and directory are restored') do
   expect(::Rake.application).to equal(@caller_rake_application)
   expect(Dir.pwd).to eql(@caller_rake_directory)
end

Then('the Hoe metadata adapter is restored') do
   expect(::Hoe).to equal(@metadata_hoe)
end

Then('the Rake task fails with {string}') do |message|
   expect(@rake_error).to be_a(RuntimeError)
   expect(@rake_error.message).to eql(message)
end

Then('the parallel worker retained its Rake context') do
   @rake_runner.app.thread_pool.join
   expect(File.read(File.join(@rake_project, 'worker-context'))).to eql('true:true')
end

Then('the obsolete project file is removed') do
   expect(File).to_not exist(File.join(@rake_project, 'obsolete'))
end

Then('the caller\'s cleaning list is restored') do
   expect(CLEAN).to equal(@caller_clean_list)
   expect(CLEAN.to_a).to_not include('obsolete')
end

After do
   if @rake_library_directory
      $LOAD_PATH.delete(@rake_library_directory)
      $LOADED_FEATURES.delete_if {|path| path.start_with?(@rake_library_directory + '/') }
      Baltix::Rake.instance_variable_get(:@task_libraries)&.delete(:Hoe)
   end
   FileUtils.remove_entry(@rake_project) if @rake_project && File.directory?(@rake_project)
end

When('the project Rake metadata is read') do
   @metadata_previous_rake_application = ::Rake.application
   @caller_rake_application = ::Rake::Application.new
   @caller_rake_directory = Dir.pwd
   ::Rake.application = @caller_rake_application
   ::Rake::Task.define_task(:baltix_metadata_caller_marker)
   @rake_metadata = Baltix::Rake.new(File.join(@rake_project, 'Rakefile'))
end

Then("the caller's metadata marker task is retained") do
   expect(::Rake.application.lookup('baltix_metadata_caller_marker')).to_not be_nil
end

Then('the imported Rake metadata contains its own task') do
   expect(@rake_metadata.app).to_not be_nil
   expect(@rake_metadata.app.lookup('imported_metadata')).to_not be_nil
   expect(@rake_metadata.app).to_not equal(@caller_rake_application)
end

After do
   ::Rake.application = @metadata_previous_rake_application if @metadata_previous_rake_application
end
