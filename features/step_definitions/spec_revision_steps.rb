When('the generated input has release {string}') do |release|
   @spec = @spec.gsub(/^Release:\s+\S+/, "Release:       #{release}")
   @spec = @spec.sub(/(^%changelog\s*\n\* [^\n]*-)\S+$/) { "#{Regexp.last_match(1)}#{release}" }
end

Then('every generated package and the latest changelog entry have release {string}') do |release|
   releases = @spec.scan(/^Release:\s+(\S+)/).flatten
   expect(releases).to_not be_empty
   expect(releases.uniq).to eql([release])
   latest = @spec.split(/^%changelog\s*\n/, 2).last.lines.first.strip
   expect(latest).to end_with("-#{release}")
end

When('he keeps the generated spec for comparison') do
   @spec_before_refresh = @spec.dup
end

Then('the generated spec is unchanged') do
   expect(@spec).to eql(@spec_before_refresh)
end
