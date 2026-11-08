Then('the generated spec contains the line {string}') do |line|
   expect(@spec.lines.map(&:strip)).to include(line)
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

Then('package {string} contains dependency line {string}') do |name, line|
   package = @spec.split(/(?=^%package\s)/).find do |section|
      section.match?(/^Name:\s+#{Regexp.escape(name)}$/) || section.match?(/^%package\s+-n\s+#{Regexp.escape(name)}$/)
   end
   expect(package).to_not be_nil
   expect(package.lines.map(&:strip)).to include(line)
end

Then('package {string} does not require {string}') do |name, dependency|
   package = @spec.split(/(?=^%package\s)/).find { |section| section.match?(/^Name:\s+#{Regexp.escape(name)}$/) }
   expect(package).to_not be_nil
   expect(package).to_not match(/^Requires:\s+gem\(#{Regexp.escape(dependency)}\)/)
end
