Then('the unconditional build requirements include:') do |table|
   header = @spec.split(/^%if_enabled check\b/, 2).first
   expect(header.lines.map(&:strip)).to include(*table.raw.flatten)
end

Then('the generated build requirements for {string} are:') do |name, table|
   pattern = /^BuildRequires:\s+gem\(#{Regexp.escape(name)}\)(?:\s|$)/
   requirements = @spec.lines.grep(pattern).map(&:strip)
   expect(requirements).to eql(table.raw.flatten)
end
