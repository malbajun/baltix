module Support
  module Projects
    def self.each(&block)
      base = File.expand_path('../../../..', __FILE__)
      projects = Dir.chdir(base) do
        Dir['mustermann*/*.gemspec'].map { |f| File.dirname(f) }.sort
      end
      projects.each(&block)
    end
  end
end
