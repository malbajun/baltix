%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname mustermann

Name:          gem-mustermann
Version:       2.0.2
Release:       alt1
Summary:       Your personal string matching expert
License:       MIT
Group:         Development/Ruby
Url:           https://github.com/sinatra/mustermann
Vcs:           https://github.com/sinatra/mustermann.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(ruby2_keywords) >= 0.0.1
BuildConflicts: gem(ruby2_keywords) >= 0.1
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      ruby >= 2.2.0
Requires:      gem(ruby2_keywords) >= 0.0.1
Conflicts:     gem(ruby2_keywords) >= 0.1
Provides:      gem(mustermann) = 2.0.2

%description
A library implementing patterns that behave like regular expressions.


%if_enabled    doc
%package       -n gem-mustermann-doc
Version:       2.0.2
Release:       alt1
Summary:       Your personal string matching expert documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета mustermann
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(mustermann) = 2.0.2

%description   -n gem-mustermann-doc
Your personal string matching expert documentation files.

A library implementing patterns that behave like regular expressions.

%description   -n gem-mustermann-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета mustermann.
%endif


%if_enabled    devel
%package       -n gem-mustermann-devel
Version:       2.0.2
Release:       alt1
Summary:       Your personal string matching expert development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета mustermann
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(mustermann) = 2.0.2

%description   -n gem-mustermann-devel
Your personal string matching expert development package.

A library implementing patterns that behave like regular expressions.

%description   -n gem-mustermann-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета mustermann.
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
%files         -n gem-mustermann-doc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-mustermann-devel
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 2.0.2-alt1
- + packaged gem with Ruby Policy 2.0
- * define explicit dependencies
