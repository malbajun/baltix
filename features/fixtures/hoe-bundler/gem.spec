%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname hoe-bundler

Name:          gem-hoe-bundler
Version:       1.5.0.4
Release:       alt1.2
Summary:       Generate a Gemfile based on a Hoe spec's declared dependencies
License:       MIT
Group:         Development/Ruby
Url:           http://github.com/flavorjones/hoe-bundler
Vcs:           https://github.com/flavorjones/hoe-bundler.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(concourse) >= 0.18
BuildRequires: gem(hoe) >= 3.17
BuildRequires: gem(hoe-gemspec) >= 0
BuildRequires: gem(hoe-git) >= 0
BuildRequires: gem(minitest) >= 5.11
BuildRequires: gem(rdoc) >= 4.0
BuildConflicts: gem(concourse) >= 1
BuildConflicts: gem(hoe) >= 4
BuildConflicts: gem(minitest) >= 6
BuildConflicts: gem(rdoc) >= 6
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Provides:      gem(hoe-bundler) = 1.5.0.4

%ruby_use_gem_version hoe-bundler:1.5.0.4

%description
Generate a Gemfile based on a Hoe spec's declared dependencies.


%if_enabled    doc
%package       -n gem-hoe-bundler-doc
Version:       1.5.0.4
Release:       alt1.2
Summary:       Generate a Gemfile based on a Hoe spec's declared dependencies documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета hoe-bundler
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(hoe-bundler) = 1.5.0.4

%description   -n gem-hoe-bundler-doc
Generate a Gemfile based on a Hoe spec's declared dependencies documentation
files.

%description   -n gem-hoe-bundler-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета hoe-bundler.
%endif


%if_enabled    devel
%package       -n gem-hoe-bundler-devel
Version:       1.5.0.4
Release:       alt1.2
Summary:       Generate a Gemfile based on a Hoe spec's declared dependencies development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета hoe-bundler
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(hoe-bundler) = 1.5.0.4
Requires:      gem(concourse) >= 0.18
Requires:      gem(hoe) >= 3.17
Requires:      gem(hoe-gemspec) >= 0
Requires:      gem(hoe-git) >= 0
Requires:      gem(minitest) >= 5.11
Requires:      gem(rdoc) >= 4.0
Conflicts:     gem(concourse) >= 1
Conflicts:     gem(hoe) >= 4
Conflicts:     gem(minitest) >= 6
Conflicts:     gem(rdoc) >= 6

%description   -n gem-hoe-bundler-devel
Generate a Gemfile based on a Hoe spec's declared dependencies development
package.

%description   -n gem-hoe-bundler-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета hoe-bundler.
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
%doc CHANGELOG.md LICENSE README.md
%ruby_gemspec
%ruby_gemlibdir

%if_enabled    doc
%files         -n gem-hoe-bundler-doc
%doc CHANGELOG.md LICENSE README.md
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-hoe-bundler-devel
%doc CHANGELOG.md LICENSE README.md
%endif


%changelog
* Wed Nov 11 2026 Pavel Skrylev <majioa@altlinux.org> 1.5.0.4-alt1.2
- ! spec

* Tue Sep 01 2026 Pavel Skrylev <majioa@altlinux.org> 1.5.0.4-alt1.1
- ! fixed dep to minitest gem

* Sat Aug 24 2024 Pavel Skrylev <majioa@altlinux.org> 1.5.0.4-alt1
- ^ 1.5.0 -> 1.5.0p4

* Thu Mar 17 2022 Pavel Skrylev <majioa@altlinux.org> 1.5.0-alt1
- + packaged gem with Ruby Policy 2.0
