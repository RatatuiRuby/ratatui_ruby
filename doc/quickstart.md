<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->
# Quickstart

Welcome to **ratatui_ruby**! This guide will help you get up and running with your first Terminal User Interface in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "ratatui_ruby"
```


And then execute:

```bash
bundle install
```


Or install it yourself as:

```bash
gem install ratatui_ruby
```


## Basic Application

Here is a "Hello World" application that demonstrates the core lifecycle of a **ratatui_ruby** app.

```ruby
require "ratatui_ruby"
 
# 1. Initialize the terminal
RatatuiRuby.init_terminal
 
begin
  # The Main Loop
  loop do
    # 2. Create your UI (Immediate Mode)
    # We define a Paragraph widget inside a Block with a title and borders.
    view = RatatuiRuby::Paragraph.new(
      text: "Hello, Ratatui! Press 'q' to quit.",
      align: :center,
      block: RatatuiRuby::Block.new(
        title: "My Ruby TUI App",
        title_alignment: :center,
        borders: [:all],
        border_color: "cyan",
        style: { fg: "white" }
      )
    )
 
    # 3. Draw the UI
    RatatuiRuby.draw(view)
 
    # 4. Poll for events
    event = RatatuiRuby.poll_event
    break if event == "q" || event == :ctrl_c
  end
ensure
  # 5. Restore the terminal to its original state
  RatatuiRuby.restore_terminal
end
```

![quickstart_lifecycle](./images/quickstart_lifecycle.png)

### How it works

1.  **`RatatuiRuby.init_terminal`**: Enters raw mode and switches to the alternate screen.
2.  **Immediate Mode UI**: On every iteration of the loop, you describe what the UI should look like by creating `Data` objects (like `Paragraph` and `Block`).
3.  **`RatatuiRuby.draw(view)`**: The Ruby UI tree is passed to the Rust backend, which renders it to the terminal.
4.  **`RatatuiRuby.poll_event`**: Checks for keyboard, mouse, or resize events.
5.  **`RatatuiRuby.restore_terminal`**: Crucial for leaving raw mode and returning the user to their shell properly. Always wrap your loop in a `begin...ensure` block to guarantee this runs.

### Idiomatic Session

You can simplify your code by using `RatatuiRuby.run`. This method handles the terminal lifecycle for you, yielding a `Session` object with factory methods for widgets.

```rb
require "ratatui_ruby"

# 1. Initialize the terminal and ensure it is restored.
RatatuiRuby.run do |tui|
  loop do
    # 2. Create your UI with methods instead of classes.
    view = tui.paragraph(
      text: "Hello, Ratatui! Press 'q' to quit.",
      align: :center,
      block: tui.block(
        title: "My Ruby TUI App",
        title_alignment: :center,
        borders: [:all],
        border_color: "cyan",
        style: { fg: "white" }
      )
    )

    # 3. Use RatatuiRuby methods, too.
    tui.draw(view)
    event = tui.poll_event
    
    break if event == "q" || event == :ctrl_c
  end
end


#### How it works

1.  **`RatatuiRuby.run`**: This context manager initializes the terminal before the block starts and ensures `restore_terminal` is called when the block exits (even if an error occurs).
2.  **Widget Shorthand**: The block yields a `Session` object (here named `tui`). This object provides factory methods for every widget, allowing you to write `tui.paragraph(...)` instead of the more verbose `RatatuiRuby::Paragraph.new(...)`.
3.  **Method Shorthand**: The session object also provides aliases for module functions of `RatatuiRuby`, allowing you to write `tui.draw(...)` instead of the more verbose `RatatuiRuby::draw(...)`.

For a deeper dive into the available application architectures (Manual vs Managed), see [Application Architecture](./application_architecture.md).

## Examples

To see more complex layouts and widget usage, check out the `examples/` directory in the repository.

### [Analytics](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/analytics/app.rb)

Demonstrates the use of `Tabs` and `BarChart` widgets with a simple data-switching mechanism. Features custom highlight styles, base styles, and dividers for the tabs, as well as toggling the `BarChart::direction` between vertical and horizontal, customizing `BarChart::label_style` (x) and `BarChart::value_style` (z), cycling through custom `BarChart::bar_set` (b), and toggling the view mode between Full and Mini height (m).

![analytics](./images/analytics.png)

### [All Events](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/all_events/app.rb)

A comprehensive demonstration of every event type supported by **ratatui_ruby**: Key, Mouse, Resize, Paste, and Focus events.

![all_events](./images/all_events.png)

### [Block Padding](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/block_padding/app.rb)

Demonstrates the `padding` property of the `Block` widget, supporting both uniform and directional padding.

![block_padding](./images/block_padding.png)

### [Block Titles](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/block_titles/app.rb)

Demonstrates the `Block` widget's ability to render multiple titles with individual alignment and positioning (top/bottom).

![block_titles](./images/block_titles.png)

### [Box Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/box_demo/app.rb)

A simple demonstration of `Block` and `Paragraph` widgets, reacting to key presses to change colors, border types, border styles, and title styling. Features the new `border_style` parameter for applying colors and modifiers (bold, italic) to borders independently of the content background.

![box_demo](./images/box_demo.png)

### [Calendar Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/calendar_demo/app.rb)

Demonstrates the `Calendar` widget with interactive attribute cycling. Features event highlighting (dates with specific styles), toggleable month/weekday headers, and surrounding month visibility (with custom styling) via keyboard shortcuts. Press `h` to toggle month header, `w` to toggle weekday header, `s` to toggle surrounding month dates, and `e` to toggle events.

![calendar_demo](./images/calendar_demo.png)

### [Chart Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/chart_demo/app.rb)

Demonstrates the `Chart` widget with both scatter and line datasets, including custom axes. Features customizable axis label alignment and legend positioning.

![chart_demo](./images/chart_demo.png)

### [Custom Widget (Escape Hatch)](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/custom_widget/app.rb)

Demonstrates how to define a custom widget in pure Ruby using the `render(area, buffer)` escape hatch for low-level drawing.

![custom_widget](./images/custom_widget.png)

### [Flex Layout](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/flex_layout/app.rb)

Demonstrates modern layout features including `Constraint.fill` and `Constraint.ratio` for proportional space distribution and `flex: :space_between` for evenly distributing fixed-size elements.

![flex_layout](./images/flex_layout.png)

### [LineGauge Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/line_gauge_demo/app.rb)

Demonstrates the `LineGauge` widget with customizable filled and unfilled symbols, base style support via the `style` parameter, independent styling for filled/unfilled portions, and interactive ratio cycling with arrow keys.

![line_gauge_demo](./images/line_gauge_demo.png)

### [List Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/list_demo/app.rb)

Demonstrates the `List` widget with interactive attribute cycling. Features multiple item sets to browse, customizable highlight styles and symbols, and exploration of all List options including direction, highlight spacing, repeat symbol mode, scroll padding, and base styling. The sidebar provides hotkey documentation for discovering all List features, including the new `p` key to adjust scroll padding.

![list_demo](./images/list_demo.png)

### [Login Form](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/login_form/app.rb)

Shows how to use `Overlay`, `Center`, and `Cursor` to build a modal login form with text input.

![login_form](./images/login_form.png)

### [Map Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/map_demo/app.rb)

Exhibits the `Canvas` widget's power, rendering a world map along with animated circles and lines.

![map_demo](./images/map_demo.png)

### [Mouse Events](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/mouse_events/app.rb)

Detailed plumbing of mouse events, including clicks, drags, and movement tracking.

![mouse_events](./images/mouse_events.png)

### [Popup Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/popup_demo/app.rb)

Demonstrates the `Clear` widget and how to prevent "style bleed" when rendering opaque popups over colored backgrounds.

![popup_demo](./images/popup_demo.png)

### [Rich Text](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/rich_text/app.rb)

Demonstrates `Text::Span` and `Text::Line` for creating styled text with inline formatting, enabling word-level control over colors and text modifiers.

![rich_text](./images/rich_text.png)

### [Scrollbar Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/scrollbar_demo/app.rb)

A demonstration of the `Scrollbar` widget, featuring mouse wheel scrolling and extensive customization of symbols and styles.

![scrollbar_demo](./images/scrollbar_demo.png)

### [Scroll Text](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/scroll_text/app.rb)

Demonstrates the `Paragraph` widget's scroll functionality, allowing navigation through long text content using arrow keys for both horizontal and vertical scrolling.

![scroll_text](./images/scroll_text.png)

### [Sparkline Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/sparkline_demo/app.rb)

Demonstrates the `Sparkline` widget with interactive attribute cycling. Features multiple data sets with different patterns (steady growth, gaps, random, sawtooth, peaks), and explores all `Sparkline` options including direction, color, and the new `absent_value_symbol` and `absent_value_style` parameters for distinguishing zero/absent values from low data.

![sparkline_demo](./images/sparkline_demo.png)

### [Gauge Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/gauge_demo/app.rb)

Demonstrates the `Gauge` widget with interactive attribute cycling. Features multiple gauge instances with customizable ratio, gauge color, background style, Unicode toggle, and label modes. The sidebar provides hotkey documentation for exploring all Gauge options, including the distinction between `style` (background) and `gauge_style` (filled bar).

![gauge_demo](./images/gauge_demo.png)

### [Table Select](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/table_select/app.rb)

Demonstrates interactive row selection in the `Table` widget with keyboard navigation, highlighting selected rows with custom styles and symbols, applying a base style, and dynamically adjusting `column_spacing`. Also demonstrates `column_highlight_style` and the new `cell_highlight_style` for precise selection visualization.

![table_select](./images/table_select.png)

### [Table Flex](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/table_flex/app.rb)

Demonstrates different flex modes in the `Table` widget, such as `:space_between` and `:space_around`, allowing for modern, responsive table layouts.

![table_flex](./images/table_flex.png)

