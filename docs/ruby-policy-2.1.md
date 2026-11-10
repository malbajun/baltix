# Ruby Policy 2.1 draft

This draft builds on [Ruby Policy 2.0](https://en.altlinux.org/Ruby/Policy_2.0).

## Versioning

Preserve upstream release versions. For prereleases, append the upstream commit
count since the preceding release, followed by a separate component for local
code patches when present; separate the upstream count with `p` in RPM `Version`
and a dot in the gem version.

Start release builds at `alt1` and prereleases at `alt0.1`. On the same upstream
release, increment the significant packaging revision for changes outside
`.spec`; append and increment a final component for spec-only changes.

## Dependencies

Declare Ruby dependencies, version constraints, and conflicts explicitly in the
RPM spec during spec generation. Use `gem(name)` capabilities with gem versions;
address development header packages by their RPM names.

## Package macros

For `gem-*` packages, `pkgname` definitions (`%def*` and `%global`) are obsolete;
use `gemname` for the source gem name. Omit unused legacy definitions when updating
specs; retain definitions still referenced by custom packaging code for compatibility.
