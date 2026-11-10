# frozen_string_literal: true
# Copyright:: Copyright 2017, Noah Kantrowitz
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module ChefUtils
  # String-like object for version strings.
  #
  # @since 13.2
  # @api internal
  class VersionString < String
    # Create a new VersionString from an input String.
    #
    # @param val [String] Version string to parse.
    def initialize(val)
      val ||= ""
      super(val)
      begin
        @parsed_version = ::Gem::Version.create(self)
      rescue ArgumentError
        @parsed_version = nil
      end
    end

  end
end
