Then('the unconditional build requirements include:') do |table|
   header = @spec.split(/^%if_enabled check\b/, 2).first
   expect(header.lines.map(&:strip)).to include(*table.raw.flatten)
end

Then('the generated build requirements for {string} are:') do |name, table|
   pattern = /^BuildRequires:\s+gem\(#{Regexp.escape(name)}\)(?:\s|$)/
   requirements = @spec.lines.grep(pattern).map(&:strip)
   expect(requirements).to eql(table.raw.flatten)
end

Then('the generated spec has no gem dependencies named:') do |table|
   names = @spec.scan(/^(?:Requires|Conflicts|BuildRequires(?:\(pre\))?|BuildConflicts):\s+gem\(([^)]+)\)/).flatten
   expect(names & table.raw.flatten).to be_empty
end

Then('the check build requirements include:') do |table|
   checks = @spec[/^%if_enabled check\n(.*?)^%endif/m, 1]
   expect(checks).to_not be_nil
   expect(checks.lines.map(&:strip)).to include(*table.raw.flatten)
end

When('the input spec has gem dependency declarations:') do |table|
   declarations = table.hashes.map { |row| "#{row['tag']}: #{row['dependency']}\n" }.join
   @spec_in = @spec_in.sub(/^Name:/, declarations + 'Name:')
end
