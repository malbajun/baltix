@rpm @spec
Feature: RPM Spec

   Scenario: Parse RPM Spec for Name
      Given blank space with empty sources
      And RPM spec file:
         """
         Name:                rpm
         """
      When developer loads the spec into the space
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then stringified property "name" of space is "rpm"

   @package_headers
   Scenario: Keep package versions separate from global header macros
      - retain independently versioned package metadata from a generated Chef spec
      - update lowercase version, epoch and release macros when a header overrides them
      - keep uppercase macros bound to the main package metadata
      - inherit main fields only when a subpackage does not override them
      Given blank space with empty sources
      And RPM spec file:
         """
         Name: gem-chef
         Version: 19.4.12
         Epoch: 1
         Release: alt1
         Summary: Chef
         %package -n kitchen-tests
         Version: 20261111
         Epoch: 2
         Release: alt3
         Summary: Kitchen tests
         %package -n chef-tools
         Version: %version
         Epoch: %epoch
         Release: %release
         Summary: Tools
         %package -n chef-main-fields
         Version: %{VERSION}
         Epoch: %{EPOCH}
         Release: %{RELEASE}
         %package -n chef-inherited
         """
      When developer loads the spec into the space
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then stringified property "version" of space is "19.4.12"
      And property "epoch" of space is "1"
      And property "release" of space is "alt1"
      And secondary spec with full name "kitchen-tests" has fields:
         | version   | 20261111  |
         | epoch     | 2         |
         | release   | alt3      |
      And secondary spec with full name "chef-tools" has fields:
         | version   | 20261111  |
         | epoch     | 2         |
         | release   | alt3      |
      And secondary spec with full name "chef-main-fields" has fields:
         | version   | 19.4.12   |
         | epoch     | 1         |
         | release   | alt1      |
      And secondary spec with full name "chef-inherited" has fields:
         | version   | 19.4.12   |
         | epoch     | 1         |
         | release   | alt1      |

   # ALT r/ruby/ruby.spec: ruby 3.3.12-alt5.2, rpm-macros-ruby has its own Epoch.
   @package_headers
   Scenario: Keep the Ruby macro package epoch out of the interpreter metadata
      - expand the Ruby version macros from the original header
      - retain rpm-macros-ruby Epoch 1 while the main Ruby package has no epoch
      - keep a global epoch macro available after the subpackage header
      Given blank space with empty sources
      And RPM spec file:
         """
         %define ruby_api_version 3.3
         %define ruby_version %{ruby_api_version}.12
         Name: ruby
         Version: %ruby_version
         Release: alt5.2
         Summary: An Interpreted Object-Oriented Scripting Language
         %package -n rpm-macros-ruby
         Epoch: 1
         Summary: rpm macros for Ruby packages
         %package -n ruby-epoch-consumer
         Epoch: %epoch
         """
      When developer loads the spec into the space
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then stringified property "version" of space is "3.3.12"
      And stringified property "epoch" of space's spec is ""
      And secondary spec with full name "rpm-macros-ruby" has fields:
         | version   | 3.3.12 |
         | epoch     | 1      |
         | release   | alt5.2 |
      And secondary spec with full name "ruby-epoch-consumer" has fields:
         | version   | 3.3.12 |
         | epoch     | 1      |
         | release   | alt5.2 |

   Scenario: Parse RPM Spec for Version
      Given blank space with empty sources
      And RPM spec file:
         """
         Name:                rpm
         Version:             1.1
         """
      When developer loads the spec into the space
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then stringified property "version" of space is "1.1"

   Scenario: Parse RPM Spec for epoch
      Given RPM spec file:
         """
         Name:                rpm
         Epoch:               1
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "epoch" of space is "1"

   Scenario: Parse RPM Spec for summary
      Given RPM spec file:
         """
         Name:                rpm
         Summary:             RPM Summary
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "summaries" of space with no argument is "RPM Summary"

   Scenario: Parse RPM Spec for release
      Given RPM spec file:
         """
         Name:                rpm
         Release:             rc1
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "release" of space is "rc1"

   Scenario: Parse RPM Spec for a license
      Given blank space with empty sources
      And RPM spec file:
         """
         Name:                rpm
         License:             MIT or GPLv2 / Ruby
         """
      When developer loads the spec into the space
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "licenses" of space has "MIT"
      And property "licenses" of space has "GPLv2"
      And property "licenses" of space has "Ruby"

   Scenario: Parse RPM Spec for a group
      Given RPM spec file:
         """
         Name:                rpm
         Group:               Group
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "group" of space is "Group"

   Scenario: Parse RPM Spec for an URL
      Given RPM spec file:
         """
         Name:                rpm
         Url:                 https://path/to/soft/rpm
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "uri" of space is "https://path/to/soft/rpm"

   Scenario: Parse RPM Spec for a VCS
      Given RPM spec file:
         """
         Name:                rpm
         Vcs:                 https://path/to/vcs/rpm
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "vcs" of space is "https://path/to/vcs/rpm.git"

   # Historical raindrops Vcs from the ALT spec; also repair previously duplicated suffixes.
   Scenario Outline: Keep a single Git suffix across legacy Vcs updates
      - normalize the old bogomips repository URL without appending another .git
      - keep the entire spec, release and changelog stable on repeated updates
      Given blank space
      And RPM spec file:
         """
         Name:          gem-raindrops
         Version:       0.20.1
         Release:       alt1.1
         Summary:       real-time stats for preforking Rack servers
         License:       LGPL-2.1+
         Vcs:           <url>
         """
      When developer locks the time to "12.11.2026"
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      And he loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated spec contains the lines:
         | Vcs:           https://bogomips.org/raindrops.git   |
      When he keeps the generated spec for comparison
      And the generated spec is refreshed 2 times
      Then the generated spec is unchanged

      Examples:
         | url                                     |
         | git://bogomips.org/raindrops.git        |
         | https://bogomips.org/raindrops.git      |
         | https://bogomips.org/raindrops.git.git  |

   Scenario: Parse RPM Spec for a packager
      Given RPM spec file:
         """
         Name:                rpm
         Packager:            Packer FIO <fio@example.com>
         """
      And developer sets the cli option "packager" to blank
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then space's property "packager" with argument "name" has text:
         """
         Packer FIO
         """
      And space's property "packager" with argument "email" has text:
         """
         fio@example.com
         """

   Scenario: Parse RPM Spec for a build architecture
      Given RPM spec file:
         """
         Name:                rpm
         BuildArch:           arch64
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "build_arch" of space is "arch64"

   Scenario: Parse RPM Spec for Source
      Given RPM spec file:
         """
         Name:                rpm
         Source:              source_file.tar
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "source_files" of space has "%name-%version.tar"

   Scenario: Parse RPM Spec for many sources
      Given RPM spec file:
         """
         Name:                rpm
         Source0:             source_file.tar
         Source1:             source_file1.tar
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "source_files" of space has "%name-%version.tar" at position "0"
      And property "source_files" of space has "source_file1.tar" at position "1"

   Scenario: Parse RPM Spec for patch
      Given RPM spec file:
         """
         Name:                rpm
         Patch:               patch.patch
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "patches" of space has "patch.patch"

   Scenario: Parse RPM Spec for many patches
      Given RPM spec file:
         """
         Name:                rpm
         Patch:               patch.patch
         Patch1:              patch1.patch
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "patches" of space has "patch.patch" at position "0"
      And property "patches" of space has "patch1.patch" at position "1"

   Scenario: Parse RPM Spec for requires
      - keep Passenger's shell-expanded Apache dependency intact
      Given RPM spec file:
         """
         Name:                rpm
         Requires:            req >= 1 req_new < 0.1
         Requires:            req_newline >= 2
         Requires:            %(eval echo %apache2_apr_buildreq)
         """
      When developer loads the spec without evaluating expressions
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "requires" of space has "req >= 1" at position "0"
      And property "requires" of space has "req_new < 0.1" at position "1"
      And property "requires" of space has "req_newline >= 2" at position "2"
      And property "requires" of space has "%(eval echo %apache2_apr_buildreq)" at position "3"

   Scenario: Parse RPM Spec for build requires
      - keep macro arguments and nested expansions together with adjacent dependencies
      Given RPM spec file:
         """
         Name:                rpm
         BuildRequires:       req >= 1 req_new < 0.1
         BuildRequires:       req_newline >= 2
         BuildRequires:       %(eval echo %apache2_apr_buildreq) apache2-devel >= 2.2.5
         BuildRequires:       %{?with_apache:%(printf '%s' "pkgconfig(apr-1)")}
         """
      When developer loads the spec without evaluating expressions
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "build_requires" of space has "req >= 1" at position "0"
      And property "build_requires" of space has "req_new < 0.1" at position "1"
      And property "build_requires" of space has "req_newline >= 2" at position "2"
      And property "build_requires" of space has "%(eval echo %apache2_apr_buildreq)" at position "3"
      And property "build_requires" of space has "apache2-devel >= 2.2.5" at position "4"
      And property "build_requires" of space has text:
         """
         %{?with_apache:%(printf '%s' "pkgconfig(apr-1)")}
         """

   Scenario: Parse RPM Spec for build pre-requires
      Given RPM spec file:
         """
         Name:                rpm
         BuildRequires(pre):  req >= 1 req_new < 0.1
         BuildRequires(pre):  req_newline >= 2
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "build_pre_requires" of space has "req >= 1" at position "0"
      And property "build_pre_requires" of space has "req_new < 0.1" at position "1"
      And property "build_pre_requires" of space has "req_newline >= 2" at position "2"

   Scenario: Parse RPM Spec for obsoletes
      Given RPM spec file:
         """
         Name:                rpm
         Obsoletes:           req >= 1 req_new < 0.1
         Obsoletes:           req_newline >= 2
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "obsoletes" of space has "req >= 1" at position "0"
      And property "obsoletes" of space has "req_new < 0.1" at position "1"
      And property "obsoletes" of space has "req_newline >= 2" at position "2"

   Scenario: Parse RPM Spec for provides
      Given RPM spec file:
         """
         Name:                rpm
         Provides:            req >= 1 req_new < 0.1
         Provides:            req_newline >= 2
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "provides" of space has "req >= 1" at position "0"
      And property "provides" of space has "req_new < 0.1" at position "1"
      And property "provides" of space has "req_newline >= 2" at position "2"

   Scenario: Parse RPM Spec for conflicts
      Given RPM spec file:
         """
         Name:                rpm
         Conflicts:           req >= 1 req_new < 0.1
         Conflicts:           req_newline >= 2
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "conflicts" of space has "req >= 1" at position "0"
      And property "conflicts" of space has "req_new < 0.1" at position "1"
      And property "conflicts" of space has "req_newline >= 2" at position "2"

   Scenario: Parse RPM Spec for description
      Given RPM spec file:
         """
         Name:                rpm
         %description
         Multiline
         Description

         Of

         The

         RPM

         Spec
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "descriptions" of space with no argument is:
         """
         Multiline Description

         Of

         The

         RPM

         Spec
         """

   Scenario: Parse RPM Spec for description with a code page
      Given RPM spec file:
         """
         Name:                rpm
         %description         -l ru_RU.UTF-8
         Многострочная
         Заметка
         РПМ

         Спека
         * текст1
         - текст2
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then space's property "descriptions" with argument "ru_RU.UTF-8" has text:
         """
         Многострочная Заметка РПМ

         Спека
         * текст1
         - текст2
         """

   @description_guards
   Scenario: Keep enclosing package conditionals out of localized descriptions
      - retain the description in each locale inside an optional doc package
      - exclude the surrounding closing directive from description text
      Given RPM spec file:
         """
         Name:                rpm
         Summary:             RPM Summary

         %if_enabled doc
         %package             doc
         Summary:             Doc Summary
         Summary(ru_RU.UTF-8): Итого Доки
         Group:               Group1
         BuildArch:           arch64

         %description         doc
         Doc Desc.

         %description         doc -l ru_RU.UTF-8
         Описание Доков
         %endif
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then secondary spec with full name "rpm-doc" has fields:
         | name         | rpm-doc   |
         | group        | Group1    |
         | build_arch   | arch64    |
      And the subfield "descriptions" with argument "ru_RU.UTF-8" of secondary spec with full name "rpm-doc" has data:
         """
         Описание Доков
         """
      And the subfield "descriptions" with no argument of secondary spec with full name "rpm-doc" has data:
         """
         Doc Desc.
         """
      And the subfield "summaries" with argument "ru_RU.UTF-8" of secondary spec with full name "rpm-doc" has data:
         """
         Итого Доки
         """
      And the subfield "summaries" with no argument of secondary spec with full name "rpm-doc" has data:
         """
         Doc Summary
         """

   Scenario: Parse RPM Spec for stages
      Given RPM spec file:
         """
         Name:                rpm
         %prep
         setup
         patch

         %build
         build

         %install
         install

         %check
         check
         """
      When developer loads the spec
      Then space's property "prep" has data:
         """
         setup
         patch
         """
      And space's property "build" has data:
         """
         build
         """
      And space's property "install" has data:
         """
         install
         """
      And space's property "check" has data:
         """
         check
         """

   @file_directives
   Scenario: Parse RPM file directives as manifest entries
      - keep file attributes, configuration flags and documentation in their section
      - avoid treating file directives as new macro definitions
      Given RPM spec file:
         """
         Name:                rpm
         %package             doc
         %files
         %defattr(-,root,root)
         %attr(0644, root, root) %_mandir/rpm.1*
         %config(noreplace) %_sysconfdir/rpm.conf
         %dir %_sysconfdir/rpm
         %ghost %_localstatedir/rpm.state
         %exclude %_bindir/rpm-private
         file1
         %files               doc
         %doc README.md
         %license LICENSE
         file2
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "file_list" of space has text:
         """
         %defattr(-,root,root)
         %attr(0644, root, root) %_mandir/rpm.1*
         %config(noreplace) %_sysconfdir/rpm.conf
         %dir %_sysconfdir/rpm
         %ghost %_localstatedir/rpm.state
         %exclude %_bindir/rpm-private
         file1
         """
      And the subfield "file_list" of secondary spec with full name "rpm-doc" has data:
         """
         %doc README.md
         %license LICENSE
         file2
         """

   @native_manifest
   Scenario Outline: Keep a retained native extension directory only once
      - preserve state-only file entries and their ownership attributes
      - avoid adding the same automatically generated Ruby extension directory
      - retain the complete manifest across repeated spec updates
      Given blank space with empty sources
      And RPM spec file:
         """
         Name: native-example
         Version: 1.0
         Release: alt1
         Summary: Native files
         License: MIT
         %files
         <entry>
         """
      When developer sets the space option "rootdir" to "features/fixtures/blank"
      And developer sets the space option "compilables" to "[ext/native.c]"
      And developer loads the spec into the space
      And he applies "spec" actor to the baltix setup
      Then the generated extension directory entries are:
         | <entry>   |
      When he keeps the generated spec for comparison
      And the generated spec is refreshed 2 times
      Then the generated spec is unchanged

      Examples:
         | entry                                         |
         | %ruby_gemextdir                               |
         | %{ruby_gemextdir}                             |
         | %dir %attr(0750, root, root) %ruby_gemextdir  |

   @changelog_history
   Scenario Outline: Preserve old changelog EVRs and version newly generated entries
      - preserve old Ruby changelog entries that omit version and release
      - retain authors, dates and descriptions without inventing an EVR
      - keep ordinary versioned entries in their original chronological order
      - give each new entry the package version and release, including epoch when set
      Given RPM spec file:
         """
         Name:                rpm
         Version:             2.0
         Release:             alt1
         <epoch_header>
         %changelog
         * Tue Jan 02 2001 FIO Packer <fio@example.com> 2.0-alt1
         - ^ new version
         * Mon Jan 01 2001 FIO Packer <fio@example.com> 1.0-rc1
         - ! of important bug
         * Wed Dec 08 1999 Atsushi Yamagata <yamagata@plathome.co.jp>
         - Updated to version 1.4.3
         """
      When developer loads the spec
      Then stringified property "version" of space is "2.0"
      And space's property "changes" at position "0" has fields:
         | date         | Wed Dec 08 1999             |
         | author       | Atsushi Yamagata            |
         | email        | yamagata@plathome.co.jp     |
         | epoch        |                             |
         | version      |                             |
         | release      |                             |
         | description  | - Updated to version 1.4.3  |
      And space's property "changes" at position "1" has fields:
         | date         | Mon Jan 01 2001       |
         | author       | FIO Packer            |
         | email        | fio@example.com       |
         | version      | 1.0                   |
         | release      | rc1                   |
         | description  | - ! of important bug  |
      And space's property "changes" at position "2" has fields:
         | date         | Tue Jan 02 2001 |
         | author       | FIO Packer      |
         | email        | fio@example.com |
         | version      | 2.0             |
         | release      | alt1            |
         | description  | - ^ new version |
      And the parsed changelog survives rendering and reparsing
      When he applies "spec" actor to the baltix setup
      Then the new changelog entry has the package EVR and preserves earlier entries

      Examples:
         | epoch_header |
         |              |
         | Epoch: 1     |

   Scenario: Parse RPM Spec for variables support
      Given RPM spec file:
         """
         %global var1         2
         %define var          rpm
         Name:                %{var}%var1
         """
      When developer loads the spec
      Then space macros context with argument "var" has text:
         """
         rpm
         """
      Then space macros context with argument "var1" has text:
         """
         2
         """
      Then stringified property "name" of space's spec is "rpm2"

   Scenario: Parse RPM Spec for macros support
      Given RPM spec file:
         """
         Name:                rpm
         %macro               rpmn < 1
         %macro               rpmn1 2
         %macro1              rpmn < 11
         """
      When developer loads the spec
      Then the subfield "macro" at position "0" of space's property "context" with argument "__macros" has data:
         """
         rpmn < 1
         """
      And the subfield "macro" at position "1" of space's property "context" with argument "__macros" has data:
         """
         rpmn1 2
         """
      Then the subfield "macro1" of space's property "context" with argument "__macros" has data:
         """
         rpmn < 11
         """
