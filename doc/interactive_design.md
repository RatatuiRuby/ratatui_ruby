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
  RatatuiRuby.run do |tui|
    @tui = tui
    loop do
      @tui.draw do |frame|
        calculate_layout(frame.area) # Phase 1: Geometry (once per frame)
        render(frame)                # Phase 2: Draw
      end
      break if handle_input == :quit  # Phase 3: Input
    end
  end
end
```

**Phase 1: Layout Calculation**

Call this inside your `draw` block. It uses the current terminal area provided by the frame:

```ruby
def calculate_layout(area)
  # Main area vs sidebar (70% / 30%)
  main_area, @sidebar_area = @tui.layout_split(
    area,
    direction: :horizontal,
    constraints: [
      @tui.constraint_percentage(70),
      @tui.constraint_percentage(30),
    ]
  )

  # Within main area, left vs right panels
  @left_rect, @right_rect = @tui.layout_split(
    main_area,
    direction: :horizontal,
    constraints: [
      @tui.constraint_percentage(@left_ratio),
      @tui.constraint_percentage(100 - @left_ratio)
    ]
  )
end
```

**Phase 2: Rendering**

Reuse the cached rects. Build and draw:

```ruby
def render(frame)
  frame.render_widget(build_widget(@left_rect), @left_rect)
  frame.render_widget(build_widget(@right_rect), @right_rect)
end
```

**Phase 3: Event Handling**

Reuse the cached rects. Test clicks:

```ruby
def handle_input
  event = RatatuiRuby.poll_event

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

`Layout.split` computes layout geometry without rendering. It returns an array of `Rect` objects. While you can call `RatatuiRuby::Layout.split` directly, we recommend using the `Session` helper (`tui.layout_split`) for cleaner application code.

```ruby
# Preferred (Session API)
left, right = tui.layout_split(area, constraints: [...])

# Manual (Core API)
left, right = RatatuiRuby::Layout.split(area, constraints: [...])
```

Use it to establish the single source of truth inside your `draw` block. Store the results in instance variables and reuse them in both `render` and `handle_input`.
