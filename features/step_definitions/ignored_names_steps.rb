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
