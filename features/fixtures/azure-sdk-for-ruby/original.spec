# vim: set ft=spec: -*- rpm-spec -*-
%define        gemname azure-sdk-for-ruby

Name:          azure-sdk-for-ruby
Version:       20200316
Release:       alt1.6
Summary:       Ruby SDK for Azure Resource Manager
License:       MIT
Group:         Development/Ruby
Url:           https://aka.ms/azure-sdk-for-ruby
Vcs:           https://github.com/Azure/azure-sdk-for-ruby.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch
Autoreq:       no
Autoprov:      no
# cpp,debuginfo,files,lib,pam,perl,pkgconfig,pkgconfiglib,python,python3,rpmlib,ruby,shebang,shell,static,symlinks,systemd-services

Source:        %name-%version.tar
BuildRequires(pre): rpm-build-ruby

%add_findreq_skiplist %ruby_gemslibdir/**/*
%ruby_use_gem_dependency unf_ext >= 0.0.7,unf_ext < 1
%ruby_use_gem_dependency timeliness >= 0.4,timeliness < 1
%ruby_use_gem_dependency azure-storage >= 0.15,azure-storage < 1
%ruby_use_gem_dependency faraday >= 2.6.0,faraday < 3
%ruby_ignore_names azure_sdk,gem-azure-sdk-for-ruby,azure-sdk-for-ruby
%ruby_alias_names azure_mgmt_compute,azure-mgmt-compute
%ruby_alias_names azure_mgmt_monitor,azure-mgmt-monitor
%ruby_alias_names azure_mgmt_network,azure-mgmt-network
%ruby_alias_names azure_mgmt_resources,azure-mgmt-resources
%ruby_alias_names azure_mgmt_storage,azure-mgmt-storage
%ruby_alias_names azure_graph_rbac,azure-graph-rbac
%ruby_alias_names azure_mgmt_key_vault,azure-mgmt-key-vault
%ruby_alias_names azure_mgmt_security,azure-mgmt-security
%ruby_alias_names ms_rest_azure,ms-rest-azure
%ruby_alias_names ms_rest,ms-rest

%description
Ruby SDK for Azure Resource Manager: build and manage your Azure cloud
infrastructure (Compute, Virtual Networks, Storage, etc...) using Ruby.

This project provides a Ruby package for Azure Resource Management (ARM).

%package       -n gem-ms-rest-azure
Version:       0.11.2
Release:       alt1.6
Summary:       Azure Client Library for Ruby.
Group:         Development/Ruby
BuildArch:     noarch

%description   -n gem-ms-rest-azure
Azure Client Library for Ruby.

%package       -n gem-ms-rest
Version:       0.7.6
Release:       alt1.6
Summary:       Client Library for Ruby.
Group:         Development/Ruby
BuildArch:     noarch

%description   -n gem-ms-rest
Client Library for Ruby.

%prep
%setup

%build
%ruby_build

%install
%ruby_install

%check
%ruby_test

%files
%doc README*

%files -n gem-ms-rest
%ruby_gemspecdir/ms_rest-0.7.6.gemspec
%ruby_gemslibdir/ms_rest-0.7.6

%files -n gem-ms-rest-azure
%ruby_gemspecdir/ms_rest_azure-0.11.2.gemspec
%ruby_gemslibdir/ms_rest_azure-0.11.2

%changelog
* Thu Jun 13 2024 Pavel Skrylev <majioa@altlinux.org> 20200316-alt1.6
- - disabled autoreq/autoprov (used auto static) to reduce build time
    (closes #39339)
