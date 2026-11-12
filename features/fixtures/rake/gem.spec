%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname rake

Name:          gem-rake
Version:       13.4.2
Release:       alt1
Summary:       Rake is a Make-like program implemented in Ruby
License:       MIT
Group:         Development/Ruby
Url:           https://github.com/ruby/rake
Vcs:           https://github.com/ruby/rake.git
Packager:      Pavel Skrylev <majioa@altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(coveralls) >= 0
BuildRequires: gem(rdoc) >= 0
BuildRequires: gem(rubocop) >= 0
BuildRequires: gem(test-unit) >= 0
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      ruby >= 2.3
Provides:      gem(rake) = 13.4.2

%description
Rake is a Make-like program implemented in Ruby. Tasks and dependencies are
specified in standard Ruby syntax. Rake has the following features: * Rakefiles
(rake's version of Makefiles) are completely defined in standard Ruby syntax. No
XML files to edit. No quirky Makefile syntax to worry about (is that a tab or a
space?) * Users can specify tasks with prerequisites. * Rake supports rule
patterns to synthesize implicit tasks. * Flexible FileLists that act like arrays
but know about manipulating file names and paths. * Supports parallel execution
of tasks.


%package       -n rake
Version:       13.4.2
Release:       alt1
Summary:       Rake is a Make-like program implemented in Ruby executable(s)
Summary(ru_RU.UTF-8): Исполнямка для самоцвета rake
Group:         Other
BuildArch:     noarch

Requires:      gem(rake) = 13.4.2

%description   -n rake
Rake is a Make-like program implemented in Ruby executable(s).

Rake is a Make-like program implemented in Ruby. Tasks and dependencies are
specified in standard Ruby syntax. Rake has the following features: * Rakefiles
(rake's version of Makefiles) are completely defined in standard Ruby syntax. No
XML files to edit. No quirky Makefile syntax to worry about (is that a tab or a
space?) * Users can specify tasks with prerequisites. * Rake supports rule
patterns to synthesize implicit tasks. * Flexible FileLists that act like arrays
but know about manipulating file names and paths. * Supports parallel execution
of tasks.

%description   -n rake -l ru_RU.UTF-8
Исполнямка для самоцвета rake.


%if_enabled    doc
%package       -n gem-rake-doc
Version:       13.4.2
Release:       alt1
Summary:       Rake is a Make-like program implemented in Ruby documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета rake
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(rake) = 13.4.2

%description   -n gem-rake-doc
Rake is a Make-like program implemented in Ruby documentation files.

Rake is a Make-like program implemented in Ruby. Tasks and dependencies are
specified in standard Ruby syntax. Rake has the following features: * Rakefiles
(rake's version of Makefiles) are completely defined in standard Ruby syntax. No
XML files to edit. No quirky Makefile syntax to worry about (is that a tab or a
space?) * Users can specify tasks with prerequisites. * Rake supports rule
patterns to synthesize implicit tasks. * Flexible FileLists that act like arrays
but know about manipulating file names and paths. * Supports parallel execution
of tasks.

%description   -n gem-rake-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета rake.
%endif


%if_enabled    devel
%package       -n gem-rake-devel
Version:       13.4.2
Release:       alt1
Summary:       Rake is a Make-like program implemented in Ruby development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета rake
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(rake) = 13.4.2
Requires:      gem(coveralls) >= 0
Requires:      gem(rdoc) >= 0
Requires:      gem(rubocop) >= 0
Requires:      gem(test-unit) >= 0

%description   -n gem-rake-devel
Rake is a Make-like program implemented in Ruby development package.

Rake is a Make-like program implemented in Ruby. Tasks and dependencies are
specified in standard Ruby syntax. Rake has the following features: * Rakefiles
(rake's version of Makefiles) are completely defined in standard Ruby syntax. No
XML files to edit. No quirky Makefile syntax to worry about (is that a tab or a
space?) * Users can specify tasks with prerequisites. * Rake supports rule
patterns to synthesize implicit tasks. * Flexible FileLists that act like arrays
but know about manipulating file names and paths. * Supports parallel execution
of tasks.

%description   -n gem-rake-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета rake.
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
%doc History.rdoc MIT-LICENSE README.rdoc
%ruby_gemspec
%ruby_gemlibdir

%files         -n rake
%doc History.rdoc MIT-LICENSE README.rdoc
%_bindir/rake
%_mandir/rake.1*

%if_enabled    doc
%files         -n gem-rake-doc
%doc History.rdoc MIT-LICENSE README.rdoc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-rake-devel
%doc History.rdoc MIT-LICENSE README.rdoc
%endif


%changelog
* Thu Nov 12 2026 Pavel Skrylev <majioa@altlinux.org> 13.4.2-alt1
- + packaged gem with Ruby Policy 2.1
- * define explicit dependencies
