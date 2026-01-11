<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->
# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Terminal Capability Detection**: New class methods on `RatatuiRuby::Terminal` for environment-based capability detection before initializing TUI mode:
  - `Terminal.tty?` — checks if stdout is connected to a terminal
  - `Terminal.dumb?` — checks if TERM is explicitly set to "dumb"
  - `Terminal.no_color?` — checks if NO_COLOR environment variable is set (respects the [NO_COLOR standard](https://no-color.org/))
  - `Terminal.force_color?` — checks if FORCE_COLOR environment variable is set
  - `Terminal.interactive?` — returns true only when tty? and not dumb?
  - `Terminal.available_color_count` — returns color support level (8, 256, or 65535) via crossterm detection
  - `Terminal.color_support` — convenience method returning `:none`, `:basic`, `:ansi256`, or `:truecolor`
  - `Terminal.supports_keyboard_enhancement?` — checks for Kitty keyboard protocol support
  - `Backend.window_size` — returns terminal dimensions as `Backend::WindowSize` with both character grid (`columns_rows`) and pixel (`pixels`) sizes as `Layout::Size` instances; mirrors upstream Ratatui's `backend::WindowSize` struct
  - `Terminal.force_color_output(enable)` — globally overrides NO_COLOR detection for `--color=always` flags
- **Alignment Constants**: New `RatatuiRuby::Layout::HorizontalAlignment` and `RatatuiRuby::Layout::VerticalAlignment` modules with discoverable constants (`LEFT`, `CENTER`, `RIGHT`, `TOP`, `BOTTOM`). `Layout::Alignment` is an alias for `HorizontalAlignment`. Use the constants for IDE discoverability, or continue passing symbols (`:left`, `:center`, etc.) directly—both work.

### Changed

### Fixed

- **TableState Row Navigation Methods**: Added missing row navigation methods (`select_next`, `select_previous`, `select_first`, `select_last`) that should have been included alongside the column navigation methods added in v0.10.0. These methods match `ListState`'s navigation API and are used in the `app_stateful_interaction` example.

### Removed


## [0.10.3] - 2026-01-16

### Added

- **Rect Destructuring**: `Rect` objects now support array destructuring (implementation of `to_ary`), allowing intuitive assignment like `x, y, w, h = rect`.
- **Global State Test Helpers**: New `RatatuiRuby::TestHelper::GlobalState` module (automatically included in `TestHelper`) provides `with_argv` and `with_env` methods for safely testing code that reads `ARGV` or `ENV`.

### Changed

- **New Website**: RatatuiRuby now has a home on the world wide web at [www.ratatui-ruby.dev](https://www.ratatui-ruby.dev).
- **A New Way to Browse Examples**: You can now browse the source code of the example applications in our documentation site. See [AppAllEvents](https://www.ratatui-ruby.dev/docs/v0.10/examples/app_all_events/app_rb.html) for an example.
- **API Documentation on the Web**: RatatuiRuby's [extensive RDoc documentation is now available on the web](https://www.ratatui-ruby.dev/docs/v0.10/RatatuiRuby.html).
- **Guides on the Web**: RatatuiRuby's [in-depth guides are now available on the web](https://www.ratatui-ruby.dev/docs/v0.10/doc/index_md.html).
- **Versioned Examples, API Documentanion, and Guides**: API reference, guides, and examples are available on our website for current and past versions of ratatui_ruby, including the trunk version. Visit [www.ratatui-ruby.dev/docs](https://www.ratatui-ruby.dev/docs) to browse.

### Fixed

- **Dependency Problems**: Removed the unused `ostruct` dependency from the gemspec. Added `rexml` as an explicit dependency.
- **Lazy REXML Loading**: `RatatuiRuby::Labs::A11y` now requires `rexml` lazily, preventing it from slowing down startup for users not using accessibility features.

## [0.10.2] - 2026-01-14

### Added

- **Experimental Labs System**: New `RatatuiRuby::Labs` module for opt-in experimental features via `RR_LABS` environment variable. Check with `Labs.enabled?(:a11y)` or enable programmatically with `Labs.enable!(:a11y)`. _Labs are subject to change even between patch releases._
- **A11Y Widget Tree Export (Lab)**: When `RR_LABS=A11Y` is set, the widget tree is serialized to XML and written to `Dir.tmpdir/ratatui_a11y.xml` every frame. This exports semantic structure (`<Paragraph>`, `<List>`, etc.) for accessibility tooling integration. Access is through `RatatuiRuby::Labs::A11y.dump_widget_tree(widget)` or automatic via `RatatuiRuby.draw`.
- **Inline Viewport**: New `viewport:` parameter for `init_terminal` and `run` accepts `:inline` or `:fullscreen` (default). Inline viewports occupy a fixed number of lines at the terminal bottom, preserving scrollback history above. Pass `height:` to specify inline viewport height (default: 8 lines). Fullscreen viewports use the alternate screen as before.
- **Insert Before**: New `insert_before(height, widget)` method inserts content above an inline viewport into scrollback without disrupting the running TUI. Essential for logging status updates, progress messages, or diagnostic output while your inline TUI continues running. Only works with inline viewports; raises `Error::Invariant` in fullscreen mode.
- **Terminal Area Accessors**: New methods to query terminal and viewport dimensions:
  - `terminal_area` / `get_terminal_size` — full terminal backend size (always full dimensions)
  - `viewport_area` / `get_viewport_area` — current viewport rendering area (inline viewport height or full terminal in fullscreen)
  - Aliases: `terminal_size`, `viewport_size`, `get_terminal_area`, `get_viewport_size`
- **Cursor Position Accessors**: New methods for querying and setting cursor position:
  - `cursor_position` / `get_cursor_position` — returns current cursor position as `Layout::Position` or `[x, y]` array
  - `cursor_position=` / `set_cursor_position` — sets cursor position from `Layout::Position`, array, or separate x/y arguments
- **Error::Internal Exception**: New exception class for framework bugs, distinct from user errors. If you encounter this, please report it as a framework bug.

### Changed

### Fixed

### Removed

## [0.10.1] - 2026-01-11

### Added

### Changed

### Fixed

- **poll_event Return Type**: Fixed `poll_event` incorrectly returning `nil` for unknown event types. The method now correctly returns `Event::None` as per its contract.

### Removed

## [0.10.0] - 2026-01-10

### Added

- **Table Integer Width Shorthand**: `Table` `widths:` parameter now accepts plain integers as shorthand for `Constraint.length(n)`. This enables cleaner table definitions like `widths: [40, 16, 10]` instead of verbose constraint arrays. Constraints and integers can be mixed freely.
- **Error Message Context**: Type errors from the Rust backend now include the `inspect` string of the value that caused the error, making debugging significantly easier. For example, "expected array for rows" now shows "expected array for rows, got {title: \"Processes\", ...}".
- **Steep Type Checking**: Integrated Steep static type analyzer with a new `rake steep` task. The Steepfile covers `lib/` with comprehensive RBS type definitions for all widgets, layout primitives, events, and interfaces.
- **RBS Type Definitions**: Added 50+ RBS signature files in `sig/ratatui_ruby/` covering all widget classes, core interfaces (`_RectLike`, `_ToS`), type aliases (`style_input`, `widget`), and a `Data.define` patch for `super()` call compatibility.
- **Duck Typing Documentation**: New `test/test_duck_typing.rb` documents that `Layout.split` accepts any object responding to `x`, `y`, `width`, `height` (Struct, Data.define, custom classes), not just `Rect`.
- **Debug Mode**: New `RatatuiRuby::Debug` module controls Rust backtrace visibility for easier debugging. Activate via:
  - `RUST_BACKTRACE=1` — Rust backtraces only
  - `RR_DEBUG=1` — full debug mode (backtraces + future Ruby-side features)
  - `include RatatuiRuby::TestHelper` — auto-enables debug mode in tests
  - `RatatuiRuby.debug_mode!` — programmatic activation
- **Debug.test_panic!**: New method that intentionally triggers a Rust panic, allowing developers to verify their backtrace setup is working correctly before encountering a real bug.
- **Deferred Panic Backtraces**: Rust backtraces during TUI sessions are now stored and printed after terminal restoration, preventing output from being lost on the alternate screen. Previously, panic output in raw terminal mode was invisible.
- **Remote Debugging**: Debug mode now integrates with Ruby's `debug` gem for remote debugging. `RR_DEBUG=1` stops at startup and waits for debugger attachment. `RatatuiRuby.debug_mode!` continues running in nonstop mode. Attach from another terminal with `rdbg --attach`.
- **Debug.suppress_debug_mode**: New block method temporarily suppresses Ruby-side debug checks within its block. Rust backtraces remain enabled. Useful for testing production behavior in debug mode environments.
- **DWIM Hash Coercion**: All widget factory methods now accept both `tui.table(hash)` and `tui.table(**hash)` calling styles. When a bare Hash is passed as the first positional argument, it is automatically splatted into keyword arguments. Unknown keys are silently ignored in production mode; in debug mode (`RR_DEBUG=1`), they raise `ArgumentError` for early typo detection.
- **Ratatui-Aligned Text Methods**: New methods on `Text::Span` and `Text::Line` matching Ratatui's API for style manipulation:
  - `Span#width` — display width in terminal cells (unicode-aware)
  - `Span.raw(content)` — factory for unstyled spans
  - `Span#patch_style(style)` — merge style onto existing style
  - `Span#reset_style` — clear all styling
  - `Line#left_aligned`, `Line#centered`, `Line#right_aligned` — fluent alignment setters
  - `Line#push_span(span)` — append span (returns new Line, immutable)
  - `Line#patch_style(style)`, `Line#reset_style` — style manipulation for all spans
- **List Query Methods**: New methods on `List` matching Ratatui's API:
  - `List#len` — number of items (with Ruby aliases `length`, `size`)
- **TableState Navigation Methods**: New methods on `TableState` matching Ratatui's API for column navigation:
  - `selected_cell` — returns `[row, column]` tuple when both are selected
  - `with_selected_cell(cell)` — constructor to create state with both row and column selected
  - `select_next_column` — select the next column (or first if none selected)
  - `select_previous_column` — select the previous column (saturates at 0)
  - `select_first_column` — select column 0
  - `select_last_column` — select the last column (clamped during rendering)
- **Buffer Query Methods**: New module methods on `Buffer` matching Ratatui's API for buffer inspection:
  - `Buffer.content` — returns all cells as an array
  - `Buffer.get(x, y)` — returns the Cell at the specified position
  - `Buffer.index_of(x, y)` — converts position to linear buffer index
  - `Buffer.pos_of(index)` — converts linear index to position coordinates
- **Rect Conversion Methods**: New methods on `Rect` for extracting geometry components:
  - `Rect#as_position` — returns a `Position` object containing x and y coordinates
  - `Rect#as_size` — returns a `Size` object containing width and height
- **Position and Size Classes**: New layout primitives matching Ratatui's API:
  - `Layout::Position` — represents terminal coordinates (x, y)
  - `Layout::Size` — represents terminal dimensions (width, height)
- **Constraint#apply**: Computes the constrained size for a given available space. For example, `Constraint.percentage(50).apply(100)` returns `50`. Also aliased as `call` for proc-like invocation (`constraint.(100)`).
- **Color Module**: New `Style::Color` module with constructors matching Ratatui's API:
  - `Color.from_u32(0xRRGGBB)` — creates a color from a hex integer (aliased as `Color.hex`)
  - `Color.from_hsl(h, s, l)` — creates a color from HSL values (aliased as `Color.hsl`)
- **Ruby-Idiomatic Aliases**: All new APIs include shorter, more Ruby-ish aliases following TIMTOWTDI:
  - `Rect#position` (alias for `as_position`), `Rect#size` (alias for `as_size`)
  - `Buffer[x, y]` (alias for `Buffer.get`)
  - `Constraint#call` (alias for `apply`, enables `constraint.(n)` syntax)
- **Layout Margin and Spacing**: `Layout` now supports `margin:` and `spacing:` parameters for edge insets and gaps between segments, matching Ratatui's Layout API.
- **Layout.split_with_spacers**: New class method returns both content segments and spacer Rects, enabling custom rendering of dividers or separators between layout sections.
- **Canvas#get_point**: Converts canvas coordinates to normalized [0.0, 1.0] grid coordinates for hit testing. Returns `nil` for out-of-bounds coordinates. Also aliased as `point` and `[]` for Ruby-idiomatic access.
- **Row#enable_strikethrough**: Returns a new Row with `:crossed_out` modifier for indicating cancelled or deleted items. Also aliased as `strikethrough`. Note: Strikethrough (SGR 9) is not supported by all terminals; macOS Terminal.app notably lacks support while Kitty, iTerm2, Alacritty, and WezTerm render it correctly.
- **Rect Geometry Methods**: New methods on `Rect` for geometry manipulation:
  - `Rect#outer(margin)` — expands a rectangle by a margin (inverse of `inner`)
  - `Rect#resize(size)` — changes dimensions while preserving top-left position
  - `Rect#centered_horizontally(constraint)` — centers horizontally using Layout
  - `Rect#centered_vertically(constraint)` — centers vertically using Layout
  - `Rect#centered(h, v)` — centers on both axes
- **TUI Shape Aliases (DWIM)**: Canvas shape factories now have terse and bidirectional aliases:
  - Terse: `circle()`, `point()`, `map()`, `label()` (shorter forms of `shape_*`)
  - Bidirectional: `circle_shape()`, `point_shape()`, `rectangle_shape()`, `map_shape()`, `label_shape()` (same as `shape_*`)
  - Note: Terse `rectangle` is intentionally excluded to avoid confusion with `Layout::Rect`; use `shape_rectangle()` or `rectangle_shape()`.
- **TUI `item` Alias**: `tui.item(...)` is now an alias for `tui.list_item(...)`, providing a terser API when building lists.
- **Gauge and LineGauge `percent`**: Both widgets now have a `percent` reader that returns the ratio as an integer percentage (0-100). `LineGauge` also now accepts a `percent:` constructor parameter matching `Gauge`.
- **List#selected_item**: Returns the item at the selected index (or nil if nothing is selected).
- **Style `underline_color`**: New optional parameter for `Style` that sets a distinct underline color independent of the foreground color. Useful for styling like "white text with red underline". Terminals must support the underline color extension (SGR 58).
- **Style `remove_modifiers`**: New optional parameter for `Style` that explicitly removes modifiers when styles are patched/inherited. Corresponds to Ratatui's `sub_modifier` field. Use it to prevent inherited bold, italic, or other modifiers from propagating.
- **Symbols::Shade Constants**: New `RatatuiRuby::Symbols::Shade` module exposes Ratatui's shade block characters as named constants: `EMPTY` (" "), `LIGHT` ("░"), `MEDIUM` ("▒"), `DARK` ("▓"), `FULL` ("█"). Use them for gradients, density fills, or custom progress indicators.
- **Symbols::Line Constants and Sets**: New `RatatuiRuby::Symbols::Line` module exposes Ratatui's box-drawing characters with 36 individual constants (VERTICAL, HORIZONTAL, corners, T-junctions, cross) and 4 predefined sets: `NORMAL` (standard corners), `ROUNDED` (rounded corners), `DOUBLE` (double-line), `THICK` (heavy lines). Use them for custom borders or drawing.
- **Symbols::Bar Constants and Sets**: New `RatatuiRuby::Symbols::Bar` module exposes Ratatui's vertical bar characters (lower blocks) with 8 individual constants and 2 predefined sets: `NINE_LEVELS` (full resolution) and `THREE_LEVELS` (simplified). Used by Sparkline widget.
- **Symbols::Block Constants and Sets**: New `RatatuiRuby::Symbols::Block` module exposes Ratatui's horizontal block characters (left blocks) with 8 individual constants and 2 predefined sets: `NINE_LEVELS` (full resolution) and `THREE_LEVELS` (simplified). Used by Gauge widget.
- **Symbols::Scrollbar Sets**: New `RatatuiRuby::Symbols::Scrollbar` module exposes 4 predefined scrollbar symbol sets: `VERTICAL`, `DOUBLE_VERTICAL`, `HORIZONTAL`, `DOUBLE_HORIZONTAL`. Each set contains `track`, `thumb`, `begin_char`, and `end_char` symbols.
- **Cell `underline_color`**: `Buffer::Cell` and top-level `Cell` now expose `underline_color` attribute for introspecting styled underline colors during testing.

### Changed

- **`tui.draw` Argument Validation (Breaking)**: `tui.draw` now validates its arguments. Calling `draw` with neither a tree nor a block raises `ArgumentError`, as does calling it with both. Previously this produced undefined behavior.
- **`Layout.split` Stricter Type Checking (Breaking)**: `Layout.split` now rejects invalid `area` arguments with a clear `ArgumentError` instead of silently misbehaving. Objects must be a `Rect`, `Hash` with `:x/:y/:width/:height` keys, or respond to all four geometry methods.
- **Schema Directory Removed (Breaking)**: The legacy `lib/ratatui_ruby/schema/` directory has been removed. All widget classes now live exclusively in their proper namespaces (`Widgets::`, `Layout::`, `Text::`, etc.). Direct usage like `RatatuiRuby::Paragraph` (without `Widgets::`) is no longer supported. Use `RatatuiRuby::Widgets::Paragraph` or the TUI facade (`tui.paragraph`).
- **Buffer::Cell Modifiers (Breaking)**: `Buffer::Cell#modifiers` and `Cell#modifiers` now return an array of `Symbol`s (e.g., `[:bold, :italic]`) instead of `String`s. This unifies the API, as `Style` modifiers were already symbols. Code expecting strings (e.g. `cell.modifiers.include?("bold")`) must be updated to use symbols. This changes behavior established in v0.9.1.

### Fixed

- **Tabs Padding Coercion**: `Tabs` `padding_left` and `padding_right` now correctly coerce duck-typed integer values (objects responding to `to_int`/`to_i`) via `Integer()`. Previously these parameters were passed through without coercion, inconsistent with other integer parameters. `Text::Line` values are still accepted as-is for styled padding.

### Removed

- **NullIO Re-export (Breaking)**: Removed `RatatuiRuby::NullIO` constant. Use `RatatuiRuby::OutputGuard::NullIO` if you were relying on this internal class.
- **Legacy Media Keys (Breaking)**: Removed support for legacy unprefixed media keys (e.g. `play`, `stop`) in event parsing. You must now use the canonical `media_`-prefixed keys (e.g. `media_play`, `media_stop`). The `play?`/`stop?` predicates still work for both, checking the correct canonical codes.

## [0.9.1] - 2026-01-08

### Added

- **Constraint Batch Constructors**: `Constraint` now provides batch factory methods matching upstream Ratatui for creating constraint arrays in a single call:
  - `from_lengths([10, 20, 10])` — create multiple Length constraints
  - `from_percentages([25, 50, 25])` — create multiple Percentage constraints
  - `from_mins([5, 10, 5])` — create multiple Min constraints
  - `from_maxes([20, 30, 40])` — create multiple Max constraints
  - `from_fills([1, 2, 1])` — create multiple Fill constraints
  - `from_ratios([[1, 4], [2, 4], [1, 4]])` — create multiple Ratio constraints

- **Async Synchronization**: New `Event::Sync` event and `SyntheticEvents` module enable deterministic testing of async behavior:
  - `Event::Sync` — synthetic event that signals runtimes (Tea, Kit) to wait for pending async operations before continuing
  - `RatatuiRuby::SyntheticEvents` — thread-safe Ruby-only queue for synthetic events; runtimes check this alongside native events
  - `inject_sync` test helper — injects a Sync event for deterministic async testing

### Changed

### Fixed

### Removed

## [0.9.0] - 2026-01-08

### Added

- **State Query Predicates (DWIM DX)**: Widgets now provide ergonomic predicate methods for querying selection and completion state:
  - `List#selected?` — returns true if an item is selected
  - `List#empty?` — returns true if the list has no items
  - `Table#row_selected?`, `Table#column_selected?`, `Table#cell_selected?` — check selection state
  - `Table#empty?` — returns true if the table has no rows
  - `Gauge#filled?`, `Gauge#complete?` — check progress state (ratio > 0, ratio >= 1.0)
  - `LineGauge#filled?`, `LineGauge#complete?` — same as Gauge

- **Symbol Constants (DWIM DX)**: Widgets now expose constants for enum-style parameters, enabling IDE autocomplete and self-documenting code:
  - `List::HIGHLIGHT_ALWAYS`, `HIGHLIGHT_WHEN_SELECTED`, `HIGHLIGHT_NEVER`
  - `List::DIRECTION_TOP_TO_BOTTOM`, `DIRECTION_BOTTOM_TO_TOP`
  - `Table::HIGHLIGHT_*` — same as List
  - `Table::FLEX_LEGACY`, `FLEX_START`, `FLEX_CENTER`, `FLEX_END`, `FLEX_SPACE_BETWEEN`, `FLEX_SPACE_AROUND`, `FLEX_SPACE_EVENLY`
  - `Layout::Layout::DIRECTION_VERTICAL`, `DIRECTION_HORIZONTAL`
  - `Layout::Layout::FLEX_*` — same as Table

- **TUI API Aliases (DWIM DX)**: The TUI facade now provides CSS-inspired constraint aliases for cleaner layout code:
  - `fixed(n)` — alias for `constraint_length(n)`
  - `percent(n)` — alias for `constraint_percentage(n)`
  - `flex(n)` / `fr(n)` — aliases for `constraint_fill(n)` (Flexbox/Grid-inspired)
  - `split(...)` — alias for `layout_split(...)`

- **ListState Navigation Methods**: `ListState` now provides ergonomic navigation methods matching upstream Ratatui:
  - `select_next` — select the next item (or first if nothing selected)
  - `select_previous` — select the previous item (or last if nothing selected)
  - `select_first` — jump to the first item
  - `select_last` — jump to the last item

- **Rect Methods**: `Rect` now provides edge accessors, size queries, geometry transformations, and iterators from upstream Ratatui:
  - `left`, `right`, `top`, `bottom` — edge coordinates
  - `area`, `empty?` — size queries
  - `union(other)`, `inner(margin)`, `offset(dx, dy)`, `clamp(bounds)` — geometry transformations
  - `rows`, `columns`, `positions` — iterators yielding slices or coordinates

### Changed

- **License**: Library code (`lib/`, `sig/`) relicensed to LGPL-3.0-or-later for proprietary use. LGPL allows proprietary applications to link against the library while keeping library modifications open source.
- **License**: Documentation code snippets now use MIT-0, letting users copy example code without attribution requirements.

### Fixed

### Removed

- **`assert_snapshot`**: Removed deprecated test helper. Use `assert_plain_snapshot` or `assert_snapshots` instead.
- **`Block#border_color`**: Removed deprecated parameter. Use `border_style: Style.new(fg: color)` for equivalent functionality.
- **`LineChart`**: Removed deprecated widget. Use `Chart` with `Dataset.new(graph_type: :line)` instead. See `examples/widget_chart/` for usage.

## [0.8.0] - 2026-01-05

### Added
- **Output Guard**: `RatatuiRuby.guard_io { }` temporarily replaces `$stdout` and `$stderr` with a null sink, preventing screen corruption from chatty gems. Active when `terminal_active?` is true; warns if called outside a session (to catch mistakes); silent no-op in headless mode.
- **Headless Mode**: `RatatuiRuby.headless!` enables batch/CLI mode for apps with `--no-tui` flags. When headless, `guard_io` becomes a silent no-op and `init_terminal`/`run` raise `Error::Invariant`. This allows the same code to work in both TUI and non-TUI modes.
- **Terminal Safety Hooks**: `at_exit` and `Signal.trap` handlers for `INT` and `TERM` automatically restore the terminal if a session is active on unexpected exit. This prevents leaving the terminal in raw mode after Ctrl+C or process termination.

### Changed

- **Double `init_terminal` Now Raises `Error::Invariant` (Breaking)** Calling `init_terminal`, `init_test_terminal`, or `run` while a TUI session is already active now raises `Error::Invariant`. Previously, this was undefined but silently "working" behavior that could cause terminal state corruption. If your code intentionally double-inits, call `restore_terminal` first.

### Fixed

### Removed

## [0.7.4] - 2026-01-05

### Added

- **Block Inner Area Calculation**: `Block#inner(area)` method computes the inner content area given an outer `Rect`, accounting for borders and padding. Essential for layout calculations when you need to know usable space inside a block.
- **Deferred Warnings During TUI Sessions**: Experimental feature warnings (like `Paragraph#line_count`) are now automatically queued during active TUI sessions and flushed to stderr after `restore_terminal`. This prevents warnings from corrupting the TUI display. See `doc/troubleshooting/tui_output.md` for details on handling terminal output during TUI sessions.
- **Session State Tracking**: `RatatuiRuby.terminal_active?` indicates whether a TUI session is active. Calling `init_terminal` or `init_test_terminal` while a session is already active now raises `Error::Invariant`.
- **Error::Invariant**: New error class for state invariant violations (e.g., double-init). Distinct from `Error::Safety` (lifetime violations) and `Error::Terminal` (operational I/O failures).

### Changed

### Fixed

- **Direct Text Rendering**: `Text::Line` and `Text::Span` can now be rendered directly as widgets via `frame.render_widget(line, area)` without wrapping in a `Paragraph`. Previously, these text primitives were silently ignored when passed to `render_widget`.
- **Text Line Alignment**: `Text::Line` `alignment:` parameter is now respected during rendering. Previously, the alignment was ignored and text always rendered left-aligned.

### Removed

## [0.7.3] - 2026-01-04

### Added

- **Symbol Shortcuts for `bar_set`**: `Sparkline` and `BarChart` now accept `:nine_levels` (full 9-character gradient) and `:three_levels` (simplified empty/half/full) as intuitive shortcuts instead of requiring custom character hashes.
- **`:half_block` Marker**: `Chart` `Dataset` now supports `:half_block` marker for higher resolution rendering using ▀ and ▄ characters.
- **`assert_snapshots` Method**: `RatatuiRuby::TestHelper#assert_snapshots` (plural) calls both `assert_plain_snapshot` and `assert_rich_snapshot` with the same name, generating both `.txt` and `.ansi` files for documentation and display purposes.
- **Edge-Center Legend Positions**: `Chart` `legend_position` now accepts `:top`, `:bottom`, `:left`, and `:right` in addition to the existing corner positions (`:top_left`, `:top_right`, `:bottom_left`, `:bottom_right`).
- **`:reset` Color**: `Style` `fg` and `bg` now accept `:reset` to explicitly clear any inherited foreground or background color, restoring the terminal's default.

### Changed

### Deprecated

- **`assert_snapshot`**: Use `assert_snapshots` (plural) instead, or `assert_plain_snapshot` if you only need plain text. The old method name lacked clarity about whether it captured plain text or styled ANSI output.

### Fixed

### Removed

## [0.7.2] - 2026-01-04

### Added

- **Tabs `padding_left` and `padding_right`**: Now accept `Integer` (for spaces), `String`, or `Text::Line` for styled padding content. Previously only accepted `Integer`. Passing a `Line` object allows colored or decorated padding.

### Changed

### Fixed

- **Styled Text Parsing**: Fixed multiple widgets incorrectly rendering styled text objects as Ruby inspect strings (e.g., `#<data RatatuiRuby::Text::Span...>`) instead of their styled content:
  - `Tabs` `divider`: Now correctly renders `Text::Span` objects.
  - `Table` `highlight_symbol`: Now correctly renders `Text::Span` objects.
  - `BarChart` `BarGroup` `label`: Now correctly renders `Text::Line` objects.
  - `Chart` `Axis` `title`: Now correctly renders `Text::Line` objects.
  - `Chart` `Axis` `labels`: Now correctly renders `Text::Line` objects.
  - `Chart` `Dataset` `name`: Now correctly renders `Text::Line` objects.

### Removed

## [0.7.1] - 2026-01-03

### Added

### Changed

### Fixed

- **Block Title Styling**: `Block` title `content` now correctly renders `Text::Line` objects with styled spans. Previously, passing a styled `Line` as title content displayed its Ruby inspect representation (e.g., `#<data RatatuiRuby::Text::Line...>`) instead of the styled text.

### Removed

## [0.7.0] - 2026-01-03

> [!WARNING]
> v0.7.0 contains significant breaking changes. See the [Migration Guide](https://man.sr.ht/~kerrick/ratatui_ruby/history/migrations/v0_7_0.md) for upgrade instructions.

### Added

- **Rich Text in Table Cells**: `Table` cells (rows, header, footer) now accept `Text::Span` and `Text::Line` objects for per-character styling, matching List widget capabilities.
- **Row Wrapper**: New `Widgets::Row` class allows applying row-level styling (background color, style) and layout properties (height, top_margin, bottom_margin) to Table rows. Table rows can now be plain arrays or `Widgets::Row` objects.
- **Cell Wrapper**: New `Widgets::Cell` class wraps table cell content with optional cell-level styling. Distinct from `Buffer::Cell` which is for buffer inspection.
- **Line#width Method**: `Text::Line` now has a `width` instance method that calculates the display width in terminal cells using unicode-aware measurement. Useful for layout calculations with rich text.
- **render_rich_buffer**: New `TestHelper::Snapshot#render_rich_buffer` method returns the terminal buffer as an ANSI-encoded string with escape codes for colors and modifiers. Useful for debugging, custom assertions, or programmatic inspection beyond `assert_rich_snapshot`.

### Changed

- **Namespace Restructure (Breaking)**: Classes reorganized to match Ratatui's module hierarchy. See [Migration Guide](https://man.sr.ht/~kerrick/ratatui_ruby/history/migrations/v0_7_0.md) for details:
  - `RatatuiRuby::Rect` → `RatatuiRuby::Layout::Rect`
  - `RatatuiRuby::Constraint` → `RatatuiRuby::Layout::Constraint`
  - `RatatuiRuby::Layout` → `RatatuiRuby::Layout::Layout`
  - `RatatuiRuby::Style` → `RatatuiRuby::Style::Style`
  - `RatatuiRuby::Paragraph` → `RatatuiRuby::Widgets::Paragraph`
  - `RatatuiRuby::Block` → `RatatuiRuby::Widgets::Block`
  - `RatatuiRuby::Table` → `RatatuiRuby::Widgets::Table`
  - `RatatuiRuby::List` → `RatatuiRuby::Widgets::List`
  - *(and all other widgets)*
- **Session → TUI Rename (Breaking)**: `RatatuiRuby::Session` renamed to `RatatuiRuby::TUI` to better reflect its role as a facade/DSL. The `TUI` class now uses explicit factory methods (no metaprogramming) for improved IDE autocomplete support.
- **Buffer::Cell vs Widgets::Cell (Breaking)**: `RatatuiRuby::Cell` (buffer inspection) renamed to `RatatuiRuby::Buffer::Cell`. New `RatatuiRuby::Widgets::Cell` added for table cell construction.
- **Text::Line style field (Breaking)**: `Text::Line` now accepts a `style:` parameter for line-level styling, matching Ratatui's `Line` struct which has `style`, `alignment`, and `spans` fields.
- **Table highlight_style → row_highlight_style (Breaking)**: `Table` parameter `highlight_style:` renamed to `row_highlight_style:` to match Ratatui's API naming convention.

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
[0.10.3]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.10.3
[0.10.2]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.10.2
[0.10.1]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.10.1
[0.10.1]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.10.1
[0.10.1]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.10.1
[0.10.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.10.0
[0.9.1]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.9.1
[0.9.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.9.0
[0.8.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.8.0
[0.7.4]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.7.4
[0.7.3]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.7.3
[0.7.2]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.7.2
[0.7.1]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.7.1
[0.7.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.7.0
[0.6.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.6.0
[0.5.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.5.0
[0.4.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.4.0
[0.3.1]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.3.1
[0.3.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.3.0
[0.2.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.2.0
[0.1.0]: https://git.sr.ht/~kerrick/ratatui_ruby/refs/v0.1.0