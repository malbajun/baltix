%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    devel
%define        gemname multi_test

Name:          gem-multi-test
Version:       2.0.0
Release:       alt1
Summary:       multi-test-1.1.0
License:       MIT
Group:         Development/Ruby
Url:           http://cukes.info
Packager:      Pavel Skrylev <majioa@altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(rubocop) >= 1.88.2
BuildRequires: gem(rubocop-performance) >= 1.26.1
BuildConflicts: gem(rubocop) >= 1.89
BuildConflicts: gem(rubocop-performance) >= 1.27
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
%ruby_alias_names multi_test,multi-test
%ruby_ignore_names activesupport,minitest,plain-ruby,rspec,test-unit
Requires:      ruby >= 3.2.0
Requires:      rubygems >= 3.2.8
Provides:      gem(multi_test) = 2.0.0

%description
Wafter-thin gem to help control rogue test/unit/autorun requires


%if_enabled    doc
%package       -n gem-multi-test-doc
Version:       2.0.0
Release:       alt1
Summary:       multi-test-1.1.0 documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета multi_test
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(multi_test) = 2.0.0

%description   -n gem-multi-test-doc
multi-test-1.1.0 documentation files.

Wafter-thin gem to help control rogue test/unit/autorun requires

%description   -n gem-multi-test-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета multi_test.
%endif


%if_enabled    devel
%package       -n gem-multi-test-devel
Version:       2.0.0
Release:       alt1
Summary:       multi-test-1.1.0 development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета multi_test
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(multi_test) = 2.0.0
Requires:      gem(rubocop) >= 1.88.2
Requires:      gem(rubocop-performance) >= 1.26.1
Conflicts:     gem(rubocop) >= 1.89
Conflicts:     gem(rubocop-performance) >= 1.27

%description   -n gem-multi-test-devel
multi-test-1.1.0 development package.

Wafter-thin gem to help control rogue test/unit/autorun requires

%description   -n gem-multi-test-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета multi_test.
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
%files         -n gem-multi-test-doc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-multi-test-devel
%endif


%changelog
* Wed Nov 11 2026 Pavel Skrylev <majioa@altlinux.org> 2.0.0-alt1
- ^ 1.1.0 -> 2.0.0

* Mon Jul 06 2026 Alexander Burmatov <thatman@altlinux.org> 1.1.0-alt1
- ^ 0.1.2 -> 1.1.0

* Thu May 13 2021 Pavel Skrylev <majioa@altlinux.org> 0.1.2-alt1
- + packaged gem with Ruby Policy 2.0
