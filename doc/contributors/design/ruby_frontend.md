<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Ruby Frontend Design (`ratatui_ruby`)

This document describes the architectural design and guiding principles of the Ruby layer in `ratatui_ruby`. It is intended for contributors, architects, and AI agents working on the codebase.

## Guiding Design Principles

### 1. Ratatui Alignment

The Ruby namespace structure mirrors Ratatui's Rust module hierarchy exactly. This is a deliberate architectural choice with specific benefits:

- **Documentation Mapping**: A contributor reading Ratatui's docs for `ratatui::widgets::Table` immediately knows to look at `RatatuiRuby::Widgets::Table`.
- **Predictability**: No mental translation required between Rust and Ruby codebases.
- **Scalability**: As Ratatui adds new types, the Ruby placement is deterministic.

**Module Mapping:**

| Rust Module | Ruby Module | Purpose |
|-------------|-------------|---------|
| `ratatui::layout` | `RatatuiRuby::Layout` | Rect, Constraint, Layout |
| `ratatui::widgets` | `RatatuiRuby::Widgets` | All widgets (Table, List, Paragraph, Block, etc.) |
| `ratatui::style` | `RatatuiRuby::Style` | Style, Color |
| `ratatui::text` | `RatatuiRuby::Text` | Span, Line |
| `ratatui::buffer` | `RatatuiRuby::Buffer` | Cell (for buffer inspection) |

This structure resolves name collisions that would otherwise require arbitrary prefixes. For example, `Buffer::Cell` (terminal cell inspection) vs `Widgets::Cell` (table cell construction) are clearly distinct.

### 2. Two-Layer Architecture

The Ruby frontend implements a "Mullet Architecture": structured namespaces in the library, flat ergonomic DSL for users.

**Layer 1: Schema Classes (The Library)**

Located in `lib/ratatui_ruby/widgets/`, `lib/ratatui_ruby/layout/`, etc.

These are the actual `Data.define` classes that the Rust backend expects. They have deep, explicit namespaces that match Ratatui:

```ruby
RatatuiRuby::Widgets::Paragraph.new(text: "Hello")
RatatuiRuby::Layout::Constraint.length(20)
RatatuiRuby::Style::Style.new(fg: :red)
```

**Layer 2: TUI Facade (The DSL)**

Located in `lib/ratatui_ruby/tui.rb` and `lib/ratatui_ruby/tui/*.rb` mixins.

The `TUI` class provides shorthand factory methods that hide namespace verbosity:

```ruby
RatatuiRuby.run do |tui|
  tui.paragraph(text: "Hello")
  tui.constraint_length(20)
  tui.style(fg: :red)
end
```

**Why This Matters:**

Users write application code using the TUI API and rarely touch deep namespaces. Contributors maintaining the library work with explicit, documentable, IDE-friendly classes. Both audiences are served without compromise.

### 3. Explicit Over Magic

The TUI facade uses explicit factory method definitions, not runtime metaprogramming.

**What We Do:**

```ruby
# lib/ratatui_ruby/tui/widget_factories.rb
module RatatuiRuby
  class TUI
    module WidgetFactories
      def paragraph(**kwargs)
        Widgets::Paragraph.new(**kwargs)
      end
      
      def table(**kwargs)
        Widgets::Table.new(**kwargs)
      end
    end
  end
end
```

**What We Don't Do:**

```ruby
# NO: Dynamic method generation
RatatuiRuby.constants.each do |const|
  define_method(const.underscore) { |**kw| RatatuiRuby.const_get(const).new(**kw) }
end
```

**Benefits of Explicit Definitions:**

1. **IDE Support**: Solargraph and Ruby LSP provide autocomplete because methods exist at parse time.
2. **RDoc**: Each method can have its own documentation with examples.
3. **RBS Types**: Each method has an explicit type signature.
4. **Debugging**: Stack traces show real method names, not `define_method` closures.
5. **Decoupling**: Internal class names can change without breaking the public TUI API.

### 4. Data-Driven UI (Immediate Mode)

All UI components are pure, immutable `Data.define` value objects. They describe *desired appearance* for a single frame, not live stateful objects.

**Widgets Are Inputs:**

```ruby
# This is just data. It has no behavior, no side effects.
paragraph = RatatuiRuby::Widgets::Paragraph.new(
  text: "Hello",
  style: RatatuiRuby::Style::Style.new(fg: :red)
)

# Pass to renderer as input
frame.render_widget(paragraph, area)
```

**Immediate Mode Loop:**

Every frame, the application constructs a fresh view tree and passes it to `draw`. No widget state persists between frames. This is Ratatui's core paradigm.

```ruby
loop do
  tui.draw do |frame|
    # Fresh tree every frame
    frame.render_widget(tui.paragraph(text: "Time: #{Time.now}"), frame.area)
  end
  break if tui.poll_event.key? && tui.poll_event.code == "q"
end
```

### 5. Separation of Configuration and Status

Widgets (Configuration) and State (Status) are strictly separated.

**Configuration (Input):**

Widgets define *what* to render. They are created, rendered, and discarded.

```ruby
list = tui.list(items: ["A", "B", "C", "D", "E"])
```

**Status (Output):**

State objects track *runtime metrics* computed by the Rust backend: scroll offsets, selection positions, etc. They persist across frames.

```ruby
# Created once
@list_state = RatatuiRuby::ListState.new

# Used every frame
frame.render_stateful_widget(list, area, @list_state)

# Read back computed values
puts "Scroll offset: #{@list_state.offset}"
```

**Precedence Rule:**

When using `render_stateful_widget`, the State object is the source of truth. Widget properties like `selected_index` are ignored.

### 6. No Render Logic in Ruby

Ruby defines data structures. Rust renders them.

The classes in `lib/ratatui_ruby/widgets/` contain no rendering code. They are pure structural definitions that the Rust extension walks and converts to Ratatui primitives.

**Ruby's Job:**
- Define `Data.define` classes with attributes
- Validate inputs (types, ranges)
- Provide convenience constructors

**Rust's Job:**
- Walk the Ruby object tree
- Extract attributes via `funcall`
- Construct Ratatui widgets
- Render to the terminal buffer

This separation ensures rendering performance remains in Rust while Ruby handles the ergonomic API layer.

---

## Directory Structure

```
lib/ratatui_ruby/
├── tui.rb                    # TUI class, includes all mixins
├── tui/                      # TUI facade mixins
│   ├── core.rb               # draw, poll_event, get_cell_at
│   ├── layout_factories.rb   # rect, constraint_*, layout_split
│   ├── style_factories.rb    # style
│   ├── widget_factories.rb   # paragraph, block, table, list, etc.
│   ├── text_factories.rb     # span, line, text_width
│   ├── state_factories.rb    # list_state, table_state, scrollbar_state
│   ├── canvas_factories.rb   # shape_map, shape_line, etc.
│   └── buffer_factories.rb   # cell (for buffer inspection)
├── layout/                   # ratatui::layout
│   ├── rect.rb
│   ├── constraint.rb
│   └── layout.rb
├── widgets/                  # ratatui::widgets
│   ├── paragraph.rb
│   ├── block.rb
│   ├── table.rb
│   ├── list.rb
│   ├── row.rb               # Table row wrapper
│   ├── cell.rb              # Table cell wrapper (NOT buffer cell)
│   └── ...
├── style/                    # ratatui::style
│   └── style.rb
├── text/                     # ratatui::text
│   ├── span.rb
│   └── line.rb
├── buffer/                   # ratatui::buffer
│   └── cell.rb              # For get_cell_at inspection
└── schema/                   # Legacy location (being migrated)
```

---

## Adding a New Widget

### Step 1: Create the Schema Class

Define the Data class in the appropriate namespace directory:

```ruby
# lib/ratatui_ruby/widgets/my_widget.rb
module RatatuiRuby
  module Widgets
    # A widget that displays foo with optional styling.
    #
    # [content] The text content to display.
    # [style] Optional styling for the content.
    # [block] Optional block border wrapper.
    class MyWidget < Data.define(:content, :style, :block)
      def initialize(content:, style: nil, block: nil)
        super
      end
    end
  end
end
```

### Step 2: Add the RBS Type

```rbs
# sig/ratatui_ruby/widgets/my_widget.rbs
module RatatuiRuby
  module Widgets
    class MyWidget < Data
      attr_reader content: String
      attr_reader style: Style::Style?
      attr_reader block: Block?

      def self.new: (content: String, ?style: Style::Style?, ?block: Block?) -> MyWidget
    end
  end
end
```

### Step 3: Add the TUI Factory Method

```ruby
# lib/ratatui_ruby/tui/widget_factories.rb
def my_widget(**kwargs)
  Widgets::MyWidget.new(**kwargs)
end
```

### Step 4: Implement Rust Rendering

See `rust_backend.md` for the Rust implementation steps.

### Step 5: Register in Requires

Add to `lib/ratatui_ruby.rb`:

```ruby
require_relative "ratatui_ruby/widgets/my_widget"
```

---

## TUI Mixin Architecture

The `TUI` class is composed of 8 focused mixins, each with a single responsibility:

| Mixin | Methods | Purpose |
|-------|---------|---------|
| `Core` | `draw`, `poll_event`, `get_cell_at`, `draw_cell` | Terminal I/O operations |
| `LayoutFactories` | `rect`, `constraint_*`, `layout`, `layout_split` | Layout construction |
| `StyleFactories` | `style` | Style construction |
| `WidgetFactories` | `paragraph`, `block`, `table`, `list`, etc. | Widget construction |
| `TextFactories` | `span`, `line`, `text_width` | Text construction |
| `StateFactories` | `list_state`, `table_state`, `scrollbar_state` | State object construction |
| `CanvasFactories` | `shape_map`, `shape_line`, `shape_circle`, etc. | Canvas shape construction |
| `BufferFactories` | `cell` | Buffer cell construction (for testing) |

This modular structure keeps each file focused (~20-50 lines) and makes it easy to locate and modify factory methods.

---

## Thread and Ractor Safety

### Shareable (Frozen Data Objects)

These are deeply frozen and `Ractor.shareable?`:

- `Event::*` objects from `poll_event`
- `Buffer::Cell` objects from `get_cell_at`  
- `Layout::Rect` objects from `Layout.split`

### Not Shareable (I/O Handles)

These have side effects and are intentionally not Ractor-safe:

- `TUI` — Has terminal I/O methods
- `Frame` — Valid only during the `draw` block; invalid after

```ruby
# OK: Cache TUI during run loop
RatatuiRuby.run do |tui|
  @tui = tui
  loop { render; handle_input }
end

# NOT OK: Include in immutable Model
Model = Data.define(:tui, :count)  # Don't do this
```
