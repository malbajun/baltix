Then('package {string} contains file lines:') do |name, table|
   main_name = @spec[/^Name:\s+(\S+)/, 1]
   section = @spec.split(/(?=^%files(?:\s|$))/).find do |part|
      header = part.lines.first.to_s.strip
      header == "%files         -n #{name}" || (name == main_name && header == '%files')
   end
   expect(section).to_not be_nil, "Missing file manifest for #{name}"
   expect(section.lines.map(&:strip)).to include(*table.raw.flatten)
end

When('the input spec uses manual page file entry {string}') do |entry|
   expect(@spec_in).to match(/^%_mandir\//)
   @spec_in = @spec_in.sub(/^%_mandir\/[^\n]+/, entry)
end

Then('the generated manual page entries are:') do |table|
   manifests = @spec.split(/^%files\b/, 2).last.split(/^%changelog\b/, 2).first
   actual = manifests.lines.map(&:strip).grep(/%(?:_mandir|\{_mandir\})\//).reject { |line| line.start_with?('#') }
   expect(actual).to eql(table.raw.flatten)
end
