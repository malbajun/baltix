%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    devel

Name:          shared
Version:       20261111
Release:       alt1
License:       Unlicense
Group:         Other
Packager:      Pavel Skrylev <majioa@altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(gapic-common) >= 1.6
BuildRequires: gem(gapic-generator) >= 0
BuildRequires: gem(gapic-generator-ads) >= 0
BuildRequires: gem(gapic-generator-cloud) >= 0
BuildRequires: gem(google-cloud-location) >= 0.4
BuildRequires: gem(google-iam-v1) >= 0.4
BuildRequires: gem(grpc-tools) >= 1.60.0
BuildRequires: gem(minitest) >= 5.16
BuildRequires: gem(minitest-autotest) >= 1.0
BuildRequires: gem(minitest-focus) >= 1.0
BuildRequires: gem(ostruct) >= 0.6.3
BuildRequires: gem(rake) >= 12.0
BuildConflicts: gem(gapic-common) >= 2
BuildConflicts: gem(google-cloud-location) >= 2
BuildConflicts: gem(google-iam-v1) >= 2
BuildConflicts: gem(grpc-tools) >= 1.75.1
BuildConflicts: gem(minitest) >= 6
BuildConflicts: gem(minitest-autotest) >= 2
BuildConflicts: gem(minitest-focus) >= 2
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      gem(gapic-common) >= 1.6
Requires:      gem(gapic-generator) >= 0
Requires:      gem(gapic-generator-ads) >= 0
Requires:      gem(gapic-generator-cloud) >= 0
Requires:      gem(google-cloud-location) >= 0.4
Requires:      gem(google-iam-v1) >= 0.4
Requires:      gem(grpc-tools) >= 1.60.0
Requires:      gem(minitest) >= 5.16
Requires:      gem(minitest-autotest) >= 1.0
Requires:      gem(minitest-focus) >= 1.0
Requires:      gem(ostruct) >= 0.6.3
Requires:      gem(rake) >= 12.0
Conflicts:     gem(gapic-common) >= 2
Conflicts:     gem(google-cloud-location) >= 2
Conflicts:     gem(google-iam-v1) >= 2
Conflicts:     gem(grpc-tools) >= 1.75.1
Conflicts:     gem(minitest) >= 6
Conflicts:     gem(minitest-autotest) >= 2
Conflicts:     gem(minitest-focus) >= 2


%package       -n gapic-generator-ruby
Version:       20261111
Release:       alt1
Group:         Other
BuildArch:     noarch

Requires:      gem(gapic-common) >= 1.6
Requires:      gem(gapic-generator) >= 0
Requires:      gem(gapic-generator-ads) >= 0
Requires:      gem(gapic-generator-cloud) >= 0
Requires:      gem(google-cloud-location) >= 0.4
Requires:      gem(google-iam-v1) >= 0.4
Requires:      gem(grpc-tools) >= 1.60.0
Requires:      gem(minitest) >= 5.16
Requires:      gem(minitest-autotest) >= 1.0
Requires:      gem(minitest-focus) >= 1.0
Requires:      gem(ostruct) >= 0.6.3
Requires:      gem(rake) >= 12.0
Conflicts:     gem(gapic-common) >= 2
Conflicts:     gem(google-cloud-location) >= 2
Conflicts:     gem(google-iam-v1) >= 2
Conflicts:     gem(grpc-tools) >= 1.75.1
Conflicts:     gem(minitest) >= 6
Conflicts:     gem(minitest-autotest) >= 2
Conflicts:     gem(minitest-focus) >= 2


%if_enabled    devel
%package       -n shared-devel
Version:       20261111
Release:       alt1
Summary:       development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета shared
Group:         Development/Ruby
BuildArch:     noarch

Requires:      shared = 20261111-alt1
Requires:      gem(gapic-common) >= 1.6
Requires:      gem(gapic-generator) >= 0
Requires:      gem(gapic-generator-ads) >= 0
Requires:      gem(gapic-generator-cloud) >= 0
Requires:      gem(google-cloud-location) >= 0.4
Requires:      gem(google-iam-v1) >= 0.4
Requires:      gem(grpc-tools) >= 1.60.0
Requires:      gem(minitest) >= 5.16
Requires:      gem(minitest-autotest) >= 1.0
Requires:      gem(minitest-focus) >= 1.0
Requires:      gem(ostruct) >= 0.6.3
Requires:      gem(rake) >= 12.0
Conflicts:     gem(gapic-common) >= 2
Conflicts:     gem(google-cloud-location) >= 2
Conflicts:     gem(google-iam-v1) >= 2
Conflicts:     gem(grpc-tools) >= 1.75.1
Conflicts:     gem(minitest) >= 6
Conflicts:     gem(minitest-autotest) >= 2
Conflicts:     gem(minitest-focus) >= 2

%description   -n shared-devel
development package.

%description   -n shared-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета shared.
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

%files         -n gapic-generator-ruby

%if_enabled    devel
%files         -n shared-devel
%endif


%changelog
* Wed Nov 11 2026 Pavel Skrylev <majioa@altlinux.org> 20261111-alt1
- + packaged gem with Ruby Policy 2.1
