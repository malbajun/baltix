Then('the generated spec contains the line {string}') do |line|
   expect(@spec.lines.map(&:strip)).to include(line)
end
