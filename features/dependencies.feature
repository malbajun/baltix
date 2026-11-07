Feature: Dependencies from real Ruby projects

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
