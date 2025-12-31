<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Improving DX for Layout & Hit Testing

## Problem Statement

Interactive TUI applications require hit testing: determining which UI region the user clicked. Current RatatuiRuby practice duplicates layout logic between rendering and input handling.

### Current Pattern (Duplication)

```ruby
def run
  loop do
    calculate_layout  # Phase 1: Manually calculate rects
    render            # Phase 2: Build UI tree (repeating the same layout logic)
    handle_input      # Phase 3: Use cached rects from Phase 1
  end
end

def calculate_layout
  full_area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 80, height: 24)
  
  @main_area, @control_area = RatatuiRuby::Layout.split(
    full_area,
    direction: :vertical,
    constraints: [
      RatatuiRuby::Constraint.fill(1),
      RatatuiRuby::Constraint.length(7)
    ]
  )
  
  @left_rect, @right_rect = RatatuiRuby::Layout.split(
    @main_area,
    direction: :horizontal,
    constraints: [
      RatatuiRuby::Constraint.percentage(50),
      RatatuiRuby::Constraint.percentage(50)
    ]
  )
end

def render
  # Rebuilds the SAME layout internally, but we can't access those rects
  layout = RatatuiRuby::Layout.new(
    direction: :vertical,
    constraints: [
      RatatuiRuby::Constraint.fill(1),
      RatatuiRuby::Constraint.length(7)
    ],
    children: [...]
  )
  RatatuiRuby.draw(layout)
end

def handle_input
  event = RatatuiRuby.poll_event
  if @left_rect&.contains?(event.x, event.y)
    # hit test using cached rect
  end
end
```

**Problems:**
1. **Duplication**: Layout constraints are written twice—once in `calculate_layout`, once in the UI tree.
2. **Fragility**: If layout changes in `render`, the cached rects become stale.
3. **Maintainability**: Adding new UI regions requires changes in two places.
4. **Performance**: Layout is calculated twice per frame.
5. **No sub-widget targeting**: Native Ratatui apps manually calculate Table row / List item positions from coordinates—tedious and error-prone.

### Ideal Pattern (No Duplication)

```ruby
def run
  loop do
    render            # Single source of truth
    break if handle_input == :quit
  end
end

def render
  layout = RatatuiRuby::Layout.new(
    direction: :vertical,
    constraints: [...],
    children: [...]
  )
  
  @regions = RatatuiRuby.draw(layout)  # Returns layout metadata
end

def handle_input
  event = RatatuiRuby.poll_event
  # Query the regions returned from draw()
  if @regions[:left_panel]&.contains?(event.x, event.y)
    handle_left_click
  end
end
```

## Proposed Solution

Extend `RatatuiRuby.draw()` to return a Hash mapping **tagged identifiers** to their rendered `Rect`.

### Core Design: The `id` Parameter

Add an optional `id:` parameter to **all widgets**. Any widget with an `id` will have its rendered `Rect` included in the Hash returned by `draw()`.

**Key design decisions:**

1. **`id` can be any Ruby object** — not just Symbols or Strings. Objects are compared using `==` and used as Hash keys, so they should implement `hash` and `eql?` correctly.

2. **`id` is added to all widgets** — not just containers. This enables sub-widget targeting (e.g., tagging individual Table rows or List items).

3. **`draw()` always returns a Hash** — empty if no widgets have `id`, populated otherwise.

### Basic Usage

```ruby
# Simple case: Symbols as IDs
layout = RatatuiRuby::Layout.new(
  direction: :horizontal,
  constraints: [
    RatatuiRuby::Constraint.percentage(30),
    RatatuiRuby::Constraint.percentage(70)
  ],
  children: [
    RatatuiRuby::Block.new(title: "Sidebar", id: :sidebar),
    RatatuiRuby::Block.new(title: "Main", id: :main)
  ]
)

regions = RatatuiRuby.draw(layout)
# => { sidebar: #<Rect x=0 y=0 width=24 height=24>,
#      main: #<Rect x=24 y=0 width=56 height=24> }

if regions[:sidebar]&.contains?(click_x, click_y)
  handle_sidebar_click
end
```

### Advanced: Any Ruby Object as ID

Since `id` accepts any Ruby object, you can use compound keys for structured hit testing:

```ruby
# Arrays as compound keys
Table.new(
  rows: users.map.with_index { |user, i|
    Row.new(cells: [user.name, user.email], id: [:user_row, i])
  },
  id: :users_table
)

regions = RatatuiRuby.draw(layout)

# Pattern matching for hit detection
regions.each do |id, rect|
  case id
  in [:user_row, index] if rect.contains?(x, y)
    select_user(index)
  in :users_table if rect.contains?(x, y)
    # Clicked table but not on a specific row (header/borders)
  else
    # Other regions
  end
end
```

### Advanced: Custom ID Objects

For complex apps, define custom ID classes with semantic equality:

```ruby
class TableRowId
  attr_reader :table, :index
  def initialize(table, index) = (@table, @index = table, index)
  def ==(other) = other.is_a?(TableRowId) && table == other.table && index == other.index
  alias eql? ==
  def hash = [table, index].hash
end

# Usage
Table.new(
  id: :users,
  rows: users.map.with_index { |u, i|
    Row.new(cells: [...], id: TableRowId.new(:users, i))
  }
)

# Hit testing
clicked = regions.find { |id, rect| rect.contains?(x, y) }&.first
case clicked
when TableRowId then select_row(clicked.table, clicked.index)
when :users then show_table_menu
end
```

### Sub-Widget Targeting: Tables and Lists

Native Rust Ratatui doesn't provide built-in APIs for "which row was clicked"—developers must calculate row/cell indices from coordinates, row heights, scroll offsets, etc.

RatatuiRuby can do better by allowing `id` on **row-level elements**:

#### Table Rows

```ruby
# Tag each row with its index (or the data object itself)
Table.new(
  id: :inventory,
  header: ["Item", "Qty", "Price"],
  rows: items.map.with_index { |item, i|
    # Use the item object as the ID for natural lookups
    [item.name, item.qty.to_s, "$#{item.price}"]
  },
  row_ids: items  # NEW: Array of IDs, one per row
)

# Or for explicit control:
Table.new(
  id: :inventory,
  rows: items.map { |item|
    Row.new(cells: [...], id: item)  # Row object with ID
  }
)
```

#### List Items

```ruby
List.new(
  id: :file_list,
  items: files.map { |f| ListItem.new(content: f.name, id: f) }
)

# Hit testing
clicked_file = regions.find { |id, rect| 
  id.is_a?(File) && rect.contains?(x, y) 
}&.first
```

### API Summary

```ruby
# All major widgets gain id: parameter
Layout.new(..., id: nil)
Block.new(..., id: nil)
Paragraph.new(..., id: nil)
List.new(..., id: nil)
Table.new(..., id: nil)
# ... etc

# draw() returns Hash<Object, Rect>
regions = RatatuiRuby.draw(widget)  # => { id1 => Rect, id2 => Rect, ... }

# Empty hash if no widgets have id
regions = RatatuiRuby.draw(widget_without_ids)  # => {}
```

## Alignment with Native Ratatui

This proposal addresses a **Ruby-specific problem** caused by RatatuiRuby's declarative API.

### Why Rust Apps Don't Need This

In native Rust Ratatui, developers have direct access to layout results:

```rust
let chunks = Layout::default()
    .constraints([Length(20), Fill(1)])
    .split(frame.area());

let sidebar_rect = chunks[0];  // Direct access
let main_rect = chunks[1];     // Direct access

frame.render_widget(sidebar, sidebar_rect);  // Same rect used
frame.render_widget(main, main_rect);
```

Rust developers **use the same `Rect` for both layout and hit testing** because they have explicit control.

### Why Ruby Needs This

In RatatuiRuby, the declarative tree hides the computed `Rect`s:

```ruby
# Ruby builds a tree, Rust computes layout internally
layout = Layout.new(children: [sidebar, main])
RatatuiRuby.draw(layout)  # Rects computed inside Rust, never exposed
```

The `id` feature **bridges this abstraction gap** by exporting the computed regions back to Ruby.

### Sub-Widget Targeting: RatatuiRuby Enhancement

Native Ratatui **does not** provide APIs to get clicked row/cell indices. Developers must manually calculate from coordinates, row heights, and scroll offsets.

RatatuiRuby's `id` on row-level elements is an **enhancement** that provides better DX than native Rust—leveraging Ruby's dynamic capabilities.

## Implementation Sketch

### Ruby Side

Add `id: nil` to all widget `Data.define` and `initialize` methods:

```ruby
class Block < Data.define(:title, :borders, ..., :id)
  def initialize(title: nil, borders: [:all], ..., id: nil)
    super
  end
end
```

### Rust Side

```rust
pub fn render_node(
  frame: &mut Frame,
  area: Rect,
  node: Value,
  regions: &mut Vec<(Value, Rect)>,  // Collect (id, rect) pairs
) -> Result<(), Error> {
  // Check for id attribute
  let id: Value = node.funcall("id", ())?;
  if !id.is_nil() {
    regions.push((id, area));
  }
  
  // ... render the widget ...
  // ... recurse into children, passing regions ...
}

pub fn draw(node: Value) -> Result<Value, Error> {
  let mut regions = Vec::new();
  render_node(&mut frame, full_area, node, &mut regions)?;
  
  // Convert to Ruby Hash
  let hash = RHash::new();
  for (id, rect) in regions {
    let ruby_rect = create_ruby_rect(rect);
    hash.aset(id, ruby_rect)?;
  }
  
  Ok(hash.into())
}
```

## Example: Complete Refactor

### Before

```ruby
class App
  def run
    RatatuiRuby.run do
      loop do
        calculate_layout
        render
        break if handle_input == :quit
      end
    end
  end

  def calculate_layout
    full = RatatuiRuby::Rect.new(x: 0, y: 0, width: 80, height: 24)
    @sidebar, @main = RatatuiRuby::Layout.split(full, ...)
  end

  def render
    RatatuiRuby.draw(
      RatatuiRuby::Layout.new(children: [sidebar_widget, main_widget])
    )
  end

  def handle_input
    event = RatatuiRuby.poll_event
    if @sidebar&.contains?(event.x, event.y)
      toggle_sidebar
    end
  end
end
```

### After

```ruby
class App
  def run
    RatatuiRuby.run do
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  def render
    @regions = RatatuiRuby.draw(
      RatatuiRuby::Layout.new(
        children: [
          sidebar_widget.with(id: :sidebar),
          main_widget.with(id: :main)
        ]
      )
    )
  end

  def handle_input
    event = RatatuiRuby.poll_event
    if @regions[:sidebar]&.contains?(event.x, event.y)
      toggle_sidebar
    end
  end
end
```

**Lines of code reduced by ~30%**, single source of truth for layout.

## Implementation Phases

1. **Phase A**: Add `id` to container widgets (Layout, Block, Center, Overlay). Return widget Rects.
2. **Phase B**: Add `id` to all widgets (Paragraph, List, Table, etc.).
3. **Phase C**: Add `id` support to sub-widget elements (Table rows, List items).

## Recommendation

**Approve**. This proposal:

1. Eliminates layout duplication pain point.
2. Aligns with immediate-mode and data-driven design.
3. Enhances DX beyond native Ratatui (sub-widget targeting).
4. Uses idiomatic Ruby (any object as Hash key).
5. Is backward compatible.
