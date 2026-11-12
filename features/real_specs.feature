@actor @spec @gem @policy2_1 @regular_dependencies
Feature: Spec actor
   All generated specs target the Ruby Policy 2.1 draft currently under development.
   Tags @policy1_0 and @policy2_0 identify obsolete input policies being migrated.
   The obsolete rpm-build-ruby prerequisite is replaced by rpm-macros-ruby, setup-rb and rake.
   Historical migration snapshots explicitly exercise regular dependency bounds.
   Default redep and all-mode specs are covered in available_dependencies.feature.
   Shared availability checks also cover the behavior reported for rdoc and prometheus-client:
   source minimums are preserved, packaged gems receive no self-overrides,
   and RPM dependency tags remain consistent across repeated spec updates.

   # cucumber/multi_test 2.0.0; ALT 1.1.0 requires RubyGems >= 1.6.1.
   @policy2_1 @main_is_gem
   Scenario: Merge RubyGems requirements from current metadata and the previous spec
      - retain one strictest RubyGems minimum when upgrading multi_test
      - merge native package requirements through the same module as Ruby requirements
      - preserve the complete result through repeated updates
      Given blank space
      And a spec from fixture "multi-test"
      When developer locks the time to "11.11.2026"
      And he sets the space options as:
         | options            | value                          |
         | rootdir            | features/fixtures/multi-test   |
         | maintainer.name    | Pavel Skrylev                  |
         | maintainer.email   | majioa@altlinux.org            |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains each line once:
         | Requires:      ruby >= 3.2.0      |
         | Requires:      rubygems >= 3.2.8  |
      And the generated spec excludes the lines:
         | Requires:      rubygems >= 1.6.1  |
      And he acquires an "multi-test" fixture spec for the baltix setup
      When he keeps the generated spec for comparison
      And the generated spec is refreshed 2 times
      Then the generated spec is unchanged

   # ruby-rc4 upstream 0.1.5: requires Ruby >= 1.9.3 and RubyGems >= 1.8.11.
   @scratch @main_is_gem
   Scenario: Keep generated Ruby and RubyGems requirements stable on the first update
      - retain the position of merged interpreter requirements among other RPM requirements
      - keep the complete generated spec, every release and changelog unchanged
      - also cover the first-update revision churn found in Rails, RDoc and multi_test
      Given blank space
      When developer locks the time to "11.11.2026"
      And he sets the space options as:
         | options            | value                       |
         | rootdir            | features/fixtures/ruby-rc4  |
         | maintainer.name    | Pavel Skrylev               |
         | maintainer.email   | majioa@altlinux.org         |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "ruby-rc4" fixture spec for the baltix setup
      When he keeps the generated spec for comparison
      And the generated spec is refreshed 2 times
      Then the generated spec is unchanged

   # chef/chef v19.4.12 kitchen-tests/Gemfile; reuse the existing minimal Chef metadata.
   @scratch @main_is_gem @temporary_project
   Scenario: Fill missing Gemfile subpackage summaries without replacing date versions
      - retain the repository root while importing the nested upstream Gemfile
      - inherit the main summary while a subproject without a version uses YYYYMMDD
      - retain an already packaged date version when refreshing on a later day
      - use a single packaging prefix for the nested Gemfile development package
      - keep every release and the whole generated spec unchanged through updates
      Given blank space
      When developer locks the time to "11.11.2026"
      And he imports fixture "chef" with the "chef-kitchen-tests" Gemfile at "kitchen-tests/Gemfile"
      And he sets the space options as:
         | options            | value                 |
         | maintainer.name    | Pavel Skrylev         |
         | maintainer.email   | majioa@altlinux.org   |
      And he applies "spec" actor to the baltix setup
      Then package "kitchen-tests" inherits the main summary
      And the generated spec has no gem dependencies named:
         | kitchen-tests   |
      And package "gem-chef" contains dependency lines:
         | Version:       19.4.12   |
      And package "kitchen-tests" contains dependency lines:
         | Version:       20261111  |
      And package "gem-kitchen-tests-devel" contains dependency lines:
         | Version:       20261111                       |
         | Requires:      kitchen-tests = 20261111-alt1  |
      And he acquires an "chef-kitchen-tests" fixture spec for the baltix setup
      When he keeps the generated spec for comparison
      And developer locks the time to "12.11.2026"
      And the generated spec is refreshed 2 times
      Then the generated spec is unchanged
      And package "kitchen-tests" inherits the main summary
      And package "kitchen-tests" contains dependency lines:
         | Version:       20261111  |
      And package "gem-kitchen-tests-devel" contains dependency lines:
         | Version:       20261111  |

   # googleapis/gapic-generator-ruby 58a40fa: shared/Gemfile, no base summary.
   @scratch @summaryless_gemfile
   Scenario: Keep auxiliary summaries stable when a Gemfile has no base summary
      - retain the repository root and original shared dependency Gemfile
      - render the development label once when neither source nor host has a summary
      - retain declared Gemfile dependencies without inventing a gem for the repository wrapper
      - preserve the full spec, revision and descriptions through repeated updates
      Given blank space
      When developer locks the time to "11.11.2026"
      And he sets the space options as:
         | options            | value                                   |
         | rootdir            | features/fixtures/gapic-generator-ruby  |
         | maintainer.name    | Pavel Skrylev                           |
         | maintainer.email   | majioa@altlinux.org                     |
      And he applies "spec" actor to the baltix setup
      Then package "shared-devel" contains dependency lines:
         | Summary:       development package   |
      And the generated spec has no gem dependencies named:
         | gapic-generator-ruby  |
      And package "shared" contains dependency lines:
         | Requires:      gem(gapic-generator) >= 0   |
         | Requires:      gem(grpc-tools) >= 1.60.0   |
      And he acquires an "gapic-generator-ruby" fixture spec for the baltix setup
      When he keeps the generated spec for comparison
      And the generated spec is refreshed 2 times
      Then the generated spec is unchanged
      And package "shared-devel" contains dependency lines:
         | Summary:       development package   |

   # chef/chef v19.4.12; ALT gem-chef 19.4.12-alt1.1, altlinux/specs 4d2273b2.
   @policy2_1 @main_is_gem
   Scenario: Update Chef together with its component gems and service package
      - retain exact internal requirements for chef-config, chef-utils and chef-bin
      - preserve service installation commands, configuration ownership and scriptlets
      - exclude the Windows-only gemspec and keep the repository root unchanged
      Given blank space
      And a spec from fixture "chef"
      When developer locks the time to "10.11.2026"
      And he sets the space options as:
         | options            | value                    |
         | rootdir            | features/fixtures/chef   |
         | maintainer.name    | Pavel Skrylev            |
         | maintainer.email   | majioa@altlinux.org      |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the main source is the "chef" gem
      And the main source metadata file is "chef.gemspec"
      And the project root remains the "chef" fixture
      And the generated package names are unique
      And the generated spec preserves the input packaging sections for package "chef"
      And internal gem requirements equal their provided versions without conflicts
      And package "gem-chef" contains dependency lines:
         | Release:       alt1.2                      |
         | Provides:      gem(chef) = 19.4.12         |
         | Requires:      gem(chef-config) = 19.4.12  |
         | Requires:      gem(chef-utils) = 19.4.12   |
         | Requires:      gem(ffi-yajl) > 3.0.0       |
         | Conflicts:     gem(ffi-yajl) >= 4.0        |
      And the project dependencies exclude:
         | name         |
         | win32-api    |
         | win32-event  |
         | wmi-lite     |
      And he acquires an "chef" fixture spec for the baltix setup
      When the generated spec is refreshed 2 times
      Then the generated dependency sections match "gem.spec" from fixture "chef"
      And the generated spec preserves the input packaging sections for package "chef"
      And internal gem requirements equal their provided versions without conflicts

   # rmosolgo/graphql-ruby dca54e3cf68b; the C parser declares graphql >= 2.2.10.
   @policy2_1 @main_is_gem
   Scenario: Bind GraphQL C parser requirements to the gem provided by this spec
      - replace the loose internal minimum with the exact generated GraphQL capability
      - ignore availability overrides for gems provided by the same spec
      - omit conflicts on gems supplied by this spec through repeated updates
      - rebuild dependencies and their phases from current metadata rather than old RPM tags
      - merge the historical Ruby minimum into the stricter gemspec requirement
      Given blank space
      And a spec from fixture "graphql"
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                       |
         | rootdir            | features/fixtures/graphql   |
         | available_gem_list | {graphql: '99.0.0'}         |
         | maintainer.name    | Pavel Skrylev               |
         | maintainer.email   | majioa@altlinux.org         |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then package "gem-graphql" contains dependency lines:
         | Provides:      gem(graphql) = 2.4.8  |
         | Requires:      ruby >= 2.7.0         |
      And the generated spec excludes the lines:
         | Requires:      ruby >= 2.4.0   |
      And the generated spec has no gem dependencies named:
         | capybara           |
         | puma               |
         | rails              |
         | selenium-webdriver |
         | webdrivers         |
         | listen             |
         | parser             |
      And the check build requirements include:
         | BuildRequires: gem(rake) >= 0     |
         | BuildRequires: gem(rubocop) >= 0  |
         | BuildRequires: gem(minitest) >= 0 |
      And package "gem-graphql-c-parser" contains dependency lines:
         | Requires:      gem(graphql) = 2.4.8  |
      And the generated spec contains no override for "graphql"
      And internal gem requirements equal their provided versions without conflicts
      And he acquires an "graphql" fixture spec for the baltix setup
      When the generated spec is refreshed 2 times
      Then the generated dependency sections match "gem.spec" from fixture "graphql"
      And internal gem requirements equal their provided versions without conflicts
      And package "gem-graphql-c-parser" contains dependency lines:
         | Requires:      gem(graphql) = 2.4.8  |

   # Passenger 3a958d427e6a, ALT gem-passenger spec from altlinux/specs 4d2273b2.
   @policy2_1 @main_is_gem
   Scenario: Preserve Passenger shell-expanded RPM dependency declarations
      - retain the Apache build requirement as one expression without evaluating it
      - keep the expression intact in generated build and devel dependency tags
      - retain the declaration after repeated spec updates
      - retain the stricter gemspec Ruby minimum even when Gemfile is weaker
      Given blank space
      And a spec from fixture "passenger"
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                       |
         | rootdir            | features/fixtures/passenger |
         | maintainer.name    | Pavel Skrylev               |
         | maintainer.email   | majioa@altlinux.org         |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains the lines:
         | BuildRequires: %(eval echo %apache2_apr_buildreq)                        |
         | BuildRequires: apache2-devel >= 2.2.5                                    |
         | Requires:      ruby >= 2.5.9                                             |
         | %ruby_ignore_path_tokens dev,build,agent,cxx_supportlib,schema_printer   |
      And the generated spec excludes the lines:
         | %ruby_ignore_names _path_tokens   |
      And package "gem-passenger-devel" contains dependency lines:
         | Requires:      %(eval echo %apache2_apr_buildreq)   |
      And he acquires an "passenger" fixture spec for the baltix setup
      When the generated spec is refreshed 2 times
      Then the generated dependency sections match "gem.spec" from fixture "passenger"
      And the generated spec excludes the lines:
         | %ruby_ignore_names _path_tokens   |

   # ai/autoprefixer-rails 10.4.19.0; ALT gear b5d38f9ba56b197f31a2b733e07fc8f212761dca.
   @scratch @main_is_gem
   Scenario: Remove a plain gem-name capability imported from a packaged spec
      - keep the typed gem capability and its packaged version
      - remove the redundant plain RPM alias already present in the input
      - retain runtime bounds and keep the result stable through repeated updates
      Given blank space
      And a spec from fixture "autoprefixer-rails"
      When developer locks the time to "10.11.2026"
      And he sets the space options as:
         | options            | value                                |
         | rootdir            | features/fixtures/autoprefixer-rails |
         | maintainer.name    | Pavel Skrylev                        |
         | maintainer.email   | majioa@altlinux.org                  |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains each line once:
         | Provides:      gem(autoprefixer-rails) = 10.4.19.0  |
      And the generated spec excludes the lines:
         | Provides:      autoprefixer-rails = %EVR   |
      And package "gem-autoprefixer-rails" contains dependency lines:
         | Requires:      gem(execjs) >= 2   |
         | Conflicts:     gem(execjs) >= 3   |
      And he acquires an "autoprefixer-rails" fixture spec for the baltix setup
      When the generated spec is refreshed 2 times
      Then the generated spec matches "gem.spec" from fixture "autoprefixer-rails"

   @scratch @main_is_gem @migrated_gem_alias
   Scenario: Rename a legacy gem RPM without creating a plain gem-name capability
      - retain the typed gem capability and obsolete the previous RPM name
      - do not recreate a forbidden alias while migrating an unprefixed package
      - keep the complete spec unchanged through subsequent updates
      Given blank space
      And a spec from fixture "autoprefixer-rails"
      When the input spec is named "autoprefixer-rails"
      And developer locks the time to "10.11.2026"
      And he sets the space options as:
         | options            | value                                |
         | rootdir            | features/fixtures/autoprefixer-rails |
         | maintainer.name    | Pavel Skrylev                        |
         | maintainer.email   | majioa@altlinux.org                  |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains each line once:
         | Name:          gem-autoprefixer-rails               |
         | Provides:      gem(autoprefixer-rails) = 10.4.19.0  |
         | Obsoletes:     autoprefixer-rails < %EVR            |
      And the generated spec excludes the lines:
         | Provides:      autoprefixer-rails = %EVR   |
      When he keeps the generated spec for comparison
      And the generated spec is refreshed 2 times
      Then the generated spec is unchanged

   # chef/license_scout v2.6.10, b7fbe3c; retain one matching gemspec from spec/fixtures.
   @scratch @blank_setup @main_is_gem
   Scenario: Keep matching test fixture gems out of generated source packages
      - keep ignored fixture sources disabled even when a runtime dependency matches
      - retain the external runtime requirement rather than packaging its test copy
      - keep exclusions stable through repeated spec updates
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                             |
         | rootdir            | features/fixtures/license-scout   |
         | spec_type          | rpm                               |
         | maintainer.name    | Pavel Skrylev                     |
         | maintainer.email   | majioa@altlinux.org               |
      Then source "mixlib-shellout" has status "disabled"
      When he applies "spec" actor to the baltix setup
      Then he acquires an "license-scout" fixture spec for the baltix setup
      And the generated library package names are:
         | gem-license-scout  |
      And package "gem-license-scout" contains dependency lines:
         | Requires:      gem(mixlib-shellout) >= 2.2 |
         | Conflicts:     gem(mixlib-shellout) >= 4.0 |
      When the generated spec is refreshed 2 times
      Then source "mixlib-shellout" has status "disabled"
      And the generated library package names are:
         | gem-license-scout  |
      And the generated dependency sections match "gem.spec" from fixture "license-scout"

   @scratch @blank_setup @main_is_gem
   Scenario: Preserve explicit source path settings through generated RPM macros
      - let explicit path settings override the default fixture exclusion
      - preserve ruby_ignore_path_tokens and ruby_regard_path_tokens when options are cleared
      - reapply the stored lists during subsequent source imports
      Given blank space
      When he sets the space options as:
         | options               | value                             |
         | rootdir               | features/fixtures/license-scout   |
         | regarded_path_tokens  | [spec]                            |
         | ignored_path_tokens   | [bench]                           |
      And he adds the case-insensitive ignored path pattern "scratch"
      Then source "mixlib-shellout" has status "valid"
      When he applies "spec" actor to the baltix setup
      Then the generated library package names are:
         | gem-license-scout     |
         | gem-mixlib-shellout   |
      And the generated spec contains each line once:
         | %ruby_ignore_path_tokens bench,[^/]*(?i-mx:scratch)[^/]*  |
         | %ruby_regard_path_tokens spec                             |
      When the generated spec is refreshed without path options
      Then source "mixlib-shellout" has status "valid"
      And a source at "bench/example.gemspec" is disabled
      And a source at "custom-SCRATCH-dir/example.gemspec" is disabled
      And the generated spec contains each line once:
         | %ruby_ignore_path_tokens bench,[^/]*(?i-mx:scratch)[^/]*  |
         | %ruby_regard_path_tokens spec                             |
      When the generated spec is refreshed 2 times
      Then source "mixlib-shellout" has status "valid"
      And a source at "bench/example.gemspec" is disabled
      And a source at "custom-SCRATCH-dir/example.gemspec" is disabled
      And the generated spec contains each line once:
         | %ruby_ignore_path_tokens bench,[^/]*(?i-mx:scratch)[^/]*  |
         | %ruby_regard_path_tokens spec                             |

   # brianmario/fast_xs, ALT gear 8a75f12; upstream declares version 0.8.0.
   @scratch @blank_setup @main_is_gem
   Scenario: Preserve native extension declarations after legacy Hoe metadata assignments
      - accept gemspec attribute writers and legacy publishing settings in the Hoe block
      - finish importing spec_extras with both dynamically discovered extensions
      - keep native extension ownership and architecture through repeated updates
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                       |
         | rootdir            | features/fixtures/fast-xs   |
         | spec_type          | rpm                         |
         | maintainer.name    | Pavel Skrylev               |
         | maintainer.email   | majioa@altlinux.org         |
      Then the main source is the "fast_xs" gem
      And source "fast_xs" declares native extensions:
         | ext/fast_xs/extconf.rb         |
         | ext/fast_xs_extra/extconf.rb   |
      When he applies "spec" actor to the baltix setup
      Then he acquires an "fast-xs" fixture spec for the baltix setup
      And the generated spec contains each line once:
         | %ruby_gemextdir |
      And the generated package build architectures are:
         | package      | build_arch   |
         | gem-fast-xs  |              |
      When the generated spec is refreshed 2 times
      Then source "fast_xs" declares native extensions:
         | ext/fast_xs/extconf.rb         |
         | ext/fast_xs_extra/extconf.rb   |
      And the generated spec contains each line once:
         | %ruby_gemextdir |
      And the generated package build architectures are:
         | package      | build_arch   |
         | gem-fast-xs  |              |

   # ruby-next/ruby-next 1.2.0; ALT gem-ruby-next b6cb98d (1.2.0-alt1).
   @scratch @main_is_gem
   Scenario: Preserve runtime dependencies on a gem packaged in the same spec
      - retain ruby-next's exact runtime requirement on its ruby-next-core subpackage
      - do not replace packaged gem versions with versions from the available list
      - keep internal runtime requirements through repeated spec updates
      Given blank space
      And a spec from fixture "ruby-next"
      When developer locks the time to "09.11.2026"
      And he sets the space options as:
         | options            | value                       |
         | rootdir            | features/fixtures/ruby-next |
         | available_gem_list | {'ruby-next-core': '2.0.0'} |
         | maintainer.name    | Pavel Skrylev               |
         | maintainer.email   | majioa@altlinux.org         |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "ruby-next" fixture spec for the baltix setup
      And the main source is the "ruby-next" gem
      And package "gem-ruby-next" contains dependency lines:
         | Requires:      gem(ruby-next-core) = 1.2.0 |
      And the generated spec contains no override for "ruby-next-core"
      And the generated package names are unique
      When the generated spec is refreshed 2 times
      Then package "gem-ruby-next" contains dependency lines:
         | Requires:      gem(ruby-next-core) = 1.2.0 |
      And the generated spec contains no override for "ruby-next-core"
      And the generated dependency sections match "gem.spec" from fixture "ruby-next"

   # datamapper/do: 16564e6dba587e92e41aba376b46ef765f3bffea.
   # Retain the core gem, one native driver and repository-level build metadata.
   @scratch @blank_setup
   Scenario: Select the nested data_objects gem through the repository's RPM name
      - treat the data-objects repository name as an alias of data_objects
      - preserve the repository root and retain its shared build dependencies
      - package the core gem once, with its SQLite driver as a secondary
      - cover the runtime/development dependency separation also reported for byebug
      - inherit the target architecture for native drivers; blank build_arch means no BuildArch declaration
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                          |
         | rootdir            | features/fixtures/data-objects |
         | spec_type          | rpm                            |
         | maintainer.name    | Pavel Skrylev                  |
         | maintainer.email   | majioa@altlinux.org            |
      Then the main source is the "data_objects" gem
      And the project root remains the "data-objects" fixture
      When he applies "spec" actor to the baltix setup
      Then stringified property "has_compilables?" of space's spec is "false"
      And he acquires an "data-objects" fixture spec for the baltix setup
      And the generated package names are unique
      And the generated spec contains the lines:
         | Name:          gem-data-objects            |
         | Version:       0.10.17                     |
         | BuildRequires: gem(rake-compiler) >= 0.7   |
         | BuildConflicts: gem(rake-compiler) >= 1    |
      And package "gem-data-objects" contains dependency lines:
         | Requires:      gem(addressable) >= 2.1  |
         | Conflicts:     gem(addressable) >= 3    |
      And package "gem-do-sqlite3" contains dependency lines:
         | Requires:      gem(data_objects) = 0.10.17 |
      And the generated package build architectures are:
         | package               | build_arch   |
         | gem-data-objects      |              |
         | gem-do-sqlite3        |              |
         | gem-do-sqlite3-doc    | noarch       |
         | gem-do-sqlite3-devel  | noarch       |
      When the generated spec is refreshed 2 times
      Then the main source is the "data_objects" gem
      And the project root remains the "data-objects" fixture
      And the generated package names are unique
      And the generated dependency sections match "gem.spec" from fixture "data-objects"
      And the generated package build architectures are:
         | package               | build_arch   |
         | gem-data-objects      |              |
         | gem-do-sqlite3        |              |
         | gem-do-sqlite3-doc    | noarch       |
         | gem-do-sqlite3-devel  | noarch       |

   # Published glu/glut 8.3.0 and kpeg 1.3.3 source packages from RubyGems.
   # Hoe reads the retained manifests, readmes and histories while importing Rakefiles.
   @scratch @blank_setup @main_is_gem
   Scenario Outline: Preserve complete development dependencies from Hoe and gemspec sources
      - import Hoe spec_extras assignments before collecting development dependencies
      - isolate each project's metadata from previously imported Rakefiles
      - keep installed Hoe plugins isolated from the metadata adapter across imports
      - keep development requirements and upper bounds out of the runtime package
      - retain dependency ranges after parsing and updating the generated spec
      Given blank space
      When developer locks the time to "13.12.2022"
      And the "fast-xs" fixture has already been imported
      And the "<previous>" fixture has already been imported
      And he sets the space options as:
         | options            | value                 |
         | rootdir            | <rootdir>             |
         | spec_type          | rpm                   |
         | maintainer.name    | Pavel Skrylev         |
         | maintainer.email   | majioa@altlinux.org   |
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
         | fixture   | previous  | rootdir                  | dependency      | minimum   | upper  |
         | glu       | glut      | features/fixtures/glu    | rake-compiler   | 1.0       | 2      |
         | glut      | glu       | features/fixtures/glut   | mini_portile2   | 2.1       | 3      |
         | kpeg      | glu       | features/fixtures/kpeg   | rdoc            | 4.0       | 7      |

   # rubyworks/facets 3.1.0, revision 86e44b354b0008c32bebb305fae7b1848cfd13a6.
   # The manifest is reduced to files retained for importing the fixture.
   @scratch @blank_setup @main_is_gem
   Scenario: Keep facets index test dependencies out of runtime requirements
      - preserve dependency groups and complete version requirements from the index
      - agree with the original gemspec declarations
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                    |
         | rootdir            | features/fixtures/facets |
         | spec_type          | rpm                      |
         | maintainer.name    | Pavel Skrylev            |
         | maintainer.email   | majioa@altlinux.org      |
      Then source "facets" has dependency declarations:
         | name         | type         | requirement  |
         | guard        | development  | >= 0         |
         | lemon        | development  | >= 0         |
         | qed          | development  | >= 0         |
         | rake         | development  | >= 0         |
         | rubytest-cli | development  | >= 0         |
         | simplecov    | development  | >= 0         |
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
      - avoid a global noarch declaration when the main gem or a nested gem has native extensions
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                 |
         | rootdir            | <rootdir>             |
         | spec_type          | rpm                   |
         | maintainer.name    | Pavel Skrylev         |
         | maintainer.email   | majioa@altlinux.org   |
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains the lines:
         | BuildRequires: gem(<dependency>) >= <minimum> |
      And package "gem-<fixture>-devel" contains dependency lines:
         | Requires:      gem(<dependency>) >= <minimum> |
      And package "gem-<fixture>" does not require "<dependency>"
      And the generated package build architectures are:
         | package         | build_arch   |
         | gem-<fixture>   | <build_arch> |
      And stringified property "has_compilables?" of space's spec is "<local_compilable>"
      And he acquires an "<fixture>" fixture spec for the baltix setup

      Examples:
         | fixture      | rootdir                        | dependency   | minimum   | build_arch   | local_compilable   |
         | wasmtime     | features/fixtures/wasmtime     | rspec        | 3.13      |              | true               |
         | redis-client | features/fixtures/redis-client | rubocop      | 0         |              | false              |
         | megatest     | features/fixtures/megatest     | rubocop      | 1.21      | noarch       | false              |

   # flavorjones/hoe-bundler 5bc5b14; ALT gem-hoe-bundler 1.5.0.4-alt1.1.
   @policy2_1 @main_is_gem @packaged_version_floor
   Scenario: Preserve a packaged version above the current Hoe source version
      - keep 1.5.0.4 when the source reports the older 1.5.0 release
      - generate a version override so gem metadata agrees with RPM Provides
      - retain the same versions and complete spec through repeated updates
      Given blank space
      And a spec from fixture "hoe-bundler"
      When developer locks the time to "11.11.2026"
      And he sets the space options as:
         | options            | value                          |
         | rootdir            | features/fixtures/hoe-bundler  |
         | maintainer.name    | Pavel Skrylev                  |
         | maintainer.email   | majioa@altlinux.org            |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains each line once:
         | %ruby_use_gem_version hoe-bundler:1.5.0.4  |
         | Provides:      gem(hoe-bundler) = 1.5.0.4  |
      And package "gem-hoe-bundler" contains dependency lines:
         | Version:       1.5.0.4   |
         | Release:       alt1.2    |
      And he acquires an "hoe-bundler" fixture spec for the baltix setup
      When he keeps the generated spec for comparison
      And the generated spec is refreshed 2 times
      Then the generated spec is unchanged

   # redis/hiredis-rb: eb27295facd5473a54585e06a043bebf5c80bb5b.
   @scratch @blank_setup @main_is_gem
   Scenario: Keep hiredis development overrides aligned with build requirements and conflicts
      - widen upper bounds using available versions without raising source minimums
      - preserve the same dependency ranges across repeated spec updates
      - retain the packaged 0.6.3.14.1 version and its explicit version macro
      Given blank space
      And a spec from fixture "hiredis"
      When developer locks the time to "09.11.2026"
      And he sets the space options as:
         | options            | value                                |
         | rootdir            | features/fixtures/hiredis            |
         | available_gem_list | {minitest: 6.0, rake-compiler: 1.2}  |
         | spec_type          | rpm                                  |
         | maintainer.name    | Pavel Skrylev                        |
         | maintainer.email   | majioa@altlinux.org                  |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains each line once:
         | %ruby_use_gem_version hiredis:0.6.3.14.1   |
         | Provides:      gem(hiredis) = 0.6.3.14.1   |
      And the generated spec excludes the lines:
         | Provides:      hiredis = %EVR  |
      And he acquires an "hiredis" fixture spec for the baltix setup
      And the generated spec contains the lines:
         | %ruby_use_gem_dependency minitest >= 5.5.1,minitest < 7            |
         | %ruby_use_gem_dependency rake-compiler >= 0.7.1,rake-compiler < 2  |
         | BuildRequires: gem(minitest) >= 5.5.1                              |
         | BuildConflicts: gem(minitest) >= 7                                 |
         | BuildRequires: gem(rake-compiler) >= 0.7.1                         |
         | BuildConflicts: gem(rake-compiler) >= 2                            |
      And package "gem-hiredis-devel" contains dependency lines:
         | Requires:      gem(minitest) >= 5.5.1      |
         | Conflicts:     gem(minitest) >= 7          |
         | Requires:      gem(rake-compiler) >= 0.7.1 |
         | Conflicts:     gem(rake-compiler) >= 2     |
      And package "gem-hiredis" does not require "minitest"
      And package "gem-hiredis" does not require "rake-compiler"
      When the generated spec is refreshed 2 times
      Then the generated spec matches "gem.spec" from fixture "hiredis"

   # gitlab-sidekiq-fetcher 0.9.0 release; input spec from altlinux/specs.
   @scratch @main_is_gem
   Scenario Outline: Increment only the spec revision when a generated package changes
      - preserve the packaged module version
      - keep release and prerelease revision components separate
      - update the changelog and every subpackage revision together
      - leave the full spec unchanged on subsequent identical refreshes
      Given blank space
      And a spec from fixture "hiredis"
      When developer locks the time to "09.11.2026"
      And he sets the space options as:
         | options            | value                       |
         | rootdir            | features/fixtures/hiredis   |
         | maintainer.name    | Pavel Skrylev               |
         | maintainer.email   | majioa@altlinux.org         |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      And the generated input has release "<before>"
      And he sets the space option "uri" to "https://example.org/hiredis"
      And the generated spec is refreshed 1 times
      Then every generated package and the latest changelog entry have release "<after>"
      When he keeps the generated spec for comparison
      And the generated spec is refreshed 2 times
      Then the generated spec is unchanged

      Examples:
         | before    | after     |
         | alt1      | alt1.1    |
         | alt1.1    | alt1.2    |
         | alt0.1    | alt0.1.1  |
         | alt0.1.1  | alt0.1.2  |

   @policy2_0 @main_is_gem
   Scenario: Recompute gitlab-sidekiq-fetcher overrides without raising source minimums
      - replace historical macro constraints with current source and availability bounds
      - keep runtime and build conflicts aligned with the sidekiq macro
      Given blank space
      And a spec from fixture "gitlab-sidekiq-fetcher"
      When developer locks the time to "09.11.2026"
      And he sets the space options as:
         | options            | value                                      |
         | rootdir            | features/fixtures/gitlab-sidekiq-fetcher   |
         | available_gem_list | {sidekiq: 7.3.8, json: 2.10}               |
         | maintainer.name    | Pavel Skrylev                              |
         | maintainer.email   | majioa@altlinux.org                        |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "gitlab-sidekiq-fetcher" fixture spec for the baltix setup
      And the generated spec contains the lines:
         | %ruby_use_gem_dependency sidekiq >= 6.1,sidekiq < 8 |
         | BuildRequires: gem(sidekiq) >= 6.1                  |
         | BuildConflicts: gem(sidekiq) >= 8                   |
         | BuildRequires: gem(json) >= 2.5                     |
      And package "gem-gitlab-sidekiq-fetcher" contains dependency lines:
         | Requires:      gem(sidekiq) >= 6.1   |
         | Conflicts:     gem(sidekiq) >= 8     |
         | Requires:      gem(json) >= 2.5      |
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
         | options            | value                       |
         | rootdir            | features/fixtures/unf_ext   |
         | available_gem_list | <available>                 |
         | spec_type          | rpm                         |
         | maintainer.name    | Pavel Skrylev               |
         | maintainer.email   | majioa@altlinux.org         |
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
         | available                         |
         | {}                                |
         | {rdoc: 6.6, rake-compiler: 1.3}   |

   @available_gem_list
   Scenario: Generate a complete mustermann spec with adjusted dependency requirements
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                      |
         | rootdir            | features/fixtures/mustermann               |
         | available_gem_list | {hansi: '1.0.0', ruby2_keywords: '0.1.0'}  |
         | packager.name      | Ruby Maintainers Team                      |
         | packager.email     | ruby@packages.altlinux.org                 |
         | maintainer.name    | Pavel Skrylev                              |
         | maintainer.email   | majioa@altlinux.org                        |
      And he applies "spec" actor to the baltix setup
      Then the generated spec matches "available.spec" from fixture "mustermann"

   @available_gem_list
   Scenario Outline: Keep RPM requirements aligned with override macros during updates
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                      |
         | rootdir            | features/fixtures/mustermann               |
         | available_gem_list | {hansi: '1.0.0', ruby2_keywords: '0.1.0'}  |
         | packager.name      | Ruby Maintainers Team                      |
         | packager.email     | ruby@packages.altlinux.org                 |
         | maintainer.name    | Pavel Skrylev                              |
         | maintainer.email   | majioa@altlinux.org                        |
      And he applies "spec" actor to the baltix setup
      And the generated spec is refreshed <updates> times
      Then the generated build prerequisites are:
         | rpm-macros-ruby setup-rb rake  |
      And the generated spec contains the lines:
         | %ruby_use_gem_dependency hansi >= 0.2.0,hansi < 2                     |
         | %ruby_use_gem_dependency ruby2_keywords >= 0.0.1,ruby2_keywords < 1   |
         | BuildRequires: gem(hansi) >= 0.2.0                                    |
         | BuildConflicts: gem(hansi) >= 2                                       |
         | BuildRequires: gem(ruby2_keywords) >= 0.0.1                           |
         | BuildConflicts: gem(ruby2_keywords) >= 1                              |
      And package "gem-mustermann" does not require "hansi"
      And package "gem-mustermann" contains dependency lines:
         | Requires:      gem(ruby2_keywords) >= 0.0.1   |
         | Conflicts:     gem(ruby2_keywords) >= 1       |
      And package "gem-mustermann-contrib" contains dependency lines:
         | Requires:      gem(hansi) >= 0.2.0      |
         | Conflicts:     gem(hansi) >= 2          |
         | Requires:      gem(mustermann) = 2.0.2  |

      And the generated dependency sections match "available.spec" from fixture "mustermann"

      Examples:
         | updates   |
         | 0         |
         | 1         |
         | 2         |

   @scratch @blank_setup
   Scenario: Generate a spec from the root of the mustermann repository
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                          |
         | rootdir            | features/fixtures/mustermann   |
         | spec_type          | rpm                            |
         | packager.name      | Ruby Maintainers Team          |
         | packager.email     | ruby@packages.altlinux.org     |
         | maintainer.name    | Pavel Skrylev                  |
         | maintainer.email   | majioa@altlinux.org            |
      Then the main source is the "mustermann" gem
      When he applies "spec" actor to the baltix setup
      Then he acquires an "mustermann" fixture spec for the baltix setup

   # bryanp/llhttp, ALT 60d6f26; preserve its existing gem-llhttp-ffi ignore entry.
   @scratch
   Scenario Outline: Preserve ignored names when updating modern and legacy specs
      - parse the full ignore macro name rather than treating its suffix as an entry
      - migrate old macro and build option forms to ruby_ignore_names
      - preserve the list through repeated updates of a nested native project
      - retain rake >= 13.0 from the FFI gemspec when other Gemfiles allow any version
      Given blank space
      And a spec from fixture "llhttp-ffi"
      When developer locks the time to "09.11.2026"
      And the input spec uses "<form>" for its ignore list
      And he sets the space options as:
         | options            | value                          |
         | rootdir            | features/fixtures/llhttp-ffi   |
         | maintainer.name    | Pavel Skrylev                  |
         | maintainer.email   | majioa@altlinux.org            |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "llhttp-ffi" fixture spec for the baltix setup
      And the parsed ignored names are:
         | gem-llhttp-ffi  |
      And the generated spec contains each line once:
         | %ruby_ignore_names gem-llhttp-ffi          |
         | %ruby_use_gem_version llhttp:0.6.1.16      |
         | %ruby_use_gem_version llhttp-ffi:0.5.1.16  |
         | BuildRequires: gem(rake) >= 13.0           |
         | BuildConflicts: gem(rake) >= 14            |
      When the generated spec is refreshed 2 times
      Then the parsed ignored names are:
         | gem-llhttp-ffi  |
      And the generated spec contains each line once:
         | %ruby_ignore_names gem-llhttp-ffi          |
         | %ruby_use_gem_version llhttp:0.6.1.16      |
         | %ruby_use_gem_version llhttp-ffi:0.5.1.16  |
         | BuildRequires: gem(rake) >= 13.0           |
         | BuildConflicts: gem(rake) >= 14            |

      Examples:
         | form         |
         | macro        |
         | legacy macro |
         | build option |

   # cucumber/common dd772f4: retain the two interdependent gemspecs and VERSION inputs.
   @scratch @documentation_source
   Scenario: Populate synthetic Cucumber repository metadata without borrowing a child title
      - keep the repository root while packaging its Gherkin and Messages gems
      - read the repository title and prose while skipping README badges
      - use the explicit repository origin rather than a component homepage
      - retain all metadata and unique package names through repeated updates
      Given blank space
      When developer locks the time to "12.11.2026"
      And he imports fixture "cucumber-common" with documentation paths:
         | README.md |
      And the repository README is:
         """
         [![CircleCI](https://circleci.com/gh/cucumber/common.svg)](https://circleci.com/gh/cucumber/common)

         # Cucumber Common Components

         This repo contains the libraries/modules for behaviour that's common between
         the various Cucumber implementations. These include:
         """
      And the repository origin is "https://github.com/cucumber/common.git"
      And he sets the space options as:
         | options            | value                 |
         | maintainer.name    | Pavel Skrylev         |
         | maintainer.email   | majioa@altlinux.org   |
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains each line once:
         | Summary:       Cucumber Common Components              |
         | Url:           https://github.com/cucumber/common      |
         | Vcs:           https://github.com/cucumber/common.git  |
      And the generated package names are unique
      And he acquires an "cucumber-common" fixture spec for the baltix setup
      When he keeps the generated spec for comparison
      And the generated spec is refreshed 2 times
      Then the generated spec is unchanged

   # ruby/rake 3f29d39: keep original metadata and its direct version import only.
   @scratch @main_is_gem @documentation_source @rake_manpages
   Scenario: Include the installed Rake manual in its executable package
      - discover doc/rake.1 through the same man tree used by setup-rb
      - assign the installed page to rake alongside its declared executable
      - keep one explicit page entry and a stable spec through repeated updates
      Given blank space
      When developer locks the time to "12.11.2026"
      And he sets the space options as:
         | options            | value                 |
         | maintainer.name    | Pavel Skrylev         |
         | maintainer.email   | majioa@altlinux.org   |
      And he imports fixture "rake" with documentation paths:
         | doc/rake.1   |
      And he applies "spec" actor to the baltix setup
      Then package "rake" contains file lines:
         | %_bindir/rake      |
         | %_mandir/rake.1*   |
      And the generated spec contains each line once:
         | %_mandir/rake.1*   |
      And he acquires an "rake" fixture spec for the baltix setup
      When he keeps the generated spec for comparison
      And the generated spec is refreshed 2 times
      Then the generated spec is unchanged

   @scratch @main_is_gem @documentation_source @rake_manpages
   Scenario Outline: Retain an existing Rake manual file entry when refreshing its spec
      - retain an existing active entry instead of adding a second owner
      - replace a commented-out declaration with an actual generated entry
      - keep executable and manual page ownership in the same package
      Given blank space
      And a spec from fixture "rake"
      When the input spec uses manual page file entry "<entry>"
      And developer locks the time to "12.11.2026"
      And he sets the space options as:
         | options            | value                 |
         | maintainer.name    | Pavel Skrylev         |
         | maintainer.email   | majioa@altlinux.org   |
      And he imports fixture "rake" with documentation paths:
         | doc/rake.1   |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then package "rake" contains file lines:
         | %_bindir/rake   |
         | <page>          |
      And the generated spec contains each line once:
         | <page> |
      And the generated manual page entries are:
         | <page> |
      When he keeps the generated spec for comparison
      And the generated spec is refreshed 2 times
      Then the generated spec is unchanged

      Examples:
         | entry                                      | page                                       |
         | %_mandir/rake.*                            | %_mandir/rake.*                            |
         | %{_mandir}/rake.1*                         | %{_mandir}/rake.1*                         |
         | %{_mandir}/rake.1.gz                       | %{_mandir}/rake.1.gz                       |
         | %{_mandir}/rake.1.*                        | %{_mandir}/rake.1.*                        |
         | %attr(0644, root, root) %{_mandir}/rake.1* | %attr(0644, root, root) %{_mandir}/rake.1* |
         | # %_mandir/rake.1*                         | %_mandir/rake.1*                           |

   # Compass 07ad85d with ALT 584eab7 version patch; recreate document paths in a temporary tree.
   @scratch @blank_setup @documentation_source
   Scenario: Keep nested Compass documentation paths relative to the repository root
      - preserve the repository root while importing the cli, core and import-once gems
      - import the full upstream dependency set independently of caller CI and PKG variables
      - qualify nested README and license entries with their source directories
      - retain the root-level shared license and valid paths through repeated updates
      - reuse the repository README.markdown when the main CLI gem has no README
      Given blank space
      When developer locks the time to "13.12.2022"
      And he imports fixture "compass" with documentation paths:
         | README.markdown          |
         | LICENSE.markdown         |
         | core/README.md           |
         | core/LICENSE.txt         |
         | import-once/README.md    |
         | import-once/LICENSE.txt  |
      And he sets the space options as:
         | options            | value                 |
         | spec_type          | rpm                   |
         | maintainer.name    | Pavel Skrylev         |
         | maintainer.email   | majioa@altlinux.org   |
      Then the main source is the "compass" gem
      When he applies "spec" actor to the baltix setup
      Then every generated documentation path exists in the repository root
      And the generated spec contains the lines:
         | %doc LICENSE.markdown README.markdown               |
         | %doc core/LICENSE.txt core/README.md                |
         | %doc import-once/LICENSE.txt import-once/README.md  |
      And he acquires an "compass" fixture spec for the baltix setup
      When the generated spec is refreshed 2 times
      Then every generated documentation path exists in the repository root
      And the generated documentation lines match "gem.spec" from fixture "compass"
      When the main source receives its own README
      And the generated spec is refreshed 1 times
      Then the generated spec contains the lines:
         | %doc LICENSE.markdown cli/README.md  |
      And the generated spec excludes the lines:
         | %doc LICENSE.markdown README.markdown   |
      And every generated documentation path exists in the repository root

   @scratch @blank_setup @main_is_gem
   Scenario: Generate a mixlib-shellout spec without inferred Windows dependencies
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                             |
         | rootdir            | features/fixtures/mixlib-shellout |
         | spec_type          | rpm                               |
         | packager.name      | Ruby Maintainers Team             |
         | packager.email     | ruby@packages.altlinux.org        |
         | maintainer.name    | Pavel Skrylev                     |
         | maintainer.email   | majioa@altlinux.org               |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "mixlib-shellout" fixture spec for the baltix setup

   # packethost/packet-rb, ALT 9d7354c; rdoc, sinatra and webmock use > and < together.
   @scratch @main_is_gem
   Scenario: Preserve valid intervals with exclusive lower and upper dependency bounds
      - keep strict source intervals instead of replacing them with an impossible < 0
      - emit the matching build and development requirements and conflicts
      - preserve the intervals through repeated spec updates
      Given blank space
      And a spec from fixture "packethost"
      When developer locks the time to "09.11.2026"
      And he sets the space options as:
         | options            | value                          |
         | rootdir            | features/fixtures/packethost   |
         | maintainer.name    | Pavel Skrylev                  |
         | maintainer.email   | majioa@altlinux.org            |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "packethost" fixture spec for the baltix setup
      And the generated spec contains each line once:
         | BuildRequires: gem(rdoc) > 4         |
         | BuildConflicts: gem(rdoc) >= 7       |
         | BuildRequires: gem(sinatra) > 1.4    |
         | BuildConflicts: gem(sinatra) >= 3    |
         | BuildRequires: gem(webmock) > 1.20   |
         | BuildConflicts: gem(webmock) >= 4    |
      And package "gem-packethost-devel" contains dependency lines:
         | Requires:      gem(rdoc) > 4         |
         | Conflicts:     gem(rdoc) >= 7        |
         | Requires:      gem(sinatra) > 1.4    |
         | Conflicts:     gem(sinatra) >= 3     |
         | Requires:      gem(webmock) > 1.20   |
         | Conflicts:     gem(webmock) >= 4     |
      When the generated spec is refreshed 2 times
      Then the generated dependency sections match "gem.spec" from fixture "packethost"

   @scratch @blank_setup @main_is_gem
   Scenario: Generate a spec for rails-html-sanitizer with Gemfile development dependencies
      Given blank space
      When developer locks the time to "13.12.2022"
      And he sets the space options as:
         | options            | value                                   |
         | rootdir            | features/fixtures/rails-html-sanitizer  |
         | spec_type          | rpm                                     |
         | packager.name      | Ruby Maintainers Team                   |
         | packager.email     | ruby@packages.altlinux.org              |
         | maintainer.name    | Pavel Skrylev                           |
         | maintainer.email   | majioa@altlinux.org                     |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "rails-html-sanitizer" fixture spec for the baltix setup

   # jfelchner/ruby-progressbar, ALT 0a5d8aa; keep one Gemfile variant that imports ruby-progressbar first.
   @scratch @main_is_gem
   Scenario: Prefer the literal progressbar gem over a legacy ruby package alias
      - select progressbar for the input RPM name gem-progressbar
      - retain ruby-progressbar as a distinct source with its own gem provide
      - preserve both packages through repeated spec updates
      Given blank space
      And a spec from fixture "progressbar"
      When developer locks the time to "09.11.2026"
      And he sets the space options as:
         | options            | value                          |
         | rootdir            | features/fixtures/progressbar  |
         | maintainer.name    | Pavel Skrylev                  |
         | maintainer.email   | majioa@altlinux.org            |
      And he loads the spec into the space
      Then the main source is the "progressbar" gem
      When he applies "spec" actor to the baltix setup
      Then he acquires an "progressbar" fixture spec for the baltix setup
      And the generated package names are unique
      And package "gem-progressbar" contains dependency lines:
         | Provides:      gem(progressbar) = 1.13.0.5 |
      And package "gem-ruby-progressbar" contains dependency lines:
         | Provides:      gem(ruby-progressbar) = 1.13.0.5  |
      When the generated spec is refreshed 2 times
      Then the main source is the "progressbar" gem
      And the generated package names are unique
      And the generated dependency sections match "gem.spec" from fixture "progressbar"

   @scratch @main_is_gem
   Scenario: Select ruby-progressbar explicitly without removing the progressbar gem
      - keep a real ruby- gem prefix distinct from an obsolete RPM package prefix
      Given blank space
      And a spec from fixture "progressbar"
      When the input spec is named "gem-ruby-progressbar"
      And developer locks the time to "09.11.2026"
      And he sets the space options as:
         | options            | value                          |
         | rootdir            | features/fixtures/progressbar  |
         | maintainer.name    | Pavel Skrylev                  |
         | maintainer.email   | majioa@altlinux.org            |
      And he loads the spec into the space
      Then the main source is the "ruby-progressbar" gem
      When he applies "spec" actor to the baltix setup
      And the generated spec is refreshed 2 times
      Then the main source is the "ruby-progressbar" gem
      And the generated package names are unique
      And the generated spec contains the lines:
         | Name:          gem-ruby-progressbar  |
      And package "gem-ruby-progressbar" contains dependency lines:
         | Provides:      gem(ruby-progressbar) = 1.13.0.5  |
      And package "gem-progressbar" contains dependency lines:
         | Provides:      gem(progressbar) = 1.13.0.5 |

   @policy1_0 @gem_change @main_is_gem
   Scenario: Migrate ucf from obsolete Ruby Policy 1.0 to 2.1
      - blank packager
      - both gem dependencies are runtime and development
      - there is a dependency to ruby
      - migrate a used pkgname alias to gemname without changing custom commands
      - remove obsolete RI cache cleanup and lines containing bundler/setup or ruby-tool-setup
      Given blank space
      And a spec from fixture "ucf"
      When developer locks the time to "21.04.2021"
      And he sets the space option "rootdir" to fixture "ucf"
      And he sets the space option "maintainer.name" to "Pavel Skrylev"
      And he sets the space option "maintainer.email" to "majioa@altlinux.org"
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains none of these packaging tokens:
         | pkgname                     |
         | ruby_ri_sitedir             |
         | # Remove unnecessary files  |
         | bundler/setup               |
         | ruby-tool-setup             |
      And he acquires an "ucf" fixture spec for the baltix setup
      When the generated spec is refreshed 2 times
      Then the generated spec contains none of these packaging tokens:
         | bundler/setup   |
         | ruby-tool-setup |

   @policy1_0 @gem_change @gem_obsolete_list @main_is_gem @loader_gc
   Scenario: Migrate zip-container from obsolete Ruby Policy 1.0 to 2.1
      - blank packager
      - both gem dependencies are runtime and development
      - there is a dependency to ruby
      Given blank space
      And a spec from fixture "zip-container"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options               | value                             |
         | rootdir               | features/fixtures/zip-container   |
         | use_gem_obsolete_list | {rubyzip: rubyzip}                |
         | maintainer.name       | Pavel Skrylev                     |
         | maintainer.email      | majioa@altlinux.org               |
      And he loads the spec into the space
      Then the main source is the "zip_container" gem
      And the main source metadata file is "zip-container.gemspec"
      When he applies "spec" actor to the baltix setup
      Then the generated spec contains none of these packaging tokens:
         | ruby_ri_sitedir             |
         | # Remove unnecessary files  |
         | bundler/setup               |
         | ruby-tool-setup             |
      And he acquires an "zip-container" fixture spec for the baltix setup
      When the generated spec is refreshed 2 times
      Then the generated spec contains none of these packaging tokens:
         | bundler/setup   |
         | ruby-tool-setup |

   @policy1_0 @gem_change @olddoc @wrongdoc @main_is_gem
   Scenario: Migrate kgio with Olddoc/Wrongdoc from obsolete Ruby Policy 1.0 to 2.1
      - use the default prefix and suffix because the main source is a gem at the repository root
      - blank packager
      - gem dependencies are development only
      - has extension containing call to #gem dep
      - regenerate standard policy sections instead of retaining obsolete setup commands
      - omit obsolete pkgname definitions once their generated uses disappear
      Given blank space
      And a spec from fixture "kgio"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                    |
         | rootdir            | features/fixtures/kgio   |
         | maintainer.name    | Pavel Skrylev            |
         | maintainer.email   | majioa@altlinux.org      |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains each line once:
         | %setup          |
         | %ruby_build     |
         | %ruby_install   |
         | %ruby_test      |
      And the generated spec excludes the lines:
         | %define pkgname kgio                    |
         | %setup -q -n %pkgname-%version          |
         | rm -rf setup.rb *.gemspec               |
         | cp %SOURCE1 %pkgname-%version.gemspec   |
         | export VERSION=%version                 |
         | #%%ruby_test_unit -Iext/kgio:lib test   |
      And packaging section migration produces these commands:
         | section   | input                                                                                | output                                                    |
         | prep      | %setup -q -n "%{gemname}-%{version}"                                                 | %setup                                                    |
         | prep      | %setup -q -n custom-tree                                                             | %setup -q -n custom-tree                                  |
         | prep      | %setup -q -a 1                                                                       | %setup -q -a 1                                            |
         | prep      | rm -rf setup.rb *.gemspec                                                            | %setup                                                    |
         | prep      | rm -rf setup.rb custom.txt                                                           | rm -rf setup.rb custom.txt                                |
         | prep      | cp %SOURCE1 %pkgname-%version.gemspec                                                | %setup                                                    |
         | prep      | cp %SOURCE2 patched.gemspec                                                          | cp %SOURCE2 patched.gemspec                               |
         | install   | export VERSION=%{version}                                                            | %ruby_install                                             |
         | install   | export VERSION=custom                                                                | export VERSION=custom                                     |
         | install   | export VERSION=%version && touch marker                                              | export VERSION=%version && touch marker                   |
         | check     | #ruby_test_unit -Ilib:test test                                                      | %ruby_test                                                |
         | check     | # custom test instructions                                                           | # custom test instructions                                |
         | install   | rm -f %buildroot%ruby_ri_sitedir/cache.ri                                            | %ruby_install                                             |
         | install   | rm -rf %{buildroot}%{ruby_ri_sitedir}/{Object/cdesc-Object.ri,cache.ri,created.rid}  | %ruby_install                                             |
         | install   | rm -f %buildroot%ruby_ri_sitedir/cache.ri custom.txt                                 | rm -f %buildroot%ruby_ri_sitedir/cache.ri custom.txt      |
         | install   | rm -f %buildroot%ruby_ri_sitedir/custom.ri                                           | rm -f %buildroot%ruby_ri_sitedir/custom.ri                |
         | install   | rm -f %buildroot%ruby_ri_sitedir/cache.ri && touch marker                            | rm -f %buildroot%ruby_ri_sitedir/cache.ri && touch marker |
         | prep      | rm -f %buildroot%ruby_ri_sitedir/cache.ri                                            | rm -f %buildroot%ruby_ri_sitedir/cache.ri                 |
         | prep      | subst 's,bundler/setup,,' lib/example.rb                                             | %setup                                                    |
         | build     | ruby -rbundler/setup build.rb                                                        | %ruby_build                                               |
         | install   | sed -i s,bundler/setup,, lib/example.rb                                              | %ruby_install                                             |
         | check     | ruby -rbundler/setup test.rb                                                         | %ruby_test                                                |
         | prep      | echo bundler-setup                                                                   | echo bundler-setup                                        |
         | build     | ruby-tool-setup build                                                                | %ruby_build                                               |
         | build     | setup-rb build                                                                       | setup-rb build                                            |
      And deprecated package-name definitions follow these rules:
         | package   | definition                  | use                            | retained  |
         | gem-kgio  | %define pkgname kgio        |                                | no        |
         | gem-kgio  | %global pkgname kgio        |                                | no        |
         | gem-kgio  | %def_legacy pkgname kgio    |                                | no        |
         | gem-kgio  | %define pkgname kgio        | echo %pkgname                  | yes       |
         | gem-kgio  | %global pkgname kgio        | echo %{pkgname}                | yes       |
         | gem-kgio  | %define pkgname kgio        | echo %{?pkgname:enabled}       | yes       |
         | gem-kgio  | %define pkgname kgio        | %define source_name %{pkgname} | yes       |
         | gem-kgio  | %define pkgname_suffix kgio |                                | yes       |
         | gem-kgio  | %define service_user _kgio  |                                | yes       |
         | kgio      | %define pkgname kgio        |                                | yes       |
      And he acquires an "kgio" fixture spec for the baltix setup
      When the generated spec is refreshed 2 times
      Then the generated dependency sections match "gem.spec" from fixture "kgio"
      And the generated spec contains each line once:
         | %setup          |
         | %ruby_build     |
         | %ruby_install   |
         | %ruby_test      |

   @scratch @blank_setup @main_is_gem
   Scenario Outline: Raise RPM minimums past rails-html-sanitizer security exclusions
      - retain the original upstream exclusions in gem metadata
      - use the greatest excluded version as a strict RPM minimum
      - keep the macro, Requires and BuildRequires on the same > boundary
      - do not create a conflict from an excluded version
      - preserve the boundary with absent, old and newer available versions
      Given blank space
      When developer locks the time to "09.11.2026"
      And he sets the space options as:
         | options               | value                                      |
         | rootdir               | features/fixtures/rails-html-sanitizer-1.7 |
         | available_gem_list    | <available>                                |
         | gem_dependency_mode   | <mode>                                     |
         | maintainer.name       | Pavel Skrylev                              |
         | maintainer.email      | majioa@altlinux.org                        |
      And he applies "spec" actor to the baltix setup
      Then package "gem-rails-html-sanitizer" contains dependency lines:
         | Requires:      gem(nokogiri) > 1.16.7   |
      And the generated spec contains each line once:
         | %ruby_use_gem_dependency nokogiri > 1.16.7 |
         | BuildRequires: gem(nokogiri) > 1.16.7      |
      And the generated spec has no gem conflicts for "nokogiri"
      And the source "rails-html-sanitizer" dependency "nokogiri" has version compatibility:
         | version   | allowed   |
         | 1.15.7    | yes       |
         | 1.16.7    | no        |
         | 1.16.8    | yes       |
      And the generated spec matches "gem.spec" from fixture "rails-html-sanitizer-1.7"
      When the generated spec is refreshed 2 times
      Then the generated dependency sections match "gem.spec" from fixture "rails-html-sanitizer-1.7"
      And the generated spec has no gem conflicts for "nokogiri"

      Examples:
         | available             | mode      |
         | {}                    | regular   |
         | {nokogiri: '1.14.0'}  | redep     |
         | {nokogiri: '1.16.8'}  | regular   |

   @policy2_0 @gem_change @main_is_gem
   Scenario: Migrate rbvmomi from obsolete Ruby Policy 2.0 to 2.1 using available gem versions
      - blank packager
      - both gem dependencies are runtime and development
      - there is a dependency to ruby
      - migrate rpm-build-ruby to rpm-macros-ruby, setup-rb and rake
      - replace legacy gem_replace_version constraints using current sources and available versions
      - use identical rake requirements in the override macro and RPM dependency fields
      - replace the old executable wildcard with names declared by the gemspec
      Given blank space
      And a spec from fixture "rbvmomi"
      And the input main package file list also contains:
         | %_bindir/*            |
         | %{_bindir}/rbvmomish  |
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                                         |
         | rootdir            | features/fixtures/rbvmomi                     |
         | available_gem_list | {racc: 1.5.1, rake: '15.0', test-unit: '3.0'} |
         | maintainer.name    | Pavel Skrylev                                 |
         | maintainer.email   | majioa@altlinux.org                           |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains each line once:
         | %_bindir/rbvmomish |
      And the generated spec excludes the lines:
         | %_bindir/*   |
      And he acquires an "rbvmomi" fixture spec for the baltix setup
      And the generated package names are unique
      And the generated build prerequisites are:
         | rpm-macros-ruby setup-rb rake  |
      And the generated spec contains the lines:
         | %ruby_use_gem_dependency rake >= 10.5,rake < 16  |
         | BuildRequires: gem(rake) >= 10.5                 |
         | BuildConflicts: gem(rake) >= 16                  |
      And package "gem-rbvmomi-devel" contains dependency lines:
         | Requires:      gem(rake) >= 10.5  |
         | Conflicts:     gem(rake) >= 16    |
      When the generated spec is refreshed 2 times
      Then the generated spec contains each line once:
         | %_bindir/rbvmomish |
      And the generated spec excludes the lines:
         | %_bindir/*   |

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
         | options            | value                    |
         | rootdir            | features/fixtures/turn   |
         | available_gem_list | <available>              |
         | spec_type          | rpm                      |
         | maintainer.name    | Pavel Skrylev            |
         | maintainer.email   | majioa@altlinux.org      |
      Then the source "turn" dependency "minitest" has version compatibility:
         | version   | allowed   |
         | 3.9       | no        |
         | 4.0       | yes       |
         | 4.99      | yes       |
         | 5.0       | no        |
         | 5.14.0    | no        |
      When he applies "spec" actor to the baltix setup
      Then the generated spec matches "<expected>" from fixture "turn"

      Examples:
         | available          | expected     |
         | {}                 | source.spec  |
         | {minitest: 5.14.0} | gem.spec     |

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
         | options            | value                          |
         | rootdir            | features/fixtures/ruby-gnome2  |
         | available_gem_list | {minitest: 5.14.0}             |
         | spec_type          | rpm                            |
         | ignored_names      | [rake]                         |
         | maintainer.name    | Pavel Skrylev                  |
         | maintainer.email   | majioa@altlinux.org            |
      And the input spec has extra build requirements:
         | gem-cairo-headers-devel  |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "ruby-gnome2" fixture spec for the baltix setup
      When the generated spec is refreshed 2 times
      Then the generated spec contains the lines:
         | BuildRequires: gem-cairo-headers-devel  |
      And the generated dependency sections match "gem.spec" from fixture "ruby-gnome2"

   @scratch @hoe @blank_setup
   Scenario: Apply the Spec actor to setup for oedipus-lex gem to blank setup
      - blank setup
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                          |
         | packager.name      | Ruby Maintainers Team          |
         | packager.email     | ruby@packages.altlinux.org     |
         | rootdir            | features/fixtures/oedipus-lex  |
         | spec_type          | rpm                            |
         | maintainer.name    | Pavel Skrylev                  |
         | maintainer.email   | majioa@altlinux.org            |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "oedipus-lex" fixture spec for the baltix setup

   @scratch @bones @blank_setup
   Scenario: Apply the Spec actor to setup for little-plugger gem to blank setup
      - blank setup
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                             |
         | packager.name      | Ruby Maintainers Team             |
         | packager.email     | ruby@packages.altlinux.org        |
         | rootdir            | features/fixtures/little-plugger  |
         | spec_type          | rpm                               |
         | maintainer.name    | Pavel Skrylev                     |
         | maintainer.email   | majioa@altlinux.org               |
      And he applies "spec" actor to the baltix setup
      Then he acquires an "little-plugger" fixture spec for the baltix setup

   @scratch @jeweler @blank_setup
   Scenario: Apply the Spec actor to setup for polyglot gem to blank setup
      - blank setup
      Given blank space
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                       |
         | packager.name      | Ruby Maintainers Team       |
         | packager.email     | ruby@packages.altlinux.org  |
         | rootdir            | features/fixtures/polyglot  |
         | spec_type          | rpm                         |
         | maintainer.name    | Pavel Skrylev               |
         | maintainer.email   | majioa@altlinux.org         |
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
         | options            | value                       |
         | packager.name      | Ruby Maintainers Team       |
         | packager.email     | ruby@packages.altlinux.org  |
         | rootdir            | features/fixtures/echoe     |
         | spec_type          | rpm                         |
         | maintainer.name    | Pavel Skrylev               |
         | maintainer.email   | majioa@altlinux.org         |
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
         | options            | value                             |
         | rootdir            | features/fixtures/ruby-debug-ide  |
         | available_gem_list | {rake: 13.2.1, test-unit: 3.6.2}  |
         | spec_type          | rpm                               |
         | packager.name      | Baltix Maintainers Team           |
         | packager.email     | baltix@packages.altlinux.org      |
         | autorender_name    | true                              |
         | maintainer.name    | Baltix Builder Bot                |
         | maintainer.email   | bbb@altlinux.org                  |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then he acquires an "ruby-debug-ide" fixture spec for the baltix setup

   # Dynflow/dynflow, ALT 3c1b30b; minitest has only the upper bound < 5.19.
   @scratch @main_is_gem
   Scenario: Retain required gems that declare only an upper version bound
      - require minitest for building even though its gemspec gives no minimum
      - keep the upper bound in build conflicts and development package conflicts
      - preserve both declarations through repeated spec updates
      Given blank space
      And a spec from fixture "dynflow"
      When developer locks the time to "09.11.2026"
      And he sets the space options as:
         | options            | value                       |
         | rootdir            | features/fixtures/dynflow   |
         | maintainer.name    | Pavel Skrylev               |
         | maintainer.email   | majioa@altlinux.org         |
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec preserves the input packaging sections
      And the generated package names are unique
      And package "dynflow" contains dependency lines:
         | Summary:       DYNamic workFLOW engine executable(s)   |
         | Requires:      gem(dynflow) = 2.0.1                    |
      And he acquires an "dynflow" fixture spec for the baltix setup
      And the generated spec contains each line once:
         | BuildRequires: gem(minitest) >= 0       |
         | BuildConflicts: gem(minitest) >= 5.19   |
      And package "gem-dynflow-devel" contains dependency lines:
         | Requires:      gem(minitest) >= 0    |
         | Conflicts:     gem(minitest) >= 5.19 |
      And package "gem-dynflow" does not require "minitest"
      When the generated spec is refreshed 2 times
      Then the generated dependency sections match "gem.spec" from fixture "dynflow"
      And the generated spec preserves the input packaging sections
