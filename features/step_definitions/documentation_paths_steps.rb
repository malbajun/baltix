require 'tmpdir'
require 'fileutils'

Around('@documentation_source') do |_scenario, run|
   previous_version_setting = ENV['SAME_VERSION']
   # Upstream's release Rakefiles otherwise bump the packaged version on import.
   ENV['SAME_VERSION'] = 'true'
   Dir.mktmpdir('baltix-doc-source-') do |directory|
      @documentation_source_directory = directory
      run.call
   end
ensure
   previous_version_setting.nil? ? ENV.delete('SAME_VERSION') : ENV['SAME_VERSION'] = previous_version_setting
end

When('he imports fixture {string} with documentation paths:') do |fixture, table|
   project = File.join(@documentation_source_directory, fixture)
   FileUtils.cp_r(File.expand_path("features/fixtures/#{fixture}"), project)
   table.raw.flatten.each do |path|
      file = File.join(project, path)
      FileUtils.mkdir_p(File.dirname(file))
      FileUtils.touch(file)
   end
   system('git', '-C', project, '-c', 'init.defaultBranch=main', 'init', '--quiet', exception: true)
   system('git', '-C', project, 'add', '--all', exception: true)
   space.options.rootdir = project
end

Then('every generated documentation path exists in the repository root') do
   paths = @spec.lines.grep(/^%doc\s/).flat_map { |line| line.sub(/^%doc\s+/, '').split }
   expect(paths).to_not be_empty
   paths.each do |path|
      expect(File.exist?(File.join(space.rootdir, path))).to be(true), "Missing repository documentation path: #{path}"
   end
end

Then('the generated documentation lines match {string} from fixture {string}') do |file, fixture|
   expected = File.read("features/fixtures/#{fixture}/#{file}").lines.grep(/^%doc\s/).map(&:strip)
   actual = @spec.lines.grep(/^%doc\s/).map(&:strip)
   expect(actual).to eql(expected)
end
