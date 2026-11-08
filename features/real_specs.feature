@actor @spec @gem
Feature: Spec actor

   @available_gem_list
   Scenario: Generate a complete mustermann spec with adjusted dependency requirements
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                     |
         | rootdir            | features/fixtures/mustermann              |
         | available_gem_list | {hansi: '1.0.0', ruby2_keywords: '0.1.0'} |
         | packager.name      | Ruby Maintainers Team                     |
         | packager.email     | ruby@packages.altlinux.org                |
         | maintainer.name    | Pavel Skrylev                             |
         | maintainer.email   | majioa@altlinux.org                       |
      And he applies "spec" actor to the baltix setup
      Then the generated spec matches "available.spec" from fixture "mustermann"

   @available_gem_list
   Scenario Outline: Keep RPM requirements aligned with override macros during updates
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                     |
         | rootdir            | features/fixtures/mustermann              |
         | available_gem_list | {hansi: '1.0.0', ruby2_keywords: '0.1.0'} |
         | packager.name      | Ruby Maintainers Team                     |
         | packager.email     | ruby@packages.altlinux.org                |
         | maintainer.name    | Pavel Skrylev                             |
         | maintainer.email   | majioa@altlinux.org                       |
      And he applies "spec" actor to the baltix setup
      And the generated spec is refreshed <updates> times
      Then the generated spec contains the lines:
         | %ruby_use_gem_dependency hansi >= 0.2.0,hansi < 2                   |
         | %ruby_use_gem_dependency ruby2_keywords >= 0.0.1,ruby2_keywords < 1 |
         | BuildRequires: gem(hansi) >= 0.2.0                                  |
         | BuildConflicts: gem(hansi) >= 2                                     |
         | BuildRequires: gem(ruby2_keywords) >= 0.0.1                         |
         | BuildConflicts: gem(ruby2_keywords) >= 1                            |
      And package "gem-mustermann" does not require "hansi"
      And package "gem-mustermann" contains dependency lines:
         | Requires:      gem(ruby2_keywords) >= 0.0.1 |
         | Conflicts:     gem(ruby2_keywords) >= 1     |
      And package "gem-mustermann-contrib" contains dependency lines:
         | Requires:      gem(hansi) >= 0.2.0     |
         | Conflicts:     gem(hansi) >= 2         |
         | Requires:      gem(mustermann) = 2.0.2 |

      And the generated dependency sections match "available.spec" from fixture "mustermann"

      Examples:
         | updates |
         | 0       |
         | 1       |
         | 2       |

   @scratch @blank_setup
   Scenario: Generate a spec from the root of the mustermann repository
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options          | value                                    |
         | rootdir          | features/fixtures/mustermann              |
         | spec_type        | rpm                                      |
         | packager.name    | Ruby Maintainers Team                    |
         | packager.email   | ruby@packages.altlinux.org                |
         | maintainer.name  | Pavel Skrylev                            |
         | maintainer.email | majioa@altlinux.org                       |
      Then the main source is the "mustermann" gem
      When he applies "spec" actor to the baltix setup
      Then he acquires an "mustermann" fixture spec for the baltix setup

   @scratch @blank_setup @main_is_gem
   Scenario: Generate a mixlib-shellout spec without inferred Windows dependencies
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options          | value                              |
         | rootdir          | features/fixtures/mixlib-shellout   |
         | spec_type        | rpm                                |
         | packager.name    | Ruby Maintainers Team              |
         | packager.email   | ruby@packages.altlinux.org          |
         | maintainer.name  | Pavel Skrylev                      |
         | maintainer.email | majioa@altlinux.org                 |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "mixlib-shellout" fixture spec for the baltix setup

   @scratch @blank_setup @main_is_gem
   Scenario: Generate a spec for rails-html-sanitizer with Gemfile development dependencies
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options          | value                                   |
         | rootdir          | features/fixtures/rails-html-sanitizer   |
         | spec_type        | rpm                                     |
         | packager.name    | Ruby Maintainers Team                   |
         | packager.email   | ruby@packages.altlinux.org               |
         | maintainer.name  | Pavel Skrylev                           |
         | maintainer.email | majioa@altlinux.org                      |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "rails-html-sanitizer" fixture spec for the baltix setup

   @policy1_0 @gem_change @main_is_gem
   Scenario: Apply the Spec actor to setup for ucf gem and old Ruby Policy 1.0 setup
      - blank packager
      - both gem dependencies are runtime and development
      - there is a dependency to ruby
      Given blank space
      And a spec from fixture "ucf"
      When developer locks the time to "21.04.2021"
      And he sets the space option "rootdir" to fixture "ucf"
      And he sets the space option "maintainer.name" to "Pavel Skrylev"
      And he sets the space option "maintainer.email" to "majioa@altlinux.org"
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "ucf" fixture spec for the baltix setup

   @policy1_0 @gem_change @gem_obsolete_list @main_is_gem
   Scenario: Apply the Spec actor to setup for zip-container gem and old Ruby Policy 1.0 setup
      - blank packager
      - both gem dependencies are runtime and development
      - there is a dependency to ruby
      Given blank space
      And a spec from fixture "zip-container"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                                         |
         | rootdir               | features/fixtures/zip-container               |
         | use_gem_obsolete_list | {rubyzip: rubyzip}                            |
         | maintainer.name       | Pavel Skrylev                                 |
         | maintainer.email      | majioa@altlinux.org                           |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "zip-container" fixture spec for the baltix setup

   @policy1_0 @gem_change @olddoc @wrongdoc @main_is_gem
   Scenario: Apply the Spec actor to setup for kgio gem with Olddoc/Wrongdoc specification
         and old Ruby Policy 1.0 setup, where root main source is a gem so it doesnt parse
         the the prefix, and suffix, and just use a default in output spec
      - blank packager
      - gem dependencies are development only
      - has extension containing call to #gem dep
      Given blank space
      And a spec from fixture "kgio"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                                         |
         | rootdir               | features/fixtures/kgio                        |
         | maintainer.name       | Pavel Skrylev                                 |
         | maintainer.email      | majioa@altlinux.org                           |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "kgio" fixture spec for the baltix setup

   @policy2_0 @gem_change @main_is_gem
   Scenario: Apply the Spec actor to setup for rbvmomi gem and manual Ruby Policy 2.0 setup
         with optimize available gem list feature
      - blank packager
      - both gem dependencies are runtime and development
      - there is a dependency to ruby
      - replace legacy gem_replace_version constraints using current sources and available versions
      - use identical rake requirements in the override macro and RPM dependency fields
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                                         |
         | rootdir            | features/fixtures/rbvmomi                     |
         | available_gem_list | {racc: 1.5.1, rake: '15.0', test-unit: '3.0'} |
         | maintainer.name    | Pavel Skrylev                                 |
         | maintainer.email   | majioa@altlinux.org                           |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "rbvmomi" fixture spec for the baltix setup
      And the generated spec contains the lines:
         | %ruby_use_gem_dependency rake >= 10.5,rake < 16 |
         | BuildRequires: gem(rake) >= 10.5                |
         | BuildConflicts: gem(rake) >= 16                 |
      And package "gem-rbvmomi-devel" contains dependency lines:
         | Requires:      gem(rake) >= 10.5 |
         | Conflicts:     gem(rake) >= 16   |

   @policy2_0 @release_change @main_is_gem
   Scenario: Apply the Spec actor to setup for rspec-support gem and manual Ruby Policy 2.0 setup
         with no gem version upgrade and skipping devel package
      - blank packager
      - "more than" condition dependency for gem
      Given blank space
      And a spec from fixture "rspec-support"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                             |
         | rootdir            | features/fixtures/rspec-support   |
         | devel_dep_setup    | :skip                             |
         | maintainer.name    | Pavel Skrylev                     |
         | maintainer.email   | majioa@altlinux.org               |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "rspec-support" fixture spec for the baltix setup

   @policy2_0 @gem_change @main_is_gem
   Scenario: Apply the Spec actor to setup for parser gem and manual Ruby Policy 2.0 setup
         with no gem version upgrade
      - blank packager
      Given blank space
      And a spec from fixture "parser"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options                              | value                    |
         | rootdir                              | features/fixtures/parser |
         | available_gem_list                   | {racc: 1.5.1}            |
         | use_gem_version_list                 | parser:3.0.1.1           |
         | maintainer.name                      | Pavel Skrylev            |
         | maintainer.email                     | majioa@altlinux.org      |
         | high_default_dependencies_priority   | true                     |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "parser" fixture spec for the baltix setup

   @scratch @index_gemspec @blank_setup
   Scenario: Apply the Spec actor to setup for turn gem to blank setup
      - blank setup
      - blank packager
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                             |
         | rootdir               | features/fixtures/turn            |
         | available_gem_list    | {minitest: 5.14.0}                |
         | spec_type             | rpm                               |
         | maintainer.name       | Pavel Skrylev                     |
         | maintainer.email      | majioa@altlinux.org               |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "turn" fixture spec for the baltix setup

   @policy2_0 @gem_change
   Scenario: Apply the Spec actor to setup for ruby-gnome2 gemset and Ruby Policy pre 2.0 setup
      - expand %summary in descriptions
      - pickup core version from common versions of submodules
      - proper detection of host rpm name line ruby-gnome2 not to rename to gem-gnome2
      - autoskip packages when they lost gemspecs like ruby-gnome2 *-no-gi packages or gem-vte defined in the original spec
      - since the top source is an application / group, so it doesn't parse a prefix, and use no prefix then
      - blank packager
      Given blank space
      And a spec from fixture "ruby-gnome2"
      When developer locks the time to "09.03.2022"
      And he sets the space options as:
         | options               | value                             |
         | rootdir               | features/fixtures/ruby-gnome2     |
         | available_gem_list    | {minitest: 5.14.0}                |
         | spec_type             | rpm                               |
         | ignored_names         | [rake]                            |
         | maintainer.name       | Pavel Skrylev                     |
         | maintainer.email      | majioa@altlinux.org               |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "ruby-gnome2" fixture spec for the baltix setup

   @scratch @hoe @blank_setup
   Scenario: Apply the Spec actor to setup for oedipus-lex gem to blank setup
      - blank setup
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                             |
         | packager.name         | Ruby Maintainers Team             |
         | packager.email        | ruby@packages.altlinux.org        |
         | rootdir               | features/fixtures/oedipus-lex     |
         | spec_type             | rpm                               |
         | maintainer.name       | Pavel Skrylev                     |
         | maintainer.email      | majioa@altlinux.org               |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "oedipus-lex" fixture spec for the baltix setup

   @scratch @bones @blank_setup
   Scenario: Apply the Spec actor to setup for little-plugger gem to blank setup
      - blank setup
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                             |
         | packager.name         | Ruby Maintainers Team             |
         | packager.email        | ruby@packages.altlinux.org        |
         | rootdir               | features/fixtures/little-plugger  |
         | spec_type             | rpm                               |
         | maintainer.name       | Pavel Skrylev                     |
         | maintainer.email      | majioa@altlinux.org               |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "little-plugger" fixture spec for the baltix setup

   @scratch @jeweler @blank_setup
   Scenario: Apply the Spec actor to setup for polyglot gem to blank setup
      - blank setup
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                             |
         | packager.name         | Ruby Maintainers Team             |
         | packager.email        | ruby@packages.altlinux.org        |
         | rootdir               | features/fixtures/polyglot        |
         | spec_type             | rpm                               |
         | maintainer.name       | Pavel Skrylev                     |
         | maintainer.email      | majioa@altlinux.org               |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "polyglot" fixture spec for the baltix setup

   @scratch @echoe @dep_rubygems @dep_runtime
   Scenario: Apply the Spec actor to setup for echoe gem to blank setup
      - blank setup
      - all gem dependencies are runtime
      - there is a dependency to rubygems
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                             |
         | packager.name         | Ruby Maintainers Team             |
         | packager.email        | ruby@packages.altlinux.org        |
         | rootdir               | features/fixtures/echoe           |
         | spec_type             | rpm                               |
         | maintainer.name       | Pavel Skrylev                     |
         | maintainer.email      | majioa@altlinux.org               |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "echoe" fixture spec for the baltix setup

   @policy2_0 @gem_change @rename @baltix_packager
   Scenario: Apply the Spec actor to setup for ruby-debug-ide gem and Ruby Policy 2.0 setup
      - rename to proper name defined by gem spec
      - use baltix team as packager
      - filter out gems (debase) not required by an allowed (currently ruby) platform
      - separate the test and developent gem groups
      - detect required gems for check and build spaces separately
        in gemfile and ext using gem_install_dependencies
      - increment alt release in spec as major due to rename
      - detect required gems for run binaries
      Given blank space
      And a spec from fixture "ruby-debug-ide"
      When developer locks the time to "16.11.2024"
      And he sets the space options as:
         | options               | value                             |
         | rootdir               | features/fixtures/ruby-debug-ide  |
         | available_gem_list    | {rake: 13.2.1, test-unit: 3.6.2}  |
         | spec_type             | rpm                               |
         | packager.name         | Baltix Maintainers Team           |
         | packager.email        | baltix@packages.altlinux.org      |
         | autorender_name       | true                              |
         | maintainer.name       | Baltix Builder Bot                |
         | maintainer.email      | bbb@altlinux.org                  |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "ruby-debug-ide" fixture spec for the baltix setup
