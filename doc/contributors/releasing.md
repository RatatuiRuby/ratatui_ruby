<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Releasing

This guide documents RatatuiRuby's release workflow. We use
[trunk-based development](https://trunkbaseddevelopment.com/committing-straight-to-the-trunk/)
with [release branches](https://trunkbaseddevelopment.com/branch-for-release/).

## Overview

- **`trunk`** — Active development. Features land here first.
- **`release/X.Y`** — Release series branches (e.g., `release/1.0`).
- **`stable`** — Always points to the latest stable release.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```
trunk        ──●──●──●──●──●──●──●──●──●──  (future work)
               \           \
release/1.0  ───●──●──●     \              (1.0.0, 1.0.1, ...)
                             \
release/1.1                   ●──●──●──    (1.1.0, 1.1.1, ...)
```
<!-- SPDX-SnippetEnd -->

## Versioning Philosophy

We follow strict SemVer without ceremony:

- **Breaking change?** → Bump major
- **New feature?** → Bump minor
- **Bug fix?** → Bump patch

Version numbers are technical artifacts, not marketing. If we end up at v50 by
year's end, so be it.

## Changelog Management

Trunk maintains the canonical project history. Each release branch maintains
its own changelog during development, then syncs back to trunk.

### During Beta/RC Cycles

The release branch (`release/1.0`) tracks granular changes:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```markdown
## [Unreleased]

## [1.0.0-beta.2] - 2026-01-20
### Fixed
- TableState row navigation methods

## [1.0.0-beta.1] - 2026-01-20
- Initial 1.0 beta release
```
<!-- SPDX-SnippetEnd -->

Trunk's `[Unreleased]` section accumulates features for the next minor:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```markdown
## [Unreleased]
### Added
- Terminal Capability Detection

### Fixed
- TableState row navigation methods
```
<!-- SPDX-SnippetEnd -->

The fix appears in both places. This is correct — both branches contain it.

### When Final Ships

When `1.0.0` final releases, **consolidate** all beta entries into one section
on both branches:

**release/1.0:**
<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```markdown
## [1.0.0] - 2026-xx-xx
### Fixed
- TableState row navigation methods

## [0.10.3] - 2026-01-16
...
```
<!-- SPDX-SnippetEnd -->

**trunk (synced):**
<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```markdown
## [Unreleased]
### Added
- Terminal Capability Detection

## [1.0.0] - 2026-xx-xx
### Fixed
- TableState row navigation methods

## [0.10.3] - 2026-01-16
...
```
<!-- SPDX-SnippetEnd -->

The beta granularity served its purpose during testing. Git tags preserve the
detailed history.

## Release Workflows

### Bugfix (Patch) Release

For bugs affecting a released version:

1. **Fix on trunk first** — All bugs get fixed on trunk.
2. **Cherry-pick to release branch** with provenance:
   ```bash
   git checkout release/1.0
   git cherry-pick -x <commit>   # -x adds "cherry picked from" trailer
   ```
3. **Update the changelog** on the release branch.
4. **Bump and release:**
   ```bash
   bundle exec rake bump:patch
   bundle exec rake release
   ```

### New Version (Major/Minor)

When trunk is ready for a new release series:

1. **Decide version** based on changes:
   - Breaking changes → Major (2.0.0)
   - New features only → Minor (1.1.0)

2. **Create release branch:**
   ```bash
   git checkout trunk
   git checkout -b release/1.1  # or release/2.0
   ```

3. **Release from the branch:**
   ```bash
   bundle exec rake bump:exact[1.1.0-beta.1]
   bundle exec rake release
   ```

4. **Bump trunk** to the next dev version if desired.

5. **Iterate** through betas/RCs as needed, then ship final.

6. **Sync changelog** — When final ships, add the consolidated section to trunk.

### Prerelease Notes

RubyGems normalizes prerelease versions. Our `rake release` task automatically:

1. Lets Bundler create the normalized tag (e.g., `v1.0.0.pre.beta.1`)
2. Deletes it locally and remotely
3. Creates the SemVer tag (e.g., `v1.0.0-beta.1`) and pushes it

This keeps our Git tags strictly SemVer-compliant.

## Commands Reference

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```bash
# Bump version
bundle exec rake bump:patch           # 1.0.0 → 1.0.1
bundle exec rake bump:minor           # 1.0.0 → 1.1.0
bundle exec rake bump:major           # 1.0.0 → 2.0.0
bundle exec rake bump:exact[1.0.0-beta.1]

# Release (builds, tags, pushes gem, updates stable branch)
bundle exec rake release

# Watch builds
bin/hbs                               # Wait for SourceHut builds
bin/hbs && bundle exec rake release   # Release only if builds pass
```
<!-- SPDX-SnippetEnd -->

## Further Reading

- [Trunk-Based Development](https://trunkbaseddevelopment.com/)
- [Branch for Release](https://trunkbaseddevelopment.com/branch-for-release/)
- [SemVer Specification](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
