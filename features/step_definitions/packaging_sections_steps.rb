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
