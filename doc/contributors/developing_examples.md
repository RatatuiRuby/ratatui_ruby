<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Developing Examples

Guidelines for creating and testing examples in the `examples/` directory.

## Example Structure

Every interactive example should follow this pattern, living in its own directory:

`examples/my_example/app.rb`:
```ruby
$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

class MyExampleApp
  def initialize
    # Initialize state
  end

  def run
    RatatuiRuby.run do
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private

  def render
    RatatuiRuby.draw do |frame|
      # 1. Split layout
      layout = RatatuiRuby::Layout.split(frame.area, constraints: [RatatuiRuby::Constraint.fill(1)])
      # 2. Render widgets
      frame.render_widget(widget, layout[0])
    end
  end

  def handle_input
    event = RatatuiRuby.poll_event
    case event
    in { type: :key, code: "q" }
      :quit
    in { type: :key, code: code }
      # Handle other keys
    end
  end
end

MyExampleApp.new.run if __FILE__ == $PROGRAM_NAME
```

### Naming Convention (Required)

Example classes **must** follow the naming convention:
- **Directory:** `examples/my_example/` (snake_case)
- **Class:** `MyExampleApp` (PascalCase with `App` suffix)

The class name is derived from the directory name: `my_example` → `MyExampleApp`.

This convention enables the `terminal_preview:update` rake task to automatically capture terminal output for all examples without maintaining a manual registry.

### Terminal Size Constraint

All interactive examples must fit within an **80×24 terminal** (standard VT100 dimensions). This ensures:
- Examples work on minimal terminal configurations
- Tests can use the default `with_test_terminal` size (80x24)
- Examples remain discoverable and self-documenting through visible hotkey help

**Layout pattern for 80×24:**
- **Bottom control panel:** Allocate ~5-7 lines at bottom for a full-width control block with hotkey documentation. Style hotkeys with **bold and underline** to make them discoverable. Use double-space or pipe separators to compress multiple controls per line. This keeps all UI text at full readability while maximizing space for the main content area.

**Best practices:**
- Use descriptive names (e.g., "Yellow on Black" not "Yellow") so controls are self-documenting and discoverable.
- **Style hotkeys visually:** Use `modifiers: [:bold, :underlined]` on hotkey letters to make them stand out from descriptions. Example: `i` (bold, underlined) followed by `Items`.
- Test early by running the example at 80×24 and verifying all content is visible without wrapping, scrolling, or clipping.

Every example must also have an RBS file documenting its public methods:

`examples/my_example/app.rbs`:
```rbs
class MyExampleApp
  # @public
  def self.new: () -> MyExampleApp

  # @public
  def run: () -> void
end
```

### Key Requirements

1. **Only `run` should be public.** All other methods (`render`, `handle_input`, helper methods) must be private. This prevents tests from calling internal methods directly.

2. **Use `RatatuiRuby.run` for terminal management.** Never call `init_terminal` or `restore_terminal` directly. The `run` block handles terminal setup/teardown automatically and safely, even if an exception occurs.

3. **Event handling must include a catch-all pattern.** When using pattern matching in `handle_input`, always include an `else` clause at the end to catch unmatched events (mouse events, resize events, focus events, etc.). Without it, unmatched events will raise `NoMatchingPatternError`:

   ```ruby
   def handle_input
     event = RatatuiRuby.poll_event
     case event
     in { type: :key, code: "q" }
       :quit
     in { type: :mouse, kind: "down", x:, y: }
       handle_click(x, y)
     end
   end
   ```

4. **Use keyboard keys to cycle through widget attributes.** Users should be able to interactively explore all widget options. Common patterns:
    - Arrow keys: Navigate or adjust values
    - Letter keys: Cycle through styles, modes, or variants. Prefer all lowercase keys to avoid confusion and simplify the UI description.
    - Space: Toggle or select
    - `q` or Ctrl+C: Quit

5. **Naming Conventions for Controls**

When documenting hotkeys and cycling options in the UI, use consistent naming:

- **Parameter names:** Always match the actual Ruby parameter name. For example:
  - Use "Scroll Padding" (not "Scroll Pad") for the `scroll_padding:` parameter
  - Use "Highlight Style" (not "Highlight") for the `highlight_style:` parameter
  - Use "Repeat Symbol" (not "Repeat") for the `repeat_highlight_symbol:` parameter
  
- **Display names for cycled values:** Create a `name` field in your options hash to keep display names paired with values:
  ```ruby
  @styles = [
    { name: "Yellow Bold", style: RatatuiRuby::Style.new(fg: :yellow, modifiers: [:bold]) },
    { name: "Blue on White", style: RatatuiRuby::Style.new(fg: :blue, bg: :white) }
  ]
  
  # In controls: "h: Highlight Style (#{@styles[@style_index][:name]})"
  # Outputs: "h: Highlight Style (Yellow Bold)"
  ```

This keeps the UI self-documenting and users can see exact parameter names when they read the hotkey help.

6. **Hit Testing**

Examples with mouse interaction should use the **Frame API**. By calling `Layout.split` inside `RatatuiRuby.draw`, you obtain the exact `Rect`s used for rendering. Store these rects in instance variables (e.g., `@sidebar_rect`) to use them in your `handle_input` method for hit testing:

```ruby
if @sidebar_rect&.contains?(event.x, event.y)
  # Handle click
end
```

## Testing Examples

Example tests live alongside examples as `test_app.rb` files in the same directory.

### Testing Pattern

`examples/my_example/test_app.rb`:
```ruby
$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestMyExampleApp < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = MyExampleApp.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)  # Queue quit event
      @app.run        # Run the app loop
      
      content = buffer_content.join("\n")
      assert_includes content, "Expected Text"
    end
  end

  def test_keyboard_interaction
    with_test_terminal do
      inject_key("s")  # Press 's' to cycle something
      inject_key(:q)   # Then quit
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Changed State"
    end
  end

  def test_mouse_interaction
    with_test_terminal do
      # Click at (10, 5)
      inject_click(x: 10, y: 5)
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Clicked at (10, 5)"
    end
  end
end
```

### Testing Guidelines

1. **Inject events, observe buffer.** Tests should only interact through:
   - `inject_key`, `inject_click`, `inject_event`, etc. for input
   - `buffer_content` for output verification

2. **Never call internal methods.** Don't call `render`, `handle_input`, `__send__`, or access instance variables with `instance_variable_get`. Tests verify behavior through the public `run` method.

3. **Use `inject_key(:q)` to exit.** All examples should support quitting with `q`, so inject this as the final event to terminate the loop.

4. **Assert and refute.** When testing which item was clicked/selected, also verify the opposite didn't happen:
   ```ruby
   assert_includes content, "Left Panel clicked"
   refute_includes content, "Right Panel clicked"
   ```

5. **Test state cycling.** If an example cycles through options (styles, modes, etc.), test that pressing the key actually changes the rendered output.

## Widget Attribute Cycling

Examples should demonstrate widget configurability by allowing interactive cycling:

| Widget | Attribute | Key Suggestion |
|--------|-----------|----------------|
| Tabs | highlight_style | Space |
| Tabs | divider | d |
| Tabs | style | s |
| Block | border_type | Space |
| Block | border_color | c |
| List | highlight_style | Space |
| Sparkline | direction | d |
| Scrollbar | orientation | o |
| Scrollbar | theme | s |

Display the current state in the UI (e.g., in a title or status bar or paragraph) so users can see what changed. Display the hotkey in the UI as well, so users can see how to change it; the hotkey should not disappear as app state changes.
