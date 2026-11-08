%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname kpeg

Name:          gem-kpeg
Version:       1.3.3
Release:       alt1
Summary:       KPeg is a simple PEG library for Ruby
License:       BSD-3-Clause
Group:         Development/Ruby
Url:           https://github.com/evanphx/kpeg
Vcs:           https://github.com/evanphx/kpeg.git
Packager:      Pavel Skrylev <majioa@altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(minitest) >= 5.16
BuildRequires: gem(rake) >= 0.8
BuildRequires: gem(rdoc) >= 4.0
BuildConflicts: gem(minitest) >= 6
BuildConflicts: gem(rake) >= 15.0
BuildConflicts: gem(rdoc) >= 7
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Provides:      gem(kpeg) = 1.3.3

%description
KPeg is a simple PEG library for Ruby. It provides an API as well as native
grammar to build the grammar.

KPeg strives to provide a simple, powerful API without being too exotic.

KPeg supports direct left recursion of rules via the {OMeta
memoization}[http://www.vpri.org/pdf/tr2008003_experimenting.pdf] trick.


%package       -n kpeg
Version:       1.3.3
Release:       alt1
Summary:       KPeg is a simple PEG library for Ruby executable(s)
Summary(ru_RU.UTF-8): Исполнямка для самоцвета kpeg
Group:         Other
BuildArch:     noarch

Requires:      gem(kpeg) = 1.3.3

%description   -n kpeg
KPeg is a simple PEG library for Ruby executable(s).

KPeg is a simple PEG library for Ruby. It provides an API as well as native
grammar to build the grammar.

KPeg strives to provide a simple, powerful API without being too exotic.

KPeg supports direct left recursion of rules via the {OMeta
memoization}[http://www.vpri.org/pdf/tr2008003_experimenting.pdf] trick.

%description   -n kpeg -l ru_RU.UTF-8
Исполнямка для самоцвета kpeg.


%if_enabled    doc
%package       -n gem-kpeg-doc
Version:       1.3.3
Release:       alt1
Summary:       KPeg is a simple PEG library for Ruby documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета kpeg
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(kpeg) = 1.3.3

%description   -n gem-kpeg-doc
KPeg is a simple PEG library for Ruby documentation files.

KPeg is a simple PEG library for Ruby. It provides an API as well as native
grammar to build the grammar.

KPeg strives to provide a simple, powerful API without being too exotic.

KPeg supports direct left recursion of rules via the {OMeta
memoization}[http://www.vpri.org/pdf/tr2008003_experimenting.pdf] trick.

%description   -n gem-kpeg-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета kpeg.
%endif


%if_enabled    devel
%package       -n gem-kpeg-devel
Version:       1.3.3
Release:       alt1
Summary:       KPeg is a simple PEG library for Ruby development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета kpeg
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(kpeg) = 1.3.3
Requires:      gem(minitest) >= 5.16
Requires:      gem(rake) >= 0.8
Requires:      gem(rdoc) >= 4.0
Conflicts:     gem(minitest) >= 6
Conflicts:     gem(rake) >= 15.0
Conflicts:     gem(rdoc) >= 7

%description   -n gem-kpeg-devel
KPeg is a simple PEG library for Ruby development package.

KPeg is a simple PEG library for Ruby. It provides an API as well as native
grammar to build the grammar.

KPeg strives to provide a simple, powerful API without being too exotic.

KPeg supports direct left recursion of rules via the {OMeta
memoization}[http://www.vpri.org/pdf/tr2008003_experimenting.pdf] trick.

%description   -n gem-kpeg-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета kpeg.
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
%doc History.txt LICENSE README.rdoc
%ruby_gemspec
%ruby_gemlibdir

%files         -n kpeg
%doc History.txt LICENSE README.rdoc
%_bindir/kpeg

%if_enabled    doc
%files         -n gem-kpeg-doc
%doc History.txt LICENSE README.rdoc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-kpeg-devel
%doc History.txt LICENSE README.rdoc
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 1.3.3-alt1
- + packaged gem with Ruby Policy 2.0
- * define explicit dependencies
