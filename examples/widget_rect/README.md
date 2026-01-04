<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Rect (Geometry) Widget Example

[![widget_rect](../../doc/images/widget_rect.png)](app.rb)

Demonstrates the Rect geometry primitive and hit-testing patterns.

TUI layouts are composed of rectangles. Understanding how to manipulate `Rect` objects, reuse them from the layout phase, and use them for mouse interaction is critical for building interactive apps.

## Features Demonstrated

- **Rect Attributes**: Investigating x, y, width, and height.
- **Cached Layout Pattern**: Computing constraints in the render loop and reusing the resulting `Rect`s in the event loop for logic.
- **Hit Testing**: Using `Rect#contains?(x, y)` to determine if a mouse click happened inside a specific panel.

## Hotkeys

- **Arrows (←/→)**: Expand/Shrink Sidebar Width (Layout Constraint)
- **Arrows (↑/↓)**: Navigate Menu Selection (`selected_index`)
- **Mouse Click**: Click anywhere to see which Rect detects the hit (`contains?`)
- **q**: Quit

## Usage

```bash
ruby examples/widget_rect/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Handle mouse clicks on specific buttons or areas.
- Create resizable panes (like a split pane in an IDE).
- Debug layout issues by inspecting Rect coordinates.