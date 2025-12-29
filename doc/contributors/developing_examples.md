<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Developing Examples

Guidelines for creating and testing examples in the `examples/` directory.

## Example Structure

Every interactive example should follow this pattern:

```ruby
class MyExampleApp
  def initialize
    # Initialize state
  end

  def run
    RatatuiRuby.init_terminal
    begin
      loop do
        render
        break if handle_input == :quit
      end
    ensure
      RatatuiRuby.restore_terminal
    end
  end

  private

  def render
    # Build and draw UI
    RatatuiRuby.draw(layout)
  end

  def handle_input
    event = RatatuiRuby.poll_event
    # Process event, return :quit to exit
  end
end

MyExampleApp.new.run if __FILE__ == $PROGRAM_NAME
```

### Key Requirements

1. **Only `run` should be public.** All other methods (`render`, `handle_input`, helper methods) must be private. This prevents tests from calling internal methods directly.

2. **The `run` method contains the main loop.** It initializes the terminal, loops on render/input, and restores the terminal in an ensure block.

3. **Use keyboard keys to cycle through widget attributes.** Users should be able to interactively explore all widget options. Common patterns:
   - Arrow keys: Navigate or adjust values
   - Letter keys: Cycle through styles, modes, or variants
   - Space: Toggle or select
   - `q` or Ctrl+C: Quit

## Testing Examples

Example tests live alongside examples as `test_*.rb` files.

### Testing Pattern

```ruby
require "test_helper"
require_relative "my_example"

class TestMyExample < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = MyExampleApp.new
  end

  def test_initial_render
    with_test_terminal(80, 24) do
      inject_key(:q)  # Queue quit event
      @app.run        # Run the app loop
      
      content = buffer_content
      assert_includes content[0], "Expected Text"
    end
  end

  def test_keyboard_interaction
    with_test_terminal(80, 24) do
      inject_key("s")  # Press 's' to cycle something
      inject_key(:q)   # Then quit
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Changed State"
    end
  end
end
```

### Testing Guidelines

1. **Inject events, observe buffer.** Tests should only interact through:
   - `inject_key` / `inject_keys` / `inject_event` for input
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
