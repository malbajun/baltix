require 'baltix/dsl'

When('the {string} gem dependency DSL is merged into the project DSL') do |name|
   project = space.sources.find { |item| item.is_a?(Baltix::Source::Gemfile) && item.rootdir == space.rootdir }
   @dependency_dsl = project.dsl
   @dependency_gemfile = @dependency_dsl.original_gemfile.to_s
   @dependency_dsl.to_gemfile
   @dependency_dsl.definition
   source = space.valid_sources.find { |item| item.name == name }
   @dependency_dsl.merge_in(source.dsl)
end

Then('the main source is the {string} gem') do |name|
   expect(space.main_source).to be_a(Baltix::Source::Gem)
   expect(space.main_source.name).to eql(name)
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
   expect(dependency.requirement).to eq(Gem::Requirement.new(requirement.split(/,\s*/)))
end

Then('the definition dependency requirement for {string} is {string}') do |name, requirement|
   dependency = @dependency_dsl.definition.dependencies.find { |dep| dep.name == name }
   expect(dependency).to_not be_nil
   expect(dependency.requirement).to eq(Gem::Requirement.new(requirement.split(/,\s*/)))
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
   expect(dependency.requirement).to eq(Gem::Requirement.new(requirement.split(/,\s*/)))
end

Then('the generated Gemfile declares {string} in group {string} with requirement {string}') do |name, group, requirement|
   generated = Bundler::Dsl.new
   generated.eval_gemfile(@dependency_gemfile, @dependency_dsl.to_gemfile)
   dependency = generated.dependencies.find { |dep| dep.name == name }
   expect(dependency).to_not be_nil
   expect(dependency.groups).to eql([group.to_sym])
   expect(dependency.requirement.to_s).to eql(Gem::Requirement.new(requirement).to_s)
end

Then('source {string} has dependency declarations:') do |name, table|
   source = space.valid_sources.find { |item| item.is_a?(Baltix::Source::Gem) && item.name == name }
   expect(source).to_not be_nil
   actual = source.spec.dependencies.map { |dep| [dep.name, dep.type.to_s, dep.requirement.to_s] }.sort
   expected = table.hashes.map { |row| row.values_at('name', 'type', 'requirement') }.sort
   expect(actual).to eql(expected)
end

Given('the {string} fixture has already been imported') do |name|
   options = space.options.deep_dup
   options.rootdir = "features/fixtures/#{name}"
   previous = Baltix::Space.new(options: options)
   expect(previous.valid_sources.any? do |source|
      source.is_a?(Baltix::Source::Gem) && source.name.tr('_', '-') == name.tr('_', '-')
   end).to eql(true)
end

Then('the project root remains the {string} fixture') do |name|
   expect(space.rootdir).to eql(File.expand_path("features/fixtures/#{name}"))
end

Then('source {string} declares native extensions:') do |name, table|
   source = space.valid_sources.find { |item| item.is_a?(Baltix::Source::Gem) && item.name == name }
   expect(source).to_not be_nil
   expect(source.spec.extensions.sort).to eql(table.raw.flatten.sort)
end

Then('requirement intersections preserve these version checks:') do |table|
   table.hashes.each do |row|
      left = Gem::Requirement.new(row['left'].split(',').map(&:strip))
      right = Gem::Requirement.new(row['right'].split(',').map(&:strip))
      originals = [left.requirements.dup, right.requirements.dup]
      merged = [left.merge(right), right.merge(left)]
      %w(allowed rejected).each do |kind|
         row[kind].split(',').reject(&:empty?).each do |version|
            merged.each do |requirement|
               expect(requirement.satisfied_by?(Gem::Version.new(version))).to eql(kind == 'allowed'), "#{row['left']} & #{row['right']} at #{version}"
            end
         end
      end
      unless row['lower'].empty?
         merged.each do |requirement|
            boundary = Baltix::Deps.lower_to_rpm(requirement).map(&:to_s).join(' ')
            expect(boundary).to eql(row['lower'])
         end
      end
      expect([left.requirements, right.requirements]).to eql(originals)
   end
end
