%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname megatest

Name:          gem-megatest
Version:       0.11.0
Release:       alt1
Summary:       Modern test-unit style test framework
License:       MIT
Group:         Development/Ruby
Url:           https://github.com/byroot/megatest
Vcs:           https://github.com/byroot/megatest.git
Packager:      Pavel Skrylev <majioa@altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(base64) >= 0
BuildRequires: gem(benchmark) >= 0
BuildRequires: gem(debug) >= 0
BuildRequires: gem(ostruct) >= 0
BuildRequires: gem(rake) >= 13.0
BuildRequires: gem(redis-client) >= 0.22
BuildRequires: gem(rubocop) >= 1.21
BuildConflicts: gem(rake) >= 14
BuildConflicts: gem(rubocop) >= 2
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      ruby >= 2.6.0
Provides:      gem(megatest) = 0.11.0

%description
Largely API compatible with test-unit / minitest, but with lots of extra modern
niceties like a proper CLI, test distribution, etc.


%if_enabled    doc
%package       -n gem-megatest-doc
Version:       0.11.0
Release:       alt1
Summary:       Modern test-unit style test framework documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета megatest
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(megatest) = 0.11.0

%description   -n gem-megatest-doc
Modern test-unit style test framework documentation files.

Largely API compatible with test-unit / minitest, but with lots of extra modern
niceties like a proper CLI, test distribution, etc.

%description   -n gem-megatest-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета megatest.
%endif


%if_enabled    devel
%package       -n gem-megatest-devel
Version:       0.11.0
Release:       alt1
Summary:       Modern test-unit style test framework development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета megatest
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(megatest) = 0.11.0
Requires:      gem(base64) >= 0
Requires:      gem(benchmark) >= 0
Requires:      gem(debug) >= 0
Requires:      gem(ostruct) >= 0
Requires:      gem(rake) >= 13.0
Requires:      gem(redis-client) >= 0.22
Requires:      gem(rubocop) >= 1.21
Conflicts:     gem(rake) >= 14
Conflicts:     gem(rubocop) >= 2

%description   -n gem-megatest-devel
Modern test-unit style test framework development package.

Largely API compatible with test-unit / minitest, but with lots of extra modern
niceties like a proper CLI, test distribution, etc.

%description   -n gem-megatest-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета megatest.
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
%ruby_gemspec
%ruby_gemlibdir

%if_enabled    doc
%files         -n gem-megatest-doc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-megatest-devel
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 0.11.0-alt1
- + packaged gem with Ruby Policy 2.0
- * define explicit dependencies
