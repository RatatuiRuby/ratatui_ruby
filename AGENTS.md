# AGENTS.md

## Project Identity

Project Name: ratatui_ruby

Description: A high-performance Ruby wrapper for the Ratatui TUI library.

Architecture:

-   **Frontend (Ruby):** Pure `Data` objects (Ruby 3.2+) defining the View Tree. Immediate mode.
-   **Backend (Rust):** A generic renderer using `ratatui` and `magnus` that traverses the Ruby `Data` tree and renders to the terminal buffer.

## 1\. File & Coding Standards

### Licensing & Copyright (Strict)

Every file must begin with an SPDX-compliant header. Use the following format:

Ruby

```
# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
```

-   **Ruby/Rust/Config files:** Use comments appropriate for the language (`#` or `//`).
-   **Markdown:** Use HTML comment style \`\`.
-   **Exceptions:** `REUSE.toml` manages exceptions (e.g., binary files or `.gitignore`).

### Ruby Standards

-   **Version:** Strict Ruby 3.4 compatibility (Target `3.4.7` as per cosmoruby).
-   **Linter:** `RuboCop` inheriting from `vendor/goodcop/base.yml`.
-   **Style:**
    -   Use `Data.define` for all value objects (UI Nodes).
    -   Prefer `frozen_string_literal: true`.
    -   Use `Minitest` for testing.
    -   Define types in `.rbs` files.
    -   Every line of Ruby must be covered by tests that would survive mutation testing.
    -   Every public Ruby class/method must be documented for humans in RDoc (preferred) or markdown files (fallback), and must have `*.rbs` types defined.
    -   Every significant architectural and design decision must be documented for contributors in markdown files. Mermaid is allowed.

### Rust Standards

-   **Crate Type:** `cdylib`.
-   **Linter:** `clippy` and `rustfmt`.
-   **Bindings:** Use [magnus](https://github.com/matsadler/magnus).
-   **Platform:** Support macOS (Apple Silicon), Linux, and Windows.
-   **Linker Flags:** Must handle macOS `-undefined dynamic_lookup`.
-   Every line of Rust must be covered by tests that would survive mutation testing.

## 2\. Directory Structure Convention

The project follows a standard Gem layout with an `ext/` directory for Rust code.

Plaintext

```
/
├── .cargo/                 # Cargo configuration (linker flags)
├── .github/                # CI/CD workflows
├── bin/                    # Executables (console, setup)
├── docs/                   # Documentation tree
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

## 3\. Configuration & Tooling

### Development Environment

-   **Setup:** `bin/setup` must handle both Bundler and Cargo dependencies.
-   **Pre-commit:** Use `.pre-commit-config.yaml` to enforce `rake` and `cargo fmt`.

### Documentation

-   Follow the `docs/` structure: `index.md` -> `contributors/` | `quickstart.md`.
-   Documentation should separate "User Guide" (Ruby API for TUI developers) from "Contributor Guide" (Ruby/Rust/Magnus internals).
-   Don't write .md files for something RDoc (Ruby) or rustdoc (Rust) can generate.

## 4\. The Ruby <-> Rust Bridge Contract

### The Ruby Side (`lib/`)

-   Define UI components as immutable `Data` objects.
-   **Example:**

    Ruby

    ```
    module RatatuiRuby
      Paragraph = Data.define(:text, :style)
    end
    ```

### The Rust Side (`ext/`)

-   Do not implement custom Rust structs for every UI component.
-   Implement a **Single Generic Renderer** that accepts a Ruby `Value`.
-   Use `value.class().name()` to switch logic (e.g., match `"RatatuiRuby::Paragraph"`).
-   Use `funcall` to extract data from the Ruby objects.

## 5\. Deployment / Release

-   The gem builds a native extension.
-   Artifact naming: Ensure the output shared library matches Ruby's expectation on macOS (rename `.dylib`to `.bundle` if necessary during the build process in `extconf.rb` or `Rakefile`).
