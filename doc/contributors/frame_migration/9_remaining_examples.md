<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Phase 9: Migrate Remaining Examples to Frame API

**Status:** Not Started

**Goal:** Refactor all remaining examples (20+) to use the new Frame-Based API, ensuring consistency across the example suite.

## Context

The Frame API migration (Phases 1-8) established the new `RatatuiRuby.draw { |frame| ... }` pattern and demonstrated it with documentation examples (quickstart, readme) and showcase examples (color_picker, hit_test, frame_demo).

This phase addresses the remaining 20+ examples that continue to use the legacy `RatatuiRuby.draw(tree)` API.

## Target Examples

All examples currently using `RatatuiRuby.draw(tree)` with a widget tree:

- `examples/all_events`
- `examples/analytics`
- `examples/box_demo`
- `examples/calendar_demo`
- `examples/chart_demo`
- `examples/flex_layout`
- `examples/gauge_demo`
- `examples/line_gauge_demo`
- `examples/list_demo`
- `examples/list_styles`
- `examples/login_form`
- `examples/map_demo`
- `examples/mouse_events`
- `examples/popup_demo`
- `examples/ratatui_logo_demo`
- `examples/ratatui_mascot_demo`
- `examples/rich_text`
- `examples/scroll_text`
- `examples/scrollbar_demo`
- `examples/sparkline_demo`
- `examples/table_flex`
- `examples/table_select`
- `examples/widget_style_colors`
- `examples/custom_widget`

## Migration Strategy

### Step 1: Categorize Examples

Divide examples by complexity:

1. **Simple (single widget):** Use `frame.render_widget(widget, frame.area)`.
2. **Layout-based (multi-widget):** Use `Layout.split(frame.area, ...)` to compute regions.
3. **Complex (dynamic layout):** May require multiple layout phases or conditional rendering.

### Step 2: Batch Refactoring

- **Batch A (Simple):** All examples with a single main widget.
- **Batch B (Layout):** Examples using explicit Layout widgets.
- **Batch C (Complex):** Examples with intricate layout logic.

### Step 3: Per-Example Refactoring

For each example:

1. Read `app.rb` to understand the current widget tree.
2. Identify the root widget(s) and layout structure.
3. Replace `RatatuiRuby.draw(tree)` with `RatatuiRuby.draw { |frame| ... }`.
4. Use `Layout.split` if needed; otherwise, render directly to `frame.area`.
5. Update `test_app.rb` to pass.
6. Verify rendering output is identical.

## Expected Outcomes

- All examples use the Frame API consistently.
- No examples use the legacy `RatatuiRuby.draw(tree)` pattern.
- Example tests remain comprehensive and passing.
- Codebase is internally consistent and easier to maintain.

## Definition of Done

- ✅ All 24 remaining examples migrated to Frame API.
- ✅ All example tests pass.
- ✅ `bin/agent_rake` passes with zero errors/warnings.
- ✅ Example rendering output verified to match pre-migration behavior.
