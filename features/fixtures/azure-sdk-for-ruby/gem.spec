# vim: set ft=spec: -*- rpm-spec -*-
%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel

Name:          azure-sdk-for-ruby
Version:       20200316
Release:       alt1.7
Summary:       Ruby SDK for Azure Resource Manager
License:       MIT
Group:         Development/Ruby
Url:           https://aka.ms/azure-sdk-for-ruby
Vcs:           https://github.com/azure/azure-sdk-for-ruby.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(bundler) >= 0
BuildRequires: gem(concurrent-ruby) >= 1.0
BuildRequires: gem(faraday) >= 0.9
BuildRequires: gem(faraday-cookie_jar) >= 0.0.6
BuildRequires: gem(rake) >= 10.0
BuildRequires: gem(rspec) >= 3.3
BuildRequires: gem(timeliness) >= 0.3.10
BuildConflicts: gem(concurrent-ruby) >= 2
BuildConflicts: gem(faraday) >= 2.0.0
BuildConflicts: gem(faraday-cookie_jar) >= 0.1
BuildConflicts: gem(rake) >= 11
BuildConflicts: gem(rspec) >= 4
BuildConflicts: gem(timeliness) >= 0.4
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
%ruby_ignore_names azure_sdk,gem-azure-sdk-for-ruby,azure-sdk-for-ruby
Requires:      gem(ms_rest) = 0.7.6
Requires:      gem(ms_rest_azure) = 0.12.0

%description
Ruby SDK for Azure Resource Manager: build and manage your Azure cloud
infrastructure (Compute, Virtual Networks, Storage, etc...) using Ruby.

This project provides a Ruby package for Azure Resource Management (ARM).


%package       -n gem-ms-rest
Version:       0.7.6
Release:       alt1.7
Summary:       Client Library for Ruby
Group:         Development/Ruby
BuildArch:     noarch

Requires:      ruby >= 2.0.0
Requires:      gem(concurrent-ruby) >= 1.0
Requires:      gem(faraday) >= 0.9
Requires:      gem(timeliness) >= 0.3.10
Conflicts:     gem(concurrent-ruby) >= 2
Conflicts:     gem(faraday) >= 2.0.0
Conflicts:     gem(timeliness) >= 0.4
Provides:      gem(ms_rest) = 0.7.6

%description   -n gem-ms-rest
Client Library for Ruby.


%if_enabled    doc
%package       -n gem-ms-rest-doc
Version:       0.7.6
Release:       alt1.7
Summary:       Client Library for Ruby documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета ms_rest
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(ms_rest) = 0.7.6

%description   -n gem-ms-rest-doc
Client Library for Ruby documentation files.

%description   -n gem-ms-rest-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета ms_rest.
%endif


%if_enabled    devel
%package       -n gem-ms-rest-devel
Version:       0.7.6
Release:       alt1.7
Summary:       Client Library for Ruby development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета ms_rest
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(ms_rest) = 0.7.6
Requires:      gem(bundler) >= 0
Requires:      gem(rake) >= 10.0
Requires:      gem(rspec) >= 3.3
Conflicts:     gem(rake) >= 11
Conflicts:     gem(rspec) >= 4

%description   -n gem-ms-rest-devel
Client Library for Ruby development package.

%description   -n gem-ms-rest-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета ms_rest.
%endif


%package       -n gem-ms-rest-azure
Version:       0.12.0
Release:       alt1.7
Summary:       Azure Client Library for Ruby
Group:         Development/Ruby
BuildArch:     noarch

Requires:      ruby >= 2.0.0
Requires:      gem(concurrent-ruby) >= 1.0
Requires:      gem(faraday) >= 0.9
Requires:      gem(faraday-cookie_jar) >= 0.0.6
Requires:      gem(ms_rest) = 0.7.6
Conflicts:     gem(concurrent-ruby) >= 2
Conflicts:     gem(faraday) >= 2.0.0
Conflicts:     gem(faraday-cookie_jar) >= 0.1
Provides:      gem(ms_rest_azure) = 0.12.0

%description   -n gem-ms-rest-azure
Azure Client Library for Ruby.


%if_enabled    doc
%package       -n gem-ms-rest-azure-doc
Version:       0.12.0
Release:       alt1.7
Summary:       Azure Client Library for Ruby documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета ms_rest_azure
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(ms_rest_azure) = 0.12.0

%description   -n gem-ms-rest-azure-doc
Azure Client Library for Ruby documentation files.

%description   -n gem-ms-rest-azure-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета ms_rest_azure.
%endif


%if_enabled    devel
%package       -n gem-ms-rest-azure-devel
Version:       0.12.0
Release:       alt1.7
Summary:       Azure Client Library for Ruby development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета ms_rest_azure
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(ms_rest_azure) = 0.12.0
Requires:      gem(bundler) >= 0
Requires:      gem(rake) >= 10.0
Requires:      gem(rspec) >= 3.3
Conflicts:     gem(rake) >= 11
Conflicts:     gem(rspec) >= 4

%description   -n gem-ms-rest-azure-devel
Azure Client Library for Ruby development package.

%description   -n gem-ms-rest-azure-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета ms_rest_azure.
%endif


%if_enabled    devel
%package       -n azure-sdk-for-ruby-devel
Version:       20200316
Release:       alt1.7
Summary:       Ruby SDK for Azure Resource Manager development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета azure-sdk-for-ruby
Group:         Development/Ruby
BuildArch:     noarch

Requires:      azure-sdk-for-ruby = 20200316-alt1.7
Requires:      gem(bundler) >= 0
Requires:      gem(concurrent-ruby) >= 1.0
Requires:      gem(faraday) >= 0.9
Requires:      gem(faraday-cookie_jar) >= 0.0.6
Requires:      gem(ms_rest) = 0.7.6
Requires:      gem(ms_rest_azure) = 0.12.0
Requires:      gem(rake) >= 10.0
Requires:      gem(rspec) >= 3.3
Requires:      gem(timeliness) >= 0.3.10
Conflicts:     gem(concurrent-ruby) >= 2
Conflicts:     gem(faraday) >= 2.0.0
Conflicts:     gem(faraday-cookie_jar) >= 0.1
Conflicts:     gem(rake) >= 11
Conflicts:     gem(rspec) >= 4
Conflicts:     gem(timeliness) >= 0.4

%description   -n azure-sdk-for-ruby-devel
Ruby SDK for Azure Resource Manager development package.

Ruby SDK for Azure Resource Manager: build and manage your Azure cloud
infrastructure (Compute, Virtual Networks, Storage, etc...) using Ruby.

This project provides a Ruby package for Azure Resource Management (ARM).

%description   -n azure-sdk-for-ruby-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета azure-sdk-for-ruby.
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

%files         -n gem-ms-rest
%ruby_gemspecdir/ms_rest-0.7.6.gemspec
%ruby_gemslibdir/ms_rest-0.7.6

%if_enabled    doc
%files         -n gem-ms-rest-doc
%ruby_gemsdocdir/ms_rest-0.7.6
%endif

%if_enabled    devel
%files         -n gem-ms-rest-devel
%endif

%files         -n gem-ms-rest-azure
%ruby_gemspecdir/ms_rest_azure-0.12.0.gemspec
%ruby_gemslibdir/ms_rest_azure-0.12.0

%if_enabled    doc
%files         -n gem-ms-rest-azure-doc
%ruby_gemsdocdir/ms_rest_azure-0.12.0
%endif

%if_enabled    devel
%files         -n gem-ms-rest-azure-devel
%endif

%if_enabled    devel
%files         -n azure-sdk-for-ruby-devel
%endif


%changelog
* Thu Nov 12 2026 Pavel Skrylev <majioa@altlinux.org> 20200316-alt1.7
- ! spec

* Thu Jun 13 2024 Pavel Skrylev <majioa@altlinux.org> 20200316-alt1.6
- - disabled autoreq/autoprov (used auto static) to reduce build time
    (closes #39339)
