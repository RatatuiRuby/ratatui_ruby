<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->
# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [Unreleased]

### Added

- **LineGauge Style**: Added `style` parameter to `LineGauge` widget, allowing a base style to be applied to the entire gauge area. This complements the existing `filled_style` and `unfilled_style` parameters.

- **Cached Layout Pattern**: Documented in `doc/interactive_design.md`, a canonical design for immediate-mode UI. Solve the layout duplication problem by calculating geometry once per frame (before rendering and event handling), then reusing the cached `Rect` objects everywhere. Three-phase lifecycle: `calculate_layout`, `render`, `handle_input`. Forms the foundation for Component architecture in Gem 1.5 where layout caching is automated.
- **Example Sidebars**: Refactored interactive examples (`box_demo`, `list_styles`, `table_select`, `hit_test`, `stock_ticker`, `system_monitor`, `scroll_text`, `dashboard`) to display hotkey controls and current settings in a sidebar, following the pattern introduced in the `analytics` example. This provides consistent, discoverable documentation of interactive features within each example.
- **Block Children**: Added `children` parameter to `Block` widget, enabling declarative composition of child widgets within the block's area. This allows nested UI structures like `Block.new(children: [Paragraph.new(...)])` for more ergonomic view composition.
- **Typed Event API**: `RatatuiRuby.poll_event` now returns rich, typed Ruby objects instead of raw Hashes. The new event classes (`Event::Key`, `Event::Mouse`, `Event::Resize`, `Event::Paste`, `Event::FocusGained`, `Event::FocusLost`) provide predicate methods (`key?`, `mouse?`, `ctrl?`, etc.), pattern matching support, and direct Symbol/String comparison for cleaner event handling code.
- **Table Highlight Spacing**: Added `highlight_spacing` parameter to `Table` widget, accepting `:always`, `:when_selected`, or `:never`. This controls whether the selection column is reserved or hidden when no row is selected.
- **List Highlight Spacing**: Added `highlight_spacing` parameter to `List` widget, accepting `:always`, `:when_selected`, or `:never`. This controls whether the selection column is reserved when no item is selected.
- **Table**: Added `column_spacing` support ([#gap-analysis](https://github.com/kerricklong/ratatui_ruby/issues/21)).
- **Canvas**: Added `background_color` property to `Canvas` widget ([#gap-analysis](https://github.com/kerricklong/ratatui_ruby/issues/21)).
- **Tabs Style**: Added `style` parameter to `Tabs` widget, allowing a base style to be applied to the entire tabs area.
- **BarChart Direction**: Added `direction` parameter to `BarChart` widget, accepting `:vertical` (default) or `:horizontal`.
- **BarChart Styling**: Added `label_style` and `value_style` support to `BarChart`, matching Ratatui 0.30's improved chart styling capabilities.
- **Tabs Padding**: Added `padding_left` and `padding_right` parameters to `Tabs` widget, enabling horizontal padding around the tab titles.
- **Sparkline Direction**: Added `direction` parameter to `Sparkline` widget, accepting `:left_to_right` (default) or `:right_to_left`.
- **Resize Events**: The event system now exposes terminal resize events via `Event::Resize`, which includes `width` and `height` attributes for building responsive layouts.
- **Paste Events**: Bracketed paste is now surfaced via `Event::Paste(content:)`, enabling safe handling of pasted text as a single atomic event.
- **Focus Events**: Terminal focus changes are now surfaced via `Event::FocusGained` and `Event::FocusLost` for terminals that support it (e.g., iTerm2, Kitty).
- **Event Discriminator Pattern**: Implementation of a discriminator pattern for events via a `type:` key in `#deconstruct_keys`. This enables more concise and idiomatic Ruby 3.0+ pattern matching (e.g., `in type: :key, code: "q"`). All existing subclasses (`Key`, `Mouse`, `Resize`, `Paste`, `FocusGained`, `FocusLost`) now support this pattern.
- **Block Title Styling**: Adds `title_style` to the `Block` widget. This paints a default style across all titles. Each entry in the `titles` array can also carry its own `style`.
- **Block Titles**: Adds multiple titles with individual alignment and positioning (top/bottom) via the `titles` array.
- **Block Style**: Added `style` parameter to `Block` widget. **Note:** This inserts a new member into the `Block` Data object, which changes the positional order of members. Pattern matching or positional initialization of `Block` is affected.
- **List Direction**: Added `direction` attribute (`:top_to_bottom` or `:bottom_to_top`) to `List` widget.
- **Table Footer**: The `Table` widget now supports a `footer` parameter, allowing for summary rows at the bottom of the table.
- **Table Style**: The `Table` widget now supports a `style` parameter, which applies a base style to the entire table area.
- **Block Padding**: `Block` widget now supports correct padding via the `padding` parameter, accepting either a single integer for uniform padding or an array of 4 integers for directional padding (`[left, right, top, bottom]`).
- **Block Title Alignment**: `Block` widget now supports `title_alignment` (`:left`, `:center`, `:right`) for positioning the title on the border.
- **Constraint Ratio**: Added `Constraint.ratio(numerator, denominator)` to support proportional constraints where the ratio is explicit (e.g., 1/4 and 3/4).
- **Table Constraints**: `Table` widget `widths` now support all constraint types including `:max`, `:fill` and `:ratio`, matching the flexibility of the `Layout` widget.
- **Table Flex**: Added `flex` parameter to `Table` widget to support modern table layouts (`:legacy`, `:start`, `:center`, `:end`, `:space_between`, `:space_around`, `:space_evenly`).
- **Flex::SpaceEvenly**: Added `Flex::SpaceEvenly` layout mode to `Layout` widget.
- **Block Border Types**: Added `border_type` to `Block` widget, allowing `:plain`, `:rounded`, `:double`, `:thick`, `:quadrant_inside`, and `:quadrant_outside` border styles.
- **Fill and Max Constraints**: Added `Constraint.fill(weight)` and `Constraint.max(value)` for modern ratatui layout patterns. Fill constraints distribute remaining space proportionally—for example, `Fill(1)` and `Fill(3)` split space in a 1:3 ratio. Max constraints cap the maximum size of a section.
- **Flex Layout**: The `Layout` widget now supports a `flex` parameter to control how empty space is distributed. Options include `:legacy` (default), `:start`, `:center`, `:end`, `:space_between`, and `:space_around`.
- **Rich Text Support**: Introduced `Text::Span` and `Text::Line` classes for creating styled text with inline formatting. Spans can be combined into lines with optional alignment, enabling word-level control over colors, modifiers, and other style attributes.
- **LineGauge Widget**: New `LineGauge` widget for displaying compact, character-based progress bars using line characters. Supports ratio, label, style, and block customization.
- **New Canvas Markers**: Support for the new `Quadrant`, `Sextant`, and `Octant` markers in the `Canvas` widget for higher-resolution pseudo-pixel rendering.
- **Canvas HalfBlock Marker**: Added `:half_block` marker to `Canvas` widget for block-based rendering using half-height blocks.
- **Shape Module**: Canvas shape primitives (`Point`, `Line`, `Rectangle`, `Circle`, `Map`) are now organized under the `Shape` module (e.g., `Shape::Line`) to avoid naming conflicts with `Text::Line`. The session provides disambiguated helper methods: `shape_line`, `shape_circle`, etc. for shapes and `text_span`, `text_line` for text components.
- **Scrollbar Styling**: Added full styling support to the `Scrollbar` widget, including `thumb_style`, `track_symbol`, `track_style`, `begin_symbol`, `begin_style`, `end_symbol`, `end_style`, and `style`.
- **Scrollbar Orientation**: Added support for all `ratatui` scrollbar orientations: `:vertical_left`, `:vertical_right`, `:horizontal_top`, and `:horizontal_bottom`. Existing `:vertical` and `:horizontal` options remain as aliases.
- **Gauge Enhancements**: Added `percent` initialization parameter as a convenience alternative to `ratio`, and explicitly exposed `use_unicode` attribute to toggle between unicode blocks and ASCII rendering (defaults to `true`).
- **Sparkline Direction**: Added `direction` parameter to `Sparkline` widget, accepting `:left_to_right` (default) or `:right_to_left`. Use `:right_to_left` when new data should appear on the left.
- **TestHelper Improvements**: Added `inject_keys` helper for concise event injection and a default `timeout` (2s) to `with_test_terminal` to prevent hanging tests. Also implemented value equality (`==`) for `Event` objects to simplify assertions.
- **Test Color Inspection**: Added `RatatuiRuby::TestHelper#get_cell` and `#assert_cell_style` for testing terminal cell attributes (colors, characters).
- **Test Safegaurds**: `RatatuiRuby::TestHelper#inject_event` (and `inject_keys`) now raises a helpful error if called outside of `with_test_terminal`, preventing test hangs caused by race conditions.
- **Cell Example**: Added `examples/cell_demo.rb` showcasing how to mix `Cell` objects with Strings in tables and custom widgets, demonstrating advanced styling and layout composition.
- **Layout Reflection**: Added `Layout.split(area, direction:, constraints:, flex:)` class method that computes layout rectangles without rendering. This enables hit testing by letting Ruby calculate where widgets will be placed before drawing.
- **Rect Hit Testing**: Added `Rect#contains?(x, y)` method for testing whether a point is inside a rectangle, essential for implementing mouse click handlers in component systems.

### Changed

- **Cell Refactor (Breaking)**: Renamed `RatatuiRuby::Cell#symbol` to `#char` to avoid confusion with Ruby's `Symbol` class. This affects initialization (`Cell.new(char: "X")`) and property access (`cell.char`).
- **Event API (Breaking)**: `RatatuiRuby.poll_event` now returns typed `Event` objects instead of raw Hashes. Code that previously used `event[:type]`, `event[:code]`, etc. must be updated to use `event.key?`, `event.code`, and similar methods. See `doc/event_handling.md` for migration guidance.
- **Ratatui Upgraded to 0.30.0**: Upgraded the underlying `ratatui` library from 0.29 to 0.30.0, bringing significant improvements including modularized crates, `no_std` support for embedded targets, and major widget and layout enhancements. Layout cache is now explicitly enabled to maintain performance.
- **RatatuiRuby.run**: Added `RatatuiRuby.run` as a lifecycle context manager that initializes the terminal, yields a session, and ensures the terminal is restored, allowing users to define their own application loops. `RatatuiRuby.main_loop` has been removed in favor of this more explicit API.
- **Event::Mouse Initialization**: `Event::Mouse.new` now allows `nil` for the `button` parameter, which is treated as `"none"`. This simplifies creation of mouse events where a specific button isn't relevant, such as scrolling.
- **Session**: The `DSL` class previously yielded by `main_loop` has been renamed to `Session` to better reflect its purpose as a managed terminal session with convenience methods.
- **Improved Event Defaults**: `RatatuiRuby.run` and `RatatuiRuby.init_terminal` now enable Focus and Bracketed Paste events by default. This provides a fuller TUI experience out of the box. Users can explicitly disable them by passing `focus_events: false` or `bracketed_paste: false`.

### Fixed

- **Alpine Linux Support**: Fixed gem installation failures on Alpine Linux (musl targets) by properly configuring `crate-type` to support static linking where dynamic linking is unsupported.
- **Rust Compilation**: Resolved a deprecation warning for `ratatui::buffer::Buffer::get_mut` by upgrading to `cell_mut`, ensuring clean builds with `cargo check` and `bundle exec rake`.

## [0.3.1] - 2025-12-28

### Added

- **Ruby 4 Support**: Updated magnus FFI bindings to use the modern API for Ruby 4.0.0 compatibility.

## [0.3.0] - 2025-12-28

### Added

- **The Escape Hatch (Ruby Render Callback)**: Added the ability to define custom widgets in pure Ruby by implementing a `render(area, buffer)` method. The `Buffer` object provides low-level drawing primitives like `set_string`, allowing developers to create custom TUI components without writing Rust code.
- **Clear Widget**: Added the `Clear` widget, which resets the terminal buffer in the area it is rendered. This is essential for creating opaque popups and modals that prevent background styles from "bleeding" through transparent widgets.
- **Interactive Table Selection**: The `Table` widget now supports row selection with `selected_row`, `highlight_style`, and `highlight_symbol` parameters. This enables building interactive data grids and file explorers where users can navigate through rows using keyboard input.
- **Scrollable Paragraphs**: The `Paragraph` widget now supports a `scroll` parameter that accepts a `(y, x)` array to scroll content vertically and horizontally. This enables viewing long text content that exceeds the visible area, such as logs or documents. The parameter order matches ratatui's convention.
- **Enhanced Tabs Customization**: The `Tabs` widget now supports `highlight_style` for the selected tab and a customizable `divider` string (defaulting to the standard pipe `|`). This allows for richer visual feedback in tabbed interfaces.

### Changed

- **Center Widget**: Removed the implicit `Clear` call from the `Center` widget. `Center` is now a pure layout widget, requiring an explicit `Clear` widget if background clearing is desired. This restores correct behavior for transparent overlays.

## [0.2.0] - 2025-12-24

### Added

- **DSL for Simpler Apps**: Introduced `RatatuiRuby.main_loop`, a new entrypoint that simplifies application structure when you don't need control of the event loop or application lifecycle.
- **Calendar Widget**: Added the `Calendar` widget, allowing you to display monthly views and visualize date-based information.
- **Generic Charts**: Implemented the full `Chart` widget, which supersedes the now-deprecated `LineChart` and `BarChart` widgets, giving you more freedom to visualize data sets.
- **Enhanced List Styling**: You can now customize the appearance of selected items in a `List` using `highlight_style` and `highlight_symbol`.
- **Broader Ruby Support**: Added support for a wider range of Ruby versions: every non-EOL version. The latest preview of Ruby 4.0 is tested in CI, but not supported.
- **Dev Tools**: Added internal Rake tasks for managing historical documentation and SemVer checks.

## [0.1.0] - 2025-12-22

### Added

- **First Release**: Initial public release of `ratatui_ruby`, bringing the power of the Rust [ratatui](https://github.com/ratatui-org/ratatui) library to Rubyists!
- **Core Widget Set**: Includes a comprehensive suite of widgets to get you started:
  - `Block`, `Borders`, and `Paragraph` for basic content.
  - `List` and `Table` for structured data.
  - `Gauge` and `Sparkline` for progress and metrics.
  - `Tabs` for navigation.
  - `Canvas` for drawing shapes (Lines, Circles, Rectangles, Maps).
- **Layout System**: A flexible layout engine using `Flex`, `Layout`, and `Constraints` to build responsive interfaces that adapt to any terminal size.
- **Forms & Layers**: Primitives like `Overlay` and `Center` for creating modal dialogs, plus a `Cursor` widget for text input interactions.
- **Styling**: Full support for `Ratatui`'s styling primitives, including modifiers and RGB/ANSI colors.
- **Input Handling**: Robust handling for both Keyboard and Mouse events.
- **Testing Support**: Included `RatatuiRuby::TestHelper` and RSpec integration to make testing your TUI applications possible.

[Unreleased]: https://git.sr.ht/~kerrick/ratatui_ruby/compare/v0.3.1...HEAD
[0.3.1]: https://git.sr.ht/~kerrick/ratatui_ruby/compare/v0.3.0...v0.3.1
[0.3.0]: https://git.sr.ht/~kerrick/ratatui_ruby/compare/v0.2.0...v0.3.0
[0.2.0]: https://git.sr.ht/~kerrick/ratatui_ruby/compare/v0.1.0...v0.2.0
[0.1.0]: https://git.sr.ht/~kerrick/ratatui_ruby/tree/v0.1.0