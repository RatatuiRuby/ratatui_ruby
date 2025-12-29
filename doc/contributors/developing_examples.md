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

3. **Use keyboard keys to cycle through widget attributes.** Users should be able to interactively explore all widget options. Common patterns:
    - Arrow keys: Navigate or adjust values
    - Letter keys: Cycle through styles, modes, or variants. Prefer all lowercase keys to avoid confusion and simplify the UI description.
    - Space: Toggle or select
    - `q` or Ctrl+C: Quit

    ## Control Sidebar Pattern

    For examples with multiple interactive controls, display a **sidebar (30% width)** on the right side of the screen showing:
    - Current values of all settings
    - Hotkey documentation organized by feature area
    - Bold section headers for clarity

    This pattern provides discoverable, self-documenting examples.

    ### Sidebar Layout Structure

    ```ruby
    # 70% main content on left
    main_content = RatatuiRuby::Paragraph.new(...)

    # 30% sidebar on right with controls
    sidebar = RatatuiRuby::Block.new(
    title: "Controls",
    borders: [:all],
    children: [
    RatatuiRuby::Paragraph.new(
     text: [
       RatatuiRuby::Text::Line.new(spans: [
         RatatuiRuby::Text::Span.new(
           content: "SECTION NAME",
           style: RatatuiRuby::Style.new(modifiers: [:bold])
         )
       ]),
       "key: Description (#{current_value})",
       "another: Something else",
       "",
       RatatuiRuby::Text::Line.new(spans: [...]),
       # ... more sections ...
     ].flatten
    )
    ]
    )

    # Combine in horizontal layout
    layout = RatatuiRuby::Layout.new(
    direction: :horizontal,
    constraints: [
    RatatuiRuby::Constraint.new(type: :percentage, value: 70),
    RatatuiRuby::Constraint.new(type: :percentage, value: 30),
    ],
    children: [main_content, sidebar]
    )
    ```

    ### Storing Styled Options with Names

    For cycling through options (styles, dividers, modes), structure state as arrays of hashes with a `name` field:

    ```ruby
    def initialize
    @styles = [
    { name: "Yellow Bold", style: RatatuiRuby::Style.new(fg: :yellow, modifiers: [:bold]) },
    { name: "Italic Blue on White", style: RatatuiRuby::Style.new(fg: :blue, bg: :white, modifiers: [:italic]) },
    ]
    @style_index = 0

    @dividers = [
    { name: " | ", divider: " | " },
    { name: " • ", divider: " • " },
    ]
    @divider_index = 0
    end

    def render
    current_style = @styles[@style_index]
    current_divider = @dividers[@divider_index]

    # Use in sidebar:
    "s: Style",
    "  #{current_style[:name]}",
    "d: Divider (#{current_divider[:name]})",
    end
    ```

    This approach keeps the display name and the actual value together, making it easy to show both in the UI.

    ### Hit Testing with the Cached Layout Pattern

    Examples with mouse interaction should implement the **Cached Layout Pattern** documented in `doc/interactive_design.md`. The `hit_test` example demonstrates this pattern.

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
    with_test_terminal(80, 24) do
      inject_key(:q)  # Queue quit event
      @app.run        # Run the app loop
      
      content = buffer_content.join("\n")
      assert_includes content, "Expected Text"
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
