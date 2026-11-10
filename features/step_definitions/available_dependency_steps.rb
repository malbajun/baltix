Then('the generated spec contains the lines:') do |table|
   expect(@spec.lines.map(&:strip)).to include(*table.raw.flatten)
end

When('the input spec has dependency override macros:') do |table|
   declarations = table.raw.flatten.map { |value| "%ruby_use_gem_dependency #{value}\n" }.join
   @spec_in = @spec_in.sub(/^%prep/, declarations + "\n%prep")
end

Then('the generated gem conflicts are {string}') do |names|
   actual = @spec.scan(/^(?:BuildConflicts|Conflicts):\s+gem\(([^)]+)\)/).flatten.uniq.sort
   expect(actual).to eql(names.split(',').reject(&:empty?).sort)
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
   # Revisions may advance on refresh; exact RPM self-requires must follow the
   # revision in their own spec, while module versions and other bounds still match.
   dependencies = ->(text) do
      name = text[/^Name:\s+(\S+)/, 1]
      epoch = text[/^Epoch:\s+(\S+)/, 1]
      version = text[/^Version:\s+(\S+)/, 1]
      release = text[/^Release:\s+(\S+)/, 1]
      evr = [epoch, "#{version}-#{release}"].compact.join(':')
      text.lines.map(&:strip).select { |line| line.match?(pattern) }.map do |line|
         if line.match?(/\ARequires:\s+#{Regexp.escape(name)}\s+= /)
            expect(line.split.last).to eql(evr)
            line.sub(/\S+\z/, [epoch, version].compact.join(':'))
         else
            line
         end
      end
   end
   expected = dependencies.call(File.read("features/fixtures/#{fixture}/#{file}"))
   actual = dependencies.call(@spec)
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

Then('the generated package build architectures are:') do |table|
   table.hashes.each do |row|
      name = Regexp.escape(row['package'])
      package = @spec.split(/(?=^%package\s)/).find do |section|
         section.match?(/^(?:Name:\s+|%package\s+-n\s+)#{name}$/)
      end
      expect(package).to_not be_nil
      header = package.split(/^%description\b/, 2).first
      expected = row['build_arch'].empty? ? [] : [row['build_arch']]
      expect(header.scan(/^BuildArch:\s+(\S+)/).flatten).to eql(expected)
   end
end

When('the input spec has extra build requirements:') do |table|
   declarations = table.raw.flatten.map { |requirement| "BuildRequires: #{requirement}\n" }.join
   @spec_in = @spec_in.sub(/^Name:/, "#{declarations}Name:")
end

When('the input spec has extra build conflicts:') do |table|
   declarations = table.raw.flatten.map { |requirement| "BuildConflicts: #{requirement}\n" }.join
   @spec_in = @spec_in.sub(/^Name:/, "#{declarations}Name:")
end

Then('the generated spec contains each line once:') do |table|
   lines = @spec.lines.map(&:strip)
   table.raw.flatten.each do |line|
      expect(lines.count(line)).to eql(1), "Expected one occurrence of #{line.inspect}"
   end
end

Then('the generated spec excludes the lines:') do |table|
   expect(@spec.lines.map(&:strip) & table.raw.flatten).to be_empty
end

Then('internal gem requirements equal their provided versions without conflicts') do
   provided = @spec.scan(/^Provides:\s+gem\(([^)]+)\)\s+=\s+(\S+)/).to_h
   tags = @spec.scan(/^(Requires|BuildRequires|Conflicts|BuildConflicts):\s+gem\(([^)]+)\)\s+(\S+)\s+(\S+)/)
   tags.each do |tag, name, operator, version|
      next unless provided.key?(name)

      expect(tag).to_not end_with('Conflicts')
      expect([operator, version]).to eql(['=', provided[name]])
   end
   space.spec.secondaries.each do |package|
      next unless %i(exec doc devel).include?(package.kind) && package.host.source.is_a?(Baltix::Source::Gem)

      capability = package.host.send(:provide_dep)
      loose = Gem::Dependency.new(capability.name, '>= 0')
      expect(package.send(:render_deps, [loose])).to eql(["gem(#{capability.name}) = #{package.host.version}"])
   end
end

Then('external gem bounds render as:') do |table|
   table.hashes.each do |row|
      dependency = Gem::Dependency.new('external-policy-probe', row['requirement'])
      expect(space.spec.send(:render_deps, [dependency])).to eql(["gem(external-policy-probe) #{row['requires']}"])
      expected = row['conflicts'].empty? ? [] : ["gem(external-policy-probe) #{row['conflicts']}"]
      expect(space.spec.send(:render_deps, [dependency], :negate)).to eql(expected)
   end
end
