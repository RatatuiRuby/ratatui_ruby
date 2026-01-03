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

- **Rich Text in Table Cells**: `Table` cells (rows, header, footer) now accept `Text::Span` and `Text::Line` objects for per-character styling, matching List widget capabilities.
- **Row Wrapper**: New `Row` data class allows applying row-level styling (background color, style) and layout properties (height, top_margin, bottom_margin) to Table rows. Table rows can now be plain arrays or `Row` objects.
- **Line#width Method**: `Text::Line` now has a `width` instance method that calculates the display width in terminal cells using unicode-aware measurement. Useful for layout calculations with rich text.

### Changed

### Fixed

### Removed

## [0.6.0] - 2026-01-03

### Added

- **Rich Text Support**: `List`, `Gauge`, `LineGauge`, and `BarChart` widgets now accept rich text objects (`Text::Span`, `Text::Line`) in addition to plain strings. This enables per-character styling, multi-colored labels, and complex text formatting matching Ratatui 0.30.0 capabilities.
- **ListItem Wrapper**: New `ListItem` data class allows applying row-level styling (background color) independent of text content. `List` items can now be `String`, `Text::Span`, `Text::Line`, or `ListItem` objects.
- **Non-Blocking Event Polling**: `RatatuiRuby.poll_event` now accepts an optional `timeout:` parameter (Float seconds). Use `timeout: 0.0` for non-blocking checks, or `timeout: 0.1` for fixed timesteps. Defaults to `0.016` (16ms) to preserve existing behavior.
- **Cursor Positioning**: `Frame#set_cursor_position(x, y)` sets the terminal's hardware cursor position. Using this method is essential for input fields where the user expects visual feedback on their cursor location.
- **Text Measurement**: `RatatuiRuby::Text.width(string)` calculates the display width of a string in terminal cells, correctly handling unicode including ASCII (1 cell), CJK full-width characters (2 cells), emoji (typically 2 cells), and zero-width combining marks (0 cells). This is essential for auto-sizing widgets and responsive layouts. Delegates to the same unicode-width logic that Ratatui uses internally.
- **Scroll Offset Control**: `List` and `Table` widgets now accept an optional `offset` parameter to control the viewport's scroll position. Use this for passive scrolling (viewing without selection) or calculating click-to-item mappings. When combined with a selection, Ratatui's natural scrolling may still adjust the viewport to keep the selection visible; set selection to `nil` for fully manual scroll control.
- **Rect Geometry Helpers**: `Rect#intersects?(other)` tests whether two rectangles overlap. `Rect#intersection(other)` returns the overlapping area as a new `Rect`, or `nil` if disjoint. Essential for viewport clipping and hit testing in component architectures.
- **Stateful Rendering**: `Frame#render_stateful_widget(widget, area, state)` renders widgets with mutable state objects (`ListState`, `TableState`, `ScrollbarState`). State objects persist across frames, enabling scroll offset read-back and selection tracking. Essential for mouse click-to-row hit testing. **Precedence rule:** State object properties override widget properties (`selected_index`, `offset`).
- **Full Keyboard Support**: Key events now recognize all keys supported by crossterm: function keys (`f1`–`f24`), navigation (`home`, `end`, `page_up`, `page_down`, `insert`, `delete`), locks (`caps_lock`, `scroll_lock`, `num_lock`), system (`print_screen`, `pause`, `menu`), media controls (`play`, `play_pause`, `track_next`, etc.), and individual modifier keys (`left_shift`, `right_control`, etc.). Previously unmapped keys returned `"unknown"`; they now return proper `snake_case` strings.
- **Key Categories**: `Event::Key` now has a `kind` attribute (`:standard`, `:function`, `:media`, `:modifier`, `:system`) for logical grouping. Category predicates (`media?`, `system?`, `function?`, `modifier?`, `standard?`) enable clean event routing without string parsing. The `unmodified?` method is an alias for `standard?`.
- **Smart Predicates (DWIM)**: Key predicates now "Do What I Mean" for media keys. `pause?` returns `true` for both system `pause` and `media_pause` keys. For strict matching, use `media_pause?` or compare `event.code` directly. This reduces boilerplate when responding to conceptual actions regardless of input method.
- **Modifier Key Predicates**: New methods `super?`, `hyper?`, and `meta?` check for these modifier keys. Platform aliases are provided for `super?`: `command?`/`cmd?` (macOS), `win?` (Windows), and `tux?` (Linux). These work for both modifier flags AND individual modifier key events (e.g., `left_super`). Additionally, `control?` aliases `ctrl?` and `option?` aliases `alt?`.
- **Navigation Aliases**: Convenient predicate aliases for common keys: `return?` for Enter, `back?` for Backspace, `del?` for Delete, `ins?` for Insert, `escape?` for Esc, `pgup?`/`pageup?` for Page Up, `pgdn?`/`pagedown?` for Page Down. The special `reverse_tab?` predicate matches both the `back_tab` key and `shift+tab` combinations.
- **Indexed Color Support**: `Style` now supports `Integer` values for `fg` and `bg`, allowing use of the Xterm 256-color palette (0-255). This includes standard ANSI colors (0-15), the 6x6x6 color cube (16-231), and the grayscale ramp (232-255).
- **Rich Snapshots**: `RatatuiRuby::TestHelper#assert_rich_snapshot` validates both content and styling by comparing against stored ANSI snapshots. This allows for visual regression testing that respects colors, bold, italics, and other terminal modifiers.
- **Semantic Style Assertions**: New testing helpers `assert_color(expected, x:, y:)`, `assert_cell_style(x, y, **style)`, and `assert_area_style(area, **style)` allow precise verification of terminal cell attributes without full-screen snapshots. Punchy convenience aliases like `assert_fg`/`assert_bg`, `assert_bold`, `assert_italic`, `assert_underlined`, and color-specific assertions (e.g., `assert_red`, `assert_bg_blue`) provide a more natural API for common testing patterns.
- **Buffer Debugging**: `RatatuiRuby::TestHelper#print_buffer` outputs the current terminal state to STDOUT with full ANSI color support, making it easier to debug rendering issues during test execution.


### Changed

- **Frozen Data Objects (Breaking)**: Events returned by `RatatuiRuby.poll_event` and `Cell` objects from `RatatuiRuby.get_cell_at` are now deeply frozen for Ractor compatibility. Code that mutates these objects (e.g., `event.modifiers << "custom"`) must copy the data before modifying. `Rect` was already frozen. Note: `Frame` and `Session` are *I/O handles* with side effects and remain intentionally non-shareable.
- **Semantic Exceptions (Breaking)**: Replaced generic `RuntimeError` with `RatatuiRuby::Error::Terminal` for backend/terminal failures and `RatatuiRuby::Error::Safety` for API contract violations (like using `Frame` outside `draw`). This allows finer-grained error handling but breaks code explicitly rescuing `RuntimeError`. `ArgumentError` works as before.
- **Media Key Codes (Breaking)**: All media key codes now use a consistent `media_` prefix: `play` → `media_play`, `stop` → `media_stop`, `play_pause` → `media_play_pause`, etc. Code comparing against literal media key strings must be updated. Use the Smart Predicates (`play?`, `stop?`) for backward-compatible behavior.
- **`Key#char` Return Value (Breaking)**: `char` now returns `nil` for non-printable keys (previously returned `""`). Code relying on `event.char.empty?` must change to `event.char.nil?` or use `event.text?` instead.

### Fixed

- **Frame Safety**: Calling methods on a `Frame` stored outside of a `draw` block now correctly raises a `RatatuiRuby::Error::Safety` (subclass of `RatatuiRuby::Error`) instead instead of causing undefined behavior or crashes. This ensures memory safety by preventing use-after-free scenarios with the underlying Rust frame.

### Removed

## [0.5.0] - 2026-01-01

### Added

#### Frame API

- **`RatatuiRuby.draw { |frame| ... }`**: New block-based drawing API that yields a `Frame` object for explicit widget placement. Enables hit testing without duplicating layout calculations.
- **`Frame#area`**: Returns the terminal area as a `Rect`.
- **`Frame#render_widget(widget, rect)`**: Renders a widget at a specific position. Works with all existing widgets and `Rect` objects.

#### Testing

- **`RatatuiRuby::TestHelper#inject_mouse`**: comprehensive mouse event injection helper supporting coordinates, buttons, and modifiers.
- **`RatatuiRuby::TestHelper#inject_click`**: Helper for left-click events.
- **`RatatuiRuby::TestHelper#inject_right_click`**: Helper for right-click events.
- **`RatatuiRuby::TestHelper#inject_drag`**: Helper for mouse drag events.
- **`RatatuiRuby::TestHelper#assert_screen_matches`**: Assert that the current terminal content matches a stored golden snapshot.

#### Session API

- **Convenience Methods**: `Session` now wraps class methods from `Layout`, `Constraint`, and other schema classes as instance methods (e.g., `layout_split` delegates to `Layout.split`, `constraint_percentage` to `Constraint.percentage`). This enables a more fluent API in `RatatuiRuby.run` blocks.

### Changed

#### Event System

- **`Event::None` (Breaking)**: `RatatuiRuby.poll_event` now returns `Event::None` instead of `nil` when no event is available. This null-object responds safely to all event predicates with `false`. Use `event.none?` or pattern-match on `type: :none`. Code using `while (event = poll_event)` must change to `while (event = poll_event) && !event.none?`.

### Fixed

#### Session API

- **Missing Convenience Methods**: Fixed `Session` convenience methods (e.g., `bar_chart`) being missed by replacing the manual list with automatic runtime introspection of the `RatatuiRuby` module.

### Removed

## [0.4.0] - 2025-12-30

### Added

#### Hex Color Support

- **Style**: `fg` and `bg` parameters now accept hex color strings (e.g., `"#ff0000"` for red). Requires a 24-bit true color capable terminal (Kitty, iTerm2, modern Terminal.app). Terminals without true color support will gracefully fall back to the closest ANSI color.

#### RatatuiMascot Widget

- **RatatuiMascot**: New widget to display the Ratatui mascot (Ferris).

#### RatatuiLogo Widget

- **RatatuiLogo**: New widget to display the Ratatui logo.


#### Duck-Typed Numeric Coercion

- All numeric parameters now accept any object that responds to `to_f` (for floats) or `to_int`/`to_i` (for integers). This provides idiomatic Ruby interoperability with `BigDecimal`, `Rational`, and custom numeric types. Uses Ruby's built-in `Float()` and `Integer()` Kernel methods for proper duck-type handling.

#### Paragraph Widget

- `alignment`: **Breaking Change**: Renamed `align` to `alignment` to match Ratatui 0.30 API.

#### Custom Widgets

- **Draw Command API**: Custom widgets now return an array of `Draw` commands instead of writing to a buffer. Use `RatatuiRuby::Draw.string(x, y, string, style)` and `RatatuiRuby::Draw.cell(x, y, cell)` to create draw commands. This eliminates use-after-free bugs by keeping all pointers inside Rust while Ruby works with pure data objects. **Breaking:** The `render` method signature changed from `render(area, buffer)` to `render(area)`.

#### BarChart Widget

- `bar_set`: Customize bar characters (digits, symbols, blocks).
- `group_gap`: Control spacing between groups in grouped bar charts.
- `data`: Now accepts an Array of `BarGroup` objects, enabling grouped bar charts.
- `Bar` and `BarGroup`: New schema classes for defining grouped bar data.

#### Block Widget

- `border_type`: Customize border style (`:plain`, `:rounded`, `:double`, `:thick`, `:quadrant_inside`, `:quadrant_outside`).
- `border_set`: Customize border characters (e.g., digits, symbols).
- `border_style`: Apply full style support (colors and modifiers) to borders. Takes precedence over `border_color`.
- `children`: Declare child widgets within the block's area for composable UI structures.
- Multiple `titles`: Display multiple titles with individual alignment (`:left`, `:center`, `:right`) and vertical positioning (`:top`, `:bottom`). Each title supports its own `style`.
- `title_style`: Base style applied to all titles.
- `style`: Base style applied to the entire block.
- `padding`: Directional padding via a single integer (uniform) or array of 4 integers (`[left, right, top, bottom]`).
- `line_count(width)`: **(Experimental)** Calculate rendered lines (including borders/padding) for a given width. Delegates to Ratatui's underlying unstable `line_count`.
- `line_width`: **(Experimental)** Calculate minimum width to avoid wrapping (including borders/padding). Delegates to Ratatui's underlying unstable `line_width`.

#### Calendar Widget

- `events`: Hash mapping `Date` objects to `Style` objects for highlighting specific dates.
- `show_month_header`: Toggle month header visibility (defaults to `false`). **Breaking:** Previously always shown.
- `show_weekdays_header`: Toggle weekday names (Mon, Tue, etc.) visibility (defaults to `true`).
- `show_surrounding`: Optional `Style` to display dates from adjacent months, or `nil` to hide them.

#### Chart Widget

- `legend_position`: Position legend at `:top_left`, `:top_right`, `:bottom_left`, or `:bottom_right` (defaults to `:top_right`).
- `hidden_legend_constraints`: Array of two `Constraint` objects to hide the legend when chart area is too small.
- **Axis**: `labels_alignment` to control horizontal alignment (`:left`, `:center`, `:right`) of axis labels.
- `Dataset`: `style` parameter replaces `color`, enabling full styling (fg, bg, modifiers) for chart datasets. **Breaking**: `color` parameter removed.

#### Gauge Widget

- `style`: Base style applied to the entire gauge background.
- `gauge_style`: Style applied specifically to the filled bar. **Breaking:** Use this instead of `style` if you want bar coloring; `style` no longer defaults to `Style.default`.
- `percent`: Convenience parameter alternative to `ratio` for initialization.
- `use_unicode`: Explicitly toggle between unicode blocks and ASCII rendering (defaults to `true`).

#### LineGauge Widget

- `style`: Base style applied to the entire gauge area.

#### List Widget

- `scroll_padding`: Number of items to keep visible above and below the selected item during scrolling.
- `repeat_highlight_symbol`: When `true`, repeat highlight symbol on each line of multi-line selections.
- `highlight_spacing`: Control selection column reservation (`:always`, `:when_selected`, `:never`).
- `direction`: List orientation (`:top_to_bottom` or `:bottom_to_top`).

#### Sparkline Widget

- `absent_value_symbol` and `absent_value_style`: Customize rendering of `nil` values (distinct from `0`).
- `direction`: Rendering direction (`:left_to_right` or `:right_to_left`).
- `bar_set`: Customize bar characters.

#### Table Widget

- `style`: Base style applied to the entire table.
- `column_spacing`: Horizontal spacing between columns.
- `footer`: Summary rows at the bottom of the table.
- `flex`: Layout distribution mode (`:legacy`, `:start`, `:center`, `:end`, `:space_between`, `:space_around`, `:space_evenly`).
- `highlight_spacing`: Control selection column reservation (`:always`, `:when_selected`, `:never`).
- `column_highlight_style`: Style applied to the selected column.
- `cell_highlight_style`: Style applied to the selected cell (intersection of row and column).
- `selected_column`: Index of the selected column (Integer or nil).
- `widths`: Now support all constraint types (`:max`, `:fill`, `:ratio`) with full flexibility.

#### Tabs Widget

- `style`: Base style applied to the entire tabs area.
- `padding_left` and `padding_right`: Horizontal padding around tab titles.
- `width`: Calculate total width of the tabs (including dividers/padding).

#### Canvas Widget

- `background_color`: Set canvas background color.
- `:half_block` marker: Block-based rendering using half-height blocks.
- `:quadrant`, `:sextant`, `:octant` markers: High-resolution pseudo-pixel rendering.
- `Shape::Label`: Text labels at canvas coordinates with optional styling.

#### Scrollbar Widget

- Full styling support: `thumb_style`, `track_symbol`, `track_style`, `begin_symbol`, `begin_style`, `end_symbol`, `end_style`, `style`.
- All orientation variants: `:vertical_left`, `:vertical_right`, `:horizontal_top`, `:horizontal_bottom` (`:vertical` and `:horizontal` remain as aliases).

#### Layout & Constraints

- `Constraint.ratio(numerator, denominator)`: Proportional constraints with explicit ratio.
- `Constraint.fill(weight)`: Distribute remaining space proportionally. Use multiple `Fill` to split space (e.g., `Fill(1)` and `Fill(3)` split 1:3).
- `Constraint.max(value)`: Cap maximum size of a section.
- `Layout.split(area, direction:, constraints:, flex:)`: Compute layout rectangles without rendering, enabling hit testing.
- `Flex::SpaceEvenly`: New layout mode for `Layout` widget.
- `flex` parameter: All layout options (`:legacy`, `:start`, `:center`, `:end`, `:space_between`, `:space_around`, `:space_evenly`).

#### Rich Text & Text Components

- `Text::Span` and `Text::Line`: Styled text with inline formatting. Combine spans into lines with optional alignment.
- `Shape` module: Canvas shape primitives (`Shape::Line`, `Shape::Circle`, `Shape::Rectangle`, `Shape::Point`, `Shape::Map`) to avoid naming conflicts with `Text::Line`.

#### Event System

- Typed `Event` API: `RatatuiRuby.poll_event` returns typed objects (`Event::Key`, `Event::Mouse`, `Event::Resize`, `Event::Paste`, `Event::FocusGained`, `Event::FocusLost`).
- Predicate methods: `key?`, `mouse?`, `ctrl?`, etc. for cleaner event handling.
- Pattern matching support and discriminator pattern via `type:` key in `#deconstruct_keys`.
- `Event::Resize`: Terminal resize events with `width` and `height` attributes.
- `Event::Paste`: Bracketed paste as atomic event with `content:`.
- `Event::FocusGained` and `Event::FocusLost`: Terminal focus changes.
- `Event::Mouse.new` accepts `nil` for `button` parameter (treated as `"none"`).

#### Geometry & Hit Testing

- `Rect#contains?(x, y)`: Test whether a point is inside a rectangle. Essential for mouse click handlers.
- `Layout.split`: Enables calculating widget positions before rendering.

#### Testing

- `RatatuiRuby::TestHelper#inject_keys`: Concise event injection helper.
- `RatatuiRuby::TestHelper#get_cell` and `#assert_cell_style`: Inspect terminal cell attributes (colors, characters).
- `with_test_terminal`: Default timeout of 2 seconds to prevent hanging tests. **Breaking:** Default size is now 80×24 (VT100 standard) instead of 20×10.
- Error on `inject_event`/`inject_keys` outside `with_test_terminal`: Prevents test hangs from race conditions.
- Value equality (`==`) for `Event` objects: Simplify assertions.

#### Lifecycle & Application Structure

- `RatatuiRuby.run`: New context manager that initializes terminal, yields session, and restores on exit. Allows custom event loop control.
- **Session** class: Renamed from `DSL` to better reflect its purpose as a managed terminal session with convenience methods.
- Focus and Bracketed Paste events: Enabled by default in `RatatuiRuby.run` and `RatatuiRuby.init_terminal` (disable with `focus_events: false` or `bracketed_paste: false`).

#### Documentation & Examples

- **Cached Layout Pattern**: Documented in `doc/interactive_design.md`. Three-phase lifecycle pattern (`calculate_layout`, `render`, `handle_input`) solves layout duplication in immediate-mode UI. Foundation for Component architecture in Gem 1.5.

### Changed

- **Calendar:** Renamed `day_style` to `default_style` to match Ratatui 0.30 API. This is a breaking change. [Kerrick Long]

- **Custom Widget `render` Method (Breaking)**: Changed signature from `render(area, buffer)` to `render(area)`, with render methods now returning an array of `Draw` commands instead of writing directly to a buffer. This change improves memory safety by eliminating use-after-free risks.
- **Ratatui Upgraded to 0.30.0**: Underlying `ratatui` library upgraded from 0.29, bringing modularized crates, `no_std` support for embedded targets, and major widget/layout enhancements. Layout cache explicitly enabled for performance.
- **Event API (Breaking)**: `RatatuiRuby.poll_event` returns typed `Event` objects instead of raw Hashes. Code using `event[:type]` must change to `event.key?`, `event.code`, etc.
- **RatatuiRuby.main_loop Removed (Breaking)**: Removed in favor of `RatatuiRuby.run` for more explicit lifecycle control.
- **TestHelper Terminal Size (Breaking)**: `with_test_terminal` defaults to 80×24 instead of 20×10.
- **Calendar Month Header Default (Breaking)**: `show_month_header` defaults to `false` (previously always shown). Set `show_month_header: true` if relying on the old behavior.
- **Gauge `style` Default (Breaking)**: No longer defaults to `Style.default`. Use `gauge_style` for bar coloring instead.

### Fixed

- **Alpine Linux Support**: Fixed gem installation failures on Alpine Linux (musl targets) by properly configuring `crate-type` to support static linking where dynamic linking is unsupported.
- **Rust Safety**: Convert `class.name()` results to owned strings for proper GC safety with Magnus 0.8.
- **Terminal Preview Detection**: Detect staged changes correctly in preview generation.

## [0.3.1] - 2025-12-28

### Added

- **Ruby 4 Support**: Updated magnus FFI bindings to use the modern API for Ruby 4.0.0 compatibility.

## [0.3.0] - 2025-12-28

### Added

- **Custom Widget API (Breaking)**: Custom widgets that define a `render` method now receive only `area` (not `buffer`) and must return an array of `Draw` commands. Use `RatatuiRuby::Draw.string(x, y, string, style)` and `RatatuiRuby::Draw.cell(x, y, cell)` instead of `buffer.set_string` and `buffer.set_cell`. This eliminates a class of use-after-free bugs by ensuring Ruby never holds pointers to Rust-owned memory. Widgets can now be unit tested by asserting on the returned array.
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

[Unreleased]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/HEAD
[0.6.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.6.0
[0.5.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.5.0
[0.4.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.4.0
[0.3.1]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.3.1
[0.3.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.3.0
[0.2.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.2.0
[0.1.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.1.0