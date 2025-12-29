<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# AGENTS.md

## Project Identity

Project Name: ratatui_ruby

Description: A high-performance Ruby wrapper for the Ratatui TUI library.

Architecture:

-   **Frontend (Ruby):** Pure `Data` objects (Ruby 3.2+) defining the View Tree. Immediate mode.
-   **Backend (Rust):** A generic renderer using `ratatui` and `magnus` that traverses the Ruby `Data` tree and renders to the terminal buffer.

## Stability & Compatibility

-   **Project Status:** Pre-1.0. 
-   **User Base:** 0 users (internal/experimental).
-   **Breaking Changes:** Backward compatibility is **NOT** a priority at this stage. Since there are no external users, you are encouraged to refactor APIs for better ergonomics and performance even if it breaks existing code.
-   **Requirement:** All breaking changes **MUST** be explicitly documented in the [CHANGELOG.md](CHANGELOG.md)'s **Unreleased** section to ensure transparency as the project evolves toward 1.0.

## 1. File & Coding Standards

### Licensing & Copyright (Strict)

Every file must begin with an SPDX-compliant header. Use the following format:

```ruby
# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
```

-   **Ruby/Rust/Config files:** Use comments appropriate for the language (`#` or `//`).
-   **Markdown:** Use HTML comment style `<!-- -->`.
-   **Exceptions:** `REUSE.toml` manages exceptions (e.g., binary files or `.gitignore`).

### Ruby Standards

-   **Version:** Tested against the latest releases of Ruby 3.2, 3.3, 3.4, and 4.0, and must work on all of them. Local development happens on the latest stable release.
-   **Linter:** Run via `bundle exec rake lint`. You are not done until all linting passes.
-   **Style:**
    -   Use `Data.define` for all value objects (UI Nodes). (Prefer `class Foo < Data.define()` over `Foo = Data.define() do`).
    -   Prefer `frozen_string_literal: true`.
    -   Use `Minitest` for testing.
    -   Define types in `.rbs` files. Don't use `untyped` just because it's easy; be comprehensive and accurate. Do not include `initialize` in `.rbs` files; use `self.new` for constructors instead.
    -   Every line of Ruby must be covered by tests that would stand up to mutation testing. This includes all examples in the `examples/` directory; they should have corresponding tests in `examples/` to ensure they continue to work as intended and serve as reliable documentation. Tests must be meaningful and verify specific behavior or rendering output; simply verifying that code "doesn't crash" is insufficient and unacceptable. For UI widgets, this means using `with_test_terminal` to verify every character of the terminal buffer's content.
    -   Every public Ruby class/method must be documented for humans in RDoc (preferred)--**not** YARD--or markdown files (fallback), and must have `*.rbs` types defined.
    -   Every significant architectural and design decision must be documented for contributors in markdown files. Mermaid is allowed.

### Rust Standards

-   **Crate Type:** `cdylib`.
-   **Linter:** `clippy` and `rustfmt`.
-   **Bindings:** Use [magnus](https://github.com/matsadler/magnus).
-   **Platform:** Support macOS (Apple Silicon), Linux, and Windows.
-   **Linker Flags:** Must handle macOS `-undefined dynamic_lookup`.
-   Every line of Rust must be covered by tests that would stand up to mutation testing. This includes every widget implementation in `ext/ratatui_ruby/src/widgets/`; each must have a `tests` module with unit tests verifying basic rendering. Tests must be meaningful; simply verifying that code "doesn't crash" or "compiles" is insufficient.

## 2. Directory Structure Convention

The project follows a standard Gem layout with an `ext/` directory for Rust code.

```plaintext
/
├── .cargo/                 # Cargo configuration (linker flags)
├── .github/                # CI/CD workflows
├── bin/                    # Executables (console, setup)
├── doc/                    # Documentation source (markdown for RDoc)
│   ├── contributors/       # Design docs, ecosystem notes
│   └── index.md
├── ext/
│   └── ratatui_ruby/       # RUST SOURCE CODE GOES HERE
│       ├── src/
│       │   └── lib.rs      # Entry point
│       ├── Cargo.toml
│       └── extconf.rb      # Makefile generator
├── lib/
│   ├── ratatui_ruby/
│   │   ├── schema/         # Ruby Data definitions
│   │   └── version.rb
│   └── ratatui_ruby.rb     # Main loader
├── test/
│   ├── data/               # Data-driven test files
│   └── ratatui_ruby/       # Unit tests
├── vendor/                 # Vendorized style configs (goodcop)
├── AGENTS.md               # Context for AI agents
├── Gemfile
├── Rakefile
├── REUSE.toml              # Compliance definition
└── ratatui_ruby.gemspec
```

## 3. Configuration & Tooling

### Development Environment

-   **Setup:** `bin/setup` must handle both Bundler and Cargo dependencies.
-   **Pre-commit:** Use `.pre-commit-config.yaml` to enforce `bundle exec rake` and `cargo fmt`.

### Documentation

-   **The `doc/` folder contains source markdown files** that are included in RDoc output. Follow the structure: `index.md` -> `contributors/` | `quickstart.md`.
-   **The `tmp/rdoc/` folder is auto-generated** by `bundle exec rake rerdoc`. Never edit files in `tmp/rdoc/` directly.
-   Documentation should separate "User Guide" (Ruby API for TUI developers) from "Contributor Guide" (Ruby/Rust/Magnus internals).
-   **Style Guide:** You **MUST** follow the [Documentation Style Guide](doc/contributors/documentation_style.md). This dictates the Alexandrian/Zinsser prose style and strict RDoc formatting required for all public API documentation.
-   Don't write .md files for something RDoc (Ruby) or rustdoc (Rust) can generate.

## 4. The Ruby <-> Rust Bridge Contract

### The Ruby Side (`lib/`)

-   Refer to [docs/contributors/design/ruby_frontend.md](docs/contributors/design/ruby_frontend.md) for detailed design philosophy regarding the Data-Driven UI and Immediate Mode paradigm.

### The Rust Side (`ext/`)

-   Refer to [docs/contributors/design/rust_backend.md](docs/contributors/design/rust_backend.md) for detailed implementation guidelines, module structure, and rendering logic.

## 5. Deployment / Release

-   The gem builds a native extension.
-   Artifact naming: Ensure the output shared library matches Ruby's expectation on macOS (rename `.dylib`to `.bundle` if necessary during the build process in `extconf.rb` or `Rakefile`).

## 6. Commit Message

-   **Commits:**
    -   Who commits: Only humans should affect the git index and history. Do not stage (do not `git add`). Do not commit. Just suggest a commit message.
    -   When: At the end of each task, before reporting the task as complete to the user, suggest the commit message.
    -   What: Consider not just what you remember, but also everything in the `git diff` and `git diff --cached`.
-   **Format:**
    -   Format: Use [Conventional Commits](https://www.conventionalcommits.org/).
        -   Structure: `type(scope): description` (e.g., `feat(widget): add Gauge widget`).
        -   Subject line: Concise summary (50 chars or less).
    -   Body: Explanation if necessary (wrap at 72 chars).
        -   Explain why this is the implementation, as opposed to other possible implementations.
        -   Skip the body entirely if it's rote, a duplication of the diff, or otherwise unhelpful.
        -   **DO NOT list the files changed or the edits made in the body.** Do not provide a bulleted list of changes. Use prose to explain the problem and the solution.
        -   **Do not use markdown syntax** (no backticks, no bolding, no lists, no links), except as required in AI Attribution. The commit message must be plain text.
    -   Footer: AI attribution if generated by an agent, sourcehut ticket if implemented by a ticket, or both.
-   **AI Attribution:**
     -   **Always include AI attribution** in the footer if the commit was generated or significantly assisted by an AI agent. This is mandatory for transparency and compliance. **This is NOT optional.**
     -   **Amp:**
         ```
         Generated with [Amp](https://ampcode.com)

         Co-Authored-By: Amp <noreply@ampcode.com>
         ```
     -   **Antigravity:**
         Specify the model used in the footer. Examples:
         ```
         Generated with [Antigravity](https://antigravity.google)

         Co-Authored-By: Gemini 3 Pro (High) <noreply@google.com>
         ```
         ```
         Generated with [Antigravity](https://antigravity.google)

         Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
         ```
     -   **Gemini 3:**
         ```
         Generated with [Gemini 3 Pro](https://gemini.google.com/)

         Co-Authored-By: Gemini 3 Pro <noreply@google.com>
         ```
     -   **JetBrains Junie:**
         ```
         Generated with [JetBrains Junie](https://www.jetbrains.com/ai/)

         Co-Authored-By: Junie <junie@jetbrains.com>
         ```
-   **Sourcehut Tickets:**
    - If the commit implements a specific ticket, include a footer: `Implements: https://todo.sr.ht/~kerrick/ratatui_ruby/<id>`
    - **Do NOT** include this footer if you were not given a specific ticket ID or URL. Do not hallucinate or guess ticket URLs.
    - This must be the **last** item in the footer, if present.

## 7. Definition of Done

Before considering a task complete and returning control to the user, you **MUST** ensure:

1.  **Default Rake Task Passes:** Run `bundle exec rake && echo "PASS"|| echo "FAIL"` (the default task) to execute **ALL** tests and linting. Do not rely on partial test runs, or `rake test`, or `rake lint` alone. Confirm it passes with no new errors **or warnings**.
2.  **Documentation Updated:** If public APIs or observable behavior changed, update relevant `doc/` files, `README.md`, and/or `ratatui_ruby-wiki` files,.
3.  **Changelog Updated:** If public APIs, observable behavior, or gemspec dependencies changed, update [CHANGELOG.md](CHANGELOG.md)'s **Unreleased** section according to the [Semantic Versioning](https://semver.org/) and [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) specifications. Changelogs should be useful to human users of the library, not simple restatements of diffs or commit messages. **Do not add entries for internal tooling, CI, or build configuration changes that do not affect the distributed gem.**
4.  **Commit Message Suggested:** You **MUST** ensure the final message to the user includes a suggested commit message block. This is NOT optional.
