When('the input spec uses {string} for its ignore list') do |form|
   declaration = @spec_in.match(/^%ruby_ignore_names\s+([^\n]+)/)
   expect(declaration).to_not be_nil
   names = declaration[1]
   case form
   when 'macro'
      # Keep the real packaged input unchanged.
   when 'legacy macro'
      @spec_in = @spec_in.sub(declaration[0], "%ruby_ignore #{names}")
   when 'build option'
      @spec_in = @spec_in.sub(declaration[0], '')
      @spec_in = @spec_in.sub(/^%ruby_build$/, "%ruby_build --ignore=#{names}")
   else
      raise ArgumentError, "Unknown ignore list form: #{form}"
   end
end

Then('the parsed ignored names are:') do |table|
   parsed = Baltix::Spec.load_from(source: @spec, options: space.options, space: space)
   expect(parsed.ignored_names).to eql(table.raw.flatten)
end

Then('the generated references to gem {string} are {string}') do |name, expectation|
   tags = @spec.scan(/^((?:Build)?(?:Requires|Conflicts)):\s+gem\(#{Regexp.escape(name)}\)(?:\s|$)/).flatten
   overrides = @spec.lines.grep(/^%ruby_use_gem_dependency /).select do |line|
      line.split(' ', 2).last.match?(/(?:\A|,)#{Regexp.escape(name)}\s/)
   end
   if expectation == 'absent'
      expect(tags).to be_empty
      expect(overrides).to be_empty
   else
      expect(tags.uniq.sort).to eql(%w(BuildConflicts BuildRequires Conflicts Requires))
      expect(overrides.size).to eql(1)
   end
end

When('he configures ignored names through CLI {string}') do |pattern|
   command = Baltix::CLI.new(["--ignore-names=#{pattern}"])
   command.parse!
   space.options.ignored_names = command.options.ignored_names
end

When('the generated spec is refreshed without name options') do
   options = space.options.deep_dup
   options.ignored_names = []
   options.regarded_names = []
   @space = Baltix::Space.new(options: options)
   @space.spec = Baltix::Spec.load_from(source: @spec, options: options, space: @space)
   @spec = Baltix::Actor.for('spec', @space).apply_to(@space)
end

When('he configures regarded names through CLI {string}') do |pattern|
   command = Baltix::CLI.new(["--regard-names=#{pattern}"])
   command.parse!
   space.options.regarded_names = command.options.regarded_names
end
