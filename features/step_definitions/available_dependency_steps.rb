Then('the generated spec contains the lines:') do |table|
   expect(@spec.lines.map(&:strip)).to include(*table.raw.flatten)
end

When('the input spec has build prerequisites:') do |table|
   @spec_in = @spec_in.gsub(/^BuildRequires\(pre\):[^\n]*\n/, '')
   declarations = table.raw.flatten.map { |requirement| "BuildRequires(pre): #{requirement}\n" }.join
   @spec_in = @spec_in.sub(/^Name:/, "#{declarations}Name:")
end

Then('the generated build prerequisites are:') do |table|
   actual = @spec.lines.grep(/^BuildRequires\(pre\):/).map { |line| line.sub(/^BuildRequires\(pre\):\s*/, '').strip }
   expect(actual).to eql(table.raw.flatten)
end

Then('the source {string} dependency {string} has version compatibility:') do |source_name, name, table|
   source = space.valid_sources.find { |item| item.name == source_name && item.is_a?(Baltix::Source::Gem) }
   expect(source).to_not be_nil
   dependency = source.spec.dependencies.find { |item| item.name == name }
   expect(dependency).to_not be_nil
   table.hashes.each do |row|
      accepted = dependency.requirement.satisfied_by?(Gem::Version.new(row['version']))
      expect(accepted).to eql(row['allowed'] == 'yes')
   end
end

When('the input spec configures rake tasks {string} through {string}') do |tasks, form|
   if form == 'macro'
      @spec_in = @spec_in.sub(/^%prep/, "%ruby_on_build_rake_tasks #{tasks}\n\n%prep")
   else
      @spec_in = @spec_in.sub(/^%ruby_build[^\n]*/) { |line| "#{line} --pre=#{tasks}" }
   end
end

Then('the generated spec contains no dependency override macros') do
   expect(@spec).to_not match(/^%ruby_use_gem_dependency /)
end

Then('the generated spec contains no override for {string}') do |name|
   expect(@spec).to_not match(/^%ruby_use_gem_dependency #{Regexp.escape(name)}\s/)
end

Then('the generated spec matches {string} from fixture {string}') do |file, fixture|
   expect(@spec).to eql(File.read("features/fixtures/#{fixture}/#{file}").strip)
end

Then('the generated dependency sections match {string} from fixture {string}') do |file, fixture|
   pattern = /\A(?:Name:|%package\s|Requires:|Conflicts:|BuildRequires:|BuildConflicts:|%ruby_use_gem_dependency\s)/
   expected = File.read("features/fixtures/#{fixture}/#{file}").lines.map(&:strip).select { |line| line.match?(pattern) }
   actual = @spec.lines.map(&:strip).select { |line| line.match?(pattern) }
   expect(actual).to eql(expected)
end

When('the generated spec is refreshed {int} times') do |count|
   count.times do
      options = space.options.deep_dup
      @space = Baltix::Space.new(options: options)
      @space.spec = Baltix::Spec.load_from(source: @spec, options: options, space: @space)
      @spec = Baltix::Actor.for('spec', @space).apply_to(@space)
   end
end

Then('package {string} contains dependency lines:') do |name, table|
   package = @spec.split(/(?=^%package\s)/).find do |section|
      section.match?(/^Name:\s+#{Regexp.escape(name)}$/) || section.match?(/^%package\s+-n\s+#{Regexp.escape(name)}$/)
   end
   expect(package).to_not be_nil
   expect(package.lines.map(&:strip)).to include(*table.raw.flatten)
end

Then('package {string} does not require {string}') do |name, dependency|
   package = @spec.split(/(?=^%package\s)/).find { |section| section.match?(/^Name:\s+#{Regexp.escape(name)}$/) }
   expect(package).to_not be_nil
   expect(package).to_not match(/^Requires:\s+gem\(#{Regexp.escape(dependency)}\)/)
end

Then('the generated package names are unique') do
   names = @spec.scan(/^(?:Name:\s+|%package\s+-n\s+)(\S+)/).flatten
   expect(names).to eql(names.uniq)
end

When('the input spec has extra build requirements:') do |table|
   declarations = table.raw.flatten.map { |requirement| "BuildRequires: #{requirement}\n" }.join
   @spec_in = @spec_in.sub(/^Name:/, "#{declarations}Name:")
end
