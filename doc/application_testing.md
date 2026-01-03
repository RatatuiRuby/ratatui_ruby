<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->
# Application Testing Guide

This guide explains how to test your RatatuiRuby applications using the provided `RatatuiRuby::TestHelper`.

## Overview

You need to verify that your application looks and behaves correctly. Manually checking every character on a terminal screen is tedious. Dealing with race conditions and complex state management in tests creates friction.

The `TestHelper` module solves this. It provides a headless "test terminal" to capture output and a suite of robust assertions to verify state.

Use it to write fast, deterministic tests for your TUI applications.

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

## Writing a View Test

To test a view or widget, wrap your assertions in `with_test_terminal`. This sets up a temporary, in-memory backend for Ratatui to draw to.

1.  **Initialize the terminal:** Call `with_test_terminal`.
2.  **Render your code:** Instantiate your widget and draw it to a frame.
3.  **Assert output:** Check the `buffer_content` against your expectations.

```ruby
def test_rendering
  # Uses default 80x24 terminal
  with_test_terminal do
    # 1. Instantiate your widget
    widget = RatatuiRuby::Paragraph.new(text: "Hello World")
    
    # 2. Render it using the Frame API
    RatatuiRuby.draw do |frame|
      frame.render_widget(widget, frame.area)
    end
    
    # 3. Assert on the output
    assert_includes buffer_content.first, "Hello World"
  end
end
```

For the full API list, including `buffer_content` and `cursor_position`, see [RatatuiRuby::TestHelper::Terminal](../lib/ratatui_ruby/test_helper/terminal.rb).

## Verifying Styles

You often need to check colors and modifiers (bold, italic) to ensure your highlighting logic works.

Use `assert_fg_color`, `assert_bg_color`, and modifier helpers like `assert_bold`.

```ruby
# Assert specific cell style
assert_fg_color(:red, 0, 0)
assert_bold(0, 0)

# Or check a whole area
assert_area_style({ x: 0, y: 0, w: 10, h: 1 }, bg: :blue)
```

See [RatatuiRuby::TestHelper::StyleAssertions](../lib/ratatui_ruby/test_helper/style_assertions.rb) for the comprehensive list of style helpers.

## Simulating Input

You need to test user interactions like typing or clicking. Stubbing `poll_event` directly is brittle.

Use `inject_event` to push mock events into the queue. This ensures safe, deterministic handling of input.

> [!IMPORTANT]
> Call `inject_event` inside a `with_test_terminal` block to avoid race conditions.

```ruby
with_test_terminal do
  # Simulate 'q' key press
  inject_event("key", { code: "q" })

  # The application receives the 'q' event
  event = RatatuiRuby.poll_event
  assert_equal "q", event.code
end
```

See [RatatuiRuby::TestHelper::EventInjection](../lib/ratatui_ruby/test_helper/event_injection.rb) for helper methods like `inject_keys` and `inject_click`.

## Snapshot Testing

Snapshots let you verify complex layouts without manually asserting every line.

Use `assert_snapshot` to compare the current screen against a stored reference file.

```ruby
with_test_terminal do
  MyApp.new.run
  assert_snapshot("dashboard_view")
end
```

### Handling Non-Determinism

Snapshots must be deterministic. Random data or current timestamps will cause test failures ("flakes").

To prevent this:
1.  **Seed Randomness:** Use a fixed seed for any RNG.
2.  **Stub Time:** Force the application to use a static time.

For detailed strategies and code examples, see [RatatuiRuby::TestHelper::Snapshot](../lib/ratatui_ruby/test_helper/snapshot.rb).

## Isolated View Testing

Sometimes you want to test a single view component without spinning up the full `TestTerminal` engine.

Use `MockFrame` and `StubRect` to test render logic in isolation.

```ruby
def test_logs_view
  frame = RatatuiRuby::TestHelper::TestDoubles::MockFrame.new
  area = RatatuiRuby::TestHelper::TestDoubles::StubRect.new(width: 40, height: 10)
  
  # Call your view directly
  MyView.new.render(frame, area)
  
  # Inspect what was rendered
  rendered = frame.rendered_widgets.first
  assert_equal "Logs", rendered[:widget].block.title
end
```

See [RatatuiRuby::TestHelper::TestDoubles](../lib/ratatui_ruby/test_helper/test_doubles.rb).

## Example

Check out the [examples directory](../examples/) for fully tested applications showcasing these patterns.
