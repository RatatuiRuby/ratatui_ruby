<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Ruby Frontend Design (`ratatui_ruby`)

This document describes the design philosophy and structure of the Ruby layer in `ratatui_ruby`.

## Core Philosophy: Data-Driven UI



The Ruby frontend is designed as a **thin, declarative layer** over the Rust backend. It uses an **Immediate Mode** paradigm where the user constructs a tree of pure data objects every frame to represent the desired UI state.

### 1. Separation of Configuration and Status

`ratatui_ruby` strictly separates **what** a widget is (Configuration) from **where** it is (Status).

#### Configuration (Input)
Widgets (e.g., `RatatuiRuby::List`) are immutable value objects defining the *desired appearance* for the current frame. They are pure inputs to the renderer.

*   Implemented using Ruby 3.2+ `Data` classes.
*   Located in `lib/ratatui_ruby/schema/`.
*   Act as a Schema/IDL between Ruby and Rust.

**Example:**
```ruby
# This is just a piece of data, not a "live" widget
paragraph = RatatuiRuby::Widgets::Paragraph.new(
  text: "Hello World",
  style: RatatuiRuby::Style::Style.new(fg: :red),
  block: nil
)
```

#### Status (Output)
**Optional.** Only specific widgets (like `List` and `Table`) rely on runtime status. State objects (e.g., `RatatuiRuby::ListState`) track metrics calculated by the backend, such as scroll offsets.

*   passed as a *secondary argument* to `render_stateful_widget`.
*   **The Widget Configuration is still required.** You cannot render a State without its corresponding Widget.
*   Updated in-place by the Rust backend to reflect the actual rendered state.

**Example:**
```ruby
# 1. Initialize State once (Input/Output)
list_state = RatatuiRuby::ListState.new
list_state.select(3)

RatatuiRuby.run do |tui|
  loop do
    tui.draw do |frame|
      # 2. Define Configuration (Input)
      # (Note: In a real app, you'd probably use `tui.list(...)` helper)
      list = RatatuiRuby::Widgets::List.new(items: ["A", "B", "C", "D"])
      
      # 3. Render with both (Side Effect: updates list_state)
      frame.render_stateful_widget(list, frame.area, list_state)
    end
    
    # 4. Read back Status (Output)
    # If the backend auto-scrolled to keep index 3 visible:
    puts "Scroll Offset: #{list_state.offset}"
    
    break if tui.poll_event == "q"
  end
end
```

### 2. Immediate Mode Rendering

The application loop typically looks like this:

1.  **Poll Event**: Ruby asks Rust for the next event.
2.  **Update State**: Ruby application code updates its own domain state (e.g., `counter += 1`).
3.  **Render**: Ruby constructs a fresh View Tree based on the current domain state and passes the root node to `RatatuiRuby.draw`.

```ruby
loop do
  # 1. & 2. Handle events and update state
  event = RatatuiRuby.poll_event
  break if event == :esc

  # 3. Construct View Tree & Draw
  RatatuiRuby.draw do |frame|
    frame.render_widget(
      RatatuiRuby::Widgets::Paragraph.new(text: "Time: #{Time.now}"),
      frame.area
    )
  end
end
```

### 3. No render logic in Ruby

The Ruby classes in `lib/ratatui_ruby/schema/` should **not** contain rendering logic. They are strictly for structural definition and validation. All rendering logic resides in the Rust extension (`ext/ratatui_ruby/`), which walks this Ruby object tree and produces Ratatui primitives.

## Adding a New Widget

To add a new widget to the Ruby frontend:

1.  Define the class in `lib/ratatui_ruby/schema/`.
2.  Use `Data.define`.
3.  Ensure attribute names match what the Rust rendering logic expects (see `ext/ratatui_ruby/src/widgets/`).

```ruby
# lib/ratatui_ruby/schema/my_widget.rb
module RatatuiRuby
  # A widget that does something specific.
  #
  # [some_property] The description of the property.
  # [style] The style to apply.
  # [block] Optional block widget.
  class MyWidget < Data.define(:some_property, :style, :block)
    # Creates a new MyWidget.
    #
    # [some_property] The description of the property.
    # [style] The style to apply.
    # [block] Optional block widget.
    def initialize(some_property:, style: nil, block: nil)
      super
    end
  end
end
```

And define the types in the corresponding `.rbs` file:

```rbs
# sig/ratatui_ruby/schema/my_widget.rbs
module RatatuiRuby
  class MyWidget < Data
    attr_reader some_property: String
    attr_reader style: Style?
    attr_reader block: Block?

    def self.new: (some_property: String, ?style: Style?, ?block: Block?) -> MyWidget
  end
end
```
