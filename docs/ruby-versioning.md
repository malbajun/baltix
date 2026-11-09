# Ruby versioning

See the normative rules in the [Ruby Policy 2.1 draft](ruby-policy-2.1.md).

## Module versions

For an upstream release, preserve its original semantic version.

For a prerelease snapshot, append a numeric component to the previous upstream
release version. This component is the number of upstream patches (commits)
between that release and the selected upstream HEAD. For example, 17 upstream
patches after release `3.4.4.0` give the gem version `3.4.4.0.17`.

If the maintainer also patches the Ruby code, append another numeric component
for those local patches. The first local code patch gives `3.4.4.0.17.1`.
Count upstream and local code patches separately; changes confined to the RPM
spec do not increment either count.

The RPM spec uses `p` before the upstream patch count, while the gem version
uses a dot. Keep these representations consistent:

| Sources | Gem version | RPM `Version` |
| --- | --- | --- |
| Upstream release | `3.4.4.0` | `3.4.4.0` |
| Prerelease with 17 upstream patches | `3.4.4.0.17` | `3.4.4.0p17` |
| Same prerelease with one local code patch | `3.4.4.0.17.1` | `3.4.4.0p17.1` |

For example, the last case has `Version: 3.4.4.0p17.1` in the RPM spec and
`3.4.4.0.17.1` in the installed gemspec.

## Package revisions

A new upstream release starts with RPM `Release: alt1`. Changes outside the
`.spec` file on the same release increment the significant packaging revision:
`alt1`, `alt2`, and so on.

For changes confined to the `.spec` file, append a separate revision component
and increment it for each subsequent spec-only change. For example, the first
two spec fixes to an `alt1` build produce `alt1.1` and `alt1.2`.

For prereleases, put a zero before the significant packaging revision. Thus
`alt0.1` corresponds to `alt1`, and its first two spec fixes produce `alt0.1.1`
and `alt0.1.2`.

| Packaging change | Release build | Prerelease build |
| --- | --- | --- |
| Initial build | `alt1` | `alt0.1` |
| Changes outside `.spec` on the same release | `alt2` | `alt0.2` |
| First spec-only fix to revision 1 | `alt1.1` | `alt0.1.1` |
| Second spec-only fix to revision 1 | `alt1.2` | `alt0.1.2` |

Keep the main package, its subpackages, and the changelog entry consistent
with the selected versions and revisions.
