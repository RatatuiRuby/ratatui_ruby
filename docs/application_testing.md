# Application Testing Guide

This guide explains how to test your RatatuiRuby applications using the provided `RatatuiRuby::TestHelper`.

## Overview

RatatuiRuby includes a `TestHelper` module designed to simplify unit testing of TUI applications. It allows you to:

- Initialize a virtual "test terminal" with specific dimensions.

- Capture the rendered output (the "buffer") to assert against expected text.

- Inspect the cursor position.

- Simulate user input (using `RatatuiRuby.stub` or similar mocking techniques for `poll_event`).

## Setup

First, require the test helper in your test file or `test_helper.rb`:

```ruby
require "ratatui_ruby/test_helper"
require "minitest/autorun" # or your preferred test framework
```

Then, include the module in your test class:

```ruby
class MyApplicationTest < Minitest::Test
  include RatatuiRuby::TestHelper
  # ...
end
```

## Basic Usage

### `with_test_terminal`

Wrap your test assertions in `with_test_terminal`. This sets up a temporary, in-memory backend for Ratatui to draw to, instead of the real terminal. It automatically cleans up afterwards.

```ruby
def test_rendering
  # Create a 80x24 terminal
  with_test_terminal(80, 24) do
    # 1. Instantiate your app/component
    widget = RatatuiRuby::Paragraph.new(text: "Hello World")
    
    # 2. Render it
    RatatuiRuby.draw(widget)
    
    # 3. Assert on the output
    assert_includes buffer_content[0], "Hello World"
  end
end
```

### `buffer_content`

Returns the current state of the terminal as an Array of Strings. Useful for verifying that specific text appears where you expect it.

```ruby
rows = buffer_content
assert_equal "Title", rows[0].strip
assert_match /Results: \d+/, rows[2]
```

### `cursor_position`

Returns the current cursor coordinates as `{ x: Integer, y: Integer }`. Useful for forms or ensuring focus is correct.

```ruby
pos = cursor_position
assert_equal 5, pos[:x]
assert_equal 2, pos[:y]
```

## Testing Interactions

Since `RatatuiRuby.poll_event` blocks waiting for input, you typically want to mock or stub it in tests to simulate key presses immediately.

Using Minitest's built-in `stub`:

```ruby
def test_quit_on_q
  # Simulate 'q' key press
  RatatuiRuby.stub :poll_event, { code: "q", type: :key } do
    # Run your app's input handling logic
    # app.handle_input ...
  end
end
```

## Example

Be sure to check out the [examples directory](../examples/) in the repository, which contains several fully tested example applications showcasing these patterns.
