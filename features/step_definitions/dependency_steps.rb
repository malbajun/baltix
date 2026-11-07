require 'baltix/dsl'

When('the {string} gem dependency DSL is merged into the project DSL') do |name|
   @dependency_dsl = space.main_source.dsl
   @dependency_gemfile = @dependency_dsl.original_gemfile.to_s
   @dependency_dsl.to_gemfile
   @dependency_dsl.definition
   source = space.valid_sources.find { |item| item.name == name }
   @dependency_dsl.merge_in(source.dsl)
end

When('the {string} gem dependency DSL is merged into the {string} gem DSL') do |other, name|
   source = space.valid_sources.find { |item| item.name == name }
   incoming = space.valid_sources.find { |item| item.name == other }
   @dependency_dsl = source.dsl
   @dependency_dsl.merge_in(incoming.dsl)
end

Then('the generated dependency requirement for {string} is {string}') do |name, requirement|
   generated = Bundler::Dsl.new
   generated.eval_gemfile(@dependency_gemfile, @dependency_dsl.to_gemfile)
   dependency = generated.dependencies.find { |dep| dep.name == name }
   expect(dependency).to_not be_nil
   expect(dependency.requirement.to_s).to eql(Gem::Requirement.new(requirement.split(/,\s*/)).to_s)
end

Then('the definition dependency requirement for {string} is {string}') do |name, requirement|
   dependency = @dependency_dsl.definition.dependencies.find { |dep| dep.name == name }
   expect(dependency).to_not be_nil
   expect(dependency.requirement.to_s).to eql(Gem::Requirement.new(requirement.split(/,\s*/)).to_s)
end

Then('the project dependencies exclude:') do |table|
   names = space.valid_sources.flat_map(&:all_dependencies).map(&:name)
   table.hashes.each { |row| expect(names).to_not include(row['name']) }
end

Then('the project dependencies include {string}') do |name|
   names = space.valid_sources.flat_map(&:all_dependencies).map(&:name)
   expect(names).to include(name)
end

Given('the dependency DSL from the {string} fixture Gemfile') do |name|
   @dependency_gemfile = File.expand_path("features/fixtures/#{name}/Gemfile")
end

When('the dependency requirement for {string} is replaced with {string}') do |name, requirement|
   @dependency_dsl = Baltix::DSL.new(@dependency_gemfile, replace_list: {name => requirement})
end

When('the fixture Gemfile dependencies are read') do
   @dependency_dsl = Baltix::DSL.new(@dependency_gemfile)
end

When('the fixture gemspec dependencies are read') do
   root = File.dirname(@dependency_gemfile)
   file = Dir[File.join(root, '*.gemspec')].first
   spec = Dir.chdir(root) { Gem::Specification.load(file) }
   expect(spec).to_not be_nil
   @dependency_dsl = Baltix::DSL.new(file, spec: spec)
end

Then('the runtime dependency names are:') do |table|
   names = @dependency_dsl.all_dependencies_for(kinds_in: :runtime).map(&:name).sort
   expect(names).to eql(table.hashes.map { |row| row['name'] }.sort)
end

Then('the development dependencies include {string} with requirement {string}') do |name, requirement|
   dependency = @dependency_dsl.all_dependencies_for(kinds_in: :devel).find { |dep| dep.name == name }
   expect(dependency).to_not be_nil
   expect(dependency.requirement.to_s).to eql(Gem::Requirement.new(requirement.split(/,\s*/)).to_s)
end

Then('the generated Gemfile declares {string} in group {string} with requirement {string}') do |name, group, requirement|
   generated = Bundler::Dsl.new
   generated.eval_gemfile(@dependency_gemfile, @dependency_dsl.to_gemfile)
   dependency = generated.dependencies.find { |dep| dep.name == name }
   expect(dependency).to_not be_nil
   expect(dependency.groups).to eql([group.to_sym])
   expect(dependency.requirement.to_s).to eql(Gem::Requirement.new(requirement).to_s)
end
