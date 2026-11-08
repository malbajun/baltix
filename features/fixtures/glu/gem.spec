%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname glu

Name:          gem-glu
Version:       8.3.0
Release:       alt1
Summary:       Glu bindings for the opengl gem, split into a separate gem because of Glu deprecation
License:       Unlicense
Group:         Development/Ruby
Packager:      Pavel Skrylev <majioa@altlinux.org>

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(hoe) >= 0
BuildRequires: gem(rake-compiler) >= 1.0
BuildRequires: gem(rake-compiler-dock) >= 0.6.0
BuildRequires: gem(rdoc) >= 4.0
BuildConflicts: gem(rake-compiler) >= 2
BuildConflicts: gem(rake-compiler-dock) >= 0.7
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      ruby >= 1.9.2
Provides:      gem(glu) = 8.3.0

%description
Glu bindings for the opengl gem, split into a separate gem because of Glu
deprecation.


%if_enabled    doc
%package       -n gem-glu-doc
Version:       8.3.0
Release:       alt1
Summary:       Glu bindings for the opengl gem, split into a separate gem because of Glu deprecation documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета glu
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(glu) = 8.3.0

%description   -n gem-glu-doc
Glu bindings for the opengl gem, split into a separate gem because of Glu
deprecation documentation files.

%description   -n gem-glu-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета glu.
%endif


%if_enabled    devel
%package       -n gem-glu-devel
Version:       8.3.0
Release:       alt1
Summary:       Glu bindings for the opengl gem, split into a separate gem because of Glu deprecation development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета glu
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(glu) = 8.3.0
Requires:      gem(hoe) >= 0
Requires:      gem(rake-compiler) >= 1.0
Requires:      gem(rake-compiler-dock) >= 0.6.0
Requires:      gem(rdoc) >= 4.0
Conflicts:     gem(rake-compiler) >= 2
Conflicts:     gem(rake-compiler-dock) >= 0.7

%description   -n gem-glu-devel
Glu bindings for the opengl gem, split into a separate gem because of Glu
deprecation development package.

%description   -n gem-glu-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета glu.
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
%doc History.rdoc README.rdoc
%ruby_gemspec
%ruby_gemlibdir
%ruby_gemextdir

%if_enabled    doc
%files         -n gem-glu-doc
%doc History.rdoc README.rdoc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-glu-devel
%doc History.rdoc README.rdoc
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 8.3.0-alt1
- + packaged gem with Ruby Policy 2.1
- * define explicit dependencies
