<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>

SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Ratatui Features Audit - Complete Comprehensive Catalog

These documents catalog EVERY public feature, method, function, enum variant, and constructor in the Ratatui Rust library with precise file/line references. This has the unfinished items; [the other has the finished items](./api_completeness_audit-finished.md).

## Terminal & Initialization Features

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| try_init | ratatui/src/init.rs:330 | ❌ |
| try_init_with_options | ratatui/src/init.rs:425 | ❌ |
| try_restore | ratatui/src/init.rs:487 | ❌ |
| Viewport::Fixed(Rect) | ratatui-core/src/terminal/viewport.rs:30 | ❌ |
| Terminal struct | ratatui-core/src/terminal/terminal.rs:76 | ⚠️ |
| Terminal::hide_cursor | ratatui-core/src/terminal/terminal.rs:495 | ❌ |
| Terminal::show_cursor | ratatui-core/src/terminal/terminal.rs:502 | ❌ |
| Terminal::get_cursor | ratatui-core/src/terminal/terminal.rs:513 | ❌ |
| Terminal::set_cursor | ratatui-core/src/terminal/terminal.rs:520 | ❌ |
| Terminal::get_cursor_position | ratatui-core/src/terminal/terminal.rs:527 | ⚠️ |
| Terminal::set_cursor_position | ratatui-core/src/terminal/terminal.rs:532 | ⚠️ |
| Terminal::clear | ratatui-core/src/terminal/terminal.rs:540 | ❌ |
| Terminal::swap_buffers | ratatui-core/src/terminal/terminal.rs:562 | ❌ |
| CompletedFrame struct | ratatui-core/src/terminal/frame.rs:40 | ❌ |

**Notes:**
- **Terminal struct**: No direct Terminal object; abstracted behind `RatatuiRuby` module methods
- **Terminal::get_cursor_position/set_cursor_position**: Only available via [Frame](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/frame.rb#72-257) during draw, not on Terminal

## Layout Features

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Spacing enum | ratatui-core/src/layout/layout.rs:80 | ❌ |
| HorizontalAlignment::Left | ratatui-core/src/layout/alignment.rs:25 | ❌ |
| HorizontalAlignment::Center | ratatui-core/src/layout/alignment.rs:26 | ❌ |
| HorizontalAlignment::Right | ratatui-core/src/layout/alignment.rs:27 | ❌ |
| VerticalAlignment::Top | ratatui-core/src/layout/alignment.rs:40 | ❌ |
| VerticalAlignment::Center | ratatui-core/src/layout/alignment.rs:41 | ❌ |
| VerticalAlignment::Bottom | ratatui-core/src/layout/alignment.rs:42 | ❌ |
| Offset struct | ratatui-core/src/layout/offset.rs:10 | ❌ |
| Margin struct | ratatui-core/src/layout/margin.rs:38 | ❌ |

## Style Features

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Styled trait | ratatui-core/src/style/stylize.rs:15 | ❌ |
| Stylize trait | ratatui-core/src/style/stylize.rs:* | ❌ |

## Text Features

| Feature Name | File/Line | Status |
|--------------|-----------| -------|
| Masked struct | ratatui-core/src/text/masked.rs:26 | ❌ |
| ToText trait | ratatui-core/src/text/text.rs:721 | ❌ |
| ToSpan trait | ratatui-core/src/text/span.rs:481 | ❌ |
| StyledGrapheme struct | ratatui-core/src/text/grapheme.rs:12 | ❌ |
| ToLine trait | ratatui-core/src/text/line.rs:810 | ❌ |

## Widgets

### Block Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| BorderType::LightDoubleDashed | ratatui-widgets/src/borders.rs:89 | ❌ |
| BorderType::HeavyDoubleDashed | ratatui-widgets/src/borders.rs:97 | ❌ |
| BorderType::LightTripleDashed | ratatui-widgets/src/borders.rs:105 | ❌ |
| BorderType::HeavyTripleDashed | ratatui-widgets/src/borders.rs:113 | ❌ |
| BorderType::LightQuadrupleDashed | ratatui-widgets/src/borders.rs:121 | ❌ |
| BorderType::HeavyQuadrupleDashed | ratatui-widgets/src/borders.rs:129 | ❌ |

### Table Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| TableState struct | ratatui-widgets/src/table/state.rs:55 | ⚠️ |
| TableState::new | ratatui-widgets/src/table/state.rs:62 | ⚠️ |
| TableState::with_offset | ratatui-widgets/src/table/state.rs:79 | ❌ |
| TableState::with_selected | ratatui-widgets/src/table/state.rs:96 | ❌ |
| TableState::with_selected_column | ratatui-widgets/src/table/state.rs:116 | ❌ |
| TableState::with_selected_cell | ratatui-widgets/src/table/state.rs:135 | ❌ |
| TableState::offset | ratatui-widgets/src/table/state.rs:161 | ⚠️ |
| TableState::offset_mut | ratatui-widgets/src/table/state.rs:175 | ❌ |
| TableState::selected | ratatui-widgets/src/table/state.rs:189 | ⚠️ |
|  TableState::selected_column | ratatui-widgets/src/table/state.rs:205 | ⚠️ |
| TableState::selected_cell | ratatui-widgets/src/table/state.rs:220 | ❌ |
| TableState::selected_mut | ratatui-widgets/src/table/state.rs:238 | ❌ |
| TableState::select | ratatui-widgets/src/table/state.rs:269 | ⚠️ |
| TableState::select_next | ratatui-widgets/src/table/state.rs:336 | ❌ |
| TableState::select_previous | ratatui-widgets/src/table/state.rs:371 | ❌ |
| TableState::select_next_column | ratatui-widgets/src/table/state.rs:353 | ❌ |
| TableState::select_previous_column | ratatui-widgets/src/table/state.rs:388 | ❌ |
| TableState::scroll_down_by | ratatui-widgets/src/table/state.rs:475 | ❌ |
| TableState::scroll_up_by | ratatui-widgets/src/table/state.rs:494 | ❌ |

**Notes:**
- **TableState**: Implemented as Data.define attributes on Table widget itself (selected_row, selected_column, offset) instead of separate state object

### List Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| ListState struct | ratatui-widgets/src/list/state.rs:45 | ⚠️ |
| ListState::with_offset | ratatui-widgets/src/list/state.rs:51 | ❌ |
| ListState::with_selected | ratatui-widgets/src/list/state.rs:68 | ❌ |
| ListState::offset | ratatui-widgets/src/list/state.rs:85 | ⚠️ |
| ListState::offset_mut | ratatui-widgets/src/list/state.rs:99 | ❌ |
| ListState::selected | ratatui-widgets/src/list/state.rs:113 | ⚠️ |
| ListState::selected_mut | ratatui-widgets/src/list/state.rs:129 | ❌ |
| ListState::select | ratatui-widgets/src/list/state.rs:145 | ⚠️ |
| ListState::select_next | ratatui-widgets/src/list/state.rs:177 | ❌ |
| ListState::select_previous | ratatui-widgets/src/list/state.rs:195 | ❌ |
| ListState::select_first | ratatui-widgets/src/list/state.rs:200 | ❌ |
| ListState::select_last | ratatui-widgets/src/list/state.rs:217 | ❌ |

**Notes:**
- **ListState**: Implemented as Data.define attributes on List widget itself (selected_index, offset) instead of separate state object
| ListState::scroll_down_by | ratatui-widgets/src/list/state.rs:248 | ❌ |
| ListState::scroll_up_by | ratatui-widgets/src/list/state.rs:267 | ❌ |

### Sparkline Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| SparklineBar struct | ratatui-widgets/src/sparkline.rs:253 | ❌ |

### Scrollbar Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| ScrollbarState struct | ratatui-widgets/src/scrollbar.rs:149 | ⚠️ |
| ScrollDirection::Forward | ratatui-widgets/src/scrollbar.rs:169 | ❌ |
| ScrollDirection::Backward | ratatui-widgets/src/scrollbar.rs:172 | ❌ |

**Notes:**
- **ScrollbarState**: Implemented as Data.define attributes on Scrollbar widget itself (content_length, position) instead of separate state object

### Calendar Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| CalendarEventStore struct | ratatui-widgets/src/calendar.rs:258 | ❌ |

### Canvas Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Context struct | ratatui-widgets/src/canvas.rs:515 | ❌ |
| Painter struct | ratatui-widgets/src/canvas.rs:403 | ❌ |
| Label struct | ratatui-widgets/src/canvas.rs:61 | ❌ |
| Points shape | ratatui-widgets/src/canvas/points.rs:7 | ❌ |

## Buffer Features

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Buffer::empty | ratatui-core/src/buffer/buffer.rs:77 | ❌ |
| Buffer::filled | ratatui-core/src/buffer/buffer.rs:83 | ❌ |
| Buffer::with_lines | ratatui-core/src/buffer/buffer.rs:91 | ❌ |
| Buffer::get_mut | ratatui-core/src/buffer/buffer.rs:150 | ❌ |
| Buffer::index_of | ratatui-core/src/buffer/buffer.rs:248 | ❌ |
| Buffer::set_string | ratatui-core/src/buffer/buffer.rs:323 | ❌ |
| Buffer::set_stringn | ratatui-core/src/buffer/buffer.rs:335 | ❌ |
| Buffer::set_line | ratatui-core/src/buffer/buffer.rs:372 | ❌ |
| Buffer::set_span | ratatui-core/src/buffer/buffer.rs:394 | ❌ |
| Buffer::set_style | ratatui-core/src/buffer/buffer.rs:404 | ❌ |
| Buffer::reset | ratatui-core/src/buffer/buffer.rs:427 | ❌ |
| Cell::set_style | ratatui-core/src/buffer/cell.rs:153 | ❌ |
| Cell::reset | ratatui-core/src/buffer/cell.rs:193 | ❌ |

**Notes:**
- **Buffer**: Read-only access implemented via `RatatuiRuby.get_cell_at`. Direct mutation methods not exposed in Ruby API

## Widget Traits

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Widget trait | ratatui-core/src/widgets/widget.rs:70 | ⚠️ |
| StatefulWidget trait | ratatui-core/src/widgets/stateful_widget.rs:124 | ⚠️ |

**Notes:**
- **Widget/StatefulWidget traits**: Not exposed as Ruby traits. Widgets implement `CoerceableWidget` mixin and rendering handled via FFI

## Backend Features

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Backend trait | ratatui-core/src/backend.rs:148 | ⚠️ |
| ClearType::All | ratatui-core/src/backend.rs:117 | ❌ |
| ClearType::AfterCursor | ratatui-core/src/backend.rs:119 | ❌ |
| ClearType::BeforeCursor | ratatui-core/src/backend.rs:121 | ❌ |
| ClearType::CurrentLine | ratatui-core/src/backend.rs:123 | ❌ |
| ClearType::UntilNewLine | ratatui-core/src/backend.rs:125 | ❌ |
| WindowSize struct | ratatui-core/src/backend.rs:130 | ❌ |
| TermionBackend | ratatui-termion/src/lib.rs:* | ❌ |
| TermwizBackend | ratatui-termwiz/src/lib.rs:* | ❌ |

**Notes:**
- **Backend trait**: Abstracted away. Terminal uses Crossterm backend internally, not exposed to Ruby API
- **ClearType**: Not exposed. Clearing handled via `Clear` widget