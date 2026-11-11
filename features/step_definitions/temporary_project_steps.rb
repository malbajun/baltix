require 'tmpdir'
require 'fileutils'

Around('@temporary_project') do |_scenario, run|
   Dir.mktmpdir('baltix-project-') do |directory|
      @temporary_project_directory = directory
      run.call
   end
end

When('he imports fixture {string} with the {string} Gemfile at {string}') do |fixture, gemfile_fixture, path|
   project = File.join(@temporary_project_directory, fixture)
   FileUtils.cp_r(File.expand_path("features/fixtures/#{fixture}"), project)
   target = File.join(project, path)
   FileUtils.mkdir_p(File.dirname(target))
   FileUtils.cp("features/fixtures/#{gemfile_fixture}/Gemfile", target)
   space.options.rootdir = project
end

Then('package {string} inherits the main summary') do |name|
   sections = @spec.split(/(?=^%package\s)/)
   package = sections.find { |section| section.match?(/^%package\s+-n\s+#{Regexp.escape(name)}$/) }
   expect(package).to_not be_nil
   metadata = lambda do |section|
      section.split(/^%description/, 2).first.scan(/^(Summary):\s+([^\n]+)/).to_h
   end
   expect(metadata.call(package)).to eql(metadata.call(sections.first))
end
