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

### Changed

### Fixed

### Removed

## [0.3.0] - 2025-12-28

### Added

- **The Escape Hatch (Ruby Render Callback)**: Added the ability to define custom widgets in pure Ruby by implementing a `render(area, buffer)` method. The `Buffer` object provides low-level drawing primitives like `set_string`, allowing developers to create custom TUI components without writing Rust code.
- **Clear Widget**: Added the `Clear` widget, which resets the terminal buffer in the area it is rendered. This is essential for creating opaque popups and modals that prevent background styles from "bleeding" through transparent widgets.
- **Interactive Table Selection**: The `Table` widget now supports row selection with `selected_row`, `highlight_style`, and `highlight_symbol` parameters. This enables building interactive data grids and file explorers where users can navigate through rows using keyboard input.
- **Scrollable Paragraphs**: The `Paragraph` widget now supports a `scroll` parameter that accepts a `(y, x)` array to scroll content vertically and horizontally. This enables viewing long text content that exceeds the visible area, such as logs or documents. The parameter order matches ratatui's convention.

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

[Unreleased]: https://git.sr.ht/~kerrick/ratatui_ruby/compare/v0.3.0...HEAD
[0.3.0]: https://git.sr.ht/~kerrick/ratatui_ruby/compare/v0.2.0...v0.3.0
[0.2.0]: https://git.sr.ht/~kerrick/ratatui_ruby/compare/v0.1.0...v0.2.0
[0.1.0]: https://git.sr.ht/~kerrick/ratatui_ruby/tree/v0.1.0