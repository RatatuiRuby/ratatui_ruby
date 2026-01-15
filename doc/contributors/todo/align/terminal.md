<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>

SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Terminal Object Design Proposals

## Executive Summary

The current ratatui_ruby architecture abstracts Terminal functionality behind module-level methods (`RatatuiRuby.draw`, `RatatuiRuby.poll_event`) and the `TUI` facade class. This document proposes a design for introducing a proper `Terminal` object that aligns with upstream Ratatui's architecture while maintaining Ruby idioms, the established Mullet Architecture, and full backward compatibility.

## Background

### Current Architecture

**Module-Level API** (`RatatuiRuby` module):
- `init_terminal`, `restore_terminal`, `run`
- `draw`, `poll_event`, `get_cell_at`
- `get_viewport_area`, `get_terminal_size`
- `insert_before` (for inline viewports)
- `cursor_position`, `cursor_position=`

**Rust Implementation**:
- Global `TERMINAL` singleton wrapped in `Mutex<Option<TerminalWrapper>>`
- `TerminalWrapper` enum supporting `Crossterm` and `Test` backends
- Direct FFI methods exposed to Ruby

**Upstream Ratatui Terminal struct** provides:
- `new(backend)`, `with_options(backend, options)` — construction
- `draw(callback)` — frame rendering
- `get_frame()` — direct frame access
- `hide_cursor()`, `show_cursor()`, `get_cursor_position()`, `set_cursor_position()` — cursor control
- `clear()` — screen clearing
- `resize(area)`, `autoresize()` — size management
- `insert_before(height, draw_fn)` — inline viewport insertion
- `backend()`, `backend_mut()` — backend access
- `current_buffer_mut()` — buffer inspection
- `flush()`, `swap_buffers()` — low-level rendering control

### Design Principles (from ruby_frontend.md)

1. **Ratatui Alignment**: Ruby namespace mirrors Rust module hierarchy
2. **Two-Layer Architecture (Mullet)**: 
   - Layer 1: Explicit schema classes (`RatatuiRuby::Widgets::*`)
   - Layer 2: Ergonomic DSL (`TUI` facade)
3. **Explicit Over Magic**: No runtime metaprogramming
4. **Data-Driven UI**: Immediate mode, immutable data structures
5. **Separation of Configuration and Status**: Widgets (input) vs State (output)
6. **No Render Logic in Ruby**: Ruby defines data, Rust renders

---

## Proposal 1: Terminal Class with Instance-Based API (Full Upstream Port)

### Overview
Create a proper `RatatuiRuby::Terminal` class that mirrors the upstream Ratatui Terminal struct. Maintains full backward compatibility via singleton delegation pattern.

### Design Philosophy: Rust-Side Object Construction

**Proposal 1 design decision**: FFI methods return fully-constructed Ruby objects, not raw primitives or hashes.

Using Magnus, Rust can instantiate Ruby classes directly:
- `_poll_event_instance(timeout)` returns `Event::Key`, `Event::Mouse`, `Event::None`, etc.
- `_viewport_area_instance()` returns `Layout::Rect`
- `_get_cell_at_instance(x, y)` returns `Buffer::Cell`

This keeps Terminal methods as **thin delegates** to Rust, with all object construction logic centralized in the FFI layer. Ruby code becomes cleaner and less error-prone.

**Current pattern** (returns hash):
<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
def poll_event(timeout: 0.016)
  raw = _poll_event_instance(timeout)
  return Event::None.new.freeze if raw.nil?
  case raw[:type]
  when :key then Event::Key.new(code: raw[:code], ...)
  # ... 30 lines of parsing
  end
end
```
<!-- SPDX-SnippetEnd -->

**Proposal 1 pattern** (returns object):
<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
def poll_event(timeout: 0.016)
  _poll_event_instance(timeout) # Rust instantiates Event::Key, etc.
end
```
<!-- SPDX-SnippetEnd -->

### Implementation

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# lib/ratatui_ruby/terminal.rb
module RatatuiRuby
  class Terminal
    # Construction
    def initialize(viewport: :fullscreen, height: nil)
      @viewport = resolve_viewport(viewport, height)
      _init_terminal_instance(@viewport.type.to_s, @viewport.height)
    end

    # Core rendering (thin delegate)
    def draw(&block)
      _draw_instance(&block)
    end

    # Event polling (Rust returns Event objects)
    def poll_event(timeout: 0.016)
      _poll_event_instance(timeout)
    end

    # Cursor control
    def hide_cursor
      _hide_cursor_instance
    end

    def show_cursor
      _show_cursor_instance
    end

    # Cursor position (Rust returns Layout::Position)
    def cursor_position
      _get_cursor_position_instance
    end

    def cursor_position=(position)
      if position.is_a?(Array)
        x, y = position
      else
        x, y = position.x, position.y
      end
      _set_cursor_position_instance(x, y)
    end

    # Viewport operations
    def insert_before(height, widget = nil, &block)
      content = widget || block&.call
      _insert_before_instance(height, content)
    end

    # Viewport queries (Rust returns Layout::Rect)
    def viewport_area
      _get_viewport_area_instance
    end

    def terminal_size
      _get_terminal_size_instance
    end

    # Screen management
    def clear
      _clear_instance
    end

    def resize(width, height)
      _resize_instance(width, height)
    end

    def autoresize
      _autoresize_instance
    end

    # Buffer inspection (Rust returns Buffer::Cell)
    def get_cell_at(x, y)
      _get_cell_at_instance(x, y)
    end

    # Low-level rendering control
    def flush
      _flush_instance
    end

    def swap_buffers
      _swap_buffers_instance
    end

    # Backend access (advanced)
    def backend
      _backend_instance
    end

    def backend_mut
      _backend_mut_instance
    end

    # Lifecycle
    def restore
      _restore_terminal_instance
    end

    private

    def resolve_viewport(viewport, height)
      case viewport
      when nil, :fullscreen then Terminal::Viewport.fullscreen
      when :inline then Terminal::Viewport.inline(height || 8)
      when Terminal::Viewport then viewport
      else raise ArgumentError, "Unknown viewport: #{viewport.inspect}"
      end
    end
  end
  
  # Module-level singleton for backward compatibility
  @default_terminal = nil
  
  class << self
    private
    
    def default_terminal
      @default_terminal ||= Terminal.new
    end
  end
  
  # Existing module methods delegate to singleton (BACKWARD COMPATIBLE)
  def self.draw(&block)
    default_terminal.draw(&block)
  end
  
  def self.poll_event(timeout: 0.016)
    default_terminal.poll_event(timeout:)
  end
  
  def self.get_cell_at(x, y)
    default_terminal.get_cell_at(x, y)
  end
  
  def self.get_viewport_area
    default_terminal.viewport_area
  end
  
  def self.get_terminal_size
    default_terminal.terminal_size
  end
  
  def self.insert_before(height, widget = nil, &block)
    default_terminal.insert_before(height, widget, &block)
  end
  
  # ... (all other module methods delegate similarly)
end

# TUI facade delegates to the Terminal instance passed to it
class TUI
  def initialize(terminal)
    @terminal = terminal
  end
  
  # Expose the terminal instance
  attr_reader :terminal
  
  # Delegate core operations to terminal
  def draw(&block)
    @terminal.draw(&block)
  end
  
  def poll_event(timeout: 0.016)
    @terminal.poll_event(timeout:)
  end
  
  # ... (all existing TUI factory methods remain unchanged)
end

# run creates a Terminal and yields a TUI wrapping it
def self.run(viewport: :fullscreen, height: nil, &block)
  terminal = Terminal.new(viewport:, height:)
  tui = TUI.new(terminal)
  yield tui
ensure
  terminal.restore
end
```
<!-- SPDX-SnippetEnd -->

### Usage: Three APIs (Deprecation Plan)

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# API 1: Beginner-friendly TUI facade (PERMANENT)
# This is the recommended API for most users
RatatuiRuby.run do |tui|
  tui.draw { |frame| ... }
  event = tui.poll_event
  
  # Access the underlying Terminal instance
  puts tui.terminal.viewport_type  # :inline or :fullscreen
  puts tui.terminal.width          # terminal width
  tui.terminal.clear if some_condition
end

# API 2: Direct module methods (DEPRECATED, remove before v1.0.0)
# This API should never have existed and will be removed
RatatuiRuby.init_terminal
RatatuiRuby.draw { |frame| ... }
event = RatatuiRuby.poll_event
RatatuiRuby.restore_terminal

# API 3: Explicit Terminal instance (PERMANENT)
# This is aligned with upstream Ratatui and provides explicit resource management
terminal = RatatuiRuby::Terminal.new(viewport: :inline, height: 10)
terminal.draw { |frame| ... }
event = terminal.poll_event
terminal.restore
```
<!-- SPDX-SnippetEnd -->

**Migration strategy**:
- **API 1** (`RatatuiRuby.run { |tui| }`) remains the primary, beginner-friendly interface
- **API 3** (`Terminal.new`) is the advanced, upstream-aligned interface for explicit control
- **API 2** (module methods like `RatatuiRuby.draw`) exists only for backward compatibility during transition
  - Add deprecation warnings immediately after implementing Terminal
  - Remove completely before v1.0.0 release

### Rust Changes

The Rust implementation needs significant refactoring to support instance-based terminals:

**Current Architecture**:
<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```rust
pub static TERMINAL: Mutex<Option<TerminalWrapper>> = Mutex::new(None);
```
<!-- SPDX-SnippetEnd -->

**New Architecture**:
<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```rust
// Instance tracking
static TERMINAL_INSTANCES: Mutex<HashMap<u64, TerminalWrapper>> = Mutex::new(HashMap::new());
static NEXT_TERMINAL_ID: AtomicU64 = AtomicU64::new(0);

pub fn init_terminal_instance(viewport_type: String, height: Option<u16>) -> Result<u64, Error> {
    let id = NEXT_TERMINAL_ID.fetch_add(1, Ordering::SeqCst);
    let terminal = create_terminal(viewport_type, height)?;
    
    let mut instances = TERMINAL_INSTANCES.lock().unwrap();
    instances.insert(id, terminal);
    Ok(id)
}

pub fn draw_instance(terminal_id: u64, callback: Value) -> Result<(), Error> {
    let mut instances = TERMINAL_INSTANCES.lock().unwrap();
    let terminal = instances.get_mut(&terminal_id)
        .ok_or_else(|| Error::new(error_class, "Terminal instance not found"))?;
    
    match terminal {
        TerminalWrapper::Crossterm(term) => term.draw(|frame| { ... }),
        TerminalWrapper::Test(term) => term.draw(|frame| { ... }),
    }
}
```
<!-- SPDX-SnippetEnd -->

**Module-level methods maintain singleton**:
<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```rust
static DEFAULT_TERMINAL_ID: Mutex<Option<u64>> = Mutex::new(None);

pub fn init_terminal(viewport_type: String, height: Option<u16>) -> Result<(), Error> {
    let id = init_terminal_instance(viewport_type, height)?;
    *DEFAULT_TERMINAL_ID.lock().unwrap() = Some(id);
    Ok(())
}

pub fn draw(callback: Value) -> Result<(), Error> {
    let default_id = DEFAULT_TERMINAL_ID.lock().unwrap()
        .ok_or_else(|| Error::new(error_class, "No default terminal initialized"))?;
    draw_instance(default_id, callback)
}
```
<!-- SPDX-SnippetEnd -->

**Rust-side object instantiation** (Magnus):
<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```rust
pub fn poll_event_instance(terminal_id: u64, timeout: Option<f64>) -> Result<Value, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let module = ruby.define_module("RatatuiRuby")?;
    let event_module = module.const_get::<_, RModule>("Event")?;
    
    match crossterm::event::poll(timeout_duration)? {
        true => match crossterm::event::read()? {
            CrosstermEvent::Key(key_event) => {
                let key_class = event_module.const_get::<_, RClass>("Key")?;
                key_class.new_instance((
                    ("code", extract_key_code(key_event.code)),
                    ("modifiers", extract_modifiers(key_event.modifiers)),
                    ("kind", extract_kind(key_event.kind)),
                ))?.freeze()
            },
            CrosstermEvent::Mouse(mouse_event) => {
                let mouse_class = event_module.const_get::<_, RClass>("Mouse")?;
                mouse_class.new_instance((
                    ("kind", extract_mouse_kind(mouse_event.kind)),
                    ("x", mouse_event.column),
                    ("y", mouse_event.row),
                    ("button", extract_mouse_button(mouse_event.kind)),
                    ("modifiers", extract_modifiers(mouse_event.modifiers)),
                ))?.freeze()
            },
            // ... other event types
        },
        false => {
            let none_class = event_module.const_get::<_, RClass>("None")?;
            none_class.new_instance(())?.freeze()
        }
    }
}

// Similar pattern for Layout::Rect, Buffer::Cell, etc.
pub fn get_viewport_area_instance(terminal_id: u64) -> Result<Value, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let module = ruby.define_module("RatatuiRuby")?;
    let layout_module = module.const_get::<_, RModule>("Layout")?;
    let rect_class = layout_module.const_get::<_, RClass>("Rect")?;
    
    let area = get_terminal_viewport_area(terminal_id)?;
    rect_class.new_instance((
        ("x", area.x),
        ("y", area.y),
        ("width", area.width),
        ("height", area.height),
    ))
}
```
<!-- SPDX-SnippetEnd -->

### Pros

✅ **Full alignment with upstream Ratatui** — Terminal is a first-class object  
✅ **Explicit ownership model** — terminal is a managed resource  
✅ **Supports multiple terminals** (future: testing, headless)  
✅ **Clear lifecycle** — `new`, `draw`, `restore`  
✅ **Non-breaking** — all existing APIs continue to work via singleton delegation  
✅ **Three API tiers** — beginner (TUI), intermediate (module), advanced (instance)  
✅ **MVU-compatible** — `Command.tui(->(tui) { tui.terminal.clear })` provides escape hatch for terminal operations while maintaining Update purity  

### Cons

❌ **Significant Rust refactoring** — requires instance tracking, ID management, and both instance-based FFI methods (`_draw_instance`) and singleton-delegating methods (`_draw`). The global `TERMINAL` mutex must be replaced with an instance registry (`HashMap<u64, TerminalWrapper>`), adding complexity to every terminal operation.  

---

## Verification Plan

### Unit Tests

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# test/test_terminal.rb
class TestTerminal < Minitest::Test
  def setup
    RatatuiRuby.init_test_terminal(80, 24, "fullscreen")
  end

  def teardown
    RatatuiRuby.restore_terminal
  end

  def test_terminal_instance_creation
    terminal = RatatuiRuby::Terminal.new
    assert_instance_of RatatuiRuby::Terminal, terminal
  end

  def test_terminal_size
    terminal = RatatuiRuby::Terminal.new
    size = terminal.terminal_size
    assert_equal 80, size.width
    assert_equal 24, size.height
  end

  def test_viewport_type_fullscreen
    terminal = RatatuiRuby::Terminal.new
    assert_equal :fullscreen, terminal.viewport_type
  end

  def test_tui_terminal_access
    RatatuiRuby.run do |tui|
      assert_instance_of RatatuiRuby::Terminal, tui.terminal
    end
  end

  def test_backward_compatible_module_methods
    # Module methods still work via singleton delegation
    RatatuiRuby.draw { |frame| frame.render_widget(...) }
    event = RatatuiRuby.poll_event
    assert_instance_of RatatuiRuby::Event::None, event
  end
end

# test/test_terminal_inline.rb  
class TestTerminalInline < Minitest::Test
  def setup
    RatatuiRuby.init_test_terminal(80, 24, "inline", 8)
  end

  def teardown
    RatatuiRuby.restore_terminal
  end

  def test_inline_viewport
    terminal = RatatuiRuby::Terminal.new(viewport: :inline, height: 8)
    assert_equal :inline, terminal.viewport_type
  end

  def test_insert_before_works_inline
    terminal = RatatuiRuby::Terminal.new(viewport: :inline, height: 8)
    terminal.insert_before(1, RatatuiRuby::Widgets::Paragraph.new(text: "test"))
    # Should not raise
  end
end
```
<!-- SPDX-SnippetEnd -->

### Integration Tests

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# examples/terminal_instance_demo.rb
require "ratatui_ruby"

# API 3: Direct Terminal instance
terminal = RatatuiRuby::Terminal.new(viewport: :inline, height: 10)

terminal.draw do |frame|
  info = <<~INFO
    Terminal Information:
    - Type: #{terminal.viewport_type}
    - Size: #{terminal.width}x#{terminal.height}
    
    Press 'q' to quit
  INFO
  
  paragraph = RatatuiRuby::Widgets::Paragraph.new(text: info)
  frame.render_widget(paragraph, frame.area)
end

# Insert log above viewport
terminal.insert_before(1, RatatuiRuby::Widgets::Paragraph.new(text: "[LOG] Started"))

loop do
  event = terminal.poll_event
  break if event.key? && event.code == "q"
end

terminal.restore
```
<!-- SPDX-SnippetEnd -->

### Manual Testing Checklist

- [ ] `Terminal.new` creates new instance
- [ ] `terminal.width` and `terminal.height` match expected dimensions
- [ ] `terminal.viewport_type` returns correct mode
- [ ] `tui.terminal` provides access from TUI facade
- [ ] `terminal.insert_before` works in inline mode
- [ ] `terminal.poll_event` returns Event objects
- [ ] `terminal.cursor_position` returns Position object
- [ ] Module methods (`RatatuiRuby.draw`) still work (backward compat)
- [ ] Deprecation warnings appear for module methods

---

## Future Enhancements

### Command.tui Integration

Implement the MVU escape hatch:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
module RatatuiRuby
  module Tea
    module Command
      def self.tui(callable)
        TuiCommand.new(callable)
      end
      
      class TuiCommand < Data.define(:callable)
        def execute(tui)
          callable.call(tui)
          nil
        end
      end
    end
  end
end

# Usage in Update
def update(model, message)
  case message
  when clear_requested
    [model, Command.tui(->(tui) { tui.terminal.clear })]
  end
end
```
<!-- SPDX-SnippetEnd -->



