%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname chef

Name:          gem-chef
Version:       19.4.12
Release:       alt1
Summary:       A systems integration framework, built to bring the benefits of configuration management to your entire infrastructure
License:       Apache-2.0
Group:         Development/Ruby
Url:           https://www.chef.io
Vcs:           https://github.com/chef/chef.git
Packager:      Pavel Skrylev <majioa@altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(addressable) >= 2.9.0
BuildRequires: gem(appbundler) >= 0
BuildRequires: gem(aws-sdk-s3) >= 1.91
BuildRequires: gem(aws-sdk-secretsmanager) >= 1.46
BuildRequires: gem(bcrypt_pbkdf) >= 1.0
BuildRequires: gem(chef-cli) >= 0
BuildRequires: gem(chef-licensing) >= 1.3
BuildRequires: gem(chef-ruby-shadow) >= 3.0.0
BuildRequires: gem(chef-vault) >= 0
BuildRequires: gem(chef-zero) >= 15.1.0
BuildRequires: gem(cheffish) >= 0
BuildRequires: gem(concurrent-ruby) >= 1.3.7
BuildRequires: gem(corefoundation) >= 0.3.19
BuildRequires: gem(crack) >= 1.0.1
BuildRequires: gem(csv) >= 3.3.5
BuildRequires: gem(diff-lcs) >= 1.6.0
BuildRequires: gem(ed25519) >= 1.2
BuildRequires: gem(erubis) >= 2.7
BuildRequires: gem(fauxhai-ng) >= 0
BuildRequires: gem(ffi) >= 1.15.5
BuildRequires: gem(ffi-libarchive) >= 1.0.3
BuildRequires: gem(ffi-yajl) > 3.0.0
BuildRequires: gem(fuzzyurl) >= 0
BuildRequires: gem(iniparse) >= 1.4
BuildRequires: gem(inspec) >= 7.1.7
BuildRequires: gem(inspec-core) >= 7.1.7
BuildRequires: gem(inspec-core-bin) >= 7.1.7
BuildRequires: gem(kitchen-dokken) >= 2.0
BuildRequires: gem(kitchen-inspec) >= 3.1.0
BuildRequires: gem(kitchen-vagrant) >= 1.0
BuildRequires: gem(license-acceptance) >= 1.0.5
BuildRequires: gem(mixlib-archive) >= 0.4
BuildRequires: gem(mixlib-authentication) >= 2.1
BuildRequires: gem(mixlib-cli) >= 2.1.1
BuildRequires: gem(mixlib-config) >= 2.2.12
BuildRequires: gem(mixlib-log) >= 2.0.3
BuildRequires: gem(mixlib-shellout) >= 3.3.8
BuildRequires: gem(net-ftp) >= 0
BuildRequires: gem(net-sftp) >= 2.1.2
BuildRequires: gem(ohai) >= 19.0
BuildRequires: gem(openssl) >= 3.3.3
BuildRequires: gem(plist) >= 3.2
BuildRequires: gem(proxifier2) >= 1.1
BuildRequires: gem(pry) >= 0.16.0
BuildRequires: gem(pry-byebug) >= 0
BuildRequires: gem(pry-stack_explorer) >= 0
BuildRequires: gem(racc) >= 0
BuildRequires: gem(rake) >= 12.3.3
BuildRequires: gem(rb-readline) >= 0
BuildRequires: gem(repl_type_completor) >= 0.1.15
BuildRequires: gem(rest-client) >= 0
BuildRequires: gem(rspec) >= 0
BuildRequires: gem(syslog) >= 0
BuildRequires: gem(syslog-logger) >= 1.6
BuildRequires: gem(test-kitchen) >= 0
BuildRequires: gem(tomlrb) >= 1.2
BuildRequires: gem(train-core) >= 3.13.4
BuildRequires: gem(train-rest) >= 0.4.1
BuildRequires: gem(train-winrm) >= 0.2.17
BuildRequires: gem(unf_ext) >= 0.0.9.1
BuildRequires: gem(uri) >= 1.0.4
BuildRequires: gem(vault) >= 0.18.2
BuildRequires: gem(webmock) >= 0
BuildConflicts: gem(aws-sdk-s3) >= 2
BuildConflicts: gem(aws-sdk-secretsmanager) >= 2
BuildConflicts: gem(bcrypt_pbkdf) >= 2
BuildConflicts: gem(chef-licensing) >= 2
BuildConflicts: gem(chef-ruby-shadow) >= 3.1
BuildConflicts: gem(chef-zero) >= 15.2
BuildConflicts: gem(corefoundation) >= 0.4
BuildConflicts: gem(crack) >= 1.1
BuildConflicts: gem(csv) >= 3.4
BuildConflicts: gem(diff-lcs) >= 1.7
BuildConflicts: gem(ed25519) >= 2
BuildConflicts: gem(erubis) >= 3
BuildConflicts: gem(ffi) >= 1.18.0
BuildConflicts: gem(ffi-libarchive) >= 2
BuildConflicts: gem(ffi-yajl) >= 4.0
BuildConflicts: gem(iniparse) >= 2
BuildConflicts: gem(inspec-core) >= 7.2
BuildConflicts: gem(license-acceptance) >= 3
BuildConflicts: gem(mixlib-archive) >= 2.0
BuildConflicts: gem(mixlib-authentication) >= 4
BuildConflicts: gem(mixlib-cli) >= 3.0
BuildConflicts: gem(mixlib-config) >= 4.0
BuildConflicts: gem(mixlib-log) >= 4.0
BuildConflicts: gem(mixlib-shellout) >= 3.5.0
BuildConflicts: gem(net-sftp) >= 5.0
BuildConflicts: gem(ohai) >= 20
BuildConflicts: gem(plist) >= 4
BuildConflicts: gem(proxifier2) >= 2
BuildConflicts: gem(pry) >= 0.17
BuildConflicts: gem(repl_type_completor) >= 0.2
BuildConflicts: gem(syslog-logger) >= 2
BuildConflicts: gem(tomlrb) >= 3.0
BuildConflicts: gem(train-core) >= 4
BuildConflicts: gem(unf_ext) >= 0.0.10
BuildConflicts: gem(uri) >= 1.2.0
BuildConflicts: gem(vault) >= 0.21.0
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
%ruby_use_gem_dependency ffi-yajl > 3.0.0,ffi-yajl < 4.0
Requires:      ruby >= 3.1.0
Requires:      gem(addressable) >= 2.9.0
Requires:      gem(aws-sdk-s3) >= 1.91
Requires:      gem(aws-sdk-secretsmanager) >= 1.46
Requires:      gem(bcrypt_pbkdf) >= 1.0
Requires:      gem(chef-config) = 19.4.12
Requires:      gem(chef-licensing) >= 1.3
Requires:      gem(chef-utils) = 19.4.12
Requires:      gem(chef-vault) >= 0
Requires:      gem(chef-zero) >= 15.1.0
Requires:      gem(corefoundation) >= 0.3.19
Requires:      gem(csv) >= 3.3.5
Requires:      gem(diff-lcs) >= 1.6.0
Requires:      gem(ed25519) >= 1.2
Requires:      gem(erubis) >= 2.7
Requires:      gem(ffi) >= 1.15.5
Requires:      gem(ffi-libarchive) >= 1.0.3
Requires:      gem(ffi-yajl) > 3.0.0
Requires:      gem(iniparse) >= 1.4
Requires:      gem(inspec-core) >= 7.1.7
Requires:      gem(license-acceptance) >= 1.0.5
Requires:      gem(mixlib-archive) >= 0.4
Requires:      gem(mixlib-authentication) >= 2.1
Requires:      gem(mixlib-cli) >= 2.1.1
Requires:      gem(mixlib-log) >= 2.0.3
Requires:      gem(mixlib-shellout) >= 3.3.8
Requires:      gem(net-ftp) >= 0
Requires:      gem(net-sftp) >= 2.1.2
Requires:      gem(ohai) >= 19.0
Requires:      gem(plist) >= 3.2
Requires:      gem(proxifier2) >= 1.1
Requires:      gem(syslog) >= 0
Requires:      gem(syslog-logger) >= 1.6
Requires:      gem(train-core) >= 3.13.4
Requires:      gem(train-rest) >= 0.4.1
Requires:      gem(train-winrm) >= 0.2.17
Requires:      gem(unf_ext) >= 0.0.9.1
Requires:      gem(uri) >= 1.0.4
Requires:      gem(vault) >= 0.18.2
Conflicts:     gem(aws-sdk-s3) >= 2
Conflicts:     gem(aws-sdk-secretsmanager) >= 2
Conflicts:     gem(bcrypt_pbkdf) >= 2
Conflicts:     gem(chef-licensing) >= 2
Conflicts:     gem(chef-zero) >= 15.2
Conflicts:     gem(corefoundation) >= 0.4
Conflicts:     gem(csv) >= 3.4
Conflicts:     gem(diff-lcs) >= 1.7
Conflicts:     gem(ed25519) >= 2
Conflicts:     gem(erubis) >= 3
Conflicts:     gem(ffi) >= 1.18.0
Conflicts:     gem(ffi-libarchive) >= 2
Conflicts:     gem(ffi-yajl) >= 4.0
Conflicts:     gem(iniparse) >= 2
Conflicts:     gem(inspec-core) >= 7.2
Conflicts:     gem(license-acceptance) >= 3
Conflicts:     gem(mixlib-archive) >= 2.0
Conflicts:     gem(mixlib-authentication) >= 4
Conflicts:     gem(mixlib-cli) >= 3.0
Conflicts:     gem(mixlib-log) >= 4.0
Conflicts:     gem(mixlib-shellout) >= 3.5.0
Conflicts:     gem(net-sftp) >= 5.0
Conflicts:     gem(ohai) >= 20
Conflicts:     gem(plist) >= 4
Conflicts:     gem(proxifier2) >= 2
Conflicts:     gem(syslog-logger) >= 2
Conflicts:     gem(train-core) >= 4
Conflicts:     gem(unf_ext) >= 0.0.10
Conflicts:     gem(uri) >= 1.2.0
Conflicts:     gem(vault) >= 0.21.0
Provides:      gem(chef) = 19.4.12

%description
A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure.


%package       -n gem-chef-bin
Version:       19.4.12
Release:       alt1
Summary:       Chef-branded binstubs for chef-client
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(chef) = 19.4.12
Provides:      gem(chef-bin) = 19.4.12

%description   -n gem-chef-bin
A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure.


%package       -n chef
Version:       19.4.12
Release:       alt1
Summary:       Chef-branded binstubs for chef-client executable(s)
Summary(ru_RU.UTF-8): Исполнямка для самоцвета chef-bin
Group:         Other
BuildArch:     noarch

Requires:      gem(chef-bin) = 19.4.12

%description   -n chef
Chef-branded binstubs for chef-client executable(s).

A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure.

%description   -n chef -l ru_RU.UTF-8
Исполнямка для самоцвета chef-bin.


%if_enabled    doc
%package       -n gem-chef-bin-doc
Version:       19.4.12
Release:       alt1
Summary:       Chef-branded binstubs for chef-client documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета chef-bin
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(chef-bin) = 19.4.12

%description   -n gem-chef-bin-doc
Chef-branded binstubs for chef-client documentation files.

A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure.

%description   -n gem-chef-bin-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета chef-bin.
%endif


%if_enabled    devel
%package       -n gem-chef-bin-devel
Version:       19.4.12
Release:       alt1
Summary:       Chef-branded binstubs for chef-client development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета chef-bin
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(chef-bin) = 19.4.12
Requires:      gem(rake) >= 12.3.3

%description   -n gem-chef-bin-devel
Chef-branded binstubs for chef-client development package.

A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure.

%description   -n gem-chef-bin-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета chef-bin.
%endif


%package       -n gem-chef-utils
Version:       19.4.12
Release:       alt1
Summary:       Basic utility functions for Core Chef Infra development
Group:         Development/Ruby
BuildArch:     noarch

Requires:      ruby >= 2.6
Requires:      gem(concurrent-ruby) >= 1.3.7
Provides:      gem(chef-utils) = 19.4.12

%description   -n gem-chef-utils
A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure.


%if_enabled    doc
%package       -n gem-chef-utils-doc
Version:       19.4.12
Release:       alt1
Summary:       Basic utility functions for Core Chef Infra development documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета chef-utils
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(chef-utils) = 19.4.12

%description   -n gem-chef-utils-doc
Basic utility functions for Core Chef Infra development documentation files.

A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure.

%description   -n gem-chef-utils-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета chef-utils.
%endif


%if_enabled    devel
%package       -n gem-chef-utils-devel
Version:       19.4.12
Release:       alt1
Summary:       Basic utility functions for Core Chef Infra development development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета chef-utils
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(chef-utils) = 19.4.12
Requires:      gem(fauxhai-ng) >= 0
Requires:      gem(rake) >= 12.3.3
Requires:      gem(rspec) >= 0

%description   -n gem-chef-utils-devel
Basic utility functions for Core Chef Infra development development package.

A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure.

%description   -n gem-chef-utils-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета chef-utils.
%endif


%package       -n gem-chef-config
Version:       19.4.12
Release:       alt1
Summary:       Chef Infra's default configuration and config loading library
Group:         Development/Ruby
BuildArch:     noarch

Requires:      ruby >= 2.6
Requires:      gem(addressable) >= 2.9.0
Requires:      gem(chef-utils) = 19.4.12
Requires:      gem(fuzzyurl) >= 0
Requires:      gem(mixlib-config) >= 2.2.12
Requires:      gem(mixlib-shellout) >= 2.0
Requires:      gem(racc) >= 0
Requires:      gem(tomlrb) >= 1.2
Conflicts:     gem(mixlib-config) >= 4.0
Conflicts:     gem(mixlib-shellout) >= 4.0
Conflicts:     gem(tomlrb) >= 3.0
Provides:      gem(chef-config) = 19.4.12

%description   -n gem-chef-config
A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure.


%if_enabled    doc
%package       -n gem-chef-config-doc
Version:       19.4.12
Release:       alt1
Summary:       Chef Infra's default configuration and config loading library documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета chef-config
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(chef-config) = 19.4.12

%description   -n gem-chef-config-doc
Chef Infra's default configuration and config loading library documentation
files.

A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure.

%description   -n gem-chef-config-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета chef-config.
%endif


%if_enabled    devel
%package       -n gem-chef-config-devel
Version:       19.4.12
Release:       alt1
Summary:       Chef Infra's default configuration and config loading library development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета chef-config
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(chef-config) = 19.4.12
Requires:      gem(rake) >= 12.3.3
Requires:      gem(rspec) >= 0

%description   -n gem-chef-config-devel
Chef Infra's default configuration and config loading library development
package.

A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure.

%description   -n gem-chef-config-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета chef-config.
%endif


%package       -n kitchen-tests
Version:       20261111
Release:       alt1
Summary:       A systems integration framework, built to bring the benefits of configuration management to your entire infrastructure
Group:         Other
BuildArch:     noarch

Requires:      gem(addressable) >= 2.9.0
Requires:      gem(aws-sdk-s3) >= 1.91
Requires:      gem(aws-sdk-secretsmanager) >= 1.46
Requires:      gem(bcrypt_pbkdf) >= 1.0
Requires:      gem(chef-bin) = 19.4.12
Requires:      gem(chef-config) = 19.4.12
Requires:      gem(chef-licensing) >= 1.3
Requires:      gem(chef-utils) = 19.4.12
Requires:      gem(chef-vault) >= 0
Requires:      gem(chef-zero) >= 15.1.0
Requires:      gem(corefoundation) >= 0.3.19
Requires:      gem(csv) >= 3.3.5
Requires:      gem(diff-lcs) >= 1.6.0
Requires:      gem(ed25519) >= 1.2
Requires:      gem(erubis) >= 2.7
Requires:      gem(ffi) >= 1.15.5
Requires:      gem(ffi-libarchive) >= 1.0.3
Requires:      gem(ffi-yajl) > 3.0.0
Requires:      gem(iniparse) >= 1.4
Requires:      gem(inspec-core) >= 7.1.7
Requires:      gem(license-acceptance) >= 1.0.5
Requires:      gem(mixlib-archive) >= 0.4
Requires:      gem(mixlib-authentication) >= 2.1
Requires:      gem(mixlib-cli) >= 2.1.1
Requires:      gem(mixlib-log) >= 2.0.3
Requires:      gem(mixlib-shellout) >= 3.3.8
Requires:      gem(net-ftp) >= 0
Requires:      gem(net-sftp) >= 2.1.2
Requires:      gem(ohai) >= 19.0
Requires:      gem(plist) >= 3.2
Requires:      gem(proxifier2) >= 1.1
Requires:      gem(syslog) >= 0
Requires:      gem(syslog-logger) >= 1.6
Requires:      gem(train-core) >= 3.13.4
Requires:      gem(train-rest) >= 0.4.1
Requires:      gem(train-winrm) >= 0.2.17
Requires:      gem(unf_ext) >= 0.0.9.1
Requires:      gem(uri) >= 1.0.4
Requires:      gem(vault) >= 0.18.2
Conflicts:     gem(aws-sdk-s3) >= 2
Conflicts:     gem(aws-sdk-secretsmanager) >= 2
Conflicts:     gem(bcrypt_pbkdf) >= 2
Conflicts:     gem(chef-licensing) >= 2
Conflicts:     gem(chef-zero) >= 15.2
Conflicts:     gem(corefoundation) >= 0.4
Conflicts:     gem(csv) >= 3.4
Conflicts:     gem(diff-lcs) >= 1.7
Conflicts:     gem(ed25519) >= 2
Conflicts:     gem(erubis) >= 3
Conflicts:     gem(ffi) >= 1.18.0
Conflicts:     gem(ffi-libarchive) >= 2
Conflicts:     gem(ffi-yajl) >= 4.0
Conflicts:     gem(iniparse) >= 2
Conflicts:     gem(inspec-core) >= 7.2
Conflicts:     gem(license-acceptance) >= 3
Conflicts:     gem(mixlib-archive) >= 2.0
Conflicts:     gem(mixlib-authentication) >= 4
Conflicts:     gem(mixlib-cli) >= 3.0
Conflicts:     gem(mixlib-log) >= 4.0
Conflicts:     gem(mixlib-shellout) >= 3.5.0
Conflicts:     gem(net-sftp) >= 5.0
Conflicts:     gem(ohai) >= 20
Conflicts:     gem(plist) >= 4
Conflicts:     gem(proxifier2) >= 2
Conflicts:     gem(syslog-logger) >= 2
Conflicts:     gem(train-core) >= 4
Conflicts:     gem(unf_ext) >= 0.0.10
Conflicts:     gem(uri) >= 1.2.0
Conflicts:     gem(vault) >= 0.21.0

%description   -n kitchen-tests
A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure.


%if_enabled    devel
%package       -n gem-kitchen-tests-devel
Version:       20261111
Release:       alt1
Summary:       A systems integration framework, built to bring the benefits of configuration management to your entire infrastructure development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета kitchen-tests
Group:         Development/Ruby
BuildArch:     noarch

Requires:      kitchen-tests = 20261111-alt1

%description   -n gem-kitchen-tests-devel
A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure development package.

%description   -n gem-kitchen-tests-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета kitchen-tests.
%endif


%if_enabled    doc
%package       -n gem-chef-doc
Version:       19.4.12
Release:       alt1
Summary:       A systems integration framework, built to bring the benefits of configuration management to your entire infrastructure documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета chef
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(chef) = 19.4.12

%description   -n gem-chef-doc
A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure documentation files.

%description   -n gem-chef-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета chef.
%endif


%if_enabled    devel
%package       -n gem-chef-devel
Version:       19.4.12
Release:       alt1
Summary:       A systems integration framework, built to bring the benefits of configuration management to your entire infrastructure development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета chef
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(chef) = 19.4.12
Requires:      gem(appbundler) >= 0
Requires:      gem(chef-ruby-shadow) >= 3.0.0
Requires:      gem(cheffish) >= 0
Requires:      gem(crack) >= 1.0.1
Requires:      gem(fauxhai-ng) >= 0
Requires:      gem(inspec-core-bin) >= 7.1.7
Requires:      gem(openssl) >= 3.3.3
Requires:      gem(pry) >= 0.16.0
Requires:      gem(pry-byebug) >= 0
Requires:      gem(pry-stack_explorer) >= 0
Requires:      gem(rake) >= 12.3.3
Requires:      gem(rb-readline) >= 0
Requires:      gem(repl_type_completor) >= 0.1.15
Requires:      gem(rest-client) >= 0
Requires:      gem(rspec) >= 0
Requires:      gem(webmock) >= 0
Conflicts:     gem(chef-ruby-shadow) >= 3.1
Conflicts:     gem(crack) >= 1.1
Conflicts:     gem(pry) >= 0.17
Conflicts:     gem(repl_type_completor) >= 0.2

%description   -n gem-chef-devel
A systems integration framework, built to bring the benefits of configuration
management to your entire infrastructure development package.

%description   -n gem-chef-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета chef.
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
%doc LICENSE README.md
%ruby_gemspec
%ruby_gemlibdir

%files         -n gem-chef-bin
%doc LICENSE
%ruby_gemspecdir/chef-bin-19.4.12.gemspec
%ruby_gemslibdir/chef-bin-19.4.12

%files         -n chef
%doc LICENSE
%_bindir/chef-apply
%_bindir/chef-client
%_bindir/chef-resource-inspector
%_bindir/chef-service-manager
%_bindir/chef-shell
%_bindir/chef-solo
%_bindir/chef-windows-service

%if_enabled    doc
%files         -n gem-chef-bin-doc
%doc LICENSE
%ruby_gemsdocdir/chef-bin-19.4.12
%endif

%if_enabled    devel
%files         -n gem-chef-bin-devel
%doc LICENSE
%endif

%files         -n gem-chef-utils
%doc LICENSE
%ruby_gemspecdir/chef-utils-19.4.12.gemspec
%ruby_gemslibdir/chef-utils-19.4.12

%if_enabled    doc
%files         -n gem-chef-utils-doc
%doc LICENSE
%ruby_gemsdocdir/chef-utils-19.4.12
%endif

%if_enabled    devel
%files         -n gem-chef-utils-devel
%doc LICENSE
%endif

%files         -n gem-chef-config
%doc LICENSE
%ruby_gemspecdir/chef-config-19.4.12.gemspec
%ruby_gemslibdir/chef-config-19.4.12

%if_enabled    doc
%files         -n gem-chef-config-doc
%doc LICENSE
%ruby_gemsdocdir/chef-config-19.4.12
%endif

%if_enabled    devel
%files         -n gem-chef-config-devel
%doc LICENSE
%endif

%files         -n kitchen-tests

%if_enabled    devel
%files         -n gem-kitchen-tests-devel
%endif

%if_enabled    doc
%files         -n gem-chef-doc
%doc LICENSE README.md
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-chef-devel
%doc LICENSE README.md
%endif


%changelog
* Wed Nov 11 2026 Pavel Skrylev <majioa@altlinux.org> 19.4.12-alt1
- + packaged gem with Ruby Policy 2.1
- * define explicit dependencies
