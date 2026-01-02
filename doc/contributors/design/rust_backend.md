<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Rust Backend Design (`ratatui_ruby` extension)

This document describes the internal architecture of the `ratatui_ruby` Rust extension.

## Architecture Guidelines

The project follows a **Structured Design** approach, separating concerns into modules to improve cohesiveness and testability.

### Core Principles

1.  **Single Generic Renderer**: The backend implements a single generic renderer that accepts a Ruby `Value` representing the root of the view tree.
2.  **No Custom Rust Structs for UI**: Do not define custom Rust structs that mirror Ruby UI components. Instead, extract data directly from Ruby objects using `funcall`.
3.  **Dynamic Dispatch**: Use `value.class().name()` (e.g., `"RatatuiRuby::Paragraph"`) to dynamically dispatch rendering logic to the appropriate widget module.
    *   *Exception:* `render_stateful_widget` bypasses generic dispatch for specific Widget/State pairs (e.g., List + ListState) to allow mutating the State object.
4.  **Immediate Mode**: The renderer traverses the Ruby object tree every frame and rebuilds the Ratatui widget tree on the fly.

### Module Structure

The Rust extension is located in `ext/ratatui_ruby/src/` and is organized as follows:

*   **`lib.rs`**: The entry point for the compiled extension. It defines the Ruby module structure using `magnus` and exports public functions (`init_terminal`, `draw`, `poll_event`). It wires together the submodules.
*   **`terminal.rs`**: Encapsulates the global `TERMINAL` state (mutex-wrapped `CrosstermBackend`). It provides functions to initialize and restore the terminal to raw mode.
*   **`events.rs`**: Handles keyboard input polling and mapping Crossterm events to Ruby hashes.
*   **`style.rs`**: Provides pure functions for parsing styling information (Colors, Styles, Blocks) from Ruby values.
*   **`rendering.rs`**: The central dispatcher for the render loop. It takes the top-level Ruby View Tree node and recursively delegates to specific widget implementations based on the Ruby class name.
*   **`widgets/`**: A directory containing individual modules for each Ratatui widget (e.g., `paragraph.rs`, `list.rs`).

### Adding a New Widget

To add a new widget:

1.  Create a new file `src/widgets/my_widget.rs`.
2.  Implement a public `render` function:
    ```rust
    /// Renders the widget to the given area.
    ///
    /// # Arguments
    ///
    /// * `frame` - The Ratatui frame to render to.
    /// * `area` - The rectangular area within the frame to draw the widget.
    /// * `node` - The Ruby object (Value) containing the widget's properties.
    pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error>
    ```
3.  Inside `render`:
    *   Extract properties from the `node` (Ruby value) using `.funcall("method_name", ())?`.
    *   Construct the Ratatui widget.
    *   Render it using `frame.render_widget`.
4.  Register the module in `src/widgets/mod.rs`.
5.  Add a dispatch arm in `src/rendering.rs` matching the Ruby class name (e.g., `RatatuiRuby::MyWidget`).

### Testing Strategy

*   **Unit Tests (`cargo test`)**:
    *   **Logic**: Test pure logic like `parse_color` in `style.rs` without needing a terminal or Ruby VM if possible (though `magnus::Value` usually requires it).
    *   **Rendering**: Verify that widgets render *something* to a buffer. Ratatui's `TestBackend` or `Buffer` can be used to assert that cells are filled.
*   **Integration Tests (`rake test`)**:
    *   Run Ruby scripts that exercise the full stack. Verify no crashes and expected return values.
