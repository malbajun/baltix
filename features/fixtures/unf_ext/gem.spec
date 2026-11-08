%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname unf_ext

Name:          gem-unf-ext
Version:       0.0.9.1
Release:       alt1
Summary:       Unicode Normalization Form support library for CRuby
License:       MIT
Group:         Development/Ruby
Url:           https://github.com/knu/ruby-unf_ext
Vcs:           https://github.com/knu/ruby-unf_ext.git
Packager:      Pavel Skrylev <majioa@altlinux.org>

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(bundler) >= 1.2
BuildRequires: gem(rake) >= 0.9.2.2
BuildRequires: gem(rake-compiler) >= 1.2.1
BuildRequires: gem(rake-compiler-dock) >= 1.3.0
BuildRequires: gem(rdoc) > 2.4.2
BuildRequires: gem(test-unit) >= 0
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
%ruby_alias_names unf_ext,unf-ext
Requires:      ruby >= 2.2
Provides:      gem(unf_ext) = 0.0.9.1

%description
Unicode Normalization Form support library for CRuby


%if_enabled    doc
%package       -n gem-unf-ext-doc
Version:       0.0.9.1
Release:       alt1
Summary:       Unicode Normalization Form support library for CRuby documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета unf_ext
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(unf_ext) = 0.0.9.1

%description   -n gem-unf-ext-doc
Unicode Normalization Form support library for CRuby documentation files.

%description   -n gem-unf-ext-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета unf_ext.
%endif


%if_enabled    devel
%package       -n gem-unf-ext-devel
Version:       0.0.9.1
Release:       alt1
Summary:       Unicode Normalization Form support library for CRuby development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета unf_ext
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(unf_ext) = 0.0.9.1
Requires:      gem(bundler) >= 1.2
Requires:      gem(rake) >= 0.9.2.2
Requires:      gem(rake-compiler) >= 1.2.1
Requires:      gem(rake-compiler-dock) >= 1.3.0
Requires:      gem(rdoc) > 2.4.2
Requires:      gem(test-unit) >= 0

%description   -n gem-unf-ext-devel
Unicode Normalization Form support library for CRuby development package.

%description   -n gem-unf-ext-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета unf_ext.
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
%doc LICENSE.txt README.md
%ruby_gemspec
%ruby_gemlibdir
%ruby_gemextdir

%if_enabled    doc
%files         -n gem-unf-ext-doc
%doc LICENSE.txt README.md
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-unf-ext-devel
%doc LICENSE.txt README.md
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 0.0.9.1-alt1
- + packaged gem with Ruby Policy 2.0
- * define explicit dependencies
