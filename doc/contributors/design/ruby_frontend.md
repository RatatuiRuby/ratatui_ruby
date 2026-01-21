<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Ruby Frontend Design (`ratatui_ruby`)

This document describes the architectural design and guiding principles of the Ruby layer in `ratatui_ruby`. It is intended for contributors, architects, and AI agents working on the codebase.

## Guiding Design Principles

### 1. Three-Tier Namespace Architecture

The gem provides three distinct namespaces, each with a specific purpose:

**Tier 1: `Ratatui::` — Upstream Alignment**

Pure upstream Ratatui types with 1:1 API correspondence. If it exists in Rust Ratatui, it has the same name and location here.

| Rust Module | Ruby Module | Purpose |
|-------------|-------------|---------|
| `ratatui::layout` | `Ratatui::Layout` | Rect, Constraint, Layout, Position, Size |
| `ratatui::widgets` | `Ratatui::Widgets` | All widgets (Table, List, Paragraph, Block, etc.) |
| `ratatui::style` | `Ratatui::Style` | Style, Color |
| `ratatui::text` | `Ratatui::Text` | Span, Line |
| `ratatui::buffer` | `Ratatui::Buffer` | Cell (for buffer inspection) |
| `ratatui::backend` | `Ratatui::Backend` | WindowSize |
| `ratatui::Terminal` | `Ratatui::Terminal` | Terminal lifecycle (draw, size, cursor) |
| `ratatui::Frame` | `Ratatui::Frame` | Frame object for render callbacks |

**Tier 2: `Crossterm::` — Backend Alignment**

Direct exposure of crossterm functionality. These are terminal I/O primitives that Ratatui builds upon.

| Rust Module | Ruby Module | Purpose |
|-------------|-------------|---------|
| `crossterm::terminal` | `Crossterm::Terminal` | `supports_keyboard_enhancement?`, `window_size` |
| `crossterm::style` | `Crossterm::Style` | `available_color_count`, `force_color_output` |

**Tier 3: `RatatuiRuby::` — Ruby Convenience Layer**

Ruby-specific conveniences, the main entry point, and the TUI DSL facade. This is where Ruby idioms live.

- `RatatuiRuby.run { |tui| ... }` — Main entry point with setup/teardown
- `RatatuiRuby.tty?`, `RatatuiRuby.dumb?`, `RatatuiRuby.interactive?` — Environment detection (Ruby-specific)
- `RatatuiRuby::TUI` — DSL facade with shorthand factory methods
- `RatatuiRuby::TestHelper` — Testing utilities
- `RatatuiRuby::Error` — Exception hierarchy

**Why Three Tiers?**

1. **Upstream Purity**: Users who want exact Ratatui API parity use `Ratatui::` and `Crossterm::` namespaces.
2. **Ruby Idioms**: Users who want convenience use `RatatuiRuby.run`, the TUI facade, and helper methods.
3. **Documentation Mapping**: A contributor reading Ratatui's Rust docs immediately knows where to find the Ruby equivalent.
4. **Predictability**: As upstream adds types, their Ruby placement is deterministic.

> [!NOTE]
> This three-tier architecture will be rolled out incrementally as 1.x releases. The `Ratatui::` and `Crossterm::` namespaces are additive—`RatatuiRuby::` will continue to work by delegating to them. No breaking changes required.

### 2. Two-Layer Architecture

The Ruby frontend implements a "Mullet Architecture": structured namespaces in the library, flat ergonomic DSL for users.

**Layer 1: Schema Classes (The Library)**

Located in `lib/ratatui_ruby/widgets/`, `lib/ratatui_ruby/layout/`, etc.

These are the actual `Data.define` classes that the Rust backend expects. They have deep, explicit namespaces that match Ratatui:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
RatatuiRuby::Widgets::Paragraph.new(text: "Hello")
RatatuiRuby::Layout::Constraint.length(20)
RatatuiRuby::Style::Style.new(fg: :red)
```
<!-- SPDX-SnippetEnd -->

**Layer 2: TUI Facade (The DSL)**

Located in `lib/ratatui_ruby/tui.rb` and `lib/ratatui_ruby/tui/*.rb` mixins.

The `TUI` class provides shorthand factory methods that hide namespace verbosity:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
RatatuiRuby.run do |tui|
  tui.paragraph(text: "Hello")
  tui.constraint_length(20)
  tui.style(fg: :red)
end
```
<!-- SPDX-SnippetEnd -->

**Why This Matters:**

Users write application code using the TUI API and rarely touch deep namespaces. Contributors maintaining the library work with explicit, documentable, IDE-friendly classes. Both audiences are served without compromise.

### 3. Explicit Over Magic

The TUI facade uses explicit factory method definitions, not runtime metaprogramming.

**What We Do:**

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
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
<!-- SPDX-SnippetEnd -->

**What We Don't Do:**

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# NO: Dynamic method generation
RatatuiRuby.constants.each do |const|
  define_method(const.underscore) { |**kw| RatatuiRuby.const_get(const).new(**kw) }
end
```
<!-- SPDX-SnippetEnd -->

**Benefits of Explicit Definitions:**

1. **IDE Support**: Solargraph and Ruby LSP provide autocomplete because methods exist at parse time.
2. **RDoc**: Each method can have its own documentation with examples.
3. **RBS Types**: Each method has an explicit type signature.
4. **Debugging**: Stack traces show real method names, not `define_method` closures.
5. **Decoupling**: Internal class names can change without breaking the public TUI API.

### 4. Data-Driven UI (Immediate Mode)

All UI components are pure, immutable `Data.define` value objects. They describe *desired appearance* for a single frame, not live stateful objects.

**Widgets Are Inputs:**

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# This is just data. It has no behavior, no side effects.
paragraph = RatatuiRuby::Widgets::Paragraph.new(
  text: "Hello",
  style: RatatuiRuby::Style::Style.new(fg: :red)
)

# Pass to renderer as input
frame.render_widget(paragraph, area)
```
<!-- SPDX-SnippetEnd -->

**Immediate Mode Loop:**

Every frame, the application constructs a fresh view tree and passes it to `draw`. No widget state persists between frames. This is Ratatui's core paradigm.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
loop do
  tui.draw do |frame|
    # Fresh tree every frame
    frame.render_widget(tui.paragraph(text: "Time: #{Time.now}"), frame.area)
  end
  break if tui.poll_event.key? && tui.poll_event.code == "q"
end
```
<!-- SPDX-SnippetEnd -->

### 5. Separation of Configuration and Status

Widgets (Configuration) and State (Status) are strictly separated.

**Configuration (Input):**

Widgets define *what* to render. They are created, rendered, and discarded.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
list = tui.list(items: ["A", "B", "C", "D", "E"])
```
<!-- SPDX-SnippetEnd -->

**Status (Output):**

State objects track *runtime metrics* computed by the Rust backend: scroll offsets, selection positions, etc. They persist across frames.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# Created once
@list_state = RatatuiRuby::ListState.new

# Used every frame
frame.render_stateful_widget(list, area, @list_state)

# Read back computed values
puts "Scroll offset: #{@list_state.offset}"
```
<!-- SPDX-SnippetEnd -->

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

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
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
<!-- SPDX-SnippetEnd -->

---

## Adding a New Widget

### Step 1: Create the Schema Class

Define the Data class in the appropriate namespace directory:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
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
<!-- SPDX-SnippetEnd -->

### Step 2: Add the RBS Type

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
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
<!-- SPDX-SnippetEnd -->

### Step 3: Add the TUI Factory Method

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# lib/ratatui_ruby/tui/widget_factories.rb
def my_widget(**kwargs)
  Widgets::MyWidget.new(**kwargs)
end
```
<!-- SPDX-SnippetEnd -->

### Step 4: Implement Rust Rendering

See `rust_backend.md` for the Rust implementation steps.

### Step 5: Register in Requires

Add to `lib/ratatui_ruby.rb`:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
require_relative "ratatui_ruby/widgets/my_widget"
```
<!-- SPDX-SnippetEnd -->

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

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# OK: Cache TUI during run loop
RatatuiRuby.run do |tui|
  @tui = tui
  loop { render; handle_input }
end

# NOT OK: Include in immutable Model
Model = Data.define(:tui, :count)  # Don't do this
```
<!-- SPDX-SnippetEnd -->
