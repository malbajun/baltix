%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname hiredis

Name:          gem-hiredis
Version:       0.6.3
Release:       alt1
Summary:       Ruby wrapper for hiredis (protocol serialization/deserialization and blocking I/O)
License:       BSD-3-Clause
Group:         Development/Ruby
Url:           http://github.com/redis/hiredis-rb
Vcs:           https://github.com/redis/hiredis-rb.git
Packager:      Pavel Skrylev <majioa@altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(minitest) >= 5.5.1
BuildRequires: gem(rake) >= 0
BuildRequires: gem(rake-compiler) >= 0.7.1
BuildConflicts: gem(minitest) >= 7
BuildConflicts: gem(rake-compiler) >= 2
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
%ruby_use_gem_dependency minitest >= 5.5.1,minitest < 7
%ruby_use_gem_dependency rake-compiler >= 0.7.1,rake-compiler < 2
Provides:      gem(hiredis) = 0.6.3

%description
Ruby wrapper for hiredis (protocol serialization/deserialization and blocking
I/O)


%if_enabled    doc
%package       -n gem-hiredis-doc
Version:       0.6.3
Release:       alt1
Summary:       Ruby wrapper for hiredis (protocol serialization/deserialization and blocking I/O) documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета hiredis
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(hiredis) = 0.6.3

%description   -n gem-hiredis-doc
Ruby wrapper for hiredis (protocol serialization/deserialization and blocking
I/O) documentation files.

Ruby wrapper for hiredis (protocol serialization/deserialization and blocking
I/O)

%description   -n gem-hiredis-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета hiredis.
%endif


%if_enabled    devel
%package       -n gem-hiredis-devel
Version:       0.6.3
Release:       alt1
Summary:       Ruby wrapper for hiredis (protocol serialization/deserialization and blocking I/O) development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета hiredis
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(hiredis) = 0.6.3
Requires:      gem(minitest) >= 5.5.1
Requires:      gem(rake) >= 0
Requires:      gem(rake-compiler) >= 0.7.1
Conflicts:     gem(minitest) >= 7
Conflicts:     gem(rake-compiler) >= 2

%description   -n gem-hiredis-devel
Ruby wrapper for hiredis (protocol serialization/deserialization and blocking
I/O) development package.

Ruby wrapper for hiredis (protocol serialization/deserialization and blocking
I/O)

%description   -n gem-hiredis-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета hiredis.
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
%doc COPYING
%ruby_gemspec
%ruby_gemlibdir

%if_enabled    doc
%files         -n gem-hiredis-doc
%doc COPYING
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-hiredis-devel
%doc COPYING
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 0.6.3-alt1
- + packaged gem with Ruby Policy 2.1
- * define explicit dependencies
