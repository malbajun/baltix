%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname compass

Name:          gem-compass
Version:       1.1.0
Release:       alt1
Summary:       A Real Stylesheet Framework
License:       MIT
Group:         Development/Ruby
Url:           http://compass-style.org
Packager:      Pavel Skrylev <majioa@altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(bundler) >= 1.3
BuildRequires: gem(chunky_png) >= 1.2
BuildRequires: gem(colorize) >= 0
BuildRequires: gem(compass-validator) >= 3.0.1
BuildRequires: gem(css_parser) >= 1.0.1
BuildRequires: gem(cucumber) >= 1.2.1
BuildRequires: gem(diff-lcs) >= 1.1.2
BuildRequires: gem(minitest) >= 2.12.1
BuildRequires: gem(mocha) >= 0.11.4
BuildRequires: gem(multi_json) >= 1.0
BuildRequires: gem(pry) >= 0
BuildRequires: gem(rake) >= 0
BuildRequires: gem(rb-fsevent) >= 0.9.3
BuildRequires: gem(rb-inotify) >= 0.9
BuildRequires: gem(rspec) >= 2.0.0
BuildRequires: gem(ruby_gntp) >= 0
BuildRequires: gem(rubyzip) >= 0.9.9
BuildRequires: gem(sass) >= 3.3.13
BuildRequires: gem(sass-globbing) >= 1.1.1
BuildRequires: gem(timecop) >= 0.5.9.2
BuildRequires: gem(true) >= 0.2.3
BuildConflicts: gem(bundler) >= 2
BuildConflicts: gem(chunky_png) >= 2
BuildConflicts: gem(css_parser) >= 1.1
BuildConflicts: gem(cucumber) >= 1.3
BuildConflicts: gem(diff-lcs) >= 1.2
BuildConflicts: gem(multi_json) >= 2
BuildConflicts: gem(rspec) >= 2.1
BuildConflicts: gem(sass) >= 3.4
BuildConflicts: gem(sass-globbing) >= 1.2
BuildConflicts: gem(timecop) >= 0.5.10
BuildConflicts: gem(true) >= 0.3
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      gem(chunky_png) >= 1.2
Requires:      gem(compass-core) = 1.1.0
Requires:      gem(compass-import-once) = 1.1.0
Requires:      gem(rb-fsevent) >= 0.9.3
Requires:      gem(rb-inotify) >= 0.9
Requires:      gem(sass) >= 3.3.13
Conflicts:     gem(chunky_png) >= 2
Conflicts:     gem(sass) >= 3.4
Provides:      gem(compass) = 1.1.0

%description
Compass is a Sass-based Stylesheet Framework that streamlines the creation and
maintenance of CSS.


%package       -n gem-compass-core
Version:       1.1.0
Release:       alt1
Summary:       The Compass core stylesheet library
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(multi_json) >= 1.0
Requires:      gem(sass) >= 3.3.0
Conflicts:     gem(multi_json) >= 2
Conflicts:     gem(sass) >= 3.5
Provides:      gem(compass-core) = 1.1.0

%description   -n gem-compass-core
The Compass core stylesheet library and minimum required ruby extensions. This
library can be used stand-alone without the compass ruby configuration file or
compass command line tools.


%if_enabled    doc
%package       -n gem-compass-core-doc
Version:       1.1.0
Release:       alt1
Summary:       The Compass core stylesheet library documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета compass-core
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(compass-core) = 1.1.0

%description   -n gem-compass-core-doc
The Compass core stylesheet library documentation files.

The Compass core stylesheet library and minimum required ruby extensions. This
library can be used stand-alone without the compass ruby configuration file or
compass command line tools.

%description   -n gem-compass-core-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета compass-core.
%endif


%if_enabled    devel
%package       -n gem-compass-core-devel
Version:       1.1.0
Release:       alt1
Summary:       The Compass core stylesheet library development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета compass-core
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(compass-core) = 1.1.0
Requires:      gem(bundler) >= 0
Requires:      gem(diff-lcs) >= 1.1.2
Requires:      gem(pry) >= 0
Requires:      gem(rake) >= 0
Requires:      gem(timecop) >= 0.5.9.2
Requires:      gem(true) >= 0.2.3
Conflicts:     gem(diff-lcs) >= 1.2
Conflicts:     gem(timecop) >= 0.5.10
Conflicts:     gem(true) >= 0.3

%description   -n gem-compass-core-devel
The Compass core stylesheet library development package.

The Compass core stylesheet library and minimum required ruby extensions. This
library can be used stand-alone without the compass ruby configuration file or
compass command line tools.

%description   -n gem-compass-core-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета compass-core.
%endif


%package       -n gem-compass-import-once
Version:       1.1.0
Release:       alt1
Summary:       Speed up your Sass compilation by making @import only import each file once
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(sass) >= 3.2
Conflicts:     gem(sass) >= 3.5
Provides:      gem(compass-import-once) = 1.1.0

%description   -n gem-compass-import-once
Changes the behavior of Sass's @import directive to only import a file once.


%if_enabled    doc
%package       -n gem-compass-import-once-doc
Version:       1.1.0
Release:       alt1
Summary:       Speed up your Sass compilation by making @import only import each file once documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета compass-import-once
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(compass-import-once) = 1.1.0

%description   -n gem-compass-import-once-doc
Speed up your Sass compilation by making @import only import each file once
documentation files.

Changes the behavior of Sass's @import directive to only import a file once.

%description   -n gem-compass-import-once-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета compass-import-once.
%endif


%if_enabled    devel
%package       -n gem-compass-import-once-devel
Version:       1.1.0
Release:       alt1
Summary:       Speed up your Sass compilation by making @import only import each file once development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета compass-import-once
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(compass-import-once) = 1.1.0
Requires:      gem(bundler) >= 1.3
Requires:      gem(diff-lcs) >= 0
Requires:      gem(rake) >= 0
Requires:      gem(sass-globbing) >= 0
Conflicts:     gem(bundler) >= 2

%description   -n gem-compass-import-once-devel
Speed up your Sass compilation by making @import only import each file once
development package.

Changes the behavior of Sass's @import directive to only import a file once.

%description   -n gem-compass-import-once-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета compass-import-once.
%endif


%package       -n compass
Version:       1.1.0
Release:       alt1
Summary:       A Real Stylesheet Framework executable(s)
Summary(ru_RU.UTF-8): Исполнямка для самоцвета compass
Group:         Other
BuildArch:     noarch

Requires:      gem(compass) = 1.1.0
Requires:      gem(colorize) >= 0
Requires:      gem(compass-validator) >= 3.0.1
Requires:      gem(css_parser) >= 1.0.1
Requires:      gem(cucumber) >= 1.2.1
Requires:      gem(diff-lcs) >= 1.1.2
Requires:      gem(minitest) >= 2.12.1
Requires:      gem(mocha) >= 0.11.4
Requires:      gem(pry) >= 0
Requires:      gem(rake) >= 0
Requires:      gem(rb-fsevent) >= 0.9.3
Requires:      gem(rspec) >= 2.0.0
Requires:      gem(ruby_gntp) >= 0
Requires:      gem(rubyzip) >= 0.9.9
Requires:      gem(sass) >= 3.3.13
Requires:      gem(sass-globbing) >= 1.1.1
Requires:      gem(true) >= 0.2.3
Conflicts:     gem(css_parser) >= 1.1
Conflicts:     gem(cucumber) >= 1.3
Conflicts:     gem(diff-lcs) >= 1.2
Conflicts:     gem(rspec) >= 2.1
Conflicts:     gem(sass) >= 3.4
Conflicts:     gem(sass-globbing) >= 1.2
Conflicts:     gem(true) >= 0.3

%description   -n compass
A Real Stylesheet Framework executable(s).

Compass is a Sass-based Stylesheet Framework that streamlines the creation and
maintenance of CSS.

%description   -n compass -l ru_RU.UTF-8
Исполнямка для самоцвета compass.


%if_enabled    doc
%package       -n gem-compass-doc
Version:       1.1.0
Release:       alt1
Summary:       A Real Stylesheet Framework documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета compass
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(compass) = 1.1.0

%description   -n gem-compass-doc
A Real Stylesheet Framework documentation files.

Compass is a Sass-based Stylesheet Framework that streamlines the creation and
maintenance of CSS.

%description   -n gem-compass-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета compass.
%endif


%if_enabled    devel
%package       -n gem-compass-devel
Version:       1.1.0
Release:       alt1
Summary:       A Real Stylesheet Framework development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета compass
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(compass) = 1.1.0
Requires:      gem(colorize) >= 0
Requires:      gem(compass-validator) >= 3.0.1
Requires:      gem(css_parser) >= 1.0.1
Requires:      gem(cucumber) >= 1.2.1
Requires:      gem(diff-lcs) >= 1.1.2
Requires:      gem(minitest) >= 2.12.1
Requires:      gem(mocha) >= 0.11.4
Requires:      gem(pry) >= 0
Requires:      gem(rake) >= 0
Requires:      gem(rspec) >= 2.0.0
Requires:      gem(ruby_gntp) >= 0
Requires:      gem(rubyzip) >= 0.9.9
Requires:      gem(sass-globbing) >= 1.1.1
Requires:      gem(true) >= 0.2.3
Conflicts:     gem(css_parser) >= 1.1
Conflicts:     gem(cucumber) >= 1.3
Conflicts:     gem(diff-lcs) >= 1.2
Conflicts:     gem(rspec) >= 2.1
Conflicts:     gem(sass-globbing) >= 1.2
Conflicts:     gem(true) >= 0.3

%description   -n gem-compass-devel
A Real Stylesheet Framework development package.

Compass is a Sass-based Stylesheet Framework that streamlines the creation and
maintenance of CSS.

%description   -n gem-compass-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета compass.
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
%doc LICENSE.markdown
%ruby_gemspec
%ruby_gemlibdir

%files         -n gem-compass-core
%doc core/LICENSE.txt core/README.md
%ruby_gemspecdir/compass-core-1.1.0.gemspec
%ruby_gemslibdir/compass-core-1.1.0

%if_enabled    doc
%files         -n gem-compass-core-doc
%doc core/LICENSE.txt core/README.md
%ruby_gemsdocdir/compass-core-1.1.0
%endif

%if_enabled    devel
%files         -n gem-compass-core-devel
%doc core/LICENSE.txt core/README.md
%endif

%files         -n gem-compass-import-once
%doc import-once/LICENSE.txt import-once/README.md
%ruby_gemspecdir/compass-import-once-1.1.0.gemspec
%ruby_gemslibdir/compass-import-once-1.1.0

%if_enabled    doc
%files         -n gem-compass-import-once-doc
%doc import-once/LICENSE.txt import-once/README.md
%ruby_gemsdocdir/compass-import-once-1.1.0
%endif

%if_enabled    devel
%files         -n gem-compass-import-once-devel
%doc import-once/LICENSE.txt import-once/README.md
%endif

%files         -n compass
%doc LICENSE.markdown
%_bindir/compass

%if_enabled    doc
%files         -n gem-compass-doc
%doc LICENSE.markdown
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-compass-devel
%doc LICENSE.markdown
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 1.1.0-alt1
- + packaged gem with Ruby Policy 2.1
- * define explicit dependencies
