<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Prompt for Conversion Agent: Migrate Documentation Examples

You are a Senior Ruby Developer. Your task is to convert all documentation-verification examples to use the new Frame-based API. This serves as a comprehensive integration test of the Frame Migration work.

## Context

The Frame Migration is complete. Previous agents implemented:
- `RatatuiRuby.draw { |frame| ... }` with a `Frame` object.
- `frame.area` returns terminal dimensions.
- `frame.render_widget(widget, rect)` renders explicitly.
- `Layout.split(frame.area, ...)` computes layout rects.

According to `doc/contributors/example_analysis.md`, there are three categories of examples. You are converting **Category 3: Documentation-Verification Examples**—these are verbatim copies of documentation code that must be kept in sync.

## Target Examples

Convert these examples from the legacy `RatatuiRuby.draw(tree)` API to the new Frame-based API:

1. **`examples/quickstart_lifecycle`** - Lifecycle example from README/quickstart docs.
2. **`examples/quickstart_dsl`** - DSL-style example from quickstart docs.
3. **`examples/readme_usage`** - Simple "Hello, Ratatui!" example from README.

## Why These Examples?

Documentation-verification examples are ideal for conversion testing because:
- They represent the simplest, most canonical usage patterns.
- If Frame works for these, it works for users following the docs.
- Any conversion issues here indicate problems with the migration.

## Conversion Pattern

**Before (Legacy)**:
```ruby
RatatuiRuby.draw(
  RatatuiRuby::Layout.new(
    direction: :vertical,
    children: [widget_a, widget_b]
  )
)
```

**After (Frame-Based)**:
```ruby
RatatuiRuby.draw do |frame|
  top, bottom = RatatuiRuby::Layout.split(
    frame.area,
    direction: :vertical,
    constraints: [...]
  )
  frame.render_widget(widget_a, top)
  frame.render_widget(widget_b, bottom)
end
```

## Task Steps

For each example:

### 1. Understand the Current Implementation

- Read the current `app.rb` and understand what it renders.
- Identify the widget tree structure.
- Note any layout constraints (explicit or implicit).

### 2. Convert to Frame API

- Replace `RatatuiRuby.draw(tree)` with `RatatuiRuby.draw { |frame| }`.
- Use `Layout.split` to compute the same layout the tree would produce.
- Use `frame.render_widget` for each widget.
- For simple single-widget examples, use `frame.render_widget(widget, frame.area)`.

### 3. Update Tests

- Ensure `test_app.rb` still passes after conversion.
- If tests rely on specific rendering output, verify it matches.

### 4. Update Documentation

- **Critical**: Since these examples are documentation-verification, the source documentation (README.md, quickstart.md, etc.) must also be updated to show the new Frame-based API.
- Find the corresponding documentation file.
- Update the code snippets to match the converted example.

## References
- `doc/contributors/example_analysis.md`: Example categories and purposes.
- `doc/contributors/frame_proposal.md`: Frame API usage patterns.
- `examples/frame_demo/app.rb`: Reference implementation of Frame API (created in Phase 4).
- `README.md`: May contain code snippets that need updating.
- `doc/user_guides/quickstart.md` (or similar): May contain snippets that need updating.

## Definition of Done

- All three documentation-verification examples use the Frame-based API.
- All example tests pass.
- Corresponding documentation is updated with matching code snippets.
- `bundle exec rake` passes.
- Running each example works correctly.
