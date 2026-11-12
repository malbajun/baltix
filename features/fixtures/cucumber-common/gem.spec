%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc

Name:          cucumber-common
Version:       20261112
Release:       alt1
Summary:       Cucumber Common Components
License:       MIT
Group:         Other
Url:           https://github.com/cucumber/common
Vcs:           https://github.com/cucumber/common.git
Packager:      Pavel Skrylev <majioa@altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(rake) >= 13.0.6
BuildRequires: gem(rspec) >= 3.11
BuildConflicts: gem(rake) >= 14
BuildConflicts: gem(rspec) >= 4
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      gem(cucumber-gherkin) = 24.0.0
Requires:      gem(cucumber-messages) = 19.0.0

%description
This repo contains the libraries/modules for behaviour that's common between the
various Cucumber implementations. These include:


%package       -n cucumber-gherkin
Version:       24.0.0
Release:       alt1
Summary:       cucumber-gherkin-24.0.0
Group:         Development/Ruby
BuildArch:     noarch

Requires:      ruby >= 2.3
Requires:      gem(cucumber-messages) = 19.0.0
Provides:      gem(cucumber-gherkin) = 24.0.0

%description   -n cucumber-gherkin
Gherkin parser


%package       -n gherkin
Version:       24.0.0
Release:       alt1
Summary:       cucumber-gherkin-24.0.0 executable(s)
Summary(ru_RU.UTF-8): Исполнямка для самоцвета cucumber-gherkin
Group:         Other
BuildArch:     noarch

Requires:      gem(cucumber-gherkin) = 24.0.0

%description   -n gherkin
cucumber-gherkin-24.0.0 executable(s).

Gherkin parser

%description   -n gherkin -l ru_RU.UTF-8
Исполнямка для самоцвета cucumber-gherkin.


%if_enabled    doc
%package       -n gem-cucumber-gherkin-doc
Version:       24.0.0
Release:       alt1
Summary:       cucumber-gherkin-24.0.0 documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета cucumber-gherkin
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(cucumber-gherkin) = 24.0.0

%description   -n gem-cucumber-gherkin-doc
cucumber-gherkin-24.0.0 documentation files.

Gherkin parser

%description   -n gem-cucumber-gherkin-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета cucumber-gherkin.
%endif


%if_enabled    devel
%package       -n gem-cucumber-gherkin-devel
Version:       24.0.0
Release:       alt1
Summary:       cucumber-gherkin-24.0.0 development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета cucumber-gherkin
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(cucumber-gherkin) = 24.0.0
Requires:      gem(rake) >= 13.0.6
Requires:      gem(rspec) >= 3.11
Conflicts:     gem(rake) >= 14
Conflicts:     gem(rspec) >= 4

%description   -n gem-cucumber-gherkin-devel
cucumber-gherkin-24.0.0 development package.

Gherkin parser

%description   -n gem-cucumber-gherkin-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета cucumber-gherkin.
%endif


%package       -n cucumber-messages
Version:       19.0.0
Release:       alt1
Summary:       cucumber-messages-19.0.0
Group:         Development/Ruby
BuildArch:     noarch

Requires:      ruby >= 2.3
Provides:      gem(cucumber-messages) = 19.0.0

%description   -n cucumber-messages
Protocol Buffer messages for Cucumber's inter-process communication


%if_enabled    doc
%package       -n gem-cucumber-messages-doc
Version:       19.0.0
Release:       alt1
Summary:       cucumber-messages-19.0.0 documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета cucumber-messages
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(cucumber-messages) = 19.0.0

%description   -n gem-cucumber-messages-doc
cucumber-messages-19.0.0 documentation files.

Protocol Buffer messages for Cucumber's inter-process communication

%description   -n gem-cucumber-messages-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета cucumber-messages.
%endif


%if_enabled    devel
%package       -n gem-cucumber-messages-devel
Version:       19.0.0
Release:       alt1
Summary:       cucumber-messages-19.0.0 development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета cucumber-messages
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(cucumber-messages) = 19.0.0
Requires:      gem(rake) >= 13.0.6
Requires:      gem(rspec) >= 3.11
Conflicts:     gem(rake) >= 14
Conflicts:     gem(rspec) >= 4

%description   -n gem-cucumber-messages-devel
cucumber-messages-19.0.0 development package.

Protocol Buffer messages for Cucumber's inter-process communication

%description   -n gem-cucumber-messages-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета cucumber-messages.
%endif


%prep
%setup

%build
%ruby_build

%install
%ruby_install

%check
%ruby_test

%files

%files         -n cucumber-gherkin
%ruby_gemspecdir/cucumber-gherkin-24.0.0.gemspec
%ruby_gemslibdir/cucumber-gherkin-24.0.0

%files         -n gherkin
%_bindir/gherkin-ruby
%_bindir/gherkin

%if_enabled    doc
%files         -n gem-cucumber-gherkin-doc
%ruby_gemsdocdir/cucumber-gherkin-24.0.0
%endif

%if_enabled    devel
%files         -n gem-cucumber-gherkin-devel
%endif

%files         -n cucumber-messages
%ruby_gemspecdir/cucumber-messages-19.0.0.gemspec
%ruby_gemslibdir/cucumber-messages-19.0.0

%if_enabled    doc
%files         -n gem-cucumber-messages-doc
%ruby_gemsdocdir/cucumber-messages-19.0.0
%endif

%if_enabled    devel
%files         -n gem-cucumber-messages-devel
%endif


%changelog
* Thu Nov 12 2026 Pavel Skrylev <majioa@altlinux.org> 20261112-alt1
- + packaged gem with Ruby Policy 2.1
