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
- `widget_tabs_demo`: Demonstrates Tabs widget with interactive attribute cycling.
- `widget_barchart_demo`: Demonstrates BarChart widget with interactive attribute cycling.
- `widget_layout_split`: Demonstrates Layout.split with interactive direction, flex, and constraint cycling.

## Category 2: Real-Application Showcases

Examples that function as proof-of-concept TUI applications, demonstrating how to build moderately complex, interactive programs.

These are not API documentation—they do not systematically cycle through all widget parameters. Instead, they showcase composing multiple widgets to solve realistic problems (dashboards, forms, data views). They serve as inspiration for developers building their own applications and do not strictly follow the single-focus pattern.

**Examples:**
- `login_form`: Form UI with text input, cursor positioning, and popup feedback using Paragraph, Overlay, Center, and Cursor.
- `table_select`: Interactive table viewer with row/column selection, simulating a process monitor application.
- `hit_test`: Demonstrates layout caching pattern for hit testing with split panels and mouse interaction.
- `map_demo`: Canvas-based world map visualization with animated shapes and interactive marker cycling.
- `mouse_events`: Multi-panel event display app showcasing all mouse event types.
- `all_events`: Multi-panel dashboard displaying all event types (key, mouse, resize, paste, focus).
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

- [x] **Split `analytics`** (demonstrates both Tabs and BarChart interactively). Create `widget_tabs_demo` and move BarChart demo to it, and extract BarChart into its own single-widget showcase.

- [x] **`all_events` and `mouse_events`** (demonstrates multiple event types in a 2×2 grid). Combine these, and make sure it has a showcases EVERY event class (as more have been added).

- [x] **Split `flex_layout`** (demonstrates Layout flex modes with multiple examples). This is borderline—it's quasi-documentation-verification of Layout behavior. Consider whether it belongs as `verify_flex_layout` or if it should remain as a showcase.o `widget_layout_split`. Instead of statically demonstrating a set of flex modes, it should use the interactive pattern to have hotkeys that cycle through ALL Layout.split parameters and options.

- [ ] **`hit_test` and `frame_demo`**: Combine these as `app_hit_testing` and make it the mother of all hit testing / layout caching / etc. patterns.

- [ ] **`custom_widget`**: Currently Category 2 (real app), but it is actually a widget demonstration for the polymorphic `render` method custom widget pattern. Rename to `widget_render` and add more custom widgets the user can cycle through with hotkeys.

- [ ] **Update documentation** (developing_examples.md) Widget-only examples should be reduced to a bulletd list with links to each widget's class. The screenshot and information about the example from the quickstart should be moved to the class's RDoc documentation.
