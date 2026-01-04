<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Color Picker Example

[![Color Picker](../../doc/images/app_color_picker.png)](app.rb)

This example demonstrates how to build a **Feature-Rich Interactive Application** using `ratatui_ruby`.

It goes beyond simple widgets to show a complete, real-world architecture for handling:
-   **Complex State Management** (Input validation, clipboard interaction)
-   **Mouse Interaction & Hit Testing**
-   **Dynamic Layouts**
-   **Modal Dialogs**

## Architecture: Component-Based

This app uses a **Strict Component-Based Architecture** where every UI element encapsulates its own **Rendering**, **State**, and **Event Handling**.

### The Component Contract

Every component implements this duck-type interface:

```ruby
# Renders the component into the given area
# Caches `area` for hit testing
def render(tui, frame, area)
  @area = area
  # ... render using frame.render_widget
end

# Processes events; returns a symbolic signal or nil
def handle_event(event) -> Symbol | nil
  # Returns :consumed, :submitted, :copy_requested, etc.
end

# Optional: time-based updates
def tick
end
```

### 1. The MainContainer (Orchestrator)

The `MainContainer` class (`main_container.rb`) owns all child components and orchestrates the UI:

-   **Layout Phase:** Calculates `Rect`s using `tui.layout_split`.
-   **Delegation Phase:** Calls `child.render(tui, frame, child_area)` for each component.
-   **Event Routing (Chain of Responsibility):** Delegates events front-to-back. The modal dialog gets priority when active.
-   **Mediator Pattern:** Interprets symbolic signals (`:submitted`, `:copy_requested`) to coordinate cross-component effects.

### 2. Self-Contained Components

Each UI element is a self-contained component:

-   **`Input`**: Text entry with validation. Returns `:submitted` when Enter is pressed.
-   **`Palette`**: Displays color harmonies. Accepts `update_color` from the container.
-   **`ExportPane`**: Shows HEX/RGB/HSL formats. Returns `:copy_requested` when clicked.
-   **`Controls`**: Displays keyboard shortcuts. Has a `tick` lifecycle for clipboard feedback.
-   **`CopyDialog`**: Modal confirmation dialog. Returns `:consumed` when handling events.

### 3. The App (Minimal Runner)

The `App` class (`app.rb`) is a thin runner:
-   Creates the `MainContainer`.
-   Runs the main loop: `tick` → `render` → `poll` → `handle_event`.
-   Checks for quit events.

## Key Features Showcased

### 🖱️ Encapsulated Hit Testing

Components cache their render area (`@area`) during `render`. In `handle_event`, they check `@area&.contains?(x, y)` to detect clicks. The container never calculates coordinates—hit testing is fully encapsulated.

### 🔲 Modal Dialogs via Chain of Responsibility

When `CopyDialog` is active, the `MainContainer` offers it events first. If it returns `:consumed`, event propagation stops. This creates modal behavior without explicit flags in the app.

### 📡 Symbolic Signals (Mediator Pattern)

Components return semantic symbols instead of just `:consumed`:
-   `Input` returns `:submitted` when the user presses Enter.
-   `ExportPane` returns `:copy_requested` when clicked.

The `MainContainer` interprets these signals to coordinate cross-component communication:

```ruby
result = @input.handle_event(event)
case result
when :submitted
  @palette.update_color(@input.parsed_color)
  return :consumed
end
```

### ⏱️ Lifecycle Hooks (`tick`)

Components can have time-based updates. `Controls#tick` delegates to `Clipboard#tick` to decrement the feedback timer.

## Problem Solving: What You Can Learn

Read this example if you are trying to solve:
1.  **"How do I structure a larger app?"** → Use the Component Contract and a Container for orchestration.
2.  **"How do I handle mouse clicks?"** → Cache `@area` during render; check `contains?` in `handle_event`.
3.  **"How do I make a popup?"** → Use Chain of Responsibility: the active modal gets events first.
4.  **"How do I coordinate between components?"** → Use symbolic signals and the Mediator pattern.
5.  **"How do I validate input?"** → Encapsulate validation inside the `Input` component.

## Usage

```bash
ruby examples/app_color_picker/app.rb
```

-   Type a hex code (e.g., `#FF0055`) or color name (`cyan`).
-   Press `Enter` to generate the palette.
-   Click on the **Export Formats** box to copy the hex code.

## Comparison: Choosing an Architecture

Complex applications require structured state habits. This Color Picker and the [App All Events](../app_all_events/README.md) example demonstrate two different approaches.

### The Tool Approach (Color Picker)

Tools require interaction. Users click buttons and drag sliders. Components need to know where they exist on screen for hit testing. The Container orchestrates cross-component effects.

This example uses a **Component-Based** pattern. Each component owns its own state, rendering, and event handling. The Container routes events and mediates communication.

Use this pattern for forms, editors, and mouse-driven tools.

### The Dashboard Approach (AppAllEvents)

Dashboards display data. They rarely require complex mouse interaction. Model-View-Update works best there. State is immutable. Logic is pure. Updates are predictable. This simplifies testing.

Use that pattern for logs, monitors, and data viewers.
