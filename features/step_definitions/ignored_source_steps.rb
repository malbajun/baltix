Then('source {string} has status {string}') do |name, status|
   source = space.send(:stat_sources).find { |item, _| item.is_a?(Baltix::Source::Gem) && item.name == name }
   expect(source).to_not be_nil
   expect(source.last).to eql(status.to_sym)
end

Then('the generated library package names are:') do |table|
   names = @spec.scan(/^(?:Name:\s+|%package\s+-n\s+)(gem-\S+)/).flatten
   names = names.reject { |name| name.match?(/-(?:doc|devel)\z/) }
   expect(names.sort).to eql(table.raw.flatten.sort)
end
