<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Example Analysis

The `examples/` directory contains examples in three distinct categories, each serving a different purpose.

## Category 1: Widget Showcases

Single-widget (or widget-focused) examples that exhaustively demonstrate a widget's configuration options through interactive attribute cycling.

These examples follow the pattern described in `developing_examples.md`: they expose all major widget parameters as hotkey-controllable options so users can interactively explore the behavior. They render at most two widgets side-by-side or vertically stacked for comparison purposes, all in service of the primary widget.

**Examples:**
- `box_demo`: Demonstrates Block widget variations (border types, styles, padding, titles).
- `gauge_demo`: Demonstrates Gauge with adjustable ratio, color, Unicode flag, and label modes.
- `list_demo`: Demonstrates List with items, highlight styles, symbols, spacing, direction, and scroll padding.
- `line_gauge_demo`: Demonstrates LineGauge widget attributes.
- `sparkline_demo`: Demonstrates Sparkline with direction, style, absent value markers, and bar sets.
- `scrollbar_demo`: Demonstrates Scrollbar with orientation and theme cycling.
- `chart_demo`: Demonstrates Chart widget attributes.
- `calendar_demo`: Demonstrates Calendar widget.
- `cell_demo`: Demonstrates Cell widget.
- `block_titles`: Demonstrates Block title positioning and alignment.
- `block_padding`: Demonstrates Block padding (uniform and directional).
- `color_picker`: Interactive tool for picking colors, generating palettes, and copying hex codes.
- `ratatui_logo_demo`: Demonstrates RatatuiLogo with style cycling.
- `ratatui_mascot_demo`: Demonstrates RatatuiMascot with style cycling.
- `list_styles`: Demonstrates List styling variations.
- `popup_demo`: Demonstrates Popup widget positioning and behavior.
- `rich_text`: Demonstrates styling via `Text::Span` and `Text::Line` objects.
- `scroll_text`: Demonstrates text scrolling behavior.
- `table_flex`: Demonstrates Table widget with flexible layouts.
- `widget_style_colors`: Demonstrates hex color gradients and style modifiers.

## Category 2: Real-Application Showcases

Examples that function as proof-of-concept TUI applications, demonstrating how to build moderately complex, interactive programs.

These are not API documentation—they do not systematically cycle through all widget parameters. Instead, they showcase composing multiple widgets to solve realistic problems (dashboards, forms, data views). They serve as inspiration for developers building their own applications and do not strictly follow the single-focus pattern.

**Examples:**
- `analytics`: Multi-widget analytics dashboard with Tabs and BarChart, demonstrating tab navigation and multi-chart layouts.
- `login_form`: Form UI with text input, cursor positioning, and popup feedback using Paragraph, Overlay, Center, and Cursor.
- `table_select`: Interactive table viewer with row/column selection, simulating a process monitor application.
- `hit_test`: Demonstrates layout caching pattern for hit testing with split panels and mouse interaction.
- `map_demo`: Canvas-based world map visualization with animated shapes and interactive marker cycling.
- `mouse_events`: Multi-panel event display app showcasing all mouse event types.
- `all_events`: Multi-panel dashboard displaying all event types (key, mouse, resize, paste, focus).
- `flex_layout`: Layout demo showcasing Layout flex modes (space_between, space_evenly, fill, ratio).
- `frame_demo`: Interactive hit-testing dashboard demonstrating `Layout.split` and frame rendering.
- `custom_widget`: Demonstrates custom widget implementation with a diagonal line widget.

## Category 3: Documentation-Verification Examples

Examples that are verbatim copies (or near copies) of code snippets from documentation files, added to the `examples/` directory to ensure they remain executable and don't rot.

These serve as automated documentation tests: if the example code changes but the documentation does not, tests will fail and reveal the inconsistency.

**Examples:**
- `quickstart_lifecycle`: Copy of the lifecycle example from `README.md` or quickstart documentation.
- `quickstart_layout`: Copy of the layout example from quickstart documentation.
- `quickstart_dsl`: Copy of the DSL-style example from quickstart documentation.
- `readme_usage`: Copy of the simple "Hello, Ratatui!" example from `README.md`.

## TODO

- [x] **Establish a naming prefix convention** to disambiguate categories alphabetically without requiring subdirectories. Suggested prefixes:
  - `app_` (application): `app_analytics`, `app_login_form`, etc.
  - `verify_` (doc/documentation): `verify_quickstart_lifecycle`, `verify_readme_usage`, etc.
  - `widget_` (widget showcase): `widget_gauge_demo`, `widget_list_demo`, etc.
  - Apply this retroactively to all examples via directory renames (includes renaming screenshots in `doc/images/`, updating markdown image references in documentation, updating links in markdown files, and ensuring the `ExampleApp.all` list reflects the new names).

- [x] **Update Quickstart** to reduce the heading levels of individual examples, inserting a new heading level above them and below "## Examples". This new heading level should map to the naming conventions, and this will require recategorizing the examples in quickstart.md.

- [ ] **Split `analytics`** (demonstrates both Tabs and BarChart interactively). Create `widget_tabs_demo` and move BarChart demo to it, or extract BarChart into its own single-widget showcase.

- [ ] **Split `all_events`** (demonstrates multiple event types in a 2×2 grid). Consider extracting each event type into its own single-widget panel, or clarify whether this remains a "showcase of everything" vs. a focused event-demo.

- [ ] **Split `flex_layout`** (demonstrates Layout flex modes with multiple examples). This is borderline—it's quasi-documentation-verification of Layout behavior. Consider whether it belongs as `verify_flex_layout` or if it should remain as a showcase.

- [ ] **Reassign `mouse_events`**: Currently straddles Category 2 (real app) and Category 3 (doc verification). Clarify its purpose: is it an app showcase or documenting mouse event structure? If doc-verification, move to Category 3 and rename to `verify_mouse_events`.

- [ ] **Reassign `hit_test`**: Currently categorized as Category 2 but serves partly to document the "Cached Layout Pattern". Consider renaming to `verify_hit_test` if it should be documentation-verification, or ensure it's purely a showcase of an application pattern.

- [ ] **Verify `custom_widget`**: Currently Category 2 (real app), but is it actually a documented pattern or example code? If it's meant to verify custom widget documentation, rename to `verify_custom_widget`.
- [ ] **Verify `frame_demo`**: Currently Category 2 (real app), but heavily used to explain caching/hit-testing. Decide if it should be `verify_frame_rendering`.

- [ ] **Update documentation** (developing_examples.md) to reflect the new naming convention and clarify which category each example should belong to.
