When('the repository README is:') do |text|
   File.write(File.join(space.rootdir, 'README.md'), text + "\n")
end

When('the repository origin is {string}') do |url|
   system('git', '-C', space.rootdir, 'remote', 'add', 'origin', url, exception: true)
end

When('the repository root metadata is {string}') do |layout|
   if layout == 'Gemfile'
      File.write(File.join(space.rootdir, 'Gemfile'), <<~GEMFILE)
         source 'https://rubygems.org'
         platforms :jruby do
            group :development do
               gem 'jruby-openssl'
            end
         end
      GEMFILE
   end
end
