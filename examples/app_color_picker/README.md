<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Color Picker Example

This example demonstrates how to build a **Feature-Rich Interactive Application** using `ratatui_ruby`.

It goes beyond simple widgets to show a complete, real-world architecture for handling:
-   **Complex State Management** (Input validation, undo/redo prep, clipboard interaction)
-   **Mouse Interaction & Hit Testing**
-   **Dynamic Layouts**
-   **Modal Dialogs**

## Architecture: The "Scene-Orchestrated" Pattern

This app uses a pattern we call **"Scene-Orchestrated MVC"**.

### 1. The App (Controller)
The main `App` class (`app.rb`) acts as the Controller. It:
-   Holds the source of truth (the State).
-   Runs the Event Loop.
-   Routes input events to the appropriate handler.
-   Initializes the `Scene`.

### 2. The Scene (View / Layout Engine)
The `Scene` class (`scene.rb`) acts as the primary View. Unlike simple examples where the render logic is in the `App` class, here the **Scene owns the Layout**.
-   **Composition**: It takes purely logical objects (`Palette`, `Input`) and decides how to present them.
-   **Hit Testing**: Crucially, the Scene **caches layout rectangles** (like `@export_area_rect`) during the render pass so the Controller knows *where* things are to handle clicks later.

### 3. The Logical Models
The application logic is broken down into small, testable Plain Old Ruby Objects (POROs) that know nothing about the TUI:
-   **`Color`**: Handles hex parsing, contrast calculation, and transformations.
-   **`Palette`**: Generates color harmonies.
-   **`Input`**: Manages the text buffer and validation state.
-   **`Clipboard`**: Wraps system commands.

This separation means your **business logic remains pure Ruby**, while the TUI layer focuses solely on presentation.

## Key Features Showcased

### 🖱️ Mouse Support & Hit Testing
See `Scene#export_rect` and `App#handle_main_input`.
The app detects clicks on specific UI elements. This handles the problem: *"How do I know which button the user clicked?"*
-   **Solution**: The rendering layer (Scene) exposes the `Rect` of interactive areas. The event loop checks `rect.contains?(mouse_x, mouse_y)`.

### 🔲 Modal Dialogs
See `CopyDialog`.
The app implements a modal overlay that intercepts input.
-   **Pattern**: The `App` checks `if dialog.active?`. If true, it routes events *only* to the dialog, effectively "blocking" the main UI.

### 🎨 Advanced Styling & Layout
-   **Dynamic Constraints**: Layouts that adapt to content.
-   **Visual Feedback**:
    -   Input fields turn red on error.
    -   Clipboard messages fade out over time (`Clipboard#tick`).
    -   Text colors automatically adjust for contrast (Black text on light backgrounds, White on dark).

## Problem Solving: What you can learn

Read this example if you are trying to solve:
1.  **"How do I structure a larger app?"** -> Move render logic out of `App` and into a `Scene` or `View` class.
2.  **"How do I handle mouse clicks?"** -> Cache the `Rect` during render.
3.  **"How do I make a popup?"** -> Use a state flag (`active?`) to conditional render on top of everything else (z-ordering) and hijack the input loop.
4.  **"How do I validate input?"** -> Wrap strings in an `Input` object that tracks both keypresses and validation errors.

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

Tools require interaction. Users click buttons and drag sliders. The Controller needs to know where components exist on screen. MVVM hides this layout data.

This example uses a "Scene" pattern. The View exposes layout rectangles. The Controller uses these rectangles to handle mouse clicks.

Use this pattern for forms, editors, and mouse-driven tools.

### The Dashboard Approach (AppAllEvents)

Dashboards display data. They rarely require complex mouse interaction. Proto-TEA (Model-View-Update) works best there. State is immutable. Logic is pure. Updates are predictable. This simplifies testing.

Use that pattern for logs, monitors, and data viewers.
