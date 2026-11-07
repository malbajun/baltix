%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname rails-html-sanitizer

Name:          gem-rails-html-sanitizer
Version:       1.4.4
Release:       alt1
Summary:       This gem is responsible to sanitize HTML fragments in Rails applications
License:       MIT
Group:         Development/Ruby
Url:           https://github.com/rails/rails-html-sanitizer
Vcs:           https://github.com/rails/rails-html-sanitizer.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(activesupport) >= 5
BuildRequires: gem(bundler) >= 1.3
BuildRequires: gem(loofah) >= 2.19.1
BuildRequires: gem(minitest) >= 0
BuildRequires: gem(nokogiri) >= 1.7
BuildRequires: gem(rails-dom-testing) >= 0
BuildRequires: gem(rake) >= 0
BuildConflicts: gem(loofah) >= 3
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      gem(loofah) >= 2.19.1
Conflicts:     gem(loofah) >= 3
Provides:      gem(rails-html-sanitizer) = 1.4.4

%description
HTML sanitization for Rails applications


%if_enabled    doc
%package       -n gem-rails-html-sanitizer-doc
Version:       1.4.4
Release:       alt1
Summary:       This gem is responsible to sanitize HTML fragments in Rails applications documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета rails-html-sanitizer
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(rails-html-sanitizer) = 1.4.4

%description   -n gem-rails-html-sanitizer-doc
This gem is responsible to sanitize HTML fragments in Rails applications
documentation files.

HTML sanitization for Rails applications

%description   -n gem-rails-html-sanitizer-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета rails-html-sanitizer.
%endif


%if_enabled    devel
%package       -n gem-rails-html-sanitizer-devel
Version:       1.4.4
Release:       alt1
Summary:       This gem is responsible to sanitize HTML fragments in Rails applications development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета rails-html-sanitizer
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(rails-html-sanitizer) = 1.4.4
Requires:      gem(activesupport) >= 5
Requires:      gem(bundler) >= 1.3
Requires:      gem(minitest) >= 0
Requires:      gem(nokogiri) >= 1.7
Requires:      gem(rails-dom-testing) >= 0
Requires:      gem(rake) >= 0

%description   -n gem-rails-html-sanitizer-devel
This gem is responsible to sanitize HTML fragments in Rails applications
development package.

HTML sanitization for Rails applications

%description   -n gem-rails-html-sanitizer-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета rails-html-sanitizer.
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
%files         -n gem-rails-html-sanitizer-doc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-rails-html-sanitizer-devel
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 1.4.4-alt1
- + packaged gem with Ruby Policy 2.0
- * define explicit dependencies
