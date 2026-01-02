<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Application Architecture

Architect robust TUI applications using core lifecycle patterns and API best practices.

## Core Concepts

Your app lives inside a terminal. You need to respect its rules.

### Lifecycle Management

Terminals have state. They remember cursor positions, input modes, and screen buffers.

**The Problem:** If your app crashes or exits without cleaning up, it "breaks" the user's terminal. The cursor vanishes. Input echoes constantly. The alternate screen doesn't clear.

**The Solution:** The library's lifecycle manager handles this for you. It enters "raw mode" on startup and guarantees restoration on exit.

#### Use `RatatuiRuby.run`

This method acts as a safety net. It initializes the terminal, yields control to your block, and restores the terminal afterwards—even if your code raises an exception.

```ruby
RatatuiRuby.run do |tui|
  loop do
    tui.draw do |frame|
      frame.render_widget(tui.paragraph(text: "Hello"), frame.area)
    end
    break if tui.poll_event == "q"
  end
end
# Terminal is restored here
```

#### Manual Management

Need granular control? You can initialize and restore the terminal yourself. Use `ensure` blocks to guarantee cleanup.

```ruby
RatatuiRuby.init_terminal
begin
  RatatuiRuby.draw do |frame|
    frame.render_widget(RatatuiRuby::Paragraph.new(text: "Hello"), frame.area)
  end
ensure
  RatatuiRuby.restore_terminal
  # Terminal is restored here
end
```

### API Convenience

Writing UI trees involves nesting many widgets.

**The Problem:** Explicitly namespacing `RatatuiRuby::` for every widget (e.g., `RatatuiRuby::Paragraph.new`) is tedious. It creates visual noise that hides your layout structure.

**The Solution:** The Session API (`tui`) provides shorthand factories for every widget. It yields a session object to your block.

```ruby
RatatuiRuby.run do |tui|
  loop do
    tui.draw do |frame|
      # Split layout using Session helpes
      sidebar_area, content_area = tui.layout_split(
        frame.area,
        direction: :horizontal,
        constraints: [
          tui.constraint_length(20),
          tui.constraint_min(0)
        ]
      )

      # Render sidebar
      frame.render_widget(
        tui.paragraph(
          text: tui.text_line(spans: [
            tui.text_span(content: "Side", style: tui.style(fg: :blue)),
            tui.text_span(content: "bar")
          ]),
          block: tui.block(borders: [:all], title: "Nav")
        ),
        sidebar_area
      )

      # Render main content
      frame.render_widget(
        tui.paragraph(
          text: "Main Content",
          style: tui.style(fg: :green),
          block: tui.block(borders: [:all], title: "Content")
        ),
        content_area
      )
    end
    
    event = tui.poll_event
    break if event == "q" || event == :ctrl_c
  end
end
```

#### Raw API

Building your own abstractions? You might prefer explicit class instantiation. The raw constants are always available.

```ruby
RatatuiRuby.run do
  loop do
    RatatuiRuby.draw do |frame|
      # Manual split
      rects = RatatuiRuby::Layout.split(
        frame.area,
        direction: :horizontal,
        constraints: [
          RatatuiRuby::Constraint.length(20),
          RatatuiRuby::Constraint.min(0)
        ]
      )

      frame.render_widget(
        RatatuiRuby::Paragraph.new(
          text: RatatuiRuby::Text::Line.new(spans: [
            RatatuiRuby::Text::Span.new(content: "Side", style: RatatuiRuby::Style.new(fg: :blue)),
            RatatuiRuby::Text::Span.new(content: "bar")
          ]),
          block: RatatuiRuby::Block.new(borders: [:all], title: "Nav")
        ),
        rects[0]
      )

      frame.render_widget(
        RatatuiRuby::Paragraph.new(
          text: "Main Content",
          style: RatatuiRuby::Style.new(fg: :green),
          block: RatatuiRuby::Block.new(borders: [:all], title: "Content")
        ),
        rects[1]
      )
    end

    event = RatatuiRuby.poll_event
    break if event == "q" || event == :ctrl_c
  end
end
```

## Thread and Ractor Safety

Building for Ruby 4.0's parallel future? Know which objects can travel between Ractors.

### Data Objects (Shareable)

These are deeply frozen and `Ractor.shareable?`. Include them in TEA Models/Messages freely:

| Object | Source |
|--------|--------|
| `Event::*` | `poll_event` |
| `Cell` | `get_cell_at` |
| `Rect` | `Layout.split`, `Frame#area` |

### I/O Handles (Not Shareable)

These have side effects and are intentionally not shareable:

| Object | Valid Usage |
|--------|-------------|
| `Session` | Cache in `@tui` during run loop. Don't include in Models. |
| `Frame` | Pass to helpers during draw block. Invalid after block returns. |

```ruby
# Good: Cache session in instance variable
RatatuiRuby.run do |tui|
  @tui = tui
  loop { render; handle_input }
end

# Bad: Include in immutable Model (won't work with Ractors)
Model = Data.define(:tui, :count)  # Don't do this
```


## Reference Architectures

Simple scripts work well with valid linear code. Complex apps need structure.

We provide these reference architectures to inspire you:

### Proto-TEA (Model-View-Update)

**Source:** [examples/app_all_events](../examples/app_all_events/README.md)

This pattern implements unidirectional data flow inspired by The Elm Architecture:
*   **Model:** A single immutable `Data.define` object holding all application state.
*   **Msg:** Semantic value objects that decouple raw events from business logic.
*   **Update:** A pure function that computes the next state: `Update.call(msg, model) -> Model`.
*   **View:** Pure rendering logic that accepts the immutable Model.

Use this when you want predictable state management and easy-to-test logic.

### Proto-Kit (Component-Based)

**Source:** [examples/app_color_picker](../examples/app_color_picker/README.md)

This pattern addresses the difficulty of mouse interaction and complex UI orchestration:
*   **Component Contract:** Every UI element implements `render(tui, frame, area)` and `handle_event(event)`.
*   **Encapsulated Hit Testing:** Components cache their render area and check `contains?` internally.
*   **Symbolic Signals:** `handle_event` returns semantic symbols (`:consumed`, `:submitted`) instead of just booleans.
*   **Container (Mediator):** A parent container routes events via Chain of Responsibility and coordinates cross-component effects.

Use this when you need rich interactivity (mouse clicks, drag-and-drop) or complex dynamic layouts.

