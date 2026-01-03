<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# RFC: Table, Row, Cell API and Namespacing Strategy

**Status:** Draft — Awaiting PM/Architect Review  
**Date:** 2026-01-03  
**Author:** AI Assistant  

---

## Executive Summary

This document summarizes an in-depth discussion about API consistency between
`ratatui_ruby` and the upstream Ratatui Rust library, specifically regarding:

1. **Rich text support in Table cells** — Should Table cells accept `Text::Span`
   and `Text::Line` objects like List already does?

2. **Row-level styling** — Should we expose a `Row` wrapper class (like `ListItem`)
   to style entire table rows?

3. **Cell-level styling** — Should we expose a `Cell` wrapper class matching
   Ratatui's `widgets::Cell` struct?

4. **Namespacing strategy** — How should we organize these types? Should we
   follow Ratatui's module structure strictly?

5. **Breaking changes** — Given pre-1.0 status, what refactoring is acceptable?

**Recommendation:** Pursue **strict alignment with Ratatui's API structure** to
position `ratatui_ruby` as THE definitive Ratatui wrapper for Ruby.

---

## Table of Contents

1. [Background and Context](#background-and-context)
2. [Current State Analysis](#current-state-analysis)
3. [Identified Gaps](#identified-gaps)
4. [Ratatui API Reference](#ratatui-api-reference)
5. [Implementation Work Completed](#implementation-work-completed)
6. [Namespace Options Analysis](#namespace-options-analysis)
7. [Recommendation: Strict Ratatui Alignment](#recommendation-strict-ratatui-alignment)
8. [Proposed API Surface](#proposed-api-surface)
9. [Migration Path](#migration-path)
10. [Breaking Changes Summary](#breaking-changes-summary)
11. [Open Questions for PM/Architect](#open-questions-for-pmarchitect)
12. [Appendix: Ratatui Module Structure](#appendix-ratatui-module-structure)

---

## Background and Context

### The Conversation Origin

The discussion began with a user audit of the v0.6.0 changelog entry for
"Rich Text Support". The audit identified an inconsistency:

> **ListItem vs Table Row Styling**
>
> You added ListItem to style specific rows in a List.
> In Table, you can style rows via RatatuiRuby::Row (implied by rows accepting
> arrays, but does schema/table.rb expose a Row class for styling?).
>
> Check: If a user wants to style a specific row in a table (e.g., make the
> header row bold, or a specific data row red), they currently rely on
> highlight_style (active only).

The user correctly identified that while `List` gained rich text support with
`ListItem`, `Text::Span`, and `Text::Line`, the `Table` widget did not receive
equivalent capabilities.

### Project Philosophy

From `AGENTS.md`:

> **Project Status:** Pre-1.0.
> **User Base:** 0 users (internal/experimental).
> **Breaking Changes:** Backward compatibility is **NOT** a priority at this
> stage. Since there are no external users, you are encouraged to refactor APIs
> for better ergonomics and performance even if it breaks existing code.

This gives us freedom to restructure the API for maximum alignment with Ratatui
before the 1.0 release locks in the public interface.

### Design Principles (from `ruby_frontend.md`)

The Ruby frontend follows these core principles:

1. **Data-Driven UI** — Widgets are pure `Data.define` value objects
2. **Immediate Mode** — Fresh view tree constructed every frame
3. **Separation of Configuration and Status** — Widgets are inputs, State is output
4. **No render logic in Ruby** — Rendering is Rust-only

These principles support the proposed changes, as Row and Cell would be pure
data objects following the existing pattern.

---

## Current State Analysis

### What List Already Has

The `List` widget in v0.6.0 supports:

```ruby
# Plain strings
List.new(items: ["Item 1", "Item 2"])

# Text::Span for styled text
List.new(items: [
  Text::Span.new(content: "Error", style: Style.new(fg: :red))
])

# Text::Line for multi-styled text
List.new(items: [
  Text::Line.new(spans: [
    Text::Span.new(content: "User: ", style: Style.new(modifiers: [:bold])),
    Text::Span.new(content: "kerrick", style: Style.new(fg: :blue))
  ])
])

# ListItem for row-level styling (background color, etc.)
List.new(items: [
  ListItem.new(
    content: "Error row",
    style: Style.new(bg: :red)
  )
])
```

This provides a complete rich text API where users can:
- Style individual characters via `Text::Span`
- Compose multi-styled content via `Text::Line`
- Style entire rows via `ListItem`

### What Table Was Missing

Before this work, `Table` only supported:

```ruby
# Plain strings
Table.new(
  rows: [["Col1", "Col2"]],
  widths: [Constraint.length(10), Constraint.length(10)]
)

# Paragraph (for styled cells with text + style)
Table.new(
  rows: [[Paragraph.new(text: "Styled", style: Style.new(fg: :red))]],
  widths: [...]
)

# Cell (but this was buffer inspection, NOT table construction!)
# The existing RatatuiRuby::Cell is for get_cell_at(), not Table cells
```

Missing capabilities:
- No `Text::Span` support in cells
- No `Text::Line` support in cells
- No row-level styling (no `Row` class equivalent to `ListItem`)
- No proper `Cell` class for table cell construction

### The `Cell` Confusion

A critical naming collision exists:

**Current `RatatuiRuby::Cell`** — Used for buffer inspection via `get_cell_at`:
```ruby
cell = RatatuiRuby.get_cell_at(x, y)
cell.char      # => "X"
cell.fg        # => :red
cell.bg        # => nil
cell.modifiers # => [:bold]
cell.bold?     # => true
```

**Ratatui's `widgets::Cell`** — A table cell wrapper (content + style):
```rust
// From Ratatui documentation:
// You can apply a Style to the Cell using Cell::style. This will set
// the style for the entire area of the cell.

Cell::new("Content").style(Style::default().fg(Color::Red))
```

**Ratatui's `buffer::Cell`** — A single terminal cell in the buffer:
```rust
// This is what our current RatatuiRuby::Cell mirrors
let cell: &buffer::Cell = buffer.cell((x, y));
```

The current naming is **incorrect** — our `Cell` mirrors `buffer::Cell`, but
the name suggests it could be used for table construction like `widgets::Cell`.

---

## Identified Gaps

### Gap 1: Table Cells Don't Accept Rich Text

**Problem:** The `parse_cell` function in `table.rs` only handles:
- `String` (via `to_s`)
- `RatatuiRuby::Paragraph` (text + style)
- `RatatuiRuby::Style` (empty cell with style)
- `RatatuiRuby::Cell` (the buffer inspection type, oddly)

**Solution:** Add `Text::Span` and `Text::Line` support to `parse_cell`, using
the existing `parse_span` and `parse_line` helpers from `text.rs`.

**Status:** ✅ **Implemented** — `parse_cell` now handles these types.

### Gap 2: No Row Class for Row-Level Styling

**Problem:** Users cannot style entire table rows (e.g., red background for
error rows, bold header rows) without the `highlight_style` mechanism, which
only affects the currently selected row.

**Solution:** Create a `Row` class similar to `ListItem`:
```ruby
Row.new(
  cells: ["Error", "Something went wrong"],
  style: Style.new(bg: :red),
  height: 2,
  top_margin: 1,
  bottom_margin: 1
)
```

**Status:** ✅ **Implemented** — `Row` class created at `RatatuiRuby::Row`.

### Gap 3: No Cell Class for Cell-Level Styling

**Problem:** While `Paragraph` can provide text + style, it's semantically
wrong — a Paragraph is a multi-line text block, not a table cell. This creates
a confusing API where users must use the "wrong" widget for styling.

Ratatui's `widgets::Cell` struct provides:
- `content: Text` — the cell's text content (can be multi-styled)
- `style: Style` — the cell's background/base style

**Solution:** Create a proper `Cell` class:
```ruby
Table::Cell.new(
  content: Text::Line.new(spans: [...]),
  style: Style.new(bg: :yellow)
)
```

**Status:** ⏳ **Pending** — Awaiting namespace decision.

### Gap 4: `Text::Line` Has No `width` Method

**Problem:** Users building layouts need to know if their rich text fits in a
column. They have `Text.width(string)` for plain strings, but `Text::Line`
(which contains multiple styled spans) has no equivalent.

**Solution:** Add `Line#width` instance method:
```ruby
line = Text::Line.new(spans: [
  Text::Span.new(content: "Hello "),
  Text::Span.new(content: "世界")  # CJK characters
])
line.width  # => 10 (6 + 4)
```

**Status:** ✅ **Implemented**

### Gap 5: Namespace Collision and Inconsistency

**Problem:** The current naming creates confusion:
- `RatatuiRuby::Cell` is for buffer inspection (should be `Buffer::Cell`)
- No `Table::Cell` exists for table construction
- `Row` is at the top level, not grouped with `Table`

**Solution:** Restructure namespaces to match Ratatui and existing patterns.

**Status:** ⏳ **Pending** — This document exists to make the decision.

---

## Ratatui API Reference

### Ratatui's Module Structure

From the Ratatui documentation search results:

```
struct ratatui::buffer::Cell       # A buffer cell (terminal cell state)
struct ratatui::widgets::Cell      # A Cell contains the Text for a Row
struct ratatui::widgets::Row       # A Row for the Table widget
struct ratatui::widgets::Table     # The Table widget

method ratatui::widgets::Row::cells          # Set the cells of the Row
method ratatui::widgets::Table::rows         # Set the rows of the Table
method ratatui::widgets::Table::header       # Set the header Row
method ratatui::widgets::Table::footer       # Set the footer Row
```

### Key Observations

1. **`buffer::Cell` vs `widgets::Cell`** — Ratatui explicitly separates these
   into different modules. They serve completely different purposes.

2. **`widgets::Row`** — Rows are explicitly widgets-namespace items, not
   top-level. They contain cells and have styling properties.

3. **`widgets::Cell`** — Cells are explicitly widgets-namespace items. They
   wrap `Text` content with an optional `Style`.

4. **Hierarchy:** Table → Row → Cell → Text (Line → Span)

### Ratatui's Cell Documentation

From the Ratatui docs:

> You can apply a Style to the Cell using Cell::style. This will set the style
> for the entire area of the cell. Any Style set on the Text content will be
> combined with the Style of the Cell by adding the Style of the Text content
> to the Style of the Cell. Styles set on the text content will only affect
> the content.
>
> You can use Text::alignment when creating a cell to align its content.

This clearly describes a **wrapper type** with:
- Content (Text)
- Style (for the cell background)
- Alignment (for content positioning)

---

## Implementation Work Completed

### 1. `parse_cell` Updated (table.rs)

Added support for `Text::Span` and `Text::Line` in table cells:

```rust
fn parse_cell(cell_val: Value) -> Result<Cell<'static>, Error> {
    // ... existing class name extraction ...

    // NEW: Try Text::Line first (contains multiple spans)
    if class_name.contains("Line") {
        if let Ok(line) = parse_line(cell_val) {
            return Ok(Cell::from(line));
        }
    }

    // NEW: Try Text::Span
    if class_name.contains("Span") {
        if let Ok(span) = parse_span(cell_val) {
            return Ok(Cell::from(ratatui::text::Line::from(vec![span])));
        }
    }

    // ... existing Paragraph, Style, Cell handling ...
}
```

### 2. `Row` Class Created (row.rb)

```ruby
class Row < Data.define(:cells, :style, :height, :top_margin, :bottom_margin)
  def initialize(cells:, style: nil, height: nil, top_margin: nil, bottom_margin: nil)
    super(
      cells:,
      style:,
      height: height.nil? ? nil : Integer(height),
      top_margin: top_margin.nil? ? nil : Integer(top_margin),
      bottom_margin: bottom_margin.nil? ? nil : Integer(bottom_margin)
    )
  end
end
```

### 3. `parse_row` Updated (table.rs)

Now detects `RatatuiRuby::Row` objects and extracts style/height/margins:

```rust
fn parse_row(row_val: Value) -> Result<Row<'static>, Error> {
    // Check if this is a RatatuiRuby::Row object
    if class_name == "RatatuiRuby::Row" {
        let cells_val: Value = row_val.funcall("cells", ())?;
        let style_val: Value = row_val.funcall("style", ())?;
        let height_val: Value = row_val.funcall("height", ())?;
        // ... extract and apply all properties ...
        return Ok(row);
    }

    // Fallback: plain array of cells
    // ...
}
```

### 4. `Line#width` Method Added (text.rb)

```ruby
class Line < Data.define(:spans, :alignment)
  def width
    RatatuiRuby::Text.width(spans.map { |s| s.content.to_s }.join)
  end
end
```

### 5. Tests Added

- `test_rich_text_cell_with_span` — Table cells with Text::Span
- `test_rich_text_cell_with_line` — Table cells with Text::Line
- `test_rich_text_header_with_span` — Header cells with styling
- `test_row_with_style` — Row with background color
- `test_row_with_height` — Row with fixed height
- `test_row_creation` — Row object creation
- `test_line_width_*` — Multiple Line#width tests

### 6. RBS Types Added

- `sig/ratatui_ruby/schema/row.rbs`
- Updated `sig/ratatui_ruby/schema/text.rbs` with `Line#width`

### 7. CHANGELOG Updated

Added entries under `## [Unreleased]`:
- Rich Text in Table Cells
- Row Wrapper
- Line#width Method

---

## Namespace Options Analysis

### Option A: Top-Level with Suffixes

Keep everything at `RatatuiRuby::*` with disambiguating names:

```ruby
RatatuiRuby::BufferCell   # for get_cell_at
RatatuiRuby::TableCell    # for table construction
RatatuiRuby::TableRow     # for row construction
RatatuiRuby::Table        # unchanged
```

**Pros:**
- Simple, flat namespace
- No nested modules to navigate
- Familiar to Rails developers

**Cons:**
- Diverges from Ratatui's structure
- Creates awkward names (`TableCell` vs `Cell`)
- Not scalable as more types are added

### Option B: Context-Based Nesting (Current Pattern)

Group by context, following existing patterns like `Text::Span`:

```ruby
RatatuiRuby::Table::Cell  # table cell construction
RatatuiRuby::Table::Row   # row construction
RatatuiRuby::Table        # table widget
RatatuiRuby::Buffer::Cell # buffer inspection
```

**Pros:**
- Follows existing pattern (`Text::Span`, `BarChart::Bar`)
- Groups related concepts logically
- Self-documenting ("Table::Cell is for Tables")

**Cons:**
- Diverges from Ratatui's `widgets::Cell` naming
- May need `autoload` or eager loading for nested classes

### Option C: Strict Ratatui Alignment (RECOMMENDED)

Mirror Ratatui's module structure exactly:

```ruby
RatatuiRuby::Widgets::Cell   # ratatui::widgets::Cell
RatatuiRuby::Widgets::Row    # ratatui::widgets::Row
RatatuiRuby::Widgets::Table  # ratatui::widgets::Table (or keep at top)
RatatuiRuby::Buffer::Cell    # ratatui::buffer::Cell
```

**Pros:**
- Direct mapping to Ratatui documentation
- Users familiar with Ratatui (from Rust) immediately understand
- Positions project as THE Ratatui wrapper
- Scalable — all widgets can live in `Widgets::`

**Cons:**
- Major refactor to move existing widgets
- Many breaking changes at once
- `Widgets::Table` is longer than just `Table`

### Hybrid Option: Selective Ratatui Alignment

Apply Ratatui naming where disambiguation is needed, keep flat elsewhere:

```ruby
RatatuiRuby::Table           # table widget (flat, existing)
RatatuiRuby::Table::Cell     # mirrors widgets::Cell context
RatatuiRuby::Table::Row      # mirrors widgets::Row context
RatatuiRuby::Buffer::Cell    # mirrors buffer::Cell
RatatuiRuby::Text::Span      # existing (already correct!)
RatatuiRuby::Text::Line      # existing (already correct!)
```

**Pros:**
- Minimal breaking changes to existing code
- New types follow Ratatui patterns
- Existing patterns (`Text::Span`) are already correct

**Cons:**
- Not 100% aligned with Ratatui (widgets stay flat)
- Some inconsistency in nesting depth

---

## Recommendation: Strict Ratatui Alignment

**I strongly recommend Option C (Strict Ratatui Alignment)** for these reasons:

### 1. Positioning as THE Ratatui Wrapper

The project goal is to be the definitive Ruby binding for Ratatui. This means:
- Users coming from Rust/Ratatui should feel at home
- Documentation can reference Ratatui docs directly
- Naming should be predictable based on Ratatui knowledge

### 2. Developer Experience

When a user reads Ratatui documentation and sees `widgets::Cell`, they should
immediately know to look for `RatatuiRuby::Widgets::Cell`. No mental translation
required.

### 3. Disambiguation

Ratatui separates `buffer::Cell` from `widgets::Cell` for good reason — they
are fundamentally different concepts. We should do the same.

### 4. Future-Proofing

As Ratatui adds new widgets and types, having a `Widgets::` namespace gives
us a clear place to add them without polluting the top-level namespace.

### 5. Pre-1.0 Freedom

Per `AGENTS.md`, breaking changes are explicitly encouraged in this phase.
Now is the time to get the API right before users depend on it.

---

## Proposed API Surface

### After Full Implementation

```ruby
# Table widget and related types
RatatuiRuby::Widgets::Table
RatatuiRuby::Widgets::Row
RatatuiRuby::Widgets::Cell

# Or, if we prefer the hybrid approach:
RatatuiRuby::Table
RatatuiRuby::Table::Row
RatatuiRuby::Table::Cell

# Buffer inspection
RatatuiRuby::Buffer::Cell

# Text types (already correct)
RatatuiRuby::Text::Span
RatatuiRuby::Text::Line

# Usage examples:
table = RatatuiRuby::Widgets::Table.new(
  header: [
    RatatuiRuby::Table::Cell.new(
      content: Text::Span.styled("Name", Style.new(modifiers: [:bold])),
      style: Style.new(bg: :blue)
    ),
    RatatuiRuby::Table::Cell.new(content: "Age")
  ],
  rows: [
    RatatuiRuby::Table::Row.new(
      cells: ["Alice", "30"],
      style: Style.new(bg: :green)  # entire row is green
    ),
    RatatuiRuby::Table::Row.new(
      cells: [
        RatatuiRuby::Table::Cell.new(
          content: Text::Line.new(spans: [
            Text::Span.new(content: "Bob ", style: Style.new(fg: :red)),
            Text::Span.new(content: "(admin)")
          ])
        ),
        "25"
      ]
    )
  ],
  widths: [Constraint.length(20), Constraint.length(10)]
)

# Buffer inspection
cell = RatatuiRuby.get_cell_at(5, 3)
# Returns: RatatuiRuby::Buffer::Cell
cell.char       # => "A"
cell.fg         # => :blue
cell.bold?      # => true
```

---

## Migration Path

### Phase 1: Add New Types (Non-Breaking)

1. Create `RatatuiRuby::Table::Cell` class
2. Create `RatatuiRuby::Buffer::Cell` class
3. Update `parse_cell` to recognize `Table::Cell`
4. Deprecate top-level `Cell` with warning

### Phase 2: Move Row (Minor Breaking)

1. Move `RatatuiRuby::Row` → `RatatuiRuby::Table::Row`
2. Add alias at old location with deprecation warning
3. Update `parse_row` to recognize new path

### Phase 3: Rename Buffer Cell (Breaking)

1. `RatatuiRuby::Cell` → `RatatuiRuby::Buffer::Cell`
2. Add temporary alias with deprecation warning
3. Update `get_cell_at` return type
4. Update all tests and examples

### Phase 4: Optional — Full Widgets Namespace

If agreed upon:
1. Create `RatatuiRuby::Widgets` module
2. Move `Table`, `List`, `Paragraph`, etc. into it
3. Add aliases at top level with deprecation
4. Update all examples and documentation

---

## Breaking Changes Summary

| Change | Impact | Mitigation |
|--------|--------|------------|
| `Cell` → `Buffer::Cell` | High — affects all tests using `get_cell_at` | Deprecation period with alias |
| `Row` → `Table::Row` | Low — newly added | Immediate move before usage |
| New `Table::Cell` | None — new addition | N/A |

---

## Open Questions for PM/Architect

### Question 1: Full Widgets Namespace?

Should we create a `RatatuiRuby::Widgets::` namespace and eventually move
ALL widgets there (Table, List, Paragraph, etc.) for strict Ratatui alignment?

**Trade-offs:**
- Pro: 100% Ratatui alignment
- Con: Massive breaking change affecting all existing code
- Con: Longer class names (`Widgets::Table` vs `Table`)

### Question 2: Table::Cell vs Widgets::Cell?

Given we already have `Text::Span` (not `Widgets::Span`), should Cell follow
that pattern?

**Options:**
- `RatatuiRuby::Table::Cell` — consistent with `Text::Span` pattern
- `RatatuiRuby::Widgets::Cell` — consistent with Ratatui
- Both work, need decision on which pattern to follow

### Question 3: Timing of Migration?

Should we:
- **Option A:** Do it all now (pre-1.0, rip the bandaid)
- **Option B:** Phased approach with deprecation warnings
- **Option C:** Defer full restructure to 1.0 planning

### Question 4: Session DSL Updates?

The Session DSL provides convenience methods like `tui.paragraph(...)`.
Should we add:
- `tui.table_cell(...)` → `Table::Cell.new(...)`
- `tui.table_row(...)` → `Table::Row.new(...)`

### Question 5: Existing Examples

There are widget examples using `RatatuiRuby::Cell` for buffer inspection.
Should we update them as part of this work or track separately?

---

## Appendix: Ratatui Module Structure

For reference, here is Ratatui's public module structure:

```
ratatui::
├── prelude::                    # Re-exports common types
├── buffer::
│   ├── Buffer                   # Terminal buffer
│   └── Cell                     # Single cell in buffer
├── layout::
│   ├── Constraint
│   ├── Flex
│   ├── Layout
│   └── Rect
├── style::
│   ├── Color
│   ├── Modifier
│   └── Style
├── symbols::                    # Box drawing characters
├── text::
│   ├── Line
│   ├── Span
│   └── Text
└── widgets::
    ├── Block
    ├── Borders
    ├── List
    ├── ListItem
    ├── ListState
    ├── Paragraph
    ├── Table
    ├── TableState
    ├── Row                      # Table row
    ├── Cell                     # Table cell
    ├── Tabs
    ├── Gauge
    ├── LineGauge
    ├── Sparkline
    ├── BarChart
    ├── Chart
    ├── Canvas
    └── ... many more
```

Our current structure:

```
RatatuiRuby::
├── Buffer (proposed)
│   └── Cell (proposed, rename from Cell)
├── Table::
│   ├── Cell (proposed)
│   └── Row (proposed, move from Row)
├── Text::
│   ├── Line ✓
│   └── Span ✓
├── BarChart::
│   ├── Bar ✓
│   └── BarGroup ✓
├── Shape::
│   └── Label ✓
├── Block ✓
├── Constraint ✓
├── Layout ✓
├── List ✓
├── ListItem ✓
├── Paragraph ✓
├── Style ✓
├── Table ✓
└── ... others
```

---

## Conclusion

The implementation work for rich text support in Table cells is complete.
The remaining question is purely organizational: **how should we namespace
Cell and Row types?**

My strong preference is for **strict Ratatui alignment** because:

1. It positions `ratatui_ruby` as THE definitive wrapper
2. It makes documentation and learning curve trivial for Ratatui users
3. Pre-1.0 is the right time for breaking changes
4. The existing patterns (`Text::Span`) already move in this direction

Awaiting PM/Architect decision to proceed with namespace restructuring.
