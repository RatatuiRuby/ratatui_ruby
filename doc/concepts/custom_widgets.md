<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Custom Widgets

Build anything. Escape the widget library.

## What Terminals Offer

Terminals do not have pixels. They have character cells arranged in a grid. Each cell holds one character with foreground color, background color, and text modifiers (bold, italic, underline).

This constraint shapes what you can draw:

- **Characters**: Any Unicode character fits in a cell
- **Box-drawing**: Lines, corners, and boxes (`│`, `┌`, `─`, `└`)
- **Block elements**: Partial fills (`▀`, `▄`, `█`, `░`, `▒`, `▓`)
- **Braille patterns**: 2×4 "pixel" grids per cell for pseudo-graphics
- **Nerd Fonts**: Icons and glyphs if the user's font supports them

The built-in Canvas widget uses Braille patterns for line graphs and shapes. Custom widgets give you direct control over every cell.

## The Problem

Standard widgets handle common needs. Paragraphs display text. Lists show selections. Tables organize data.

But terminals can do more. You want a game board, a network graph, or a custom visualization. The built-in widgets cannot help you here.

## The Solution

Any Ruby object that implements `render(area)` works as a widget. You are not limited to what the library ships. Define a class. Implement one method. Pass it to `frame.render_widget`.

The Engine calls your `render` method with the area where your widget should draw. You return an array of Draw commands. The Engine executes them.

## The Contract

Your custom widget implements [the `_CustomWidget` interface](../../sig/ratatui_ruby/frame.rbs). The `area` parameter is a `Rect` with `x`, `y`, `width`, and `height`. It tells you where to draw and how much space you have.

## Draw Commands

Two commands describe what to draw:

| Command | Purpose |
|---------|---------|
| `Draw.string(x, y, text, style)` | Draw a styled string at absolute coordinates |
| `Draw.cell(x, y, cell)` | Draw a single cell (character + style) |

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
class HelloWidget
  def render(area)
    [
      RatatuiRuby::Draw.string(
        area.x,
        area.y,
        "Hello, World!",
        RatatuiRuby::Style::Style.new(fg: :green, modifiers: [:bold])
      )
    ]
  end
end
```
<!-- SPDX-SnippetEnd -->

## Coordinate Offsets

The `area.x` and `area.y` values are not always zero. When your widget renders inside a `Block` with borders, or within a nested layout, the area's origin shifts.

Always add `area.x` and `area.y` to your drawing coordinates. This pattern ensures your widget works regardless of where it appears on screen.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
class DiagonalWidget
  def render(area)
    (0...area.height).filter_map do |i|
      next if i >= area.width  # Stay within bounds

      RatatuiRuby::Draw.string(
        area.x + i,  # Offset from area origin
        area.y + i,
        "\\",
        RatatuiRuby::Style::Style.new(fg: :red)
      )
    end
  end
end
```
<!-- SPDX-SnippetEnd -->

## Composability

Custom widgets compose with standard widgets. Wrap them in Blocks. Place them in layouts. Mix them with Paragraphs and Lists.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
RatatuiRuby.run do |tui|
  tui.draw do |frame|
    areas = tui.layout_split(
      frame.area,
      direction: :horizontal,
      constraints: [tui.constraint_percentage(50), tui.constraint_percentage(50)]
    )

    # Standard widget on the left
    frame.render_widget(tui.paragraph(text: "Standard"), areas[0])

    # Custom widget on the right
    frame.render_widget(DiagonalWidget.new, areas[1])
  end
end
```
<!-- SPDX-SnippetEnd -->

To render inside a bordered Block, calculate the inner area first:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
tui.draw do |frame|
  # Render the block frame
  block = tui.block(title: "Custom", borders: [:all])
  frame.render_widget(block, frame.area)

  # Calculate inner area (1-cell border on all sides)
  inner = tui.rect(
    x: frame.area.x + 1,
    y: frame.area.y + 1,
    width: [frame.area.width - 2, 0].max,
    height: [frame.area.height - 2, 0].max
  )

  # Render custom widget inside
  frame.render_widget(MyWidget.new, inner)
end
```
<!-- SPDX-SnippetEnd -->

## Using Custom Widgets in Layouts

Custom widgets work as children in Layout trees. The layout system passes the calculated area to your `render` method.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
layout = RatatuiRuby::Layout::Layout.new(
  direction: :vertical,
  constraints: [
    RatatuiRuby::Layout::Constraint.length(1),
    RatatuiRuby::Layout::Constraint.fill(1),
  ],
  children: [
    RatatuiRuby::Widgets::Paragraph.new(text: "Header"),
    MyCustomWidget.new,  # Your widget here
  ]
)

RatatuiRuby.draw(layout)
```
<!-- SPDX-SnippetEnd -->

## Testing Custom Widgets

Custom widgets return arrays. Test them by calling `render` directly and asserting on the result.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
def test_hello_widget_output
  area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 20, height: 5)
  widget = HelloWidget.new
  commands = widget.render(area)

  assert_equal 1, commands.length
  assert_equal 0, commands[0].x
  assert_equal 0, commands[0].y
  assert_equal "Hello, World!", commands[0].string
end
```
<!-- SPDX-SnippetEnd -->

For visual testing, use the test helper to render to a buffer and assert on content:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
class TestMyWidget < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_renders_in_terminal
    with_test_terminal(10, 5) do
      RatatuiRuby.draw(MyWidget.new)
      assert_equal "Expected  ", buffer_content[0]
    end
  end
end
```
<!-- SPDX-SnippetEnd -->

## Typing Your Widgets (RBS)

Type your custom widgets by implementing the `_CustomWidget` interface:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```rbs
# my_widget.rbs
class MyWidget
  def render: (RatatuiRuby::Rect area) -> Array[RatatuiRuby::Draw::StringCmd | RatatuiRuby::Draw::CellCmd]
end
```
<!-- SPDX-SnippetEnd -->

The interface uses structural typing. Any class with a matching `render` signature satisfies it.

## Related Resources

- [Custom Render Example](../examples/widget_render/README.md) — Full working example
- [Cell Example](../examples/widget_cell/README.md) — Low-level cell drawing
- [Application Testing](./application_testing.md) — Test helper reference
