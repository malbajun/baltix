Feature: Dependencies from real Ruby projects

   # Original build metadata from chef/mixlib-shellout, tag v3.2.7.
   Scenario: Infer Windows-only dependencies from platform gemspecs
      Given blank space
      When he sets the space option "rootdir" to fixture "mixlib-shellout"
      Then the project dependencies exclude:
         | name                 |
         | win32-process        |
         | wmi-lite             |
         | ffi-win32-extensions |
      And the project dependencies include "chef-utils"

   Scenario: Retain inferred platform dependencies when no platform is ignored
      Given blank space
      When he sets the space option "rootdir" to fixture "mixlib-shellout"
      And he sets the space option "skip_platforms" to:
         """
         []
         """
      Then the project dependencies include "win32-process"
      And the project dependencies include "wmi-lite"
      And the project dependencies include "ffi-win32-extensions"

   # Original build metadata from rails/rails-html-sanitizer, tag v1.4.4.
   Scenario Outline: Gemfile dependencies do not become runtime requirements of rails-html-sanitizer
      Given the dependency DSL from the "rails-html-sanitizer" fixture Gemfile
      When the fixture <source> dependencies are read
      Then the runtime dependency names are:
         | name   |
         | loofah |
      And the development dependencies include "nokogiri" with requirement ">= 1.7"
      And the development dependencies include "activesupport" with requirement ">= 5"

      Examples:
         | source  |
         | Gemfile |
         | gemspec |

   Scenario: Replace a development dependency version in digest-crc
      Given the dependency DSL from the "digest-crc" fixture Gemfile
      When the dependency requirement for "rspec" is replaced with "~> 3.12"
      Then the generated Gemfile declares "rspec" in group "development" with requirement "~> 3.12"
