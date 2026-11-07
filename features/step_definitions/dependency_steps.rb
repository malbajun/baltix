require 'baltix/dsl'

Given('the dependency DSL from the {string} fixture Gemfile') do |name|
   @dependency_gemfile = File.expand_path("features/fixtures/#{name}/Gemfile")
end

When('the dependency requirement for {string} is replaced with {string}') do |name, requirement|
   @dependency_dsl = Baltix::DSL.new(@dependency_gemfile, replace_list: {name => requirement})
end

Then('the generated Gemfile declares {string} in group {string} with requirement {string}') do |name, group, requirement|
   generated = Bundler::Dsl.new
   generated.eval_gemfile(@dependency_gemfile, @dependency_dsl.to_gemfile)
   dependency = generated.dependencies.find { |dep| dep.name == name }
   expect(dependency).to_not be_nil
   expect(dependency.groups).to eql([group.to_sym])
   expect(dependency.requirement.to_s).to eql(Gem::Requirement.new(requirement).to_s)
end
