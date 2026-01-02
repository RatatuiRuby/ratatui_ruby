<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# App All Events Example

This example application captures and visualizes every event supported by `ratatui_ruby`. It serves as a comprehensive reference for event handling and a demonstration of the Proto-TEA architectural pattern.

## Architecture: Proto-TEA (Model-View-Update)

This application demonstrates **unidirectional data flow** inspired by The Elm Architecture. This separation ensures that state management is predictable and easy to test.

### 1. Model (`model/app_model.rb`)
A single immutable `Data.define` object holding **all** application state:
*   Event log entries
*   Focus state
*   Window size
*   Highlight timestamps
*   Color cycle index

State changes use `.with(...)` to return a new Model instance.

### 2. Msg (`model/msg.rb`)
Semantic value objects that decouple raw terminal events from business logic:
*   `Msg::Input` — keyboard, mouse, or paste events
*   `Msg::Resize` — terminal size changes
*   `Msg::Focus` — focus gained/lost
*   `Msg::Quit` — exit signal

### 3. Update (`update.rb`)
A **pure function** that computes the next state:

```ruby
Update.call(msg, model) -> Model
```

All logic previously in `Events.record` now lives here. The function never mutates, never draws, never performs IO.

### 4. View (`view/`)
Pure rendering logic. Views accept the immutable `AppModel` and draw to the screen.
*   **`View::App`**: Root view handling high-level layout
*   **Sub-views**: `Counts`, `Live`, `Log`, `Controls`

### 5. Runtime (`app.rb`)
The MVU loop:

```ruby
loop do
  tui.draw { |f| view.call(model, tui, f, f.area) }
  msg = map_event_to_msg(tui.poll_event, model)
  break if msg.is_a?(Msg::Quit)
  model = Update.call(msg, model)
end
```

## Library Features Showcased

Reading this code will teach you how to:

*   **Handle All Events**:
    *   **Keyboard**: Capture normal keys and modifiers (`Ctrl+c`, `q`).
    *   **Mouse**: track clicks, drags, and scroll events.
    *   **Focus**: React to the terminal window gaining or losing focus (`FocusGained`/`FocusLost`).
    *   **Resize**: Dynamically adapt layouts when the terminal size changes.
    *   **Paste**: Handle bracketed paste events (if supported by the terminal).
*   **Layouts**: Use `tui.layout_split` with constraints (`Length`, `Fill`) to create complex, responsive dashboards.
*   **Styling**: Apply dynamic styles (bold, colors) based on application state.
*   **Structure**: Organize a non-trivial CLI tool into small, single-purpose classes.

## What Problems Does This Solve?

### "What key code is my terminal sending?"
If you are building an app and your logic isn't catching `Ctrl+Left`, run this app and press the keys. You will see exactly how `ratatui_ruby` parses that input (e.g., is it a `Key` event? What are the modifiers?).

### "How do I structure a real app?"
Hello World examples are great, but they don't scale. This example shows how to structure an application that can grow. By using immutable state and pure functions, it solves the problem of "where does my state live and how does it change?"

### "How do I test my business logic?"
The `Update` function is pure. You can test it by constructing a `Msg`, calling `Update.call(msg, model)`, and asserting on the returned `Model`. No mocking required.

## Comparison: Choosing an Architecture

Complex applications require structured state habits. `AppAllEvents` and the [Color Picker](../app_color_picker/README.md) demonstrate two different approaches.

### The Dashboard Approach (AppAllEvents)

Dashboards display data. They rarely require complex mouse interaction. Proto-TEA works best here. State is immutable. Logic is pure. Updates are predictable. This simplifies testing.

Use this pattern for logs, monitors, and data viewers.

### The Tool Approach (Color Picker)

Tools require interaction. Users click buttons and drag sliders. The Controller needs to know where components exist on screen.

The Color Picker uses a "Scene-Orchestrated" pattern. The Scene calculates layout and exposes cached rectangles for hit testing.

Use this pattern for forms, editors, and mouse-driven tools.
