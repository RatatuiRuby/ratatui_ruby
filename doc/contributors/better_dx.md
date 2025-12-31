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
2. **Fragility**: If layout changes in `render`, the cached rects in `@left_rect` become stale. The user must remember to update both places.
3. **Maintainability**: Adding new UI regions requires changes in two places and explicit rect caching.
4. **Performance**: Layout is calculated twice per frame (once manually, once internally during render).

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
    constraints: [
      RatatuiRuby::Constraint.fill(1),
      RatatuiRuby::Constraint.length(7)
    ],
    children: [...]
  )
  
  @layout_info = RatatuiRuby.draw(layout)  # Returns layout metadata
end

def handle_input
  event = RatatuiRuby.poll_event
  # Query the layout info returned from draw()
  if @layout_info[:left_panel]&.contains?(event.x, event.y)
    # No manual caching needed; rects come from the same render pass
  end
end
```

## Proposed Solution

Extend `RatatuiRuby.draw()` to return a `LayoutInfo` object containing the rectangles where widgets were rendered.

### API Changes

#### Option A: Return a Plain Hash (Simpler)

```ruby
# Layout.rb with optional layout_id parameter
class Layout < Data
  def self.new(
    direction: :vertical,
    constraints: [],
    children: [],
    flex: :legacy,
    layout_id: nil  # NEW: Optional semantic identifier
  )
    # ...
  end
end

# Block.rb with optional layout_id parameter
class Block < Data
  def self.new(
    title: nil,
    borders: [],
    border_type: :rounded,
    style: nil,
    layout_id: nil  # NEW: Optional semantic identifier
  )
    # ...
  end
end

# Usage in app:
layout = RatatuiRuby::Layout.new(
  direction: :vertical,
  constraints: [...],
  layout_id: :main,  # Tag this layout
  children: [
    RatatuiRuby::Block.new(
      title: "Left",
      layout_id: :left_panel,  # Tag this block
      ...
    ),
    RatatuiRuby::Block.new(
      title: "Right",
      layout_id: :right_panel,
      ...
    )
  ]
)

layout_info = RatatuiRuby.draw(layout)

# layout_info is a Hash:
# {
#   left_panel: #<Rect x=0 y=0 width=40 height=24>,
#   right_panel: #<Rect x=40 y=0 width=40 height=24>,
#   main: #<Rect x=0 y=0 width=80 height=24>
# }

if layout_info[:left_panel]&.contains?(event.x, event.y)
  handle_left_click
end
```

#### Option B: Return a LayoutInfo Class (More Structured)

```ruby
class LayoutInfo
  attr_reader :rects  # Hash of layout_id => Rect
  
  def [](key)
    rects[key]
  end
  
  def get(key)
    rects[key]
  end
  
  def contains?(key, x, y)
    rects[key]&.contains?(x, y)
  end
end

# Usage:
layout_info = RatatuiRuby.draw(layout)
if layout_info.contains?(:left_panel, event.x, event.y)
  handle_left_click
end
```

**Recommendation:** Start with Option A (Plain Hash). It's simpler, aligns with RatatuiRuby's minimal design, and can evolve to Option B if needed.

### Implementation Sketch

#### Ruby Side

1. **Add `layout_id` parameter** to `Layout` and `Block` (and optionally other container widgets like `Center`, `Overlay`).
2. **Update `.rbs` type signatures** to document the new optional parameter.
3. **Update `RatatuiRuby.draw()` signature** to return `Hash[Symbol | String, Rect] | nil` (or return both render status and layout info as needed).

```ruby
# sig/ratatui_ruby/ratatui_ruby.rbs
def self.draw: (widget, ?return_layout: bool) -> (nil | Hash[Symbol | String, Rect])
```

#### Rust Side

1. **Track layout IDs during render:** When the Rust renderer encounters a widget with a `layout_id`, record its rendered rectangle.
2. **Return layout info as a Ruby Hash:** Construct a Ruby Hash mapping `layout_id` (String or Symbol) to `Rect` objects.
3. **Wire into `lib.rs`:** Modify the `draw` function to return this Hash instead of `nil`.

**Pseudo-code for `rendering.rs`:**

```rust
pub fn render_node(
  frame: &mut Frame,
  area: Rect,
  node: Value,
  layout_map: &mut HashMap<Value, Rect>,  // Collect rects as we go
) -> Result<(), Error> {
  // Extract layout_id if present
  let layout_id: Option<Value> = node.funcall("layout_id", ()).ok();
  
  if let Some(id) = layout_id {
    layout_map.insert(id.clone(), area);
  }
  
  // ... render the widget ...
}

// In lib.rs, wrap the result:
pub fn draw(node: Value) -> Result<Value, Error> {
  let mut layout_map = HashMap::new();
  render_node(&mut frame, full_area, node, &mut layout_map)?;
  
  // Convert HashMap to Ruby Hash
  let result_hash = RHash::new();
  for (key, rect) in layout_map {
    result_hash.aset(key, rect)?;
  }
  
  Ok(result_hash.into())
}
```

### Backward Compatibility

**No breaking changes:**
- `layout_id` is optional on all widgets.
- `RatatuiRuby.draw()` continues to render correctly.
- **Behavior**: If `layout_id` is omitted, that region is simply not included in the returned Hash.
- **Return value**: If no widgets have `layout_id`, returns an empty Hash (or `nil` if we want to preserve existing return type).

**Recommendation**: Return `nil` if `layout_id` is not used anywhere in the tree (preserves current behavior of returning nothing). Return a Hash if any widget has a `layout_id`.

## Example: Before and After

### Before (Current)

```ruby
class ColorPickerApp
  def initialize
    @input = "#F96302"
    @current_color = parse_color(@input)
    @error_message = ""
  end

  def run
    RatatuiRuby.run do
      loop do
        calculate_layout  # Manual layout calculation
        render
        result = handle_input
        break if result == :quit
      end
    end
  end

  def calculate_layout
    terminal_size = RatatuiRuby.terminal_size
    width, height = terminal_size

    full_area = RatatuiRuby::Rect.new(x: 0, y: 0, width: width, height: height)
    
    input_area, rest = RatatuiRuby::Layout.split(full_area, 
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.length(3),
        RatatuiRuby::Constraint.fill(1)
      ]
    )
    
    color_area, control_area = RatatuiRuby::Layout.split(rest,
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.length(14),
        RatatuiRuby::Constraint.fill(1)
      ]
    )
    
    harmony_area, @export_area_rect = RatatuiRuby::Layout.split(color_area,
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.length(7),
        RatatuiRuby::Constraint.fill(1)
      ]
    )
  end

  def render
    main_ui = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.length(3),
        RatatuiRuby::Constraint.length(14),
        RatatuiRuby::Constraint.fill(1)
      ],
      children: [
        build_input_section,
        build_color_section,
        build_controls_section
      ]
    )
    RatatuiRuby.draw(main_ui)
  end

  def handle_input
    event = RatatuiRuby.poll_event
    case event
    in {type: :mouse, kind: "down", button: "left", x:, y:}
      if @export_area_rect&.contains?(x, y)  # Using cached rect
        @copy_dialog_text = @current_color.to_hex.upcase
        @copy_dialog_active = true
      end
    # ...
    end
  end
end
```

**Problems:**
- `calculate_layout` duplicates the exact same layout structure as `render`.
- Changes to layout in `render` require manual updates to `calculate_layout`.
- Fragile: rect caching is manual and easy to forget.

### After (With `layout_id`)

```ruby
class ColorPickerApp
  def initialize
    @input = "#F96302"
    @current_color = parse_color(@input)
    @error_message = ""
    @layout_info = {}  # Will be populated by draw()
  end

  def run
    RatatuiRuby.run do
      loop do
        render
        result = handle_input
        break if result == :quit
      end
    end
  end

  def render
    main_ui = RatatuiRuby::Layout.new(
      direction: :vertical,
      layout_id: :main,  # Tag the main layout
      constraints: [
        RatatuiRuby::Constraint.length(3),
        RatatuiRuby::Constraint.length(14),
        RatatuiRuby::Constraint.fill(1)
      ],
      children: [
        build_input_section,
        build_color_section(layout_id: :color_section),  # Tag child layouts
        build_controls_section
      ]
    )
    @layout_info = RatatuiRuby.draw(main_ui) || {}  # Capture layout info
  end

  def build_color_section(layout_id: nil)
    RatatuiRuby::Layout.new(
      direction: :vertical,
      layout_id: layout_id,
      constraints: [
        RatatuiRuby::Constraint.length(7),
        RatatuiRuby::Constraint.fill(1)
      ],
      children: [
        build_harmonies,
        RatatuiRuby::Block.new(
          title: "Export Formats",
          layout_id: :export_formats,  # Tag the export block
          borders: [:all],
          children: [
            build_export_content
          ]
        )
      ]
    )
  end

  def handle_input
    event = RatatuiRuby.poll_event
    case event
    in {type: :mouse, kind: "down", button: "left", x:, y:}
      if @layout_info[:export_formats]&.contains?(x, y)  # No manual caching!
        @copy_dialog_text = @current_color.to_hex.upcase
        @copy_dialog_active = true
      end
    # ...
    end
  end
end
```

**Benefits:**
- **Single source of truth**: Layout is defined once in `render`, not duplicated in `calculate_layout`.
- **Automatic tracking**: As you modify the UI tree, rects are automatically updated by the same render pass.
- **No manual caching**: Use `@layout_info` directly from `draw()`.
- **Declarative**: Tag regions with semantic IDs, making hit testing code self-documenting.

## Design Alignment

### Immediate-Mode Rendering

This proposal **preserves** immediate-mode principles:

- **Every frame**, the app constructs a fresh UI tree from current state.
- **Every frame**, `draw()` consumes that tree and renders it.
- **Returns**: Layout metadata computed during the same render pass.

The key insight: Returning layout info is **not** retained state; it's a **by-product** of the render, computed fresh each frame.

### Data-Driven UI

Widgets remain immutable data objects; adding `layout_id` is just an optional annotation:

```ruby
# Still pure data:
widget = RatatuiRuby::Block.new(
  title: "Foo",
  layout_id: :my_widget,  # Just metadata, not behavior
  borders: [:all]
)
```

No rendering logic moves to Ruby.

### Rust Backend Alignment

In Rust Ratatui, the `Frame` tracks where widgets are rendered:

```rust
let mut frame = Terminal::new(backend)?;
frame.render_widget(widget, area);  // Frame knows where this widget is now
```

Returning layout info from `draw()` mirrors this: the Rust backend knows where things ended up, and returns that information to Ruby.

## Alternatives Considered

### Alternative 1: Widgets Maintain Their Own State

Store rects on mutable widget objects. **Rejected** because:
- Violates immediate-mode and data-driven design.
- Requires mutable state tracking in Rust.
- Complicates the simplicity of immutable data objects.

### Alternative 2: Full Frame Object

Return a `Frame` object (similar to Ratatui's Frame) that tracks all rendering details. **Rejected** because:
- Over-engineered for the current need.
- RatatuiRuby is intentionally minimal.
- Overkill if the app only cares about hit testing a few regions.

### Alternative 3: Callback-Based Rendering

Allow widgets to register callbacks when rendered. **Rejected** because:
- Adds complexity and statefulness.
- Less idiomatic for Ruby.
- Harder to reason about in immediate-mode loop.

### Alternative 4: Hit Testing DSL

Provide a declarative hit testing layer separate from rendering. **Rejected** because:
- Duplicates layout info (still two sources of truth).
- Unnecessary indirection.

## Impact Assessment

### User-Facing Changes

- **New optional parameter**: `layout_id` on `Layout`, `Block`, and similar container widgets.
- **New return value**: `RatatuiRuby.draw()` optionally returns a Hash of rects.
- **Zero breaking changes**: Existing apps without `layout_id` work unchanged.

### Documentation Updates

- **Update RDoc** for `Layout` and `Block` to document `layout_id`.
- **Add example**: `examples/hit_test/app.rb` (or new example) showing the pattern.
- **Update `doc/interactive_design.md`** with the new approach.

### Testing

- **Unit tests (Rust)**: Verify that rects are collected and returned correctly.
- **Integration tests (Ruby)**: Verify hit testing works with returned layout info.
- **Example app**: Ensure the color picker and hit test examples demonstrate the pattern.

## Timeline & Scope

**Scope**: Pre-1.0 feature. Fits RatatuiRuby's design philosophy and solves a real pain point.

**Estimated effort**:
- Rust backend: 4–6 hours (add `layout_id` extraction, rect collection, Hash construction)
- Ruby side: 2–3 hours (add parameter to widget classes, update `.rbs`, docs)
- Testing & examples: 2–3 hours
- **Total**: ~10 hours

**Risk**: Low. The change is additive (optional parameter, new return value). Backward compatible.

## Recommendation

**Approve**. This proposal:

1. Eliminates a real pain point (layout duplication).
2. Aligns with immediate-mode and data-driven design.
3. Mirrors how Rust Ratatui works (Frame tracks layout).
4. Requires no breaking changes.
5. Is low-risk and achievable pre-1.0.

Implement as **Option A (Plain Hash)** first. It's simpler and sufficient for hit testing. Evolve to `LayoutInfo` class if more complex queries are needed later.
