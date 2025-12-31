<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Frame-Based Rendering: Aligning RatatuiRuby with Native Ratatui

## Executive Summary

RatatuiRuby's current declarative API hides critical layout information from developers, forcing them to duplicate layout logic for hit testing. This proposal introduces a **Frame-based rendering API** that mirrors native Rust Ratatui, giving developers explicit control over widget placement while exporting computed geometry for input handling.

This approach provides maximum alignment with the upstream Ratatui library, enabling knowledge transfer between Rust and Ruby codebases and positioning RatatuiRuby for future feature parity.

## Problem Statement

### The Abstraction Gap

Native Rust Ratatui gives developers direct access to the `Frame` and explicit control over where widgets are rendered:

```rust
// Rust Ratatui: Explicit control
terminal.draw(|frame| {
    let chunks = Layout::default()
        .constraints([Length(20), Fill(1)])
        .split(frame.area());
    
    let sidebar_rect = chunks[0];  // Developer has this
    let main_rect = chunks[1];     // Developer has this
    
    frame.render_widget(sidebar, sidebar_rect);
    frame.render_widget(main, main_rect);
})?;

// Hit testing uses the same rects
if sidebar_rect.contains(mouse_pos) { ... }
```

RatatuiRuby's declarative approach abstracts this away:

```ruby
# RatatuiRuby: Layout hidden inside render
RatatuiRuby.draw(
  RatatuiRuby::Layout.new(
    constraints: [...],
    children: [sidebar, main]  # Rects computed internally, never exposed
  )
)
```

### The Duplication Tax

Without access to computed rects, developers must duplicate layout logic:

```ruby
def run
  loop do
    calculate_layout  # Duplicate #1: Manual rect computation
    render            # Duplicate #2: Same layout, different purpose
    handle_input      # Uses rects from #1
  end
end
```

This is:
- **Error-prone**: Layout changes require updates in two places
- **Wasteful**: Layout computed twice per frame
- **Un-Rubyist**: Violates DRY principle
- **Un-Ratatui**: Native Rust apps don't have this problem

## Proposed Solution: Frame Object

Expose a `Frame` object to Ruby that mirrors the native Rust Ratatui API. The Frame provides:

1. **Explicit rendering control**: Developers render widgets at specific locations
2. **Access to terminal dimensions**: `frame.area` returns the current terminal `Rect`
3. **Computed rect collection**: Every `render_widget` call records the widget's location
4. **Direct parity with Rust**: Same mental model, transferable knowledge

### Core API

```ruby
RatatuiRuby.draw do |frame|
  # frame.area => Rect representing the full terminal
  chunks = RatatuiRuby::Layout.split(
    frame.area,
    direction: :horizontal,
    constraints: [
      RatatuiRuby::Constraint.percentage(30),
      RatatuiRuby::Constraint.fill(1)
    ]
  )
  
  @sidebar_rect = chunks[0]
  @main_rect = chunks[1]
  
  # Explicit widget placement (like Rust's frame.render_widget)
  frame.render(sidebar_widget, @sidebar_rect)
  frame.render(main_widget, @main_rect)
end

# Hit testing uses the same rects — no duplication!
if @sidebar_rect.contains?(click_x, click_y)
  handle_sidebar_click
end
```

### The Frame Class

```ruby
module RatatuiRuby
  class Frame
    # The full terminal area
    attr_reader :area  # => Rect
    
    # Render a widget at a specific location
    def render(widget, area)
      # Delegates to Rust backend
    end
    
    # Render a stateful widget
    def render_stateful(widget, area, state)
      # For widgets with state (List selection, Table scroll, etc.)
    end
    
    # Set cursor position
    def set_cursor_position(x, y)
      # For text input focus
    end
  end
end
```

### Comparison: Current vs. Proposed

| Aspect | Current (Declarative) | Proposed (Frame-based) |
|--------|----------------------|------------------------|
| Widget placement | Implicit (tree structure) | Explicit (developer specifies rect) |
| Rect access | None (hidden in Rust) | Direct (from `Layout.split`) |
| Hit testing | Requires duplicated layout | Uses same rects as rendering |
| Rust alignment | Low (custom abstraction) | High (same `frame.render` pattern) |
| Learning curve | Lower entry barrier | Familiar to Ratatui developers |
| Flexibility | Limited | Full control |

## Detailed Design

### 1. `RatatuiRuby.draw` with Block

Change `draw` to accept a block yielding a `Frame`:

```ruby
# New signature
def self.draw(&block)  # => nil
  # ...
end

# Usage
RatatuiRuby.draw do |frame|
  # Developer has full control
end
```

### 2. Layout Integration

`Layout.split` already exists and works perfectly with this model:

```ruby
RatatuiRuby.draw do |frame|
  # Vertical split: header, main, footer
  header, main, footer = RatatuiRuby::Layout.split(
    frame.area,
    direction: :vertical,
    constraints: [
      RatatuiRuby::Constraint.length(3),
      RatatuiRuby::Constraint.fill(1),
      RatatuiRuby::Constraint.length(1)
    ]
  )
  
  # Horizontal split within main
  sidebar, content = RatatuiRuby::Layout.split(
    main,
    direction: :horizontal,
    constraints: [
      RatatuiRuby::Constraint.percentage(25),
      RatatuiRuby::Constraint.fill(1)
    ]
  )
  
  # Explicit rendering with full rect visibility
  frame.render(build_header, header)
  frame.render(build_sidebar, sidebar)
  frame.render(build_content, content)
  frame.render(build_footer, footer)
  
  # Store rects for hit testing
  @regions = { sidebar: sidebar, content: content }
end
```

### 3. Nested Widgets

Widgets can contain children. The Frame applies parent transforms:

```ruby
RatatuiRuby.draw do |frame|
  sidebar_rect = ...
  
  # Block widget with children — still works
  block = RatatuiRuby::Block.new(
    title: "Sidebar",
    borders: [:all],
    children: [paragraph, list]  # Children rendered inside block's inner area
  )
  
  frame.render(block, sidebar_rect)
end
```

The Block widget internally manages its children's layout, but the **outer rect** is controlled by the developer.

### 4. Stateful Widgets

Table and List have selection state. The Frame provides `render_stateful`:

```ruby
RatatuiRuby.draw do |frame|
  table_rect = ...
  
  frame.render_stateful(@table_widget, table_rect, @table_state)
  # @table_state tracks selected row, scroll position, etc.
end
```

### 5. Cursor Positioning

Text inputs need cursor placement:

```ruby
RatatuiRuby.draw do |frame|
  input_rect = ...
  
  frame.render(@input_widget, input_rect)
  
  if @input_focused
    # Position cursor at end of input text
    frame.set_cursor_position(input_rect.x + @cursor_offset, input_rect.y)
  end
end
```

## Example: Complete App

```ruby
class DashboardApp
  def initialize
    @sidebar_items = ["Home", "Settings", "Logs", "Help"]
    @selected_index = 0
    @regions = {}
  end

  def run
    RatatuiRuby.run do
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  def render
    RatatuiRuby.draw do |frame|
      # Layout computation — single source of truth
      sidebar, main = RatatuiRuby::Layout.split(
        frame.area,
        direction: :horizontal,
        constraints: [
          RatatuiRuby::Constraint.length(20),
          RatatuiRuby::Constraint.fill(1)
        ]
      )
      
      # Build widgets
      sidebar_widget = RatatuiRuby::List.new(
        items: @sidebar_items,
        selected_index: @selected_index,
        highlight_style: RatatuiRuby::Style.new(fg: :yellow, modifiers: [:bold]),
        block: RatatuiRuby::Block.new(title: "Navigation", borders: [:all])
      )
      
      main_widget = RatatuiRuby::Paragraph.new(
        text: "Selected: #{@sidebar_items[@selected_index]}",
        block: RatatuiRuby::Block.new(title: "Content", borders: [:all])
      )
      
      # Explicit rendering
      frame.render(sidebar_widget, sidebar)
      frame.render(main_widget, main)
      
      # Store for hit testing
      @regions = { sidebar: sidebar, main: main }
    end
  end

  def handle_input
    event = RatatuiRuby.poll_event
    return unless event

    case event
    in type: :key, code: "q"
      :quit
    in type: :key, code: "up"
      @selected_index = [@selected_index - 1, 0].max
    in type: :key, code: "down"
      @selected_index = [@selected_index + 1, @sidebar_items.length - 1].min
    in type: :mouse, kind: "down", x:, y:
      if @regions[:sidebar]&.contains?(x, y)
        # Could calculate which item was clicked based on y coordinate
        handle_sidebar_click(y - @regions[:sidebar].y)
      end
    else
      nil
    end
  end

  def handle_sidebar_click(relative_y)
    # List items are 1 row each (after accounting for border)
    clicked_index = relative_y - 1  # -1 for top border
    if clicked_index >= 0 && clicked_index < @sidebar_items.length
      @selected_index = clicked_index
    end
  end
end
```

## Benefits

### 1. Rust Parity

The Frame API mirrors native Ratatui exactly:

| Rust | Ruby |
|------|------|
| `frame.area()` | `frame.area` |
| `frame.render_widget(w, a)` | `frame.render(w, a)` |
| `frame.render_stateful_widget(w, a, s)` | `frame.render_stateful(w, a, s)` |
| `frame.set_cursor_position(p)` | `frame.set_cursor_position(x, y)` |

Knowledge transfers directly between languages. Rust Ratatui tutorials and examples become relevant to RatatuiRuby users.

### 2. Single Source of Truth

Rects computed once, used for both rendering and hit testing:

```ruby
@sidebar = Layout.split(...)[0]  # Computed once
frame.render(widget, @sidebar)   # Used for rendering
@sidebar.contains?(x, y)         # Used for hit testing
```

### 3. Full Flexibility

Developers control exact widget placement. Complex layouts are straightforward:

```ruby
# Overlapping widgets for popups
frame.render(background, frame.area)
frame.render(popup, centered_popup_rect)

# Conditional rendering
frame.render(sidebar, sidebar_rect) if @sidebar_visible

# Dynamic layout based on terminal size
if frame.area.width > 100
  # Wide layout
else
  # Narrow layout
end
```

### 4. Future-Proof

As Ratatui adds features, RatatuiRuby can expose them naturally through the Frame API without redesigning the abstraction layer.

## Sub-Widget Targeting

The Frame approach excels at outer widget placement but leaves a question: How do we handle clicks on **sub-widget elements** like table rows, list items, or individual tabs?

Native Rust Ratatui also doesn't solve this automatically—developers must manually calculate row indices from coordinates, row heights, and scroll offsets. However, RatatuiRuby can do better.

### The Problem

```ruby
RatatuiRuby.draw do |frame|
  table_rect = ...
  frame.render(table, table_rect)
  @regions[:table] = table_rect  # We have the TABLE rect, but not row rects
end

# Hit testing: Which row was clicked?
if @regions[:table].contains?(x, y)
  # Manual calculation required:
  clicked_row = (y - @regions[:table].y - header_height) / row_height
end
```

This is tedious and error-prone, especially with variable row heights or scroll offsets.

### Option A: `frame.render` Returns Sub-Widget Layout Info

Extend `frame.render` to return layout information computed during rendering:

```ruby
RatatuiRuby.draw do |frame|
  table_rect = ...
  
  # render() returns detailed layout info
  layout_info = frame.render(table, table_rect)
  
  @table_layout = layout_info
  # => {
  #   area: Rect(0, 0, 80, 20),
  #   header: Rect(0, 0, 80, 1),
  #   rows: [
  #     Rect(0, 1, 80, 1),   # Row 0
  #     Rect(0, 2, 80, 1),   # Row 1
  #     ...
  #   ],
  #   cells: [               # For Table: 2D array of cell rects
  #     [Rect(...), Rect(...)],  # Row 0 cells
  #     [Rect(...), Rect(...)],  # Row 1 cells
  #   ]
  # }
end

# Hit testing becomes trivial
clicked_row = @table_layout[:rows].find_index { |r| r.contains?(x, y) }
clicked_cell = @table_layout[:cells].flatten.find { |c| c.contains?(x, y) }
```

**Pros:**
- Most complete solution
- No manual calculations ever needed
- Works with scroll offsets automatically

**Cons:**
- Requires significant Rust-side changes (widgets must report internal layout)
- Some widgets may not have meaningful sub-structure

### Option B: Query Methods on Frame

Add utility methods to Frame for common sub-widget calculations:

```ruby
RatatuiRuby.draw do |frame|
  table_rect = ...
  frame.render(table, table_rect)
  
  # During the same draw call, can query computed info
  @row_rects = frame.rendered_rows(table)  # Returns array of Rects
  @visible_range = frame.visible_row_range(table)  # [first, last] indices
end

# Alternative: calculation helpers (don't require widget tracking)
clicked_row = Frame.row_index_at(
  click_y,
  table_rect: @regions[:table],
  header_height: 1,
  row_height: 1,
  scroll_offset: @scroll_offset
)
```

**Pros:**
- Less invasive than Option A
- Can provide both widget-tracking and pure calculation approaches
- Calculation helpers work without Rust changes

**Cons:**
- Widget-tracking version still requires some Rust work
- Calculation helpers shift burden back to developer for complex cases

### Option C: Hybrid with ID Tagging

Combine Frame for outer layout with an `id:` parameter for sub-widget tracking:

```ruby
RatatuiRuby.draw do |frame|
  sidebar, main = RatatuiRuby::Layout.split(frame.area, ...)
  
  # Outer layout: explicit Frame control
  frame.render(sidebar_widget, sidebar)
  @regions[:sidebar] = sidebar
  
  # Sub-widget targeting: id tags on rows
  table = RatatuiRuby::Table.new(
    rows: items.map.with_index { |item, i|
      Row.new(cells: [...], id: [:row, i])  # Tag each row
    }
  )
  
  result = frame.render(table, main)
  @regions[:main] = main
  @row_regions = result  # { [:row, 0] => Rect, [:row, 1] => Rect, ... }
end

# Hit testing uses both
if @regions[:sidebar].contains?(x, y)
  handle_sidebar_click
elsif row_id = @row_regions.find { |id, rect| rect.contains?(x, y) }&.first
  handle_row_click(row_id[1])  # row_id is [:row, index]
end
```

**Pros:**
- Best of both worlds: explicit outer layout + tagged sub-widgets
- Aligns with Ruby's flexible object-as-key pattern
- Incremental: `id:` is optional, only used where needed

**Cons:**
- Two mechanisms to learn
- Requires implementing both Frame and id-tracking features

### Option D: Do Nothing (Align with Ratatui)

Match native Rust Ratatui exactly: provide no sub-widget targeting support. Developers calculate row indices manually, just as they do in Rust.

```ruby
RatatuiRuby.draw do |frame|
  table_rect = ...
  frame.render(table, table_rect)
  @regions[:table] = table_rect
end

# Hit testing: Manual calculation (same as Rust)
if @regions[:table].contains?(x, y)
  relative_y = y - @regions[:table].y
  header_height = 1
  row_height = 1
  
  if relative_y >= header_height
    clicked_row = (relative_y - header_height) / row_height + @scroll_offset
    handle_row_click(clicked_row) if clicked_row < @rows.length
  end
end
```

**Pros:**
- Perfect alignment with Rust Ratatui — knowledge transfers directly
- No new concepts for developers familiar with Ratatui
- Keeps RatatuiRuby minimal and focused

**Cons:**
- Tedious for developers
- Error-prone with scroll offsets, variable row heights, borders
- Misses opportunity to provide better DX than Rust

### Recommendation

**Start with Option D (Do Nothing)**. It provides:
1. Frame for explicit outer layout control (solves the main problem)
2. Perfect Rust alignment — no divergence from upstream patterns

Consider Option C (Hybrid with `id:`) as a future enhancement if sub-widget targeting proves to be a common pain point. Option A (return sub-widget layout) is the most complete solution but should only be pursued if there's demonstrated demand.

The Frame API can be extended with Option A's return-value approach in a future iteration once the core Frame infrastructure exists.

## Implementation

### Rust Side

```rust
// Frame wrapper exposed to Ruby
#[magnus::wrap(class = "RatatuiRuby::Frame")]
struct RubyFrame {
    inner: RefCell<Frame<'static>>,
}

impl RubyFrame {
    fn area(&self) -> RubyRect {
        let frame = self.inner.borrow();
        RubyRect::from(frame.area())
    }
    
    fn render(&self, widget: Value, area: RubyRect) -> Result<(), Error> {
        let frame = self.inner.borrow_mut();
        // Render widget at specified area
        render_node(frame, area.into(), widget)
    }
}

// Updated draw function
fn draw_with_block(block: Proc) -> Result<(), Error> {
    TERMINAL.lock().unwrap().draw(|frame| {
        let ruby_frame = RubyFrame { inner: RefCell::new(frame) };
        block.call((ruby_frame,))?;
        Ok(())
    })
}
```

### Ruby Side

```ruby
module RatatuiRuby
  class Frame
    # Rust-backed methods:
    # - area: Rect
    # - render(widget, rect): nil
    # - render_stateful(widget, rect, state): nil
    # - set_cursor_position(x, y): nil
  end
  
  def self.draw(tree = nil, &block)
    if block_given?
      _draw_with_block(&block)
    else
      _draw_tree(tree)
    end
  end
end
```

## Design Alignment

### Preserving Immediate-Mode Rendering

A key question: Does the Frame approach abandon immediate-mode rendering?

**No.** Native Rust Ratatui uses this exact pattern and is definitively immediate-mode. The Frame block is a callback that runs once per frame—it does not build retained state.

| Immediate-Mode Characteristic | Frame Approach | Status |
|-------------------------------|----------------|--------|
| No retained widget objects | Widgets are Data objects, created fresh each frame | ✅ Preserved |
| UI rebuilt from scratch each frame | Block runs every frame, calling `frame.render()` anew | ✅ Preserved |
| No diffing or reconciliation | Every frame overwrites the buffer completely | ✅ Preserved |
| State lives in app, not widgets | `@selected_index`, etc. remain in app | ✅ Preserved |

### Declarative vs. Imperative (Not Retained vs. Immediate)

The real distinction is **declarative vs. imperative**, not **retained vs. immediate**:

| | Current (Declarative) | Frame (Imperative) |
|--|----------------------|-------------------|
| **Style** | Describe WHAT (tree) → Rust figures out WHERE | Tell Rust WHERE to render each widget |
| **Control** | Implicit (constraints drive placement) | Explicit (developer specifies rects) |
| **Mental model** | "Build a tree, hand it off" | "Paint widgets onto a canvas" |
| **Immediate-mode?** | Yes | Yes |

Both approaches are immediate-mode. The Frame approach simply gives developers more explicit control—matching how native Rust Ratatui works.

## Trade-offs

### Increased Verbosity

Frame-based code is more explicit:

```ruby
# Declarative (fewer lines)
RatatuiRuby.draw(Layout.new(children: [a, b]))

# Frame-based (more lines, more control)
RatatuiRuby.draw do |frame|
  left, right = Layout.split(frame.area, ...)
  frame.render(a, left)
  frame.render(b, right)
end
```

**Counter-argument**: The verbosity is justified. It makes the code's behavior explicit and eliminates hidden complexity. Apps that need hit testing (most interactive apps) will have *fewer* total lines because they don't duplicate layout logic.

### Learning Curve

New users must understand `Frame` and `Layout.split` rather than just passing a tree.

**Counter-argument**: This matches how Rust Ratatui works. Users learning from Rust tutorials or porting Rust apps will find RatatuiRuby familiar. The current tree abstraction is a leaky abstraction that causes confusion when hit testing is needed.

## Recommendation

**Approve the Frame-based API.** It:

1. **Eliminates layout duplication** — the core problem
2. **Aligns with Rust Ratatui** — knowledge transfer, tutorials apply
3. **Future-proofs RatatuiRuby** — new Ratatui features map naturally
4. **Provides full flexibility** — handles any layout scenario
5. **Maintains compatibility** — tree API still works

The initial investment is higher than simpler alternatives, but the long-term benefits justify the cost. RatatuiRuby should aspire to be a Ruby interface to Ratatui, not a reimagined abstraction on top of it.
