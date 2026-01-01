<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# App All Events Example

This example application captures and visualizes every event supported by `ratatui_ruby`. It serves as a comprehensive reference for event handling and a demonstration of a clean, scalable architectural pattern.

## Architecture: MVVM (Model-View-ViewModel)

This application demonstrates the **Model-View-ViewModel (MVVM)** pattern, modified for the immediate-mode nature of terminal UIs. This separation of concerns ensures that the UI logic is completely decoupled from the business logic, making the application easier to test and maintain.

### 1. Model (`model/`)
The **Model** manages the application's domain data and logic. It knows nothing about the UI.

*   **`Events` (`model/events.rb`)**: The core store. It records incoming events, maintains statistics (counts), and handles business logic like "highlight this event type for 300ms."
*   **`EventEntry` (`model/event_entry.rb`)**: A value object representing a single recorded event.

### 2. View State (ViewModel) (`view_state.rb`)
The **View State** (comparable to a ViewModel or Presenter) is an immutable data structure built specifically for the View.

*   **`ViewState`**: It acts as a bridge. In every render loop, the application builds a fresh `ViewState` object, calculating derived data (like styles, active flags, and formatted strings) from the raw Model data.
*   **Why?**: This prevents the View from having to contain logic. The View doesn't ask "is the app focused so I should use green?"; it just asks `state.border_color`.

### 3. View (`view/`)
The **View** is responsible **only** for rendering. It receives the `ViewState` and draws to the screen.

*   **`View::App` (`view/app_view.rb`)**: The root view. It handles the high-level layout (splitting the screen into areas).
*   **Sub-views**: `Counts`, `Live`, `Log`, `Controls`. Each is a small, focused component that renders a specific part of the screen based on the data in `ViewState`.

### 4. Controller/App (`app.rb`)
The **`AppAllEvents`** class ties it all together. It owns the main loop:

1.  **Poll**: Waits for an event from the terminal.
2.  **Update**: Passes the event to the **Model** (`@events.record`).
3.  **Build State**: Creates a new **ViewState** from the current Model and global state.
4.  **Render**: Passes the **ViewState** to the **View** to draw the frame.

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
Hello World examples are great, but they don't scale. This example shows how to structure an application that can grow. By simulating a "dashboard" with multiple independent widgets updating in real-time, it solves the problem of "how do I pass data around without global variables?"

### "How do I implement an event loop?"
It provides a robust reference implementation of the standard `loop { draw; handle_input }` cycle, including the correct way to handle quit signals.

## Comparison: Choosing an Architecture

Complex applications require structured state habits. `AppAllEvents` and the [Color Picker](../app_color_picker/README.md) demonstrate two different approaches.

### The Dashboard Approach (AppAllEvents)

Dashboards display data. They rarely require complex mouse interaction. Strict MVVM works best here. The View is a pure function. It accepts a `ViewState` and draws it. It ignores input. This simplifies testing.

Use this pattern for logs, monitors, and data viewers.

### The Tool Approach (Color Picker)

Tools require interaction. Users click buttons and drag sliders. The Controller needs to know where components exist on screen. MVVM hides this layout data.

The Color Picker uses a "Scene" pattern. The View exposes layout rectangles. The Controller uses these rectangles to handle mouse clicks.

Use this pattern for forms, editors, and mouse-driven tools.
