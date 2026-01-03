<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Rust Backend Design (`ratatui_ruby` extension)

This document describes the internal architecture of the `ratatui_ruby` Rust extension. It is intended for contributors, architects, and AI agents working on the codebase.

This is the companion document to [Ruby Frontend Design](./ruby_frontend.md). The Ruby layer defines data structures; the Rust layer renders them.

## Key Dependencies

| Crate | Purpose |
|-------|---------|
| `ratatui` | TUI framework providing widgets, layout, and rendering |
| `crossterm` | Cross-platform terminal manipulation (raw mode, events, colors) |
| `magnus` | Ruby FFI bindings for Rust (value extraction, exception handling) |

**Why `ratatui` vs `ratatui-crossterm`?**

Ratatui's workspace includes modular crates (`ratatui-crossterm`, `ratatui-core`, etc.) for library authors who need fine-grained dependency control. We use the main `ratatui` crate because:

1. We're building an application extension, not a widget library
2. The main crate includes crossterm backend by default
3. It provides the complete API surface we need

## Guiding Design Principles

### 1. Ruby Defines, Rust Renders

The Rust backend is a pure rendering engine. It receives Ruby objects representing the desired UI state and converts them to Ratatui primitives. It does not own or manage UI state—that responsibility belongs to Ruby.

**The Contract:**
- Ruby constructs a tree of `Data.define` objects describing the UI
- Ruby calls `RatatuiRuby.draw { |frame| ... }` or passes a widget to `frame.render_widget`
- Rust walks the Ruby object tree via `magnus::Value` and `funcall`
- Rust builds Ratatui widgets and renders them to the terminal buffer

### 2. Single Generic Renderer

The backend implements one generic rendering function that accepts any Ruby `Value` and dispatches based on class name. There is no compile-time knowledge of Ruby types—everything is runtime reflection.

```rust
// rendering.rs
pub fn render_widget(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let class_name: String = node.class().name()?.into_owned();
    
    match class_name.as_str() {
        "RatatuiRuby::Widgets::Paragraph" => paragraph::render(frame, area, node),
        "RatatuiRuby::Widgets::Block" => block::render(frame, area, node),
        "RatatuiRuby::Widgets::Table" => table::render(frame, area, node),
        // ... etc
        _ => Err(Error::new(
            magnus::exception::type_error(),
            format!("Unknown widget type: {}", class_name)
        ))
    }
}
```

### 3. No Custom Rust Structs for UI

Do not define Rust structs that mirror Ruby UI components. This would create synchronization problems when Ruby classes change.

**What We Do:**
```rust
// Extract directly from Ruby object
let text: String = node.funcall("text", ())?;
let style_val: Value = node.funcall("style", ())?;
let style = parse_style(style_val)?;
```

**What We Don't Do:**
```rust
// NO: Rust struct mirroring Ruby
struct Paragraph {
    text: String,
    style: Option<Style>,
    block: Option<Block>,
}
```

### 4. Immediate Mode Rendering

The renderer traverses the Ruby object tree every frame and rebuilds the Ratatui widget tree from scratch. No widget state persists between frames in Rust.

This mirrors Ratatui's own immediate mode paradigm. The Rust backend is stateless (except for terminal state).

### 5. Memory Safety via Value Extraction

Ruby's GC can move or collect objects at any time. All data extracted from Ruby must be owned (copied) before use, never borrowed.

```rust
// SAFE: Convert to owned String immediately
let text: String = node.funcall::<_, String>("text", ())?.into_owned();

// UNSAFE: Holding reference across GC-safe point
let text_ref: &str = node.funcall("text", ())?;  // DON'T
do_something_that_might_gc();
use(text_ref);  // CRASH: text_ref may be invalid
```

---

## Directory Structure

```
ext/ratatui_ruby/src/
├── lib.rs              # Entry point, Ruby module registration
├── terminal.rs         # Global TERMINAL state, init/restore
├── frame.rs            # Frame wrapper for render_widget, area access
├── events.rs           # Event polling, crossterm -> Ruby conversion
├── style.rs            # Style/Color parsing from Ruby values
├── text.rs             # Span/Line parsing
├── rendering.rs        # Central dispatcher, class name -> widget module
└── widgets/            # Per-widget rendering modules
    ├── mod.rs          # Re-exports all widget modules
    ├── paragraph.rs
    ├── block.rs
    ├── table.rs
    ├── list.rs
    ├── canvas.rs
    └── ...
```

---

## Module Responsibilities

### `lib.rs` — Entry Point

Defines the Ruby module hierarchy using `magnus` and exports public functions (`init_terminal`, `restore_terminal`, `draw`, `poll_event`, `get_cell_at`).

### `terminal.rs` — Terminal State

Manages the global `TERMINAL` singleton (mutex-wrapped `CrosstermBackend<Stdout>`).

Key functions:
- `init()` — Enter raw mode, enable mouse capture, switch to alternate screen
- `restore()` — Disable raw mode, restore main screen
- `get_cell_at(x, y)` — Return buffer cell as Ruby `Buffer::Cell` object

**Safety Note:** The terminal is a global mutable resource. All access goes through a mutex. Holding the lock across Ruby calls risks deadlock—release the lock before calling back into Ruby.

### `frame.rs` — Frame Wrapper

Wraps Ratatui's `Frame` struct for safe Ruby access. The `Frame` reference is only valid inside the `draw` closure. The `FrameWrapper` tracks validity and raises `Safety` error if used after the closure returns.

### `events.rs` — Event Conversion

Polls crossterm events and converts them to Ruby `Event::*` objects. Handles key, mouse, resize, paste, and focus events.

### `style.rs` — Style Parsing

Pure functions for extracting style information from Ruby values. Handles `parse_style`, `parse_color` (symbols, integers 0-255, hex strings), and `parse_modifiers`.

### `rendering.rs` — Central Dispatcher

The routing layer that maps Ruby class names to widget renderers:

```rust
pub fn render_widget(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let class_name: String = node.class().name()?.into_owned();
    
    match class_name.as_str() {
        // Widgets module
        "RatatuiRuby::Widgets::Paragraph" => widgets::paragraph::render(frame, area, node),
        "RatatuiRuby::Widgets::Block" => widgets::block::render(frame, area, node),
        "RatatuiRuby::Widgets::Table" => widgets::table::render(frame, area, node),
        "RatatuiRuby::Widgets::List" => widgets::list::render(frame, area, node),
        "RatatuiRuby::Widgets::Tabs" => widgets::tabs::render(frame, area, node),
        "RatatuiRuby::Widgets::Gauge" => widgets::gauge::render(frame, area, node),
        "RatatuiRuby::Widgets::Chart" => widgets::chart::render(frame, area, node),
        "RatatuiRuby::Widgets::Canvas" => widgets::canvas::render(frame, area, node),
        "RatatuiRuby::Widgets::Scrollbar" => widgets::scrollbar::render(frame, area, node),
        "RatatuiRuby::Widgets::Calendar" => widgets::calendar::render(frame, area, node),
        // ... all widgets
        
        // Special widgets
        "RatatuiRuby::Widgets::Clear" => widgets::clear::render(frame, area, node),
        "RatatuiRuby::Widgets::Cursor" => widgets::cursor::render(frame, area, node),
        
        // Custom widgets (Ruby escape hatch)
        _ if has_render_method(node) => widgets::custom::render(frame, area, node),
        
        _ => Err(Error::new(
            magnus::exception::type_error(),
            format!("Unknown widget type: {}", class_name)
        ))
    }
}
```

**Namespace Pattern:** All built-in widgets use the `RatatuiRuby::Widgets::*` namespace. The dispatcher matches on full class names, not prefixes.

### `widgets/*.rs` — Widget Renderers

Each widget has its own module with a standard interface:

```rust
// widgets/paragraph.rs
pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    // 1. Extract properties from Ruby object
    let text = parse_text(node.funcall("text", ())?)?;
    let style = parse_style(node.funcall("style", ())?)?;
    let alignment = parse_alignment(node.funcall("alignment", ())?)?;
    let block_val: Value = node.funcall("block", ())?;
    
    // 2. Build Ratatui widget
    let mut paragraph = Paragraph::new(text)
        .style(style)
        .alignment(alignment);
    
    // 3. Handle optional block wrapper
    if !block_val.is_nil() {
        paragraph = paragraph.block(parse_block(block_val)?);
    }
    
    // 4. Render
    frame.render_widget(paragraph, area);
    Ok(())
}
```

---

## Adding a New Widget

### Step 1: Create the Widget Module

```rust
// src/widgets/my_widget.rs

use magnus::{Error, Value};
use ratatui::prelude::*;

use crate::style::parse_style;

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    // Extract properties
    let content: String = node.funcall::<_, String>("content", ())?.into_owned();
    let style = parse_style(node.funcall("style", ())?)?;
    
    // Build and render
    let widget = MyWidget::new(content).style(style);
    frame.render_widget(widget, area);
    
    Ok(())
}
```

### Step 2: Register in `widgets/mod.rs`

```rust
pub mod my_widget;
```

### Step 3: Add Dispatch Arm in `rendering.rs`

```rust
"RatatuiRuby::Widgets::MyWidget" => widgets::my_widget::render(frame, area, node),
```

### Step 4: Test

Run `cargo test` for Rust unit tests, then `rake test` for Ruby integration tests.

---

## Stateful Widget Rendering

Some widgets (List, Table, Scrollbar) support stateful rendering where a mutable State object tracks scroll position and selection.

### The Pattern

```rust
pub fn render_stateful_widget(
    frame: &mut Frame,
    area: Rect,
    widget_node: Value,
    state_node: Value
) -> Result<(), Error> {
    // 1. Build the widget (immutable configuration)
    let list = build_list(widget_node)?;
    
    // 2. Extract mutable state
    let mut state = ListState::default();
    if let Ok(selected) = state_node.funcall::<_, Option<i64>>("selected", ()) {
        state.select(selected.map(|i| i as usize));
    }
    
    // 3. Render with state (Ratatui may mutate offset)
    frame.render_stateful_widget(list, area, &mut state);
    
    // 4. Write computed values back to Ruby state object
    state_node.funcall::<_, Value>("set_offset", (state.offset() as i64,))?;
    
    Ok(())
}
```

**State Precedence:** When using stateful rendering, the State object's values take precedence over Widget properties. This is documented in Ruby.

---

## Custom Widget Escape Hatch

Ruby users can define custom widgets that implement a `render(area)` method returning an array of `Draw` commands. The dispatcher detects a `render` method and calls it, processing the returned commands to manipulate the buffer directly. This is the "escape hatch" for functionality not yet wrapped by built-in widgets.

---

## Error Handling

All Rust functions that can fail return `Result<T, magnus::Error>`. Magnus automatically converts these to Ruby exceptions.

**Error Types:**

| Scenario | Ruby Exception | Notes |
|----------|---------------|-------|
| Invalid argument | `ArgumentError` | Wrong type, out of range |
| Unknown widget | `TypeError` | Class name not in dispatch table |
| Terminal not initialized | `RatatuiRuby::Error::Terminal` | Custom exception class |
| Frame used after draw block | `RatatuiRuby::Error::Safety` | Memory safety violation |

---

## Testing Strategy

### Rust Unit Tests (`cargo test`)

Test pure parsing functions that don't require Ruby VM. Most tests require Ruby VM via magnus, which means they run in integration test style.

### Ruby Integration Tests (`rake test`)

The primary testing strategy. Ruby tests exercise the full stack and verify end-to-end behavior without testing Rust internals.

### Buffer Verification

For Rust-level rendering tests, use Ratatui's `TestBackend` or `Buffer` to assert cells are filled correctly.

---

## Performance Considerations

### Avoid Repeated `funcall`

Each `funcall` crosses the Ruby/Rust boundary. Cache results when accessing the same property multiple times rather than calling `funcall` repeatedly.

### String Ownership

Always convert to owned `String` immediately via `into_owned()` to avoid GC-related memory safety issues.

### Batch Collection Iteration

When processing Ruby arrays, collect all values into a `Vec<Value>` before processing to avoid holding references across iterations.
