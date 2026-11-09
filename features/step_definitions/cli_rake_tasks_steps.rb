Given('the project has versioned Rake tasks for the CLI') do
   File.write(File.join(@rake_project, 'version.txt'), '0.0.0')
   File.write(File.join(@rake_project, 'ordered.gemspec'), <<~RUBY)
      Gem::Specification.new do |spec|
         spec.name = 'ordered'
         spec.version = File.read('version.txt').strip
         spec.summary = 'Ordered task example'
         spec.authors = ['Example']
         spec.files = []
      end
   RUBY
   File.write(File.join(@rake_project, 'Rakefile'), <<~RUBY)
      task :first do
         File.write('version.txt', '1.0.0')
         File.open('tasks.log', 'a') { |file| file.puts 'first' }
      end
      task :second do
         File.write('version.txt', '2.0.0')
         File.open('tasks.log', 'a') { |file| file.puts 'second' }
      end
      task :fail do
         File.open('tasks.log', 'a') { |file| file.puts 'fail' }
         raise 'generation failed'
      end
   RUBY
end

Given('the configured rake_task_before list is {string}') do |tasks|
   @configured_rake_tasks = tasks.split(',').map(&:to_sym)
end

Given('the root Rakefile is moved into {string}') do |directory|
   FileUtils.mkdir_p(File.join(@rake_project, directory))
   FileUtils.mv(File.join(@rake_project, 'Rakefile'), File.join(@rake_project, directory, 'Rakefile'))
end

When('the ordered Baltix commands are executed:') do |arguments|
   args = Shellwords.split(arguments.gsub('$PROJECT', @rake_project))
   @ordered_cli = Baltix::CLI.new(['--rootdir', @rake_project, '--verbose=none'] + args)
   @ordered_cli.options.rake_task_before = @configured_rake_tasks if @configured_rake_tasks
   @ordered_cli_error = nil
   begin
      @ordered_cli_results = @ordered_cli.run
   rescue StandardError => error
      @ordered_cli_error = error
   end
end

Then('the ordered CLI succeeds') do
   expect(@ordered_cli_error).to be_nil
end

Then('the generated CLI specs contain:') do |table|
   table.hashes.each do |row|
      path = File.join(@rake_project, row['file'])
      expect(File).to exist(path)
      expect(File.readlines(path).map(&:strip)).to include(row['line'])
   end
end

Then('the CLI Rake tasks ran in this order:') do |table|
   path = File.join(@rake_project, 'tasks.log')
   expect(File.readlines(path).map(&:strip)).to eql(table.raw.flatten)
end

Then('the CLI Rake tasks in {string} ran in this order:') do |directory, table|
   path = File.join(@rake_project, directory, 'tasks.log')
   expect(File.readlines(path).map(&:strip)).to eql(table.raw.flatten)
end

Then('the ordered CLI fails with {string}') do |message|
   expect(@ordered_cli_error).to_not be_nil
   expect(@ordered_cli_error.message).to include(message)
end

Then('no CLI spec files are written') do
   expect(Dir.glob(File.join(@rake_project, '*.spec'))).to be_empty
end
