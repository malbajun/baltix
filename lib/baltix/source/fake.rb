require 'open3'

class Baltix::Source::Fake < Baltix::Source::Base
   OPTIONS_IN = {
      source_file: true,
      valid: ->(value_in, _source_name) { value_in.nil? ? true : value_in }
   }

   def dsl
      @dsl ||=
         Baltix::DSL.new(source_file,
         replace_list: replace_list,
         skip_list: (options[:gem_skip_list] || []) | [self.name],
         append_list: options[:gem_append_list])
   end

   def valid?
      @valid
   end

   # Supplies the repository title for a synthetic package without gem metadata.
   # @return [OpenStruct] default-locale summary, or an empty struct without a title
   def summaries
      title = repository_metadata.first
      title ? { Baltix::I18n.default_locale => title }.to_os : {}.to_os
   end

   # Supplies repository prose without borrowing a child gem's description.
   # @return [OpenStruct] default-locale description, falling back to the summary
   def descriptions
      description = repository_metadata.last || summaries[Baltix::I18n.default_locale]
      description ? { Baltix::I18n.default_locale => description }.to_os : {}.to_os
   end

   # Reads the configured origin without executing project code or a shell.
   # @return [String, nil] HTTP(S) repository URL, or nil for missing/unsupported origins
   # SSH GitHub-style origins are converted to HTTPS; other non-HTTP schemes are ignored.
   def vcs
      return @repository_vcs if defined?(@repository_vcs)
      return @repository_vcs = nil unless source_file && File.exist?(File.join(rootdir, '.git'))

      output, status = Open3.capture2e('git', '-C', rootdir, 'config', '--get', 'remote.origin.url')
      url = status.success? ? output.strip : ''
      url = url.sub(/\Agit@([^:]+):/, 'https://\1/')
      @repository_vcs = url.match?(/\Ahttps?:\/\/[^\s]+\z/) ? url : nil
   rescue Errno::ENOENT
      @repository_vcs = nil
   end

   # Derives the repository homepage from an explicitly configured Git origin.
   # @return [String, nil] homepage without the .git suffix, or nil if origin is unknown
   def uri
      vcs&.sub(/\.git\z/, '')
   end

   # Reads a README title and its first prose paragraph for synthetic root metadata.
   # @return [Array<String, nil>] title and description, or nil entries without readable prose
   # Supported README names share the RPM documentation whitelist. Leading badges,
   # blank lines and headings are skipped; lists/code blocks never become descriptions.
   # An unreadable or absent README leaves parsed/caller-supplied metadata in charge.
   def repository_metadata
      return @repository_metadata if defined?(@repository_metadata)
      return @repository_metadata = [nil, nil] unless source_file

      file = default_files.grep(README_FILE_RE).sort.first
      return @repository_metadata = [nil, nil] unless file

      text = File.read(File.join(rootdir, file), encoding: 'UTF-8')
      heading = text.match(/^\#\s+([^\n]+)|^([^\n]+)\n[=]{3,}\s*$/)
      title = heading && (heading[1] || heading[2]).strip
      body = heading ? text[heading.end(0)..] : text
      paragraph = body.split(/\n\s*\n/).map(&:strip).find do |part|
         !part.empty? && !part.match?(/\A(?:[\[!#<`*\-]|\d+\.)/)
      end
      @repository_metadata = [title, paragraph&.gsub(/\s*\n\s*/, ' ')]
   rescue SystemCallError, EncodingError, ArgumentError
      @repository_metadata = [nil, nil]
   end
end
