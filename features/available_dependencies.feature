Feature: Available gem versions and dependency override macros

   Scenario: Keep the source version of gems packaged in the same spec
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                   |
         | rootdir            | features/fixtures/mustermann             |
         | available_gem_list | {mustermann: '3.0.0', hansi: '1.0.0'}    |
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains no override for "mustermann"
      And package "gem-mustermann-contrib" contains dependency line "Requires:      gem(mustermann) = 2.0.2"
      And package "gem-mustermann-contrib" contains dependency line "Requires:      gem(hansi) >= 1.0.0"
      And package "gem-mustermann-contrib" contains dependency line "Conflicts:     gem(hansi) >= 2"

   Scenario: Emit an override for an adjusted dependency of a secondary gem
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                  |
         | rootdir            | features/fixtures/mustermann            |
         | available_gem_list | {hansi: '1.0.0'}                        |
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains the line "%ruby_use_gem_dependency hansi >= 1.0.0,hansi < 2"

   Scenario: Remove obsolete overrides when the available list is cleared
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                     |
         | rootdir            | features/fixtures/mustermann               |
         | available_gem_list | {hansi: '1.0.0', ruby2_keywords: '0.1.0'}   |
      And he applies "spec" actor to the baltix setup
      And he sets the space option "available_gem_list" to:
         """
         {}
         """
      And the generated spec is refreshed 1 times
      Then the generated spec contains no dependency override macros
      And the generated spec contains the line "BuildRequires: gem(hansi) >= 0.2.0"
      And the generated spec contains the line "BuildConflicts: gem(hansi) >= 0.3"
      And package "gem-mustermann-contrib" contains dependency line "Requires:      gem(hansi) >= 0.2.0"
      And package "gem-mustermann-contrib" contains dependency line "Conflicts:     gem(hansi) >= 0.3"
      And package "gem-mustermann" contains dependency line "Requires:      gem(ruby2_keywords) >= 0.0.1"
      And package "gem-mustermann" contains dependency line "Conflicts:     gem(ruby2_keywords) >= 0.1"
