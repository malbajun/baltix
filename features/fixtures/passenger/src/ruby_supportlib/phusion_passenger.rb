# encoding: utf-8

#  Phusion Passenger - https://www.phusionpassenger.com/
#  Copyright (c) 2010-2026 Asynchronous B.V.
#
#  "Passenger", "Phusion Passenger" and "Union Station" are registered
#  trademarks of Asynchronous B.V.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

# Metadata fixture: retain only gemspec import helpers from upstream 3a958d4.
module PhusionPassenger
  FILE_LOCATION = File.expand_path(__FILE__)
  PACKAGE_NAME = 'passenger'
  VERSION_STRING = '6.2.1'
  GLOBAL_NAMESPACE_DIRNAME_           = "passenger"
  USER_NAMESPACE_DIRNAME_             = ".passenger"

  REQUIRED_LOCATIONS_INI_FIELDS = [
    # User-invoked commands
    :bin_dir,
    # Support binaries
    :support_binaries_dir,
    # Library files like libboost_oxt.a and various .o files
    :lib_dir,
    # Scripts not directly invoked by users
    :helper_scripts_dir,
    # Various non-executable resources
    :resources_dir,
    # C header files, necessary for compiling Nginx
    :include_dir,
    # Documentation
    :doc_dir,
    # Ruby support libraries
    :ruby_libdir,
    # Node.js support libraries
    :node_libdir,
    # Path to the compiled Apache module
    :apache2_module_path,
    # Directory containing the source code of our Ruby extension
    :ruby_extension_source_dir,
    # Directory containing the source code of our Nginx module
    :nginx_module_source_dir,
  ].freeze
  OPTIONAL_LOCATIONS_INI_FIELDS = [
    # Directory which contains the main Phusion Passenger Rakefile. Only
    # available when originally packaged,
    :build_system_dir,
    # Directory in which downloaded Phusion Passenger binaries are cached.
    :download_cache_dir,
  ].freeze


  def self.locate_directories(install_spec = nil)
    @install_spec = install_spec || infer_install_spec
    if @install_spec && File.file?(@install_spec)
      filename = @install_spec
      options  = parse_ini_file(filename)

      @custom_packaged = true
      @packaging_method = get_option(filename, options, 'packaging_method')
      REQUIRED_LOCATIONS_INI_FIELDS.each do |field|
        value = get_option(filename, options, field.to_s)
        value.freeze unless value.nil?
        instance_variable_set("@#{field}", value)
      end
      OPTIONAL_LOCATIONS_INI_FIELDS.each do |field|
        value = get_option(filename, options, field.to_s, false)
        value.freeze unless value.nil?
        instance_variable_set("@#{field}", value)
      end
    else
      source_root            = File.dirname(File.dirname(File.dirname(FILE_LOCATION)))
      @install_spec          = source_root
      @custom_packaged       = false
      @bin_dir               = "#{source_root}/bin".freeze
      @support_binaries_dir  = "#{source_root}/buildout/support-binaries".freeze
      @lib_dir               = "#{source_root}/buildout".freeze
      @helper_scripts_dir    = "#{source_root}/src/helper-scripts".freeze
      @resources_dir         = "#{source_root}/resources".freeze
      @include_dir           = "#{source_root}/src".freeze
      @doc_dir               = "#{source_root}/doc".freeze
      @ruby_libdir           = File.dirname(FILE_LOCATION).freeze
      @node_libdir           = "#{source_root}/src/nodejs_supportlib".freeze
      @apache2_module_path   = "#{source_root}/buildout/apache2/mod_passenger.so".freeze
      @ruby_extension_source_dir = "#{source_root}/src/ruby_native_extension".freeze
      @nginx_module_source_dir   = "#{source_root}/src/nginx_module".freeze
      @download_cache_dir        = "#{source_root}/download_cache".freeze
      @build_system_dir          = source_root.dup.freeze
      REQUIRED_LOCATIONS_INI_FIELDS.each do |field|
        if instance_variable_get("@#{field}").nil?
          raise "BUG: @#{field} not set"
        end
      end
    end
  end

  def self.ruby_libdir
    @ruby_libdir
  end

  def self.require_passenger_lib(name)
    require("#{ruby_libdir}/phusion_passenger/#{name}")
  end

  def self.infer_install_spec
    filename = ENV['PASSENGER_LOCATION_CONFIGURATION_FILE']
    return filename if filename && !filename.empty?

    filename = File.dirname(FILE_LOCATION) + "/phusion_passenger/locations.ini"
    return filename if filename && File.exist?(filename)

    require 'etc' if !defined?(Etc)
    begin
      home_dir = Etc.getpwuid(Process.uid).dir
    rescue ArgumentError
      # Unknown user.
      home_dir = ENV['HOME']
    end
    if home_dir && !home_dir.empty?
      filename = "#{home_dir}/#{USER_NAMESPACE_DIRNAME_}/locations.ini"
      return filename if File.exist?(filename)
    end

    filename = "/etc/#{GLOBAL_NAMESPACE_DIRNAME_}/locations.ini"
    return filename if File.exist?(filename)

    nil
  end

end
