%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname glut

Name:          gem-glut
Version:       8.3.0
Release:       alt1
Summary:       Glut bindings for OpenGL
License:       Unlicense
Group:         Development/Ruby
Packager:      Pavel Skrylev <majioa@altlinux.org>

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(hoe) >= 0
BuildRequires: gem(mini_portile2) >= 2.1
BuildRequires: gem(rake-compiler) >= 1.0
BuildRequires: gem(rake-compiler-dock) >= 0.6.0
BuildRequires: gem(rdoc) >= 4.0
BuildConflicts: gem(mini_portile2) >= 3
BuildConflicts: gem(rake-compiler) >= 2
BuildConflicts: gem(rake-compiler-dock) >= 0.7
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      ruby >= 1.9.2
Provides:      gem(glut) = 8.3.0

%description
Glut bindings for OpenGL. To be used with the
{opengl}[https://github.com/larskanis/opengl] gem.


%if_enabled    doc
%package       -n gem-glut-doc
Version:       8.3.0
Release:       alt1
Summary:       Glut bindings for OpenGL documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета glut
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(glut) = 8.3.0

%description   -n gem-glut-doc
Glut bindings for OpenGL documentation files.

Glut bindings for OpenGL. To be used with the
{opengl}[https://github.com/larskanis/opengl] gem.

%description   -n gem-glut-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета glut.
%endif


%if_enabled    devel
%package       -n gem-glut-devel
Version:       8.3.0
Release:       alt1
Summary:       Glut bindings for OpenGL development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета glut
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(glut) = 8.3.0
Requires:      gem(hoe) >= 0
Requires:      gem(mini_portile2) >= 2.1
Requires:      gem(rake-compiler) >= 1.0
Requires:      gem(rake-compiler-dock) >= 0.6.0
Requires:      gem(rdoc) >= 4.0
Conflicts:     gem(mini_portile2) >= 3
Conflicts:     gem(rake-compiler) >= 2
Conflicts:     gem(rake-compiler-dock) >= 0.7

%description   -n gem-glut-devel
Glut bindings for OpenGL development package.

Glut bindings for OpenGL. To be used with the
{opengl}[https://github.com/larskanis/opengl] gem.

%description   -n gem-glut-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета glut.
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
%files         -n gem-glut-doc
%doc History.rdoc README.rdoc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-glut-devel
%doc History.rdoc README.rdoc
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 8.3.0-alt1
- + packaged gem with Ruby Policy 2.0
- * define explicit dependencies
