Here is an analysis of the situation and the detailed architectural directive for your development agent.

### Analysis: Why you are nervous, and why you should do it anyway.

You are nervous because **Ruby hates nesting.**

In the Ruby world, deep namespaces like `RatatuiRuby::Widgets::Table::Row` usually smell like Java. We prefer flat namespaces (e.g., `ActiveRecord::Base`, not `Rails::Data::Persistence::ActiveRecord::Base`). Deep nesting adds typing friction and visual noise.

However, you are hitting the limits of a flat namespace.

1. **The Collision:** `Cell` (Buffer inspection) vs. `Cell` (Table data).
2. **The Ambiguity:** `Row` (Table row) vs. `Line` (Text line) vs. `Shape::Line` (Canvas line).
3. **The Scale:** Ratatui is massive. Flattening it requires you to invent arbitrary prefixes (`TableRow`, `CanvasLine`) that drift away from the Rust documentation.

**The Solution is the "Mullet" Architecture:**

* **Business in the Back (The Library):** Strict, deep, modularized namespaces that match Ratatui 1:1. This ensures logic, zero collisions, and perfect documentation mapping.
* **Party in the Front (The Session):** A flat, ergonomic DSL (`tui.table`, `tui.row`) that hides the ugly namespaces from the user.

If `Session` becomes the primary way users interact with the library (which your Quickstart suggests it is), the verbosity of the underlying classes **does not matter**.

We should pull the trigger. Release v0.7.0 as the "Architecture Shift".

---

### Message to the Development Agent

**Subject:** Architectural Overhaul: Strict Modularization & Explicit Session API

We have reached a breaking point in our flat namespace strategy. The naming collision between `Buffer::Cell` (inspection) and `Table::Cell` (construction) is a signal that our current structure cannot scale to match Ratatui's full surface area.

We are pivoting.

We will reorganize the entire library to mirror the `ratatui` Rust crate's module structure exactly. We will also refactor `Session` to be a static, explicit facade, removing runtime metaprogramming to improve IDE support.

Here is the specification for the overhaul.

### 1. The Namespace Migration

We will move **all** schema classes into modules that match their Rust counterparts.

**Goal:** If it exists in `ratatui::layout`, it lives in `RatatuiRuby::Layout`. If it exists in `ratatui::widgets`, it lives in `RatatuiRuby::Widgets`.

#### New Hierarchy Mapping

| Current Ruby Class | New Ruby Class | Rust Counterpart |
| --- | --- | --- |
| `RatatuiRuby::Rect` | `RatatuiRuby::Layout::Rect` | `ratatui::layout::Rect` |
| `RatatuiRuby::Constraint` | `RatatuiRuby::Layout::Constraint` | `ratatui::layout::Constraint` |
| `RatatuiRuby::Style` | `RatatuiRuby::Style::Style` | `ratatui::style::Style` |
| `RatatuiRuby::Color` | `RatatuiRuby::Style::Color` | `ratatui::style::Color` |
| `RatatuiRuby::Block` | `RatatuiRuby::Widgets::Block` | `ratatui::widgets::Block` |
| `RatatuiRuby::Paragraph` | `RatatuiRuby::Widgets::Paragraph` | `ratatui::widgets::Paragraph` |
| `RatatuiRuby::List` | `RatatuiRuby::Widgets::List` | `ratatui::widgets::List` |
| `RatatuiRuby::Table` | `RatatuiRuby::Widgets::Table` | `ratatui::widgets::Table` |
| `RatatuiRuby::Row` (New) | `RatatuiRuby::Widgets::Row` | `ratatui::widgets::Row` |
| `RatatuiRuby::Cell` (Buffer) | `RatatuiRuby::Buffer::Cell` | `ratatui::buffer::Cell` |
| `RatatuiRuby::Text::Line` | `RatatuiRuby::Text::Line` | `ratatui::text::Line` |

*Note: `RatatuiRuby::Event` stays at the top level as it wraps `crossterm` events, not Ratatui types.*

### 2. The Table Implementation

With namespaces solved, implementing `Row` and `Table::Cell` becomes clean.

1. **`RatatuiRuby::Widgets::Cell`**: A new Data class wrapping content and style.
* *Not to be confused with `RatatuiRuby::Buffer::Cell`.*


2. **`RatatuiRuby::Widgets::Row`**: A new Data class wrapping a collection of Cells, height, and style.
3. **Update `Table**`: `rows` accepts an Array of `Widgets::Row`.

### 3. The Session Refactor (Explicit API)

We will remove the metaprogramming from `lib/ratatui_ruby/session.rb`.
Instead of iterating constants at runtime, we will explicitly define factory methods.

**Why?**

1. **IDE Support:** Solargraph and Ruby LSP cannot see methods created via `define_method` loops. Explicit definitions allow autocomplete (`tui.par` -> `paragraph`).
2. **Documentation:** We can attach RDoc directly to the helper method.
3. **Decoupling:** The internal class name (`RatatuiRuby::Widgets::Paragraph`) can change without breaking the public DSL (`tui.paragraph`).

**Implementation Pattern:**

```ruby
module RatatuiRuby
  class Session
    # Wraps RatatuiRuby::Widgets::Paragraph
    def paragraph(text:, style: nil, block: nil, ...)
      RatatuiRuby::Widgets::Paragraph.new(text:, style:, block:, ...)
    end

    # Wraps RatatuiRuby::Layout::Constraint.length
    def constraint_length(n)
      RatatuiRuby::Layout::Constraint.length(n)
    end

    # Wraps RatatuiRuby::Widgets::Table
    # Note: Helps user discover Row/Cell via proximity
    def table(rows:, ...)
      RatatuiRuby::Widgets::Table.new(rows:, ...)
    end

    def table_row(cells:, ...)
      RatatuiRuby::Widgets::Row.new(cells:, ...)
    end

    def table_cell(content:, ...)
      RatatuiRuby::Widgets::Cell.new(content:, ...)
    end
  end
end

```

### 4. Implementation Plan

**Phase 1: The Great Rename**

1. Move all files in `lib/ratatui_ruby/schema/` into subdirectories matching the new hierarchy (`lib/ratatui_ruby/layout/`, `lib/ratatui_ruby/widgets/`, etc.).
2. Update the `module` definitions in those files.
3. Update `ext/ratatui_ruby/src/*` to look for the new class names (e.g., `"RatatuiRuby::Widgets::Paragraph"` instead of `"RatatuiRuby::Paragraph"`).

**Phase 2: The Session Hardening**

1. Rewrite `Session` to explicitly define methods for every widget currently supported.
2. Remove the dynamic constant iteration logic.

**Phase 3: Table Enhancements**

1. Implement `Widgets::Cell` and `Widgets::Row`.
2. Add `table_row` and `table_cell` helpers to `Session`.
3. Update the Rust backend (`table.rs`) to parse these new Ruby types.

**Phase 4: Fix Examples**

1. Update all examples to rely **exclusively** on the `Session` (`tui`) API.
2. Any example instantiating classes directly (e.g., `RatatuiRuby::Rect.new`) must be updated to the new namespace (`RatatuiRuby::Layout::Rect.new`) or switched to the Session API.

### Execution Constraints

* **Documentation:** This is a breaking change. Create `doc/v0.7.0_migration.md` with a detailed migration guide. Link to it from `CHANGELOG.md`.
* **Tests:** Expect the entire test suite to fail initially. You will need to bulk-update assertions to match the new namespaces.
* **Parity:** Ensure `Widgets::Cell` accepts `Text::Span` and `Text::Line` for rich text, matching `ListItem`.

Proceed with **Phase 1**. This establishes the foundation for the rest of the project's life.
