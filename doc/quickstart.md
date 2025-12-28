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
        borders: [:all],
        border_color: "cyan"
      )
    )
 
    # 3. Draw the UI
    RatatuiRuby.draw(view)
 
    # 4. Poll for events
    event = RatatuiRuby.poll_event
    if event && event[:type] == :key && event[:code] == "q"
      break
    end
  end
ensure
  # 5. Restore the terminal to its original state
  RatatuiRuby.restore_terminal
end
```

![Basic Application Screenshot](./images/examples-quickstart_lifecycle.rb.png)

### How it works

1.  **`RatatuiRuby.init_terminal`**: Enters raw mode and switches to the alternate screen.
2.  **Immediate Mode UI**: On every iteration of the loop, you describe what the UI should look like by creating `Data` objects (like `Paragraph` and `Block`).
3.  **`RatatuiRuby.draw(view)`**: The Ruby UI tree is passed to the Rust backend, which renders it to the terminal.
4.  **`RatatuiRuby.poll_event`**: Checks for keyboard, mouse, or resize events.
5.  **`RatatuiRuby.restore_terminal`**: Crucial for leaving raw mode and returning the user to their shell properly. Always wrap your loop in a `begin...ensure` block to guarantee this runs.

### DSL

A small DSL is provided for convenience when writing scripts.

```rb
require "ratatui_ruby"

# 1. Initialize the terminal, start the main loop, and ensure the terminal is restored.
RatatuiRuby.main_loop do |tui|
  # 2. Create your UI with methods instead of classes.
  view = tui.paragraph(
    text: "Hello, Ratatui! Press 'q' to quit.",
    align: :center,
    block: tui.block(
      title: "My Ruby TUI App",
      borders: [:all],
      border_color: "cyan"
    )
  )

  # 3. Use RatatuiRuby methods, too.
  tui.draw(view)
  event = tui.poll_event
  
  if event && event[:type] == :key && event[:code] == "q"
    break
  end
end
```

#### How it works

1.  **`RatatuiRuby.main_loop`**: This helper method manages the entire terminal lifecycle for you. It initializes the terminal before the block starts and ensures `restore_terminal` is called when the block exits (even if an error occurs).
2.  **Widget Shorthand**: The block yields a special DSL object (here named `tui`). This object provides factory methods for every widget, allowing you to write `tui.paragraph(...)` instead of the more verbose `RatatuiRuby::Paragraph.new(...)`.
3.  **Method SHorthand**: The DSL object also provides aliases for module functions of `RatatuiRuby`, allowing you to write `tui.draw(...)` instead of the more verbose `RatatuiRuby::draw(...)`.

## Examples

To see more complex layouts and widget usage, check out the `examples/` directory in the repository.

### [Analytics](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/analytics.rb)
Demonstrates the use of `Tabs` and `BarChart` widgets with a simple data-switching mechanism.

![Analytics Screenshot](./images/examples-analytics.rb.png)

### [Box Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/box_demo.rb)
A simple demonstration of `Block` and `Paragraph` widgets, reacting to arrow key presses to change colors.

![Box Demo Screenshot](./images/examples-box_demo.rb.png)

### [Calendar Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/calendar_demo.rb)
A simple demo application for the `Calendar` widget.

### [Chart Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/chart_demo.rb)
Demonstrates the `Chart` widget with both scatter and line datasets, including custom axes.

### [Dashboard](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/dashboard.rb)
Uses `Layout`, `List`, and `Paragraph` to create a classic sidebar-and-content interface.

![Dashboard Screenshot](./images/examples-dashboard.rb.png)

### [List Styles](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/list_styles.rb)
Showcases advanced styling options for the `List` widget, including selection highlighting.

### [Login Form](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/login_form.rb)
Shows how to use `Overlay`, `Center`, and `Cursor` to build a modal login form with text input.

![Login Form Screenshot](./images/examples-login_form.rb.png)

### [Map Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/map_demo.rb)
Exhibits the `Canvas` widget's power, rendering a world map along with animated circles and lines.

![Map Demo Screenshot](./images/examples-map_demo.rb.png)

### [Mouse Events](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/mouse_events.rb)
Detailed plumbing of mouse events, including clicks, drags, and movement tracking.

![Mouse Events Screenshot](./images/examples-mouse_events.rb.png)

### [Scrollbar Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/scrollbar_demo.rb)
A simple example of integrating the `Scrollbar` widget and handling mouse wheel events for scrolling.

![Scrollbar Demo Screenshot](./images/examples-scrollbar_demo.rb.png)

### [Scroll Text](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/scroll_text.rb)
Demonstrates the `Paragraph` widget's scroll functionality, allowing navigation through long text content using arrow keys for both horizontal and vertical scrolling.

![Scroll Text Screenshot](./images/examples-scroll_text.rb.png)

### [Stock Ticker](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/stock_ticker.rb)
Utilizes `Sparkline` and `Chart` widgets to visualize real-time (simulated) data.

![Stock Ticker Screenshot](./images/examples-stock_ticker.rb.png)

### [System Monitor](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/system_monitor.rb)
Combines `Table` and `Gauge` widgets in a vertical layout to create a functional system overview.

![System Monitor Screenshot](./images/examples-system_monitor.rb.png)

### [Table Select](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/table_select.rb)
Demonstrates interactive row selection in the `Table` widget with keyboard navigation, highlighting selected rows with custom styles and symbols.

![Table Select Screenshot](./images/examples-table_select.rb.png)

