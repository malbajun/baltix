@actor @spec @gem @policy2_1
Feature: Spec actor
   All generated specs target the Ruby Policy 2.1 draft currently under development.
   Tags @policy1_0 and @policy2_0 identify obsolete input policies being migrated.
   The obsolete rpm-build-ruby prerequisite is replaced by rpm-macros-ruby, setup-rb and rake.
   Shared availability checks also cover the behavior reported for rdoc and prometheus-client:
   source minimums are preserved, packaged gems receive no self-overrides,
   and RPM dependency tags remain consistent across repeated spec updates.

   # datamapper/do: 16564e6dba587e92e41aba376b46ef765f3bffea.
   # Retain the core gem, one native driver and repository-level build metadata.
   @scratch @blank_setup
   Scenario: Select the nested data_objects gem through the repository's RPM name
      - treat the data-objects repository name as an alias of data_objects
      - preserve the repository root and retain its shared build dependencies
      - package the core gem once, with its SQLite driver as a secondary
      - cover the runtime/development dependency separation also reported for byebug
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options          | value                          |
         | rootdir          | features/fixtures/data-objects |
         | spec_type        | rpm                            |
         | maintainer.name  | Pavel Skrylev                  |
         | maintainer.email | majioa@altlinux.org            |
      Then the main source is the "data_objects" gem
      And the project root remains the "data-objects" fixture
      When he applies "spec" actor to the baltix setup
      Then he acquires an "data-objects" fixture spec for the baltix setup
      And the generated package names are unique
      And the generated spec contains the lines:
         | Name:          gem-data-objects          |
         | Version:       0.10.17                   |
         | BuildRequires: gem(rake-compiler) >= 0.7 |
         | BuildConflicts: gem(rake-compiler) >= 1  |
      And package "gem-data-objects" contains dependency lines:
         | Requires:      gem(addressable) >= 2.1 |
         | Conflicts:     gem(addressable) >= 3   |
      And package "gem-do-sqlite3" contains dependency lines:
         | Requires:      gem(data_objects) = 0.10.17 |
      When the generated spec is refreshed 2 times
      Then the main source is the "data_objects" gem
      And the project root remains the "data-objects" fixture
      And the generated package names are unique
      And the generated dependency sections match "gem.spec" from fixture "data-objects"

   # Published glu/glut 8.3.0 and kpeg 1.3.3 source packages from RubyGems.
   # Hoe reads the retained manifests, readmes and histories while importing Rakefiles.
   @scratch @blank_setup @main_is_gem
   Scenario Outline: Preserve complete development dependencies from Hoe and gemspec sources
      - import Hoe spec_extras assignments before collecting development dependencies
      - isolate each project's metadata from previously imported Rakefiles
      - keep development requirements and upper bounds out of the runtime package
      - retain dependency ranges after parsing and updating the generated spec
      Given blank space
      When developer locks the time to "13.12.2022"
      And the "<previous>" fixture has already been imported
      And he sets the space options as:
         | options          | value               |
         | rootdir          | <rootdir>           |
         | spec_type        | rpm                 |
         | maintainer.name  | Pavel Skrylev       |
         | maintainer.email | majioa@altlinux.org |
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains the lines:
         | BuildRequires: gem(<dependency>) >= <minimum> |
         | BuildConflicts: gem(<dependency>) >= <upper>  |
      And package "gem-<fixture>-devel" contains dependency lines:
         | Requires:      gem(<dependency>) >= <minimum> |
         | Conflicts:     gem(<dependency>) >= <upper>   |
      And package "gem-<fixture>" does not require "<dependency>"
      And he acquires an "<fixture>" fixture spec for the baltix setup
      When the generated spec is refreshed 2 times
      Then the generated dependency sections match "gem.spec" from fixture "<fixture>"

      Examples:
         | fixture | previous | rootdir                | dependency    | minimum | upper |
         | glu     | glut     | features/fixtures/glu  | rake-compiler | 1.0     | 2     |
         | glut    | glu      | features/fixtures/glut | mini_portile2 | 2.1     | 3     |
         | kpeg    | glu      | features/fixtures/kpeg | rdoc          | 4.0     | 7     |

   # rubyworks/facets 3.1.0, revision 86e44b354b0008c32bebb305fae7b1848cfd13a6.
   # The manifest is reduced to files retained for importing the fixture.
   @scratch @blank_setup @main_is_gem
   Scenario: Keep facets index test dependencies out of runtime requirements
      - preserve dependency groups and complete version requirements from the index
      - agree with the original gemspec declarations
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options          | value                    |
         | rootdir          | features/fixtures/facets |
         | spec_type        | rpm                      |
         | maintainer.name  | Pavel Skrylev            |
         | maintainer.email | majioa@altlinux.org      |
      Then source "facets" has dependency declarations:
         | name         | type        | requirement |
         | guard        | development | >= 0        |
         | lemon        | development | >= 0        |
         | qed          | development | >= 0        |
         | rake         | development | >= 0        |
         | rubytest-cli | development | >= 0        |
         | simplecov    | development | >= 0        |
      When he applies "spec" actor to the baltix setup
      Then he acquires an "facets" fixture spec for the baltix setup

   # BytecodeAlliance/wasmtime-rb: 8b7a7bbc69bd64248f8ed636d3fd36607c7b5d5a.
   # redis-rb/redis-client: 773ff6284cd78167034ddce405baf3364ffedd5c.
   # byroot/megatest: aebecf133ee581aaa4565150aa2b88a5f9b9e4ed.
   @scratch @blank_setup @main_is_gem
   Scenario Outline: Retain development dependencies from standard and custom Gemfile groups
      - merge the repository Gemfile with gemspec runtime declarations
      - classify custom groups as development and test dependencies
      - retain internal requirements for the nested hiredis-client gem
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options          | value               |
         | rootdir          | <rootdir>           |
         | spec_type        | rpm                 |
         | maintainer.name  | Pavel Skrylev       |
         | maintainer.email | majioa@altlinux.org |
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains the lines:
         | BuildRequires: gem(<dependency>) >= <minimum> |
      And package "gem-<fixture>-devel" contains dependency lines:
         | Requires:      gem(<dependency>) >= <minimum> |
      And package "gem-<fixture>" does not require "<dependency>"
      And he acquires an "<fixture>" fixture spec for the baltix setup

      Examples:
         | fixture      | rootdir                        | dependency | minimum |
         | wasmtime     | features/fixtures/wasmtime     | rspec      | 3.13    |
         | redis-client | features/fixtures/redis-client | rubocop    | 0       |
         | megatest     | features/fixtures/megatest     | rubocop    | 1.21    |

   # redis/hiredis-rb: eb27295facd5473a54585e06a043bebf5c80bb5b.
   @scratch @blank_setup @main_is_gem
   Scenario: Keep hiredis development overrides aligned with build requirements and conflicts
      - widen upper bounds using available versions without raising source minimums
      - preserve the same dependency ranges across repeated spec updates
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                               |
         | rootdir            | features/fixtures/hiredis           |
         | available_gem_list | {minitest: 6.0, rake-compiler: 1.2} |
         | spec_type          | rpm                                 |
         | maintainer.name    | Pavel Skrylev                       |
         | maintainer.email   | majioa@altlinux.org                 |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "hiredis" fixture spec for the baltix setup
      And the generated spec contains the lines:
         | %ruby_use_gem_dependency minitest >= 5.5.1,minitest < 7           |
         | %ruby_use_gem_dependency rake-compiler >= 0.7.1,rake-compiler < 2 |
         | BuildRequires: gem(minitest) >= 5.5.1                             |
         | BuildConflicts: gem(minitest) >= 7                                |
         | BuildRequires: gem(rake-compiler) >= 0.7.1                        |
         | BuildConflicts: gem(rake-compiler) >= 2                           |
      And package "gem-hiredis-devel" contains dependency lines:
         | Requires:      gem(minitest) >= 5.5.1      |
         | Conflicts:     gem(minitest) >= 7          |
         | Requires:      gem(rake-compiler) >= 0.7.1 |
         | Conflicts:     gem(rake-compiler) >= 2     |
      And package "gem-hiredis" does not require "minitest"
      And package "gem-hiredis" does not require "rake-compiler"
      When the generated spec is refreshed 2 times
      Then the generated dependency sections match "gem.spec" from fixture "hiredis"

   # gitlab-sidekiq-fetcher 0.9.0 release; input spec from altlinux/specs.
   @policy2_0 @main_is_gem
   Scenario: Recompute gitlab-sidekiq-fetcher overrides without raising source minimums
      - replace historical macro constraints with current source and availability bounds
      - keep runtime and build conflicts aligned with the sidekiq macro
      Given blank space
      And a spec from fixture "gitlab-sidekiq-fetcher"
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                    |
         | rootdir            | features/fixtures/gitlab-sidekiq-fetcher |
         | available_gem_list | {sidekiq: 7.3.8, json: 2.10}             |
         | maintainer.name    | Pavel Skrylev                            |
         | maintainer.email   | majioa@altlinux.org                      |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "gitlab-sidekiq-fetcher" fixture spec for the baltix setup
      And the generated spec contains the lines:
         | %ruby_use_gem_dependency sidekiq >= 6.1,sidekiq < 8 |
         | BuildRequires: gem(sidekiq) >= 6.1                  |
         | BuildConflicts: gem(sidekiq) >= 8                   |
         | BuildRequires: gem(json) >= 2.5                     |
      And package "gem-gitlab-sidekiq-fetcher" contains dependency lines:
         | Requires:      gem(sidekiq) >= 6.1 |
         | Conflicts:     gem(sidekiq) >= 8   |
         | Requires:      gem(json) >= 2.5    |
      And the generated spec contains no override for "json"
      When the generated spec is refreshed 2 times
      Then the generated dependency sections match "gem.spec" from fixture "gitlab-sidekiq-fetcher"

   # knu/ruby-unf_ext: c72a36d0a5ea9fe3950611b0f289fc68a2595fcf.
   @scratch @blank_setup @main_is_gem
   Scenario Outline: Keep unf_ext unbounded requirements when available versions already satisfy them
      - preserve exclusive and inclusive source minimums
      - avoid redundant macros and artificial conflicts for unbounded source requirements
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                     |
         | rootdir            | features/fixtures/unf_ext |
         | available_gem_list | <available>               |
         | spec_type          | rpm                       |
         | maintainer.name    | Pavel Skrylev             |
         | maintainer.email   | majioa@altlinux.org       |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "unf_ext" fixture spec for the baltix setup
      And the generated spec contains no dependency override macros
      And the generated spec contains the lines:
         | BuildRequires: gem(rdoc) > 2.4.2           |
         | BuildRequires: gem(rake-compiler) >= 1.2.1 |
      And package "gem-unf-ext-devel" contains dependency lines:
         | Requires:      gem(rdoc) > 2.4.2           |
         | Requires:      gem(rake-compiler) >= 1.2.1 |
      When the generated spec is refreshed 2 times
      Then the generated dependency sections match "gem.spec" from fixture "unf_ext"

      Examples:
         | available                       |
         | {}                              |
         | {rdoc: 6.6, rake-compiler: 1.3} |

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
      Then the generated build prerequisites are:
         | rpm-macros-ruby setup-rb rake |
      And the generated spec contains the lines:
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
   Scenario: Migrate ucf from obsolete Ruby Policy 1.0 to 2.1
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
   Scenario: Migrate zip-container from obsolete Ruby Policy 1.0 to 2.1
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
   Scenario: Migrate kgio with Olddoc/Wrongdoc from obsolete Ruby Policy 1.0 to 2.1
      - use the default prefix and suffix because the main source is a gem at the repository root
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
   Scenario: Migrate rbvmomi from obsolete Ruby Policy 2.0 to 2.1 using available gem versions
      - blank packager
      - both gem dependencies are runtime and development
      - there is a dependency to ruby
      - migrate rpm-build-ruby to rpm-macros-ruby, setup-rb and rake
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
      And the generated build prerequisites are:
         | rpm-macros-ruby setup-rb rake |
      And the generated spec contains the lines:
         | %ruby_use_gem_dependency rake >= 10.5,rake < 16 |
         | BuildRequires: gem(rake) >= 10.5                |
         | BuildConflicts: gem(rake) >= 16                 |
      And package "gem-rbvmomi-devel" contains dependency lines:
         | Requires:      gem(rake) >= 10.5 |
         | Conflicts:     gem(rake) >= 16   |

   @policy2_0 @release_change @main_is_gem
   Scenario: Migrate rspec-support from obsolete Ruby Policy 2.0 to 2.1
      - retain the gem version and skip the devel package
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
   Scenario: Migrate parser from obsolete Ruby Policy 2.0 to 2.1
      - retain the gem version
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

   @scratch @index_gemspec @blank_setup @main_is_gem
   Scenario Outline: Apply the Spec actor to setup for turn gem to blank setup
      - blank setup
      - blank packager
      - interpret the original 4~ requirement as >= 4 and < 5
      - widen the upper bound only when the available list explicitly requests it
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                  |
         | rootdir            | features/fixtures/turn |
         | available_gem_list | <available>            |
         | spec_type          | rpm                    |
         | maintainer.name    | Pavel Skrylev          |
         | maintainer.email   | majioa@altlinux.org    |
      Then the source "turn" dependency "minitest" has version compatibility:
         | version | allowed |
         | 3.9     | no      |
         | 4.0     | yes     |
         | 4.99    | yes     |
         | 5.0     | no      |
         | 5.14.0  | no      |
      When he applies "spec" actor to the baltix setup
      Then the generated spec matches "<expected>" from fixture "turn"

      Examples:
         | available          | expected    |
         | {}                 | source.spec |
         | {minitest: 5.14.0} | gem.spec    |

   @policy2_0 @gem_change
   Scenario: Migrate ruby-gnome2 from obsolete Ruby Policy pre-2.0 to 2.1
      - expand %summary in descriptions
      - pickup core version from common versions of submodules
      - proper detection of host rpm name line ruby-gnome2 not to rename to gem-gnome2
      - autoskip packages when they lost gemspecs like ruby-gnome2 *-no-gi packages or gem-vte defined in the original spec
      - since the top source is an application / group, so it doesn't parse a prefix, and use no prefix then
      - retain explicit header-package build requirements without the cairo-devel dependency cycle
      - preserve source dependency groups and runtime/development requirements across repeated updates
      - blank packager
      Given blank space
      And a spec from fixture "ruby-gnome2"
      When developer locks the time to "09.03.2022"
      And he sets the space options as:
         | options            | value                         |
         | rootdir            | features/fixtures/ruby-gnome2 |
         | available_gem_list | {minitest: 5.14.0}            |
         | spec_type          | rpm                           |
         | ignored_names      | [rake]                        |
         | maintainer.name    | Pavel Skrylev                 |
         | maintainer.email   | majioa@altlinux.org           |
      And the input spec has extra build requirements:
         | gem-cairo-headers-devel |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "ruby-gnome2" fixture spec for the baltix setup
      When the generated spec is refreshed 2 times
      Then the generated spec contains the lines:
         | BuildRequires: gem-cairo-headers-devel |
      And the generated dependency sections match "gem.spec" from fixture "ruby-gnome2"

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
   Scenario: Migrate ruby-debug-ide from obsolete Ruby Policy 2.0 to 2.1
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
