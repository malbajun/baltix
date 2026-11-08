%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname redis-client

Name:          gem-redis-client
Version:       0.31.0
Release:       alt1
Summary:       Simple low-level client for Redis 6+
License:       MIT
Group:         Development/Ruby
Url:           https://github.com/redis-rb/redis-client
Vcs:           https://github.com/redis-rb/redis-client.git
Packager:      Pavel Skrylev <majioa@altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-macros-ruby setup-rb rake
%if_enabled check
BuildRequires: gem(base64) >= 0
BuildRequires: gem(benchmark) >= 0
BuildRequires: gem(benchmark-ips) >= 0
BuildRequires: gem(cgi) >= 0.5.0
BuildRequires: gem(connection_pool) >= 0
BuildRequires: gem(hiredis) >= 0
BuildRequires: gem(megatest) >= 0
BuildRequires: gem(ostruct) >= 0
BuildRequires: gem(rake) >= 13.4
BuildRequires: gem(rake-compiler) >= 0
BuildRequires: gem(redis) >= 4.6
BuildRequires: gem(rubocop) >= 0
BuildRequires: gem(rubocop-minitest) >= 0
BuildRequires: gem(toxiproxy) >= 0
BuildConflicts: gem(rake) >= 14
BuildConflicts: gem(redis) >= 5
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      ruby >= 2.6.0
Requires:      gem(connection_pool) >= 0
Provides:      gem(redis-client) = 0.31.0

%description
Simple low-level client for Redis 6+


%package       -n gem-hiredis-client
Version:       0.31.0
Release:       alt1
Summary:       Hiredis binding for redis-client
Group:         Development/Ruby

Requires:      ruby >= 2.6.0
Requires:      gem(redis-client) = 0.31.0
Provides:      gem(hiredis-client) = 0.31.0

%description   -n gem-hiredis-client
Simple low-level client for Redis 6+


%if_enabled    devel
%package       -n gem-hiredis-client-devel
Version:       0.31.0
Release:       alt1
Summary:       Hiredis binding for redis-client development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета hiredis-client
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(hiredis-client) = 0.31.0

%description   -n gem-hiredis-client-devel
Hiredis binding for redis-client development package.

Simple low-level client for Redis 6+

%description   -n gem-hiredis-client-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета hiredis-client.
%endif


%if_enabled    doc
%package       -n gem-redis-client-doc
Version:       0.31.0
Release:       alt1
Summary:       Simple low-level client for Redis 6+ documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета redis-client
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(redis-client) = 0.31.0

%description   -n gem-redis-client-doc
Simple low-level client for Redis 6+ documentation files.

%description   -n gem-redis-client-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета redis-client.
%endif


%if_enabled    devel
%package       -n gem-redis-client-devel
Version:       0.31.0
Release:       alt1
Summary:       Simple low-level client for Redis 6+ development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета redis-client
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(redis-client) = 0.31.0
Requires:      gem(base64) >= 0
Requires:      gem(benchmark) >= 0
Requires:      gem(benchmark-ips) >= 0
Requires:      gem(cgi) >= 0.5.0
Requires:      gem(hiredis) >= 0
Requires:      gem(megatest) >= 0
Requires:      gem(ostruct) >= 0
Requires:      gem(rake) >= 13.4
Requires:      gem(rake-compiler) >= 0
Requires:      gem(redis) >= 4.6
Requires:      gem(rubocop) >= 0
Requires:      gem(rubocop-minitest) >= 0
Requires:      gem(toxiproxy) >= 0
Conflicts:     gem(rake) >= 14
Conflicts:     gem(redis) >= 5

%description   -n gem-redis-client-devel
Simple low-level client for Redis 6+ development package.

%description   -n gem-redis-client-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета redis-client.
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

%files         -n gem-hiredis-client
%ruby_gemspecdir/hiredis-client-0.31.0.gemspec
%ruby_gemslibdir/hiredis-client-0.31.0
%ruby_gemsextdir/hiredis-client-0.31.0

%if_enabled    devel
%files         -n gem-hiredis-client-devel
%endif

%if_enabled    doc
%files         -n gem-redis-client-doc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-redis-client-devel
%endif


%changelog
* Tue Dec 13 2022 Pavel Skrylev <majioa@altlinux.org> 0.31.0-alt1
- + packaged gem with Ruby Policy 2.0
- * define explicit dependencies
