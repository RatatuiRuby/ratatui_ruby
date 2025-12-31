<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Prompt for Developer Agent: Create Frame Demo and Refactor Hit Test

You are a polyglot Tech Lead Developer with Ruby, Rust, and Ratatui expertise. Your task is to create a new `frame_demo` example and refactor the existing `hit_test` example to use the Frame API. This proves the migration works end-to-end.

## Context

The Frame Migration is complete:
- `RatatuiRuby.draw { |frame| ... }` yields a Frame object.
- `frame.area` returns terminal dimensions as a `Rect`.
- `frame.render_widget(widget, rect)` renders explicitly.
- `Layout.split(frame.area, ...)` computes rects for both rendering and hit-testing.

Your job is to create a reference example and refactor an existing one.

## Task 1: Create `examples/frame_demo`

Create a new example demonstrating the Frame API.

### File: `examples/frame_demo/app.rb`

**Requirements**:
- Use `RatatuiRuby.run do ... end` for the main loop.
- Use `RatatuiRuby.draw do |frame| ... end` (the new block syntax).
- Use `Layout.split(frame.area, ...)` to divide the terminal into at least two regions.
- Render widgets using `frame.render_widget(widget, rect)`.
- **Hit-Testing Demonstration**:
    - Store a `Rect` in an instance variable (e.g., `@sidebar_rect`).
    - In `handle_input`, check if a mouse click is within `@sidebar_rect.contains?(x, y)`.
    - Respond visibly to the click (e.g., change content, toggle state).

**Suggested Layout**:
- Sidebar (left, fixed width) with a list or simple content.
- Main area (right, fill) that updates when sidebar is clicked.

### File: `examples/frame_demo/test_app.rb`

- Use the test backend (`RatatuiRuby.init_test_terminal`).
- Verify that the draw block renders content to the buffer.
- Verify `frame.area` returns a `Rect` with expected dimensions.
- Optionally test hit-testing by injecting mouse events.

## Task 2: Refactor `examples/hit_test`

The existing `hit_test` example uses a manual `calculate_layout` method to compute rects—duplicating layout logic. Eliminate this duplication.

### Refactor `examples/hit_test/app.rb`

**Before (likely pattern)**:
```ruby
def run
  RatatuiRuby.run do
    loop do
      calculate_layout  # <-- Duplicated layout
      render
      handle_input
    end
  end
end

def calculate_layout
  # Manually compute rects for hit-testing
end

def render
  # Build tree with Layout.new (also computes layout internally)
  RatatuiRuby.draw(tree)
end
```

**After (target pattern)**:
```ruby
def run
  RatatuiRuby.run do
    loop do
      render
      handle_input
    end
  end
end

def render
  RatatuiRuby.draw do |frame|
    @left_rect, @right_rect = Layout.split(frame.area, ...)
    frame.render_widget(left_widget, @left_rect)
    frame.render_widget(right_widget, @right_rect)
  end
end
```

**Key Changes**:
- Delete `calculate_layout` method entirely.
- Replace `RatatuiRuby.draw(tree)` with `RatatuiRuby.draw { |frame| ... }`.
- Use `Layout.split` inside the block and store results for hit-testing.
- Hit-testing logic should still work with the stored rects.

### Update Tests (if present)

- Ensure `test_app.rb` passes after refactoring.
- Verify hit-testing behavior is preserved.

## References
- `doc/contributors/frame_proposal.md`: Frame API design and examples.
- `doc/contributors/frame_migration.md`: Migration plan and Definition of Done.
- Existing examples in `examples/` for patterns.

## Definition of Done

- `examples/frame_demo/app.rb` exists and runs successfully.
- `examples/frame_demo/test_app.rb` exists and passes.
- `examples/hit_test/app.rb` uses the Frame API exclusively.
- No duplicated layout calculation in `hit_test` (no `calculate_layout` method).
- All tests pass: `bundle exec rake test`.
