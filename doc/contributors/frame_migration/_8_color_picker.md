<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Prompt for Staff Engineer: Complete Color Picker Example

You are a Staff Engineer polyglot. You previously attempted to implement a color picker example app but got stuck on the hit-testing problem. Your feedback led to the Frame Migration. The API you needed now exists.

## Context: Your Previous Work

You started `examples/_app_color_picker/` but hit a wall. The problem:

1. You needed to detect mouse clicks on the "Export Formats" section to trigger a copy dialog.
2. To do that, you needed the `Rect` for that section.
3. But `RatatuiRuby.draw(tree)` consumes the tree and computes layout internally—you never saw the actual rects.
4. You worked around it with a `calculate_layout` method that duplicated the layout logic.
5. This was fragile: any mismatch between `render` and `calculate_layout` would break hit-testing.

Your WIP code shows this pattern clearly:

```ruby
def run
  RatatuiRuby.run do
    loop do
      calculate_layout    # <-- Duplicated layout computation
      render
      result = handle_input
      break if result == :quit
    end
  end
end

def calculate_layout
  # Pre-calculate layout regions for hit testing
  # ...manually calling Layout.split to cache @export_area_rect
end

def render
  # Build a tree with Layout.new, which ALSO computes layout internally
  # ...the Layout widgets here don't expose their computed rects
end
```

You abandoned the work with this comment:
> "WIP: This example is under active development and should NOT be used as a reference.
> See doc/contributors/frame_proposal.md for the design discussion.
> This will be restructured once layout_id feature is implemented."

## What Changed: The Frame API

The Frame Migration is complete. You can now do this:

```ruby
RatatuiRuby.draw do |frame|
  input_area, rest = Layout.split(frame.area, ...)
  color_area, control_area = Layout.split(rest, ...)
  harmony_area, @export_area_rect = Layout.split(color_area, ...)
  
  frame.render_widget(build_input_section, input_area)
  frame.render_widget(build_color_section, harmony_area)
  frame.render_widget(build_export_section, @export_area_rect)
  frame.render_widget(build_controls_section, control_area)
end
```

Now `@export_area_rect` comes from the **same** `Layout.split` call that determines rendering—no duplication.

## Your Task

Complete the color picker example using the new Frame API.

### 1. Apply the Patch

Your WIP is in `doc/contributors/frame_migration/color_picker.patch`. Apply it:
```bash
git apply doc/contributors/frame_migration/color_picker.patch
```

### 2. Refactor to Frame API

Convert `examples/_app_color_picker/app.rb`:

- Remove the `calculate_layout` method entirely.
- Replace `RatatuiRuby.draw(ui)` with `RatatuiRuby.draw do |frame| ... end`.
- Move `Layout.split` calls inside the draw block.
- Store rects in instance variables for hit-testing (e.g., `@export_area_rect`).
- Use `frame.render_widget(widget, rect)` for each section.

### 3. Fix Any Build Issues

The WIP was written before the Frame API existed. You may need to:
- Update widget construction if APIs changed.
- Fix any Ruby syntax or style issues.
- Remove the "WIP" warnings since the example is now complete.

### 4. Remove the Skip from Tests

In `test_app.rb`, remove the `skip` statement:
```ruby
def setup
  skip "WIP: App color picker example is under active development..."
  @app = AppColorPickerApp.new
end
```

Ensure all tests pass.

### 5. Rename the Example

The underscore prefix (`_app_color_picker`) was used to hide WIP examples. Rename to `color_picker`:
```bash
mv examples/_app_color_picker examples/color_picker
```

Update any internal references.

## References
- `doc/contributors/frame_migration/color_picker.patch`: Your WIP code.
- `doc/contributors/frame_proposal.md`: The proposal that came from your feedback.
- `examples/frame_demo/app.rb`: Reference implementation of Frame API.
- `examples/hit_test/app.rb`: Another example that was refactored to use Frame.

## Definition of Done

- `examples/color_picker/app.rb` runs successfully.
- No duplicated layout logic—rects come from `Layout.split` inside the draw block.
- Hit-testing (click on Export Formats → copy dialog) works.
- All tests in `test_app.rb` pass (no skip).
- `bundle exec rake` passes.
