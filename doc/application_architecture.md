<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Core Concepts

This guide explains the core concepts and patterns available in `ratatui_ruby` for structuring your terminal applications.

## 1. Lifecycle Management

Managing the terminal state is critical. You must enter "alternate screen" and "raw mode" on startup, and **always** restore the terminal on exit (even on errors), otherwise the user's terminal will be left in a broken state.

### `RatatuiRuby.run` (Recommended)

The `run` method acts as a **Context Manager**. It handles the initialization and restoration for you, ensuring the terminal is always restored even if your code raises an exception. We recommend using `run` for all applications, as it provides a safe sandbox for your TUI.

```ruby
RatatuiRuby.run do |tui|
  loop do
     # Your code here
    tui.draw(...)
  end
end
# Terminal is restored here
```

### Manual Management (Advanced)

You can manage this manually if you need granular control, but use `ensure` blocks!

```ruby
RatatuiRuby.init_terminal
begin
  # Your code here
  RatatuiRuby.draw(...)
ensure
  RatatuiRuby.restore_terminal
end
```

## 2. API Convenience

### Session API (Recommended)

The block yielded by `run` is a `RatatuiRuby::Session` instance (`tui`).
It provides factory methods for every widget class (converting snake_case to CamelCase) and aliases for module functions.

**Why use it?** It significantly reduces verbosity and repeated `RatatuiRuby::` namespacing, making the UI tree structure easier to read.

```ruby
RatatuiRuby.run do |tui|
  loop do
    layout = tui.layout(
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.length(20),
        RatatuiRuby::Constraint.min(0)
      ],
      children: [
        tui.paragraph(
          text: tui.text_line(spans: [
            tui.text_span(content: "Side", style: tui.style(fg: :blue)),
            tui.text_span(content: "bar")
          ]),
          block: tui.block(borders: [:all], title: "Nav")
        ),
        tui.paragraph(
          text: "Main Content",
          style: tui.style(fg: :green),
          block: tui.block(borders: [:all], title: "Content")
        )
      ]
    )
    
    tui.draw(layout)
    
    event = tui.poll_event
    break if event == "q" || event == :ctrl_c
  end
end
```

### Raw API

You can always use the raw module methods and classes directly. This is useful if you are building your own abstractions or prefer explicit class instantiation.

**Comparison:** Notice how much more verbose the same UI definition is.

```ruby
RatatuiRuby.run do
  loop do
    layout = RatatuiRuby::Layout.new(
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.length(20),
        RatatuiRuby::Constraint.min(0)
      ],
      children: [
        RatatuiRuby::Paragraph.new(
          text: RatatuiRuby::Text::Line.new(spans: [
            RatatuiRuby::Text::Span.new(content: "Side", style: RatatuiRuby::Style.new(fg: :blue)),
            RatatuiRuby::Text::Span.new(content: "bar")
          ]),
          block: RatatuiRuby::Block.new(borders: [:all], title: "Nav")
        ),
        RatatuiRuby::Paragraph.new(
          text: "Main Content",
          style: RatatuiRuby::Style.new(fg: :green),
          block: RatatuiRuby::Block.new(borders: [:all], title: "Content")
        )
      ]
    )
    
    RatatuiRuby.draw(layout)

    event = RatatuiRuby.poll_event
    break if event == "q" || event == :ctrl_c
  end
end
```
