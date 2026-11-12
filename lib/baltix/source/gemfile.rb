require 'baltix/dsl'
require 'baltix/source/base'

class Baltix::Source::Gemfile < Baltix::Source::Base
   class << self
      def search dir, options_in = {}
         Dir.glob("#{dir}/**/Gemfile", File::FNM_DOTMATCH).select {|f| File.file?(f) }.map do |f|
            self.new(source_options({ source_file: f, loader: :gemfile }.to_os.merge(options_in)))
         end
      end
   end

   def gemfile_path
      gemspec_file = Tempfile.create('Gemfile.')
      gemspec_file.puts(dsl.to_gemfile)
      gemspec_file.rewind
      gemspec_file.path
   end

   def dsl
      @dsl ||=
         Baltix::DSL.new(source_file,
         replace_list: replace_list,
         skip_list: (options[:gem_skip_list] || []) | [self.name],
         append_list: options[:gem_append_list])
   end

   def valid?
      dsl.valid?
   end

   # Supplies the repository README title for a project rooted at a Gemfile.
   # Takes no parameters.
   # @return [OpenStruct] summaries indexed by locale, empty without a readable title
   def summaries
      repository_metadata_source.summaries
   end

   # Supplies the repository prose for a project whose root metadata is a Gemfile.
   # Takes no parameters.
   # @return [OpenStruct] descriptions indexed by locale, empty without readable prose
   def descriptions
      repository_metadata_source.descriptions
   end

   # Supplies the configured repository homepage for a Gemfile project.
   # Takes no parameters.
   # @return [String, nil] repository homepage, or nil without a supported Git origin
   def uri
      repository_metadata_source.uri
   end

   # Supplies the configured repository origin for a Gemfile project.
   # Takes no parameters.
   # @return [String, nil] repository URL, or nil without a supported Git origin
   def vcs
      repository_metadata_source.vcs
   end

   def rake
      @rake ||= Baltix::Rake.new(source_file)
   end

   protected

   # Reuses the synthetic-source reader for metadata at this repository root.
   # Takes no parameters.
   # @return [Baltix::Source::Fake] cached reader for the same directory
   def repository_metadata_source
      @repository_metadata_source ||= Baltix::Source::Fake.new(source_file: File.join(rootdir, '.fake'))
   end
end
