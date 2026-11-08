Feature: Available gem versions and dependency override macros

   Scenario: Emit an override for an adjusted dependency of a secondary gem
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                  |
         | rootdir            | features/fixtures/mustermann            |
         | available_gem_list | {hansi: '1.0.0'}                        |
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains the line "%ruby_use_gem_dependency hansi >= 1.0.0,hansi < 2"
