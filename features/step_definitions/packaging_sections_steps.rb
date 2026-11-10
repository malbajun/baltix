Then('the generated spec preserves the input packaging sections') do
   headers = /^%(?:prep|build|install|check|pre|post|preun|postun|files)(?:\s|$)/
   split = ->(text) do
      text.split(/(?=^%(?:prep|build|install|check|pre|post|preun|postun|files|package|description|changelog)(?:\s|$))/).filter_map do |section|
         header, *body = section.lines
         [header.strip, body.join.strip] if header&.match?(headers)
      end.to_h
   end
   expected = split.call(@spec_in)
   actual = split.call(@spec)
   expected.each do |header, body|
      next if header.start_with?('%files') && !header.match?(/-n\s+dynflow$/)
      key = header.gsub(/\s+/, ' ')
      matching = actual.find { |candidate, _| candidate.gsub(/\s+/, ' ') == key }
      expect(matching).to_not be_nil, "Missing packaging section #{header}"
      expect(matching.last).to eql(body), "Changed packaging section #{header}"
   end
end

Then('packaging section migration produces these commands:') do |table|
   table.hashes.each do |row|
      options = space.options.deep_dup
      options[row['section']] = row['input']
      spec = Baltix::Spec.load_from(source: @spec_in, options: options, space: space)
      expect(spec.preserved_script(row['section'].to_sym)).to eql(row['output']), row.inspect
   end
end

Then('deprecated package-name definitions follow these rules:') do |table|
   table.hashes.each do |row|
      body = ["Name: #{row['package']}", row['use']].reject(&:empty?).join("\n")
      template = row['definition'] + "\n" + body
      expected = row['retained'] == 'yes' ? template : body
      expect(space.spec.render_template(template)).to eql(expected), row.inspect
   end
end

Then('the generated spec contains none of these packaging tokens:') do |table|
   packaging = @spec.split(/^%changelog\b/, 2).first
   table.raw.flatten.each { |token| expect(packaging).to_not include(token) }
end
