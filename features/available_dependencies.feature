Feature: Available gem versions and dependency override macros

   @policy2_0 @policy2_1
   Scenario: Upgrade mixed obsolete Ruby Policy 2.0 prerequisites to 2.1 without duplicates
      - replace the obsolete rpm-build-ruby prerequisite with Ruby Policy 2.1 prerequisites
      - retain explicit version constraints and unrelated prerequisites across updates
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And he sets the space option "rootdir" to fixture "rbvmomi"
      And the input spec has build prerequisites:
         | rpm-build-ruby                |
         | rpm-macros-ruby setup-rb rake |
         | rake >= 12                    |
         | gcc >= 10                     |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      And the generated spec is refreshed 2 times
      Then the generated build prerequisites are:
         | rpm-macros-ruby setup-rb |
         | rake >= 12               |
         | gcc >= 10                |

   Scenario Outline: Preserve configured rake tasks while refreshing dependency overrides
      - retain the build:c_exts task needed by digest-crc when upgrading to Ruby Policy 2.1
      - migrate legacy ruby_build --pre declarations to ruby_on_build_rake_tasks
      - preserve external-task markers such as ruby_parser's @generate across updates
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And the input spec configures rake tasks "<tasks>" through "<form>"
      And he sets the space options as:
         | options            | value                     |
         | rootdir            | features/fixtures/rbvmomi |
         | available_gem_list | {rake: '15.0'}            |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains the lines:
         | %ruby_on_build_rake_tasks <tasks>               |
         | %ruby_use_gem_dependency rake >= 10.5,rake < 16 |
         | %ruby_build                                     |
      When the generated spec is refreshed 2 times
      Then the generated spec contains the lines:
         | %ruby_on_build_rake_tasks <tasks>               |
         | %ruby_use_gem_dependency rake >= 10.5,rake < 16 |
      And package "gem-rbvmomi-devel" contains dependency lines:
         | Requires:      gem(rake) >= 10.5 |

      Examples:
         | form         | tasks                        |
         | macro        | build:prepare,assets:compile |
         | build option | build:prepare,assets:compile |
         | macro        | build:c_exts                 |
         | build option | build:c_exts                 |
         | macro        | @generate                    |
         | build option | @generate                    |

   Scenario: Keep the source minimum when available versions straddle it
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                     |
         | rootdir            | features/fixtures/rbvmomi |
         | available_gem_list | {rake: ['9.0', '15.0']}   |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains the lines:
         | %ruby_use_gem_dependency rake >= 10.5,rake < 16 |
         | BuildRequires: gem(rake) >= 10.5                |
      And package "gem-rbvmomi-devel" contains dependency lines:
         | Requires:      gem(rake) >= 10.5 |

   Scenario Outline: Never lower a source requirement to accommodate an older available version
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                     |
         | rootdir            | features/fixtures/rbvmomi |
         | available_gem_list | <available>               |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains no override for "rake"
      And the generated spec contains the lines:
         | BuildRequires: gem(rake) >= 10.5 |
         | BuildConflicts: gem(rake) >= 11  |
      And package "gem-rbvmomi-devel" contains dependency lines:
         | Requires:      gem(rake) >= 10.5 |
         | Conflicts:     gem(rake) >= 11   |

      Examples:
         | available     |
         | {}            |
         | {rake: '9.0'} |

   Scenario: Keep the source version of gems packaged in the same spec
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                 |
         | rootdir            | features/fixtures/mustermann          |
         | available_gem_list | {mustermann: '3.0.0', hansi: '1.0.0'} |
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains no override for "mustermann"
      And package "gem-mustermann-contrib" contains dependency lines:
         | Requires:      gem(mustermann) = 2.0.2 |
         | Requires:      gem(hansi) >= 0.2.0     |
         | Conflicts:     gem(hansi) >= 2         |

   Scenario: Emit an override for an adjusted dependency of a secondary gem
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                        |
         | rootdir            | features/fixtures/mustermann |
         | available_gem_list | {hansi: '1.0.0'}             |
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains the lines:
         | %ruby_use_gem_dependency hansi >= 0.2.0,hansi < 2 |

   Scenario: Remove obsolete overrides when the available list is cleared
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                     |
         | rootdir            | features/fixtures/mustermann              |
         | available_gem_list | {hansi: '1.0.0', ruby2_keywords: '0.1.0'} |
      And he applies "spec" actor to the baltix setup
      And he sets the space option "available_gem_list" to:
         """
         {}
         """
      And the generated spec is refreshed 1 times
      Then the generated spec contains no dependency override macros
      And the generated spec contains the lines:
         | BuildRequires: gem(hansi) >= 0.2.0 |
         | BuildConflicts: gem(hansi) >= 0.3  |
      And package "gem-mustermann-contrib" contains dependency lines:
         | Requires:      gem(hansi) >= 0.2.0 |
         | Conflicts:     gem(hansi) >= 0.3   |
      And package "gem-mustermann" contains dependency lines:
         | Requires:      gem(ruby2_keywords) >= 0.0.1 |
         | Conflicts:     gem(ruby2_keywords) >= 0.1   |

   Scenario Outline: Preserve external gem build requirements absent from source metadata
      - retain an externally identified tool such as Ruby Next parser's cliver
      - keep explicit version bounds outside the optional checks section
      - reconstruct known source dependencies rather than retaining stale input bounds
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                     |
         | rootdir            | features/fixtures/rbvmomi |
         | available_gem_list | {rake: '15.0'}            |
      And the input spec has extra build requirements:
         | <declaration>   |
         | gem(rake) >= 99 |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the unconditional build requirements include:
         | BuildRequires: <expected> |
      And the generated build requirements for "rake" are:
         | BuildRequires: gem(rake) >= 10.5 |
      And package "gem-rbvmomi" does not require "cliver"
      When the generated spec is refreshed 2 times
      Then the unconditional build requirements include:
         | BuildRequires: <expected> |
      And the generated build requirements for "rake" are:
         | BuildRequires: gem(rake) >= 10.5 |
      And package "gem-rbvmomi" does not require "cliver"

      Examples:
         | declaration        | expected           |
         | gem(cliver)        | gem(cliver) >= 0   |
         | gem(cliver) >= 1.0 | gem(cliver) >= 1.0 |
         | gem(cliver) < 2    | gem(cliver) < 2    |
