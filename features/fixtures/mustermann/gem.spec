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
BuildRequires: gem(hansi) >= 0.2.0
BuildRequires: gem(ruby2_keywords) >= 0.0.1
BuildRequires: gem(support) >= 0
BuildConflicts: gem(hansi) >= 0.3
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


%package       -n gem-mustermann-contrib
Version:       2.0.2
Release:       alt1
Summary:       Collection of extensions for Mustermann
Group:         Development/Ruby
BuildArch:     noarch

Requires:      ruby >= 2.2.0
Requires:      gem(hansi) >= 0.2.0
Requires:      gem(mustermann) = 2.0.2
Conflicts:     gem(hansi) >= 0.3
Provides:      gem(mustermann-contrib) = 2.0.2

%description   -n gem-mustermann-contrib
Adds many plugins to Mustermann


%if_enabled    devel
%package       -n gem-mustermann-contrib-devel
Version:       2.0.2
Release:       alt1
Summary:       Collection of extensions for Mustermann development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета mustermann-contrib
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(mustermann-contrib) = 2.0.2

%description   -n gem-mustermann-contrib-devel
Collection of extensions for Mustermann development package.

Adds many plugins to Mustermann

%description   -n gem-mustermann-contrib-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета mustermann-contrib.
%endif


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

%files         -n gem-mustermann-contrib
%doc mustermann-contrib/mustermann-contrib.gemspec
%ruby_gemspecdir/mustermann-contrib-2.0.2.gemspec
%ruby_gemslibdir/mustermann-contrib-2.0.2

%if_enabled    devel
%files         -n gem-mustermann-contrib-devel
%doc mustermann-contrib/mustermann-contrib.gemspec
%endif

%if_enabled    doc
%files         -n gem-mustermann-doc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-mustermann-devel
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 2.0.2-alt1
- + packaged gem with Ruby Policy 2.1
- * define explicit dependencies
