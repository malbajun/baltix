%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname license_scout

Name:          gem-license-scout
Version:       2.6.10
Release:       alt1
Summary:       Discovers license files of a project's dependencies
License:       Apache-2.0
Group:         Development/Ruby
Url:           https://github.com/chef/license_scout
Vcs:           https://github.com/chef/license_scout.git
Packager:      Pavel Skrylev <majioa@altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(berkshelf) >= 4.3
BuildRequires: gem(chefstyle) >= 0
BuildRequires: gem(ffi-yajl) >= 2.2
BuildRequires: gem(fuzzy_match) >= 0
BuildRequires: gem(licensee) >= 9.8
BuildRequires: gem(mixlib-cli) >= 0
BuildRequires: gem(mixlib-config) >= 3.0
BuildRequires: gem(mixlib-log) >= 0
BuildRequires: gem(mixlib-shellout) >= 2.2
BuildRequires: gem(pry) >= 0
BuildRequires: gem(rake) >= 10.0
BuildRequires: gem(rb-readline) >= 0
BuildRequires: gem(rspec) >= 0
BuildRequires: gem(rugged) = 0.27
BuildRequires: gem(terminal-table) >= 0
BuildRequires: gem(toml-rb) >= 1.0
BuildRequires: gem(vcr) >= 0
BuildRequires: gem(webmock) >= 0
BuildConflicts: gem(berkshelf) >= 5
BuildConflicts: gem(ffi-yajl) >= 3
BuildConflicts: gem(licensee) >= 10
BuildConflicts: gem(mixlib-config) >= 4
BuildConflicts: gem(mixlib-shellout) >= 4.0
BuildConflicts: gem(rake) >= 11
BuildConflicts: gem(toml-rb) >= 2
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
%ruby_alias_names license_scout,license-scout
Requires:      gem(ffi-yajl) >= 2.2
Requires:      gem(fuzzy_match) >= 0
Requires:      gem(licensee) >= 9.8
Requires:      gem(mixlib-cli) >= 0
Requires:      gem(mixlib-config) >= 3.0
Requires:      gem(mixlib-log) >= 0
Requires:      gem(mixlib-shellout) >= 2.2
Requires:      gem(terminal-table) >= 0
Requires:      gem(toml-rb) >= 1.0
Conflicts:     gem(ffi-yajl) >= 3
Conflicts:     gem(licensee) >= 10
Conflicts:     gem(mixlib-config) >= 4
Conflicts:     gem(mixlib-shellout) >= 4.0
Conflicts:     gem(toml-rb) >= 2
Provides:      gem(license_scout) = 2.6.10

%description
Discovers license files of a project's dependencies.


%package       -n license-scout
Version:       2.6.10
Release:       alt1
Summary:       Discovers license files of a project's dependencies executable(s)
Summary(ru_RU.UTF-8): Исполнямка для самоцвета license_scout
Group:         Other
BuildArch:     noarch

Requires:      gem(license_scout) = 2.6.10
Requires:      gem(rugged) = 0.27

%description   -n license-scout
Discovers license files of a project's dependencies executable(s).

%description   -n license-scout -l ru_RU.UTF-8
Исполнямка для самоцвета license_scout.


%if_enabled    doc
%package       -n gem-license-scout-doc
Version:       2.6.10
Release:       alt1
Summary:       Discovers license files of a project's dependencies documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета license_scout
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(license_scout) = 2.6.10

%description   -n gem-license-scout-doc
Discovers license files of a project's dependencies documentation files.

%description   -n gem-license-scout-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета license_scout.
%endif


%if_enabled    devel
%package       -n gem-license-scout-devel
Version:       2.6.10
Release:       alt1
Summary:       Discovers license files of a project's dependencies development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета license_scout
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(license_scout) = 2.6.10
Requires:      gem(berkshelf) >= 4.3
Requires:      gem(chefstyle) >= 0
Requires:      gem(pry) >= 0
Requires:      gem(rake) >= 10.0
Requires:      gem(rb-readline) >= 0
Requires:      gem(rspec) >= 0
Requires:      gem(rugged) = 0.27
Requires:      gem(vcr) >= 0
Requires:      gem(webmock) >= 0
Conflicts:     gem(berkshelf) >= 5
Conflicts:     gem(rake) >= 11

%description   -n gem-license-scout-devel
Discovers license files of a project's dependencies development package.

%description   -n gem-license-scout-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета license_scout.
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
%doc license_scout.gemspec
%ruby_gemspec
%ruby_gemlibdir

%files         -n license-scout
%doc license_scout.gemspec
%_bindir/license_scout

%if_enabled    doc
%files         -n gem-license-scout-doc
%doc license_scout.gemspec
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-license-scout-devel
%doc license_scout.gemspec
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 2.6.10-alt1
- + packaged gem with Ruby Policy 2.1
- * define explicit dependencies
