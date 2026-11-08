%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname mixlib-shellout

Name:          gem-mixlib-shellout
Version:       3.2.7
Release:       alt1
Summary:       Run external commands on Unix or Windows
License:       Apache-2.0
Group:         Development/Ruby
Url:           https://github.com/chef/mixlib-shellout
Vcs:           https://github.com/chef/mixlib-shellout.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(chef-utils) >= 0
BuildRequires: gem(chefstyle) = 1.6.2
BuildRequires: gem(pry) >= 0
BuildRequires: gem(pry-byebug) >= 0
BuildRequires: gem(rake) >= 0
BuildRequires: gem(rb-readline) >= 0
BuildRequires: gem(rspec) >= 3.0
BuildConflicts: gem(rspec) >= 4
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      ruby >= 2.5
Requires:      gem(chef-utils) >= 0
Provides:      gem(mixlib-shellout) = 3.2.7

%description
Run external commands on Unix or Windows


%if_enabled    doc
%package       -n gem-mixlib-shellout-doc
Version:       3.2.7
Release:       alt1
Summary:       Run external commands on Unix or Windows documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета mixlib-shellout
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(mixlib-shellout) = 3.2.7

%description   -n gem-mixlib-shellout-doc
Run external commands on Unix or Windows documentation files.

%description   -n gem-mixlib-shellout-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета mixlib-shellout.
%endif


%if_enabled    devel
%package       -n gem-mixlib-shellout-devel
Version:       3.2.7
Release:       alt1
Summary:       Run external commands on Unix or Windows development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета mixlib-shellout
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(mixlib-shellout) = 3.2.7
Requires:      gem(chefstyle) = 1.6.2
Requires:      gem(pry) >= 0
Requires:      gem(pry-byebug) >= 0
Requires:      gem(rake) >= 0
Requires:      gem(rb-readline) >= 0
Requires:      gem(rspec) >= 3.0
Conflicts:     gem(rspec) >= 4

%description   -n gem-mixlib-shellout-devel
Run external commands on Unix or Windows development package.

%description   -n gem-mixlib-shellout-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета mixlib-shellout.
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
%doc LICENSE
%ruby_gemspec
%ruby_gemlibdir

%if_enabled    doc
%files         -n gem-mixlib-shellout-doc
%doc LICENSE
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-mixlib-shellout-devel
%doc LICENSE
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 3.2.7-alt1
- + packaged gem with Ruby Policy 2.1
- * define explicit dependencies
