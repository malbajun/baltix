@regular_dependencies
Feature: Available gem versions and dependency override macros
   Existing interval examples exercise regular dependency bounds explicitly.
   Mode-selection examples override that setting; an unset option selects redep.

   Scenario: Preserve strict external dependency boundaries in RPM tags
      - external equality is an inclusive minimum, while > remains strict
      - source < becomes Conflicts >= and source <= becomes Conflicts >
      Given blank space
      When he sets the space option "rootdir" to fixture "rbvmomi"
      Then external gem bounds render as:
         | requirement  | requires  | conflicts |
         | = 4.2        | >= 4.2    |           |
         | > 4.2        | > 4.2     |           |
         | < 4.2        | >= 0      | >= 4.2    |
         | <= 4.2       | >= 0      | > 4.2     |
         | != 4.2       | > 4.2     |           |

   Scenario Outline: Selectively remove gem upper bounds without changing source minimums
      - regular retains the current dependency override behavior
      - redep relaxes only gems selected for dependency override macros
      - all also relaxes every gem appearing in runtime or build conflicts
      - preserve the original gem metadata
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                                         |
         | rootdir               | features/fixtures/rbvmomi                     |
         | available_gem_list    | {racc: 1.5.1, rake: '15.0', test-unit: '3.0'} |
         | gem_dependency_mode   | <setting>                                     |
         | maintainer.name       | Pavel Skrylev                                 |
         | maintainer.email      | majioa@altlinux.org                           |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains each line once:
         | %ruby_use_gem_dependency <rake_override>   |
      And the generated gem conflicts are "<conflicts>"
      And the source "rbvmomi" dependency "rake" has version compatibility:
         | version   | allowed   |
         | 10.5      | yes       |
         | 15.0      | no        |
      And the generated spec matches "<expected>" from fixture "rbvmomi"
      When the generated spec is refreshed 2 times
      Then the generated dependency sections match "<expected>" from fixture "rbvmomi"
      And the generated gem conflicts are "<conflicts>"
      When he sets the space option "gem_dependency_mode" to ":regular"
      And the generated spec is refreshed 1 times
      Then the generated gem conflicts are "builder,nokogiri,optimist,rake,simplecov,yard"
      And the generated spec contains each line once:
         | %ruby_use_gem_dependency rake >= 10.5,rake < 16  |

      Examples:
         | setting   | rake_override            | conflicts                                     | expected           |
         | :regular  | rake >= 10.5,rake < 16   | builder,nokogiri,optimist,rake,simplecov,yard | mode-regular.spec  |
         | :redep    | rake >= 10.5             | builder,nokogiri,optimist,simplecov,yard      | mode-redep.spec    |
         | :all      | rake >= 10.5             |                                               | mode-all.spec      |
         | null      | rake >= 10.5             | builder,nokogiri,optimist,simplecov,yard      | mode-redep.spec    |

   Scenario Outline: Relax imported dependency macros without an available gem list
      - include gems already named in ruby_use_gem_dependency
      - recompute the minimum from sources rather than a historical macro
      Given blank space
      And a spec from fixture "rbvmomi"
      When he sets the space options as:
         | options               | value                       |
         | rootdir               | features/fixtures/rbvmomi   |
         | gem_dependency_mode   | <mode>                      |
      And the input spec has dependency override macros:
         | nokogiri >= 1.14,nokogiri < 2  |
         | json >= 2                      |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains each line once:
         | %ruby_use_gem_dependency nokogiri >= 1.5   |
         | %ruby_use_gem_dependency json >= 1.8       |
      And the generated gem conflicts are "<conflicts>"
      When the generated spec is refreshed 2 times
      Then the generated spec contains each line once:
         | %ruby_use_gem_dependency nokogiri >= 1.5   |
         | %ruby_use_gem_dependency json >= 1.8       |
      And the generated gem conflicts are "<conflicts>"

      Examples:
         | mode   | conflicts                            |
         | redep  | builder,optimist,rake,simplecov,yard |
         | all    |                                      |


   Scenario: Relax an external gem found only in input build conflicts
      - include external build tools even without a source Gemfile declaration
      - preserve the explicit build minimum when creating the lower-only override
      Given blank space
      And a spec from fixture "rbvmomi"
      When he sets the space options as:
         | options               | value                       |
         | rootdir               | features/fixtures/rbvmomi   |
         | gem_dependency_mode   | :all                        |
      And the input spec has extra build requirements:
         | gem(cliver) >= 1.0 |
      And the input spec has extra build conflicts:
         | gem(cliver) >= 2 # gem(comment-only) is not a declaration |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains each line once:
         | %ruby_use_gem_dependency cliver >= 1.0  |
         | BuildRequires: gem(cliver) >= 1.0       |
      And the generated gem conflicts are ""
      And the generated spec contains no override for "comment-only"
      When the generated spec is refreshed 2 times
      Then the generated spec contains each line once:
         | %ruby_use_gem_dependency cliver >= 1.0  |
         | BuildRequires: gem(cliver) >= 1.0       |
      And the generated gem conflicts are ""

   Scenario Outline: Preserve explicit package build conflicts across spec updates
      - exercise RPM tool bounds separately from the unchanged rbvmomi source metadata
      - recompute gem conflicts from source requirements and available versions
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                       |
         | rootdir            | features/fixtures/rbvmomi   |
         | available_gem_list | {rake: '15.0'}              |
      And the input spec has extra build requirements:
         | ragel6 >= 6.7   |
         | bison >= 3      |
      And the input spec has extra build conflicts:
         | ragel6 >= 7                             |
         | bison >= 4 ragel6 >= 7 # repeated tool  |
         | gem(rake) >= 11                         |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      And the generated spec is refreshed <updates> times
      Then the generated spec contains each line once:
         | BuildRequires: ragel6 >= 6.7                     |
         | BuildRequires: bison >= 3                        |
         | BuildConflicts: ragel6 >= 7                      |
         | BuildConflicts: bison >= 4                       |
         | BuildConflicts: gem(rake) >= 16                  |
         | %ruby_use_gem_dependency rake >= 10.5,rake < 16  |
      And the generated spec excludes the lines:
         | BuildConflicts: gem(rake) >= 11   |

      Examples:
         | updates   |
         | 0         |
         | 2         |

   @policy2_0 @policy2_1
   Scenario: Upgrade mixed obsolete Ruby Policy 2.0 prerequisites to 2.1 without duplicates
      - replace the obsolete rpm-build-ruby prerequisite with Ruby Policy 2.1 prerequisites
      - retain explicit version constraints and unrelated prerequisites across updates
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And he sets the space option "rootdir" to fixture "rbvmomi"
      And the input spec has build prerequisites:
         | rpm-build-ruby                 |
         | rpm-macros-ruby setup-rb rake  |
         | rake >= 12                     |
         | gcc >= 10                      |
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
         | options            | value                       |
         | rootdir            | features/fixtures/rbvmomi   |
         | available_gem_list | {rake: '15.0'}              |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains the lines:
         | %ruby_on_build_rake_tasks <tasks>                |
         | %ruby_use_gem_dependency rake >= 10.5,rake < 16  |
         | %ruby_build                                      |
      When the generated spec is refreshed 2 times
      Then the generated spec contains the lines:
         | %ruby_on_build_rake_tasks <tasks>                |
         | %ruby_use_gem_dependency rake >= 10.5,rake < 16  |
      And package "gem-rbvmomi-devel" contains dependency lines:
         | Requires:      gem(rake) >= 10.5  |

      Examples:
         | form         | tasks                          |
         | macro        | build:prepare,assets:compile   |
         | build option | build:prepare,assets:compile   |
         | macro        | build:c_exts                   |
         | build option | build:c_exts                   |
         | macro        | @generate                      |
         | build option | @generate                      |

   Scenario: Keep the source minimum when available versions straddle it
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                       |
         | rootdir            | features/fixtures/rbvmomi   |
         | available_gem_list | {rake: ['9.0', '15.0']}     |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains the lines:
         | %ruby_use_gem_dependency rake >= 10.5,rake < 16  |
         | BuildRequires: gem(rake) >= 10.5                 |
      And package "gem-rbvmomi-devel" contains dependency lines:
         | Requires:      gem(rake) >= 10.5  |

   Scenario Outline: Never lower a source requirement to accommodate an older available version
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                       |
         | rootdir            | features/fixtures/rbvmomi   |
         | available_gem_list | <available>                 |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains no override for "rake"
      And the generated spec contains the lines:
         | BuildRequires: gem(rake) >= 10.5  |
         | BuildConflicts: gem(rake) >= 11   |
      And package "gem-rbvmomi-devel" contains dependency lines:
         | Requires:      gem(rake) >= 10.5  |
         | Conflicts:     gem(rake) >= 11    |

      Examples:
         | available       |
         | {}              |
         | {rake: '9.0'}   |

   Scenario: Keep the source version of gems packaged in the same spec
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                   |
         | rootdir            | features/fixtures/mustermann            |
         | available_gem_list | {mustermann: '3.0.0', hansi: '1.0.0'}   |
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains no override for "mustermann"
      And package "gem-mustermann-contrib" contains dependency lines:
         | Requires:      gem(mustermann) = 2.0.2  |
         | Requires:      gem(hansi) >= 0.2.0      |
         | Conflicts:     gem(hansi) >= 2          |

   Scenario: Emit an override for an adjusted dependency of a secondary gem
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                          |
         | rootdir            | features/fixtures/mustermann   |
         | available_gem_list | {hansi: '1.0.0'}               |
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains the lines:
         | %ruby_use_gem_dependency hansi >= 0.2.0,hansi < 2   |

   Scenario: Remove obsolete overrides when the available list is cleared
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                      |
         | rootdir            | features/fixtures/mustermann               |
         | available_gem_list | {hansi: '1.0.0', ruby2_keywords: '0.1.0'}  |
      And he applies "spec" actor to the baltix setup
      And he sets the space option "available_gem_list" to:
         """
         {}
         """
      And the generated spec is refreshed 1 times
      Then the generated spec contains no dependency override macros
      And the generated spec contains the lines:
         | BuildRequires: gem(hansi) >= 0.2.0   |
         | BuildConflicts: gem(hansi) >= 0.3    |
      And package "gem-mustermann-contrib" contains dependency lines:
         | Requires:      gem(hansi) >= 0.2.0   |
         | Conflicts:     gem(hansi) >= 0.3     |
      And package "gem-mustermann" contains dependency lines:
         | Requires:      gem(ruby2_keywords) >= 0.0.1   |
         | Conflicts:     gem(ruby2_keywords) >= 0.1     |

   Scenario Outline: Preserve external gem build requirements absent from source metadata
      - retain an externally identified tool such as Ruby Next parser's cliver
      - keep explicit version bounds outside the optional checks section
      - reconstruct known source dependencies rather than retaining stale input bounds
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                       |
         | rootdir            | features/fixtures/rbvmomi   |
         | available_gem_list | {rake: '15.0'}              |
      And the input spec has extra build requirements:
         | <declaration>   |
         | gem(rake) >= 99 |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the unconditional build requirements include:
         | BuildRequires: <expected>   |
      And the generated build requirements for "rake" are:
         | BuildRequires: gem(rake) >= 10.5  |
      And package "gem-rbvmomi" does not require "cliver"
      When the generated spec is refreshed 2 times
      Then the unconditional build requirements include:
         | BuildRequires: <expected>   |
      And the generated build requirements for "rake" are:
         | BuildRequires: gem(rake) >= 10.5  |
      And package "gem-rbvmomi" does not require "cliver"

      Examples:
         | declaration        | expected           |
         | gem(cliver)        | gem(cliver) >= 0   |
         | gem(cliver) >= 1.0 | gem(cliver) >= 1.0 |
         | gem(cliver) = 1.0  | gem(cliver) >= 1.0 |
         | gem(cliver) > 1.0  | gem(cliver) > 1.0  |
         | gem(cliver) != 1.0 | gem(cliver) > 1.0  |
         | gem(cliver) < 2    | gem(cliver) < 2    |
