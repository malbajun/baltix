Feature: Dependencies from real Ruby projects

   Scenario: Merge Ruby bounds from the Gemfile, gemspec and original RPM spec
      - choose the greatest lower bound and the least upper bound per interpreter
      - retain strictness at equal boundaries and keep opaque RPM macros unchanged
      - retain the merged bounds through two more spec updates
      Then Ruby interpreter constraints produce these RPM bounds:
         | gemspec         | gemfile         | original_requires  | original_conflicts | requires  | conflicts |
         | >= 2.7          | >= 2.4          | >= 2.0             |                    | >= 2.7    |           |
         | >= 2.4          | >= 2.7, < 3.4   | >= 2.0             | >= 3.5             | >= 2.7    | >= 3.4    |
         | >= 2.4, < 3.5   | >= 2.7, < 3.4   | >= 2.0             | >= 3.3             | >= 2.7    | >= 3.3    |
         | >= 2.7          | > 2.7           | >= 2.0             |                    | > 2.7     |           |
         | > 2.7           | >= 2.7          | >= 2.0             |                    | > 2.7     |           |
         | <= 3.4          | < 3.4           | >= 2.7             | > 3.4              | >= 2.7    | >= 3.4    |
         | <= 3.4          | <= 3.5          | > 2.7              | > 3.4              | > 2.7     | > 3.4     |
         | >= 2.0          | >= 2.4          | >= 2.5; > 2.7      | >= 3.6; > 3.4      | > 2.7     | > 3.4     |
         | >= 2.7          | >= 2.0          | >= %ruby_version   |                    | >= 2.7    |           |

   Scenario: Keep the Ruby language and alternate interpreter bounds separate
      Then a JRuby Gemfile and gemspec retain their interpreter requirements


   Scenario: Preserve source requirement intersections independently of operand order
      - keep every constraint, including exclusions and pessimistic requirements
      - retain strict boundaries and do not broaden or empty compatible ranges
      - leave original requirement objects unchanged
      Then requirement intersections preserve these version checks:
         | left            | right           | allowed   | rejected  | lower  |
         | > 2.0           | > 1.0           | 2.1       | 2.0       | > 2.0  |
         | > 1.0           | >= 1.5          | 1.5       | 1.0       | >= 1.5 |
         | >= 1.0, < 3.0   | >= 2.0, < 2.5   | 2.1       | 1.5,2.5   | >= 2.0 |
         | ~> 1.0          | != 1.5          | 1.6       | 1.5,2.0   | > 1.5  |
         | ~> 1.5          | < 1.8           | 1.7       | 1.9       | >= 1.5 |
         | <= 2.0          | != 1.0          | 0.9       | 1.0,2.1   | > 1.0  |
         | = 1.5           | >= 2.0          |           | 1.5,2.1   |        |
         | = 2.0           | >= 1.0          | 2.0       | 1.5,2.1   | = 2.0  |


   # Original build metadata from sinatra/mustermann, tag v2.0.2.
   Scenario: Merge gemspec requirements into an already read project Gemfile
      Given blank space
      When he sets the space option "rootdir" to fixture "mustermann"
      And the "mustermann" gem dependency DSL is merged into the project DSL
      Then the development dependencies include "ruby2_keywords" with requirement "~> 0.0.1, >= 0"
      And the generated dependency requirement for "ruby2_keywords" is "~> 0.0.1, >= 0"
      And the definition dependency requirement for "ruby2_keywords" is "~> 0.0.1, >= 0"

   Scenario: Merge two gemspec sources which have no Gemfile
      Given blank space
      When he sets the space option "rootdir" to fixture "mustermann"
      And the "mustermann-contrib" gem dependency DSL is merged into the "mustermann" gem DSL
      Then the runtime dependency names are:
         | name            |
         | ruby2_keywords  |
         | mustermann      |
         | hansi           |

   # Original build metadata from chef/mixlib-shellout, tag v3.2.7.
   Scenario: Infer Windows-only dependencies from platform gemspecs
      Given blank space
      When he sets the space option "rootdir" to fixture "mixlib-shellout"
      Then the project dependencies exclude:
         | name                  |
         | win32-process         |
         | wmi-lite              |
         | ffi-win32-extensions  |
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
         | source    |
         | Gemfile   |
         | gemspec   |

   Scenario: Replace a development dependency version in digest-crc
      Given the dependency DSL from the "digest-crc" fixture Gemfile
      When the dependency requirement for "rspec" is replaced with "~> 3.12"
      Then the generated Gemfile declares "rspec" in group "development" with requirement "~> 3.12"
