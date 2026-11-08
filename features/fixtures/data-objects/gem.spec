%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname data_objects

Name:          gem-data-objects
Version:       0.10.17
Release:       alt1
Summary:       DataObjects basic API and shared driver specifications
License:       Unlicense
Group:         Development/Ruby
Url:           http://github.com/datamapper/do
Vcs:           https://github.com/datamapper/do.git
Packager:      Pavel Skrylev <majioa@altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(addressable) >= 2.1
BuildRequires: gem(rake) >= 0
BuildRequires: gem(rake-compiler) >= 0.7
BuildRequires: gem(rspec) >= 2.5
BuildRequires: gem(yard) >= 0.5
BuildConflicts: gem(addressable) >= 3
BuildConflicts: gem(rake-compiler) >= 1
BuildConflicts: gem(rspec) >= 3
BuildConflicts: gem(yard) >= 1
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
%ruby_alias_names data_objects,data-objects
Requires:      gem(addressable) >= 2.1
Conflicts:     gem(addressable) >= 3
Provides:      gem(data_objects) = 0.10.17

%description
Provide a standard and simplified API for communicating with RDBMS from Ruby


%package       -n gem-do-sqlite3
Version:       0.10.17
Release:       alt1
Summary:       DataObjects Sqlite3 Driver
Group:         Development/Ruby

Requires:      gem(data_objects) = 0.10.17
Provides:      gem(do_sqlite3) = 0.10.17

%description   -n gem-do-sqlite3
Implements the DataObjects API for Sqlite3


%if_enabled    doc
%package       -n gem-do-sqlite3-doc
Version:       0.10.17
Release:       alt1
Summary:       DataObjects Sqlite3 Driver documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета do_sqlite3
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(do_sqlite3) = 0.10.17

%description   -n gem-do-sqlite3-doc
DataObjects Sqlite3 Driver documentation files.

Implements the DataObjects API for Sqlite3

%description   -n gem-do-sqlite3-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета do_sqlite3.
%endif


%if_enabled    devel
%package       -n gem-do-sqlite3-devel
Version:       0.10.17
Release:       alt1
Summary:       DataObjects Sqlite3 Driver development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета do_sqlite3
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(do_sqlite3) = 0.10.17
Requires:      gem(rake-compiler) >= 0.7
Requires:      gem(rspec) >= 2.5
Conflicts:     gem(rake-compiler) >= 1
Conflicts:     gem(rspec) >= 3

%description   -n gem-do-sqlite3-devel
DataObjects Sqlite3 Driver development package.

Implements the DataObjects API for Sqlite3

%description   -n gem-do-sqlite3-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета do_sqlite3.
%endif


%if_enabled    doc
%package       -n gem-data-objects-doc
Version:       0.10.17
Release:       alt1
Summary:       DataObjects basic API and shared driver specifications documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета data_objects
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(data_objects) = 0.10.17

%description   -n gem-data-objects-doc
DataObjects basic API and shared driver specifications documentation
files.

Provide a standard and simplified API for communicating with RDBMS from Ruby

%description   -n gem-data-objects-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета data_objects.
%endif


%if_enabled    devel
%package       -n gem-data-objects-devel
Version:       0.10.17
Release:       alt1
Summary:       DataObjects basic API and shared driver specifications development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета data_objects
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(data_objects) = 0.10.17
Requires:      gem(rspec) >= 2.5
Requires:      gem(yard) >= 0.5
Conflicts:     gem(rspec) >= 3
Conflicts:     gem(yard) >= 1

%description   -n gem-data-objects-devel
DataObjects basic API and shared driver specifications development
package.

Provide a standard and simplified API for communicating with RDBMS from Ruby

%description   -n gem-data-objects-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета data_objects.
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
%doc ChangeLog.markdown LICENSE README.markdown
%ruby_gemspec
%ruby_gemlibdir

%files         -n gem-do-sqlite3
%doc ChangeLog.markdown LICENSE README.markdown
%ruby_gemspecdir/do_sqlite3-0.10.17.gemspec
%ruby_gemslibdir/do_sqlite3-0.10.17
%ruby_gemsextdir/do_sqlite3-0.10.17

%if_enabled    doc
%files         -n gem-do-sqlite3-doc
%doc ChangeLog.markdown LICENSE README.markdown
%ruby_gemsdocdir/do_sqlite3-0.10.17
%endif

%if_enabled    devel
%files         -n gem-do-sqlite3-devel
%doc ChangeLog.markdown LICENSE README.markdown
%ruby_includedir/*
%endif

%if_enabled    doc
%files         -n gem-data-objects-doc
%doc ChangeLog.markdown LICENSE README.markdown
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-data-objects-devel
%doc ChangeLog.markdown LICENSE README.markdown
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 0.10.17-alt1
- + packaged gem with Ruby Policy 2.0
- * define explicit dependencies
