# Ruby dependencies

See the normative rules in the [Ruby Policy 2.1 draft](ruby-policy-2.1.md).

## Declaring dependencies

Determine Ruby dependencies and version constraints when generating the RPM
spec, and write them explicitly into it. The generated spec must contain the
runtime and build requirements and applicable conflicts before the RPM package
build starts. Include dependencies needed by configured build tasks, even when
they are loaded inside a Rake task rather than at Rakefile import time.

When updating a spec, recalculate every `gem(...)` dependency, its version bounds
and its build/check/runtime assignment from the current source and discovery
metadata. A gem removed from those inputs must disappear from the generated tags
and dependency overrides. Preserve non-gem RPM tools and packaging commands.
Historical RPM tags must not supply missing gems, old bounds or group assignments.

Use the appropriate RPM declarations:

| Declaration | Purpose |
| --- | --- |
| `Requires` | Gems needed at runtime |
| `BuildRequires` | Gems and tools needed to build or test the package |
| `Conflicts` | Unsupported runtime dependency versions |
| `BuildConflicts` | Unsupported build dependency versions |

For example, a dependency on Racc versions from 1.5 up to, but excluding, 2 is
written as follows when needed both at build time and at runtime:

```spec
BuildRequires: gem(racc) >= 1.5
BuildConflicts: gem(racc) >= 2
Requires: gem(racc) >= 1.5
Conflicts: gem(racc) >= 2
```

Keep these declarations consistent with any corresponding
`%ruby_use_gem_dependency` overrides.

## Gem capabilities and package versions

Prefer gem capabilities to RPM package names for Ruby library dependencies.
Their constraints refer to gem versions, not RPM releases. For example:

```spec
Requires: gem(ruby-next-parser) = 3.4.4.0
```

This requirement does not tie the consumer to a particular packaging revision
such as `3.4.4.0-alt1` or `3.4.4.0-alt1.1`. For snapshots, use the numeric gem
version described in [Versioning](ruby-versioning.md), rather than the RPM
`Version` spelling containing `p`.

Development packages containing compilation headers can be addressed by their
RPM package names. Use an exact EVR when the matching package build is required,
for example `gem-ruby-next-parser-devel = %EVR`.
