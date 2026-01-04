<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->
# Why RatatuiRuby?

The terminal is having a renaissance. Ruby deserves to be at the forefront.

**RatatuiRuby** is a high-performance, immediate-mode TUI engine that brings the power of Rust's [Ratatui](https://ratatui.rs) library directly into Ruby. No ports. No emulations. A native bridge to the industry-standard Rust crate.


## The Pitch

You want to build a terminal UI. You love Ruby. Your options were:

1. **Learn Go** for Bubble Tea
2. **Learn Rust** for Ratatui
3. **Use a pure-Ruby library** with limited performance

We built a fourth option: **Write Ruby. Run Rust.**

RatatuiRuby gives you Rust's layout engine, rendering speed, and battle-tested widgets — with Ruby's expressiveness, ecosystem, and joy.


## RatatuiRuby vs. CharmRuby

[CharmRuby](https://github.com/marcoroth/charm_ruby) is an excellent project by Marco Roth. It provides Ruby bindings to Charm's Go libraries (Bubble Tea, Lipgloss). The Ruby ecosystem is better because both projects exist.

So which one should you choose?

| | CharmRuby | RatatuiRuby |
|---|-----------|-------------|
| **Backend** | Go runtime | Rust (no runtime) |
| **Architecture** | Elm Architecture (MVU) | Immediate-mode + your choice |
| **GC Behavior** | Two GCs (Ruby + Go) | One GC (Ruby only) |
| **Rendering** | String manipulation | Constraint-based layout tree |
| **Best for** | Fans of Bubble Tea, MVU | Native performance, heavy-duty apps |

**What's a runtime?** A runtime is background machinery that a language needs to run. Go has one (for goroutines and garbage collection). Rust doesn't — it compiles to plain machine code. When you use Go bindings, you're running *two* runtimes in the same process (Ruby's and Go's), which adds complexity and memory overhead. With Rust bindings, there's only Ruby.

**Choose CharmRuby** if you prefer Charm's aesthetics or are migrating existing Bubble Tea code.

**Choose RatatuiRuby** if you want zero-overhead native performance and architectural freedom. RatatuiRuby doesn't force a framework — you can build MVU, component-based, or any pattern you prefer.


## Why Not Just Write Rust?

Rust is amazing. It's also strict.

The borrow checker enforces memory safety. That's great for systems programming. It's painful for UI iteration. Moving a sidebar, changing a color, or swapping a widget often requires refactoring ownership chains.

With RatatuiRuby, you just change the object. You get Rust's performance where it matters — rendering — and Ruby's flexibility where it counts — designing.


## Why Not Just Write Go?

Go is pragmatic. But using Go bindings means running *two* runtimes in the same process: Ruby's and Go's. That adds complexity and memory overhead.

With RatatuiRuby, there's only Ruby. Rust compiles to plain machine code with no runtime — it integrates seamlessly.


## Why Ruby?

[Ruby isn't just another language](https://www.ruby-lang.org/en/). It's an ecosystem:

- **[ActiveRecord](https://guides.rubyonrails.org/active_record_basics.html)** — Query your database with elegant, chainable methods
- **[RSpec](https://rspec.info/)** — Write expressive, readable tests with `describe`, `it`, and `expect`
- **[Blocks](https://ruby-doc.org/docs/ruby-doc-bundle/UsersGuide/rg/blocks.html)** — Pass behavior to methods with `do...end`, the heart of Ruby's expressiveness
- **[Metaprogramming](https://ruby-doc.org/docs/ruby-doc-bundle/UsersGuide/rg/objinitialization.html)** — Define methods dynamically, build DSLs, and write code that writes code
- **[Bundler](https://bundler.io/)** — Access 180,000+ gems with a single `bundle add`

Build a dashboard for your Rails app. Monitor your Sidekiq jobs. Create developer tools in the same language as the code they inspect.


## The Philosophy: A Solid Foundation

RatatuiRuby is a **low-level engine**. It provides raw primitives — Layouts, Blocks, Text, Tables, Charts — to build anything.

It doesn't force a framework on you. You can use:
- **Model-View-Update** for dashboards and data displays
- **Component-based** patterns for interactive tools
- **Your own architecture** for everything else

This is the foundation for Ruby's next generation of TUI tools, dashboards, and interactive scripts.


## Get Started

Ready to build?

- [Quickstart Guide](./quickstart.md) — Your first app in 5 minutes
- [Widget Gallery](./quickstart.md#widget-demos) — See what's possible
- [Application Architecture](./application_architecture.md) — Patterns for scaling
