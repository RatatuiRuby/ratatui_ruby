<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Interactive TUI Design Patterns

Canonical patterns for building responsive, interactive terminal user interfaces with ratatui_ruby.

## The Cached Layout Pattern

**Context:** In immediate-mode TUI development, you render once per event loop. The render happens, the user clicks, you respond. This cycle repeats 60 times a second.

**Problem:** Your layout has constraints. When you render, you calculate where each widget goes. When the user clicks, you need to know which widget was under the cursor. Two separate calculations means two separate constraint definitions. Change the layout once and forget to update the hit test logic—bugs happen.

**Solution:** Calculate layout once. Cache the results. Reuse them everywhere.

### The Three-Phase Lifecycle

Structure your event loop into three clear phases:

```ruby
def run
  RatatuiRuby.run do
    loop do
      calculate_layout   # Phase 1: Geometry (once per frame)
      render             # Phase 2: Draw
      break if handle_input == :quit  # Phase 3: Input
    end
  end
end
```

**Phase 1: Layout Calculation**

Call this before rendering and event handling. It's the single source of truth for geometry:

```ruby
def calculate_layout
  full_area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 80, height: 24)

  # Main area vs sidebar (70% / 30%)
  main_area, @sidebar_area = RatatuiRuby::Layout.split(
    full_area,
    direction: :horizontal,
    constraints: [
      RatatuiRuby::Constraint.percentage(70),
      RatatuiRuby::Constraint.percentage(30),
    ]
  )

  # Within main area, left vs right panels
  @left_rect, @right_rect = RatatuiRuby::Layout.split(
    main_area,
    direction: :horizontal,
    constraints: [
      RatatuiRuby::Constraint.percentage(@left_ratio),
      RatatuiRuby::Constraint.percentage(100 - @left_ratio)
    ]
  )
end
```

**Phase 2: Rendering**

Reuse the cached rects. Build and draw:

```ruby
def render
  left_panel = build_widget(@left_rect)
  right_panel = build_widget(@right_rect)
  # ... draw ...
end
```

**Phase 3: Event Handling**

Reuse the cached rects. Test clicks:

```ruby
def handle_input
  event = RatatuiRuby.poll_event
  return unless event

  case event
  in type: :mouse, kind: "down", x:, y:
    if @left_rect.contains?(x, y)
      handle_left_click
    elsif @right_rect.contains?(x, y)
      handle_right_click
    end
  else
    nil
  end
end
```

### Why This Matters

- **Single source of truth:** Change constraints once. They apply everywhere.
- **No duplication:** Write `Layout.split(area, constraints:)` once. Use the result in render and input.
- **Testable:** Layout geometry is explicit. You can verify it.
- **Foundation for components:** In Gem 1.5, the `Component` class automates this caching. This pattern teaches the mental model.

## Layout.split

`Layout.split` computes layout geometry without rendering. It returns an array of `Rect` objects.

```ruby
rects = Layout.split(
  area,
  direction: :horizontal,
  constraints: [Constraint.percentage(70), Constraint.percentage(30)]
)

left, right = rects
# left is a Rect describing the left 70% of the area
# right is a Rect describing the right 30% of the area
```

Use it to establish the single source of truth in `calculate_layout`. Reuse the results in both render and event handling.
