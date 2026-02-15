<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Contributing

This guide walks you through setting up a development environment for
RatatuiRuby. By the end, you will have a working test suite on macOS, Linux,
or Windows.

## Prerequisites

The only prerequisite is [mise](https://mise.jdx.dev/installing-mise.html), a
dev tool manager. It installs Ruby, Rust, Python, and pre-commit hooks
according to `mise.toml`.

## Setup

Clone the repository and run the setup script for your platform.

### macOS / Linux

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```sh
bin/setup
```
<!-- SPDX-SnippetEnd -->

### Windows (PowerShell)

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```powershell
bin/setup.ps1
```
<!-- SPDX-SnippetEnd -->

Both scripts do the same work:

1. Install Ruby, Rust, and Python via mise.
2. Add Rust components (`rustfmt`, `clippy`).
3. Install the [REUSE](https://reuse.software/) license checker.
4. Install Bundler and all gem dependencies.
5. Set up pre-commit hooks and build the API docs (skipped in CI).

On Windows, the script configures mise to use precompiled Ruby from
RubyInstaller, which bundles the MSYS2 devkit for native gem compilation. If
Visual Studio Build Tools are missing (Rust depends on them), the script offers
to install them via winget.

## Running Tests

The default Rake task runs lint fixes, the test suite, code quality tools,
license checks, and the Steep type checker:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```sh
bundle exec rake
```
<!-- SPDX-SnippetEnd -->

## Running Examples

Run any example with `bundle exec ruby` so Bundler loads the development version
of the gem:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```sh
bundle exec ruby examples/app_all_events/app.rb
```
<!-- SPDX-SnippetEnd -->

## Project Structure

See [doc/contributors/](./doc/contributors/index.md) for architecture guides,
documentation standards, and release procedures.

## Community

Active development happens on the `trunk` branch. The `stable` branch tracks
releases only. Use `trunk` for contributions.

The [discussion forum](https://forum.setdef.com/tags/c/ratatui-ruby/6/discussion)
is the best place to ask questions, share patches, and get feedback. Report bugs
on the [bug tracker](https://forum.setdef.com/tags/c/ratatui-ruby/6/bug). Follow
[announcements](https://forum.setdef.com/tags/c/ratatui-ruby/6/announcement)
for release notes. All participants follow the
[Code of Conduct](https://man.sr.ht/~kerrick/ratatui_ruby/code_of_conduct.md).

File issues for the underlying Rust library at
[ratatui/ratatui](https://github.com/ratatui/ratatui).