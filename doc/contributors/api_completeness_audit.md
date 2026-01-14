<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>

SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Ratatui Features Audit - Complete Comprehensive Catalog

This document catalogs EVERY public feature, method, function, enum variant, and constructor in the Ratatui Rust library with precise file/line references.

## Terminal & Initialization Features

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| run | ratatui/src/init.rs:251 | ✅ |
| init | ratatui/src/init.rs:298 | ✅ |
| try_init | ratatui/src/init.rs:330 | ❌ |
| init_with_options | ratatui/src/init.rs:382 | ✅ |
| try_init_with_options | ratatui/src/init.rs:425 | ❌ |
| restore | ratatui/src/init.rs:457 | ✅ |
| try_restore | ratatui/src/init.rs:487 | ❌ |
| Viewport::Fullscreen | ratatui-core/src/terminal/viewport.rs:22 | ✅ |
| Viewport::Inline(u16) | ratatui-core/src/terminal/viewport.rs:28 | ✅ |
| Viewport::Fixed(Rect) | ratatui-core/src/terminal/viewport.rs:30 | ❌ |
| Terminal struct | ratatui-core/src/terminal/terminal.rs:76 | ⚠️ |
| Terminal::draw | ratatui-core/src/terminal/terminal.rs:373 | ✅ |
| Terminal::hide_cursor | ratatui-core/src/terminal/terminal.rs:495 | ❌ |
| Terminal::show_cursor | ratatui-core/src/terminal/terminal.rs:502 | ❌ |
| Terminal::get_cursor | ratatui-core/src/terminal/terminal.rs:513 | ❌ |
| Terminal::set_cursor | ratatui-core/src/terminal/terminal.rs:520 | ❌ |
| Terminal::get_cursor_position | ratatui-core/src/terminal/terminal.rs:527 | ⚠️ |
| Terminal::set_cursor_position | ratatui-core/src/terminal/terminal.rs:532 | ⚠️ |
| Terminal::clear | ratatui-core/src/terminal/terminal.rs:540 | ❌ |
| Terminal::swap_buffers | ratatui-core/src/terminal/terminal.rs:562 | ❌ |
| Terminal::size | ratatui-core/src/terminal/terminal.rs:568 | ✅ |
| Terminal::insert_before | ratatui-core/src/terminal/terminal.rs:648 | ✅ |
| TerminalOptions struct | ratatui-core/src/terminal/terminal.rs:104 | ✅ |
| Frame struct | ratatui-core/src/terminal/frame.rs:17 | ✅ |
| Frame::render_widget | ratatui-core/src/terminal/frame.rs:93 | ✅ |
| Frame::render_stateful_widget | ratatui-core/src/terminal/frame.rs:124 | ✅ |
| Frame::set_cursor_position | ratatui-core/src/terminal/frame.rs:141 | ✅ |
| CompletedFrame struct | ratatui-core/src/terminal/frame.rs:40 | ❌ |

**Notes:**
- **Terminal struct**: No direct Terminal object; abstracted behind `RatatuiRuby` module methods
- **Terminal::get_cursor_position/set_cursor_position**: Only available via [Frame](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/frame.rb#72-257) during draw, not on Terminal

## Layout Features

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Layout struct | ratatui-core/src/layout/layout.rs:193 | ✅ |
| Layout::horizontal | ratatui-core/src/layout/layout.rs:285 | ✅ |
| Layout::vertical | ratatui-core/src/layout/layout.rs:265 | ✅ |
| Layout::constraints | ratatui-core/src/layout/layout.rs:377 | ✅ |
| Layout::spacing | ratatui-core/src/layout/layout.rs:521 | ✅ |
| Layout::split | ratatui-core/src/layout/layout.rs:663 | ✅ |
| Layout::split_with_spacers | ratatui-core/src/layout/layout.rs:713 | ✅ |
| Spacing enum | ratatui-core/src/layout/layout.rs:80 | ❌ |
| Constraint::Min(u16) | ratatui-core/src/layout/constraint.rs:94 | ✅ |
| Constraint::Max(u16) | ratatui-core/src/layout/constraint.rs:117 | ✅ |
| Constraint::Length(u16) | ratatui-core/src/layout/constraint.rs:140 | ✅ |
| Constraint::Percentage(u16) | ratatui-core/src/layout/constraint.rs:168 | ✅ |
|  Constraint::Ratio(u32, u32) | ratatui-core/src/layout/constraint.rs:192 | ✅ |
| Constraint::Fill(u16) | ratatui-core/src/layout/constraint.rs:218 | ✅ |
| Constraint::from_lengths | ratatui-core/src/layout/constraint.rs:230 | ✅ |
| Constraint::from_ratios | ratatui-core/src/layout/constraint.rs:254 | ✅ |
| Constraint::from_percentages | ratatui-core/src/layout/constraint.rs:277 | ✅ |
| Constraint::from_maxes | ratatui-core/src/layout/constraint.rs:300 | ✅ |
| Constraint::from_mins | ratatui-core/src/layout/constraint.rs:320 | ✅ |
| Constraint::from_fills | ratatui-core/src/layout/constraint.rs:341 | ✅ |
| Flex::Legacy | ratatui-core/src/layout/flex.rs:75 | ✅ |
| Flex::Start | ratatui-core/src/layout/flex.rs:98 | ✅ |
| Flex::End | ratatui-core/src/layout/flex.rs:120 | ✅ |
| Flex::Center | ratatui-core/src/layout/flex.rs:142 | ✅ |
| Flex::SpaceBetween | ratatui-core/src/layout/flex.rs:164 | ✅ |
| Flex::SpaceEvenly | ratatui-core/src/layout/flex.rs:187 | ✅ |
| Flex::SpaceAround | ratatui-core/src/layout/flex.rs:209 | ✅ |
| Direction::Horizontal | ratatui-core/src/layout/direction.rs:16 | ✅ |
| Direction::Vertical | ratatui-core/src/layout/direction.rs:20 | ✅ |
| HorizontalAlignment::Left | ratatui-core/src/layout/alignment.rs:25 | ❌ |
| HorizontalAlignment::Center | ratatui-core/src/layout/alignment.rs:26 | ❌ |
| HorizontalAlignment::Right | ratatui-core/src/layout/alignment.rs:27 | ❌ |
| VerticalAlignment::Top | ratatui-core/src/layout/alignment.rs:40 | ❌ |
| VerticalAlignment::Center | ratatui-core/src/layout/alignment.rs:41 | ❌ |
| VerticalAlignment::Bottom | ratatui-core/src/layout/alignment.rs:42 | ❌ |
| Position struct | ratatui-core/src/layout/position.rs:57 | ✅ |
| Offset struct | ratatui-core/src/layout/offset.rs:10 | ❌ |
| Size struct | ratatui-core/src/layout/size.rs:46 | ✅ |
| Margin struct | ratatui-core/src/layout/margin.rs:38 | ❌ |
| Rect struct | ratatui-core/src/layout/rect.rs:134 | ✅ |
| Rect::new | ratatui-core/src/layout/rect.rs:166 | ✅ |
| Rect::area | ratatui-core/src/layout/rect.rs:190 | ✅ |
| Rect::is_empty | ratatui-core/src/layout/rect.rs:195 | ✅ |
| Rect::left | ratatui-core/src/layout/rect.rs:200 | ✅ |
| Rect::right | ratatui-core/src/layout/rect.rs:205 | ✅ |
| Rect::top | ratatui-core/src/layout/rect.rs:214 | ✅ |
| Rect::bottom | ratatui-core/src/layout/rect.rs:219 | ✅ |
| Rect::inner | ratatui-core/src/layout/rect.rs:228 | ✅ |
| Rect::outer | ratatui-core/src/layout/rect.rs:248 | ✅ |
| Rect::offset | ratatui-core/src/layout/rect.rs:276 | ✅ |
| Rect::resize | ratatui-core/src/layout/rect.rs:289 | ✅ |
| Rect::union | ratatui-core/src/layout/rect.rs:305 | ✅ |
| Rect::intersection | ratatui-core/src/layout/rect.rs:322 | ✅ |
| Rect::clamp | ratatui-core/src/layout/rect.rs:387 | ✅ |
| Rect::rows | ratatui-core/src/layout/rect/iter.rs:4 | ✅ |
| Rect::columns | ratatui-core/src/layout/rect/iter.rs:66 | ✅ |
| Rect::positions | ratatui-core/src/layout/rect/iter.rs:130 | ✅ |

## Style Features

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Color::Reset | ratatui-core/src/style/color.rs:30 | ✅ |
| Color::Black | ratatui-core/src/style/color.rs:32 | ✅ |
| Color::Red | ratatui-core/src/style/color.rs:34 | ✅ |
| Color::Green | ratatui-core/src/style/color.rs:36 | ✅ |
| Color::Yellow | ratatui-core/src/style/color.rs:38 | ✅ |
| Color::Blue | ratatui-core/src/style/color.rs:40 | ✅ |
| Color::Magenta | ratatui-core/src/style/color.rs:42 | ✅ |
| Color::Cyan | ratatui-core/src/style/color.rs:44 | ✅ |
| Color::Gray | ratatui-core/src/style/color.rs:46 | ✅ |
| Color::DarkGray | ratatui-core/src/style/color.rs:48 | ✅ |
| Color::LightRed | ratatui-core/src/style/color.rs:50 | ✅ |
| Color::LightGreen | ratatui-core/src/style/color.rs:52 | ✅ |
| Color::LightYellow | ratatui-core/src/style/color.rs:54 | ✅ |
| Color::LightBlue | ratatui-core/src/style/color.rs:56 | ✅ |
| Color::LightMagenta | ratatui-core/src/style/color.rs:58 | ✅ |
| Color::LightCyan | ratatui-core/src/style/color.rs:60 | ✅ |
| Color::White | ratatui-core/src/style/color.rs:62 | ✅ |
| Color::Rgb(u8, u8, u8) | ratatui-core/src/style/color.rs:64 | ✅ |
| Color::Indexed(u8) | ratatui-core/src/style/color.rs:66 | ✅ |
| Color::from_u32 | ratatui-core/src/style/color.rs:133 | ✅ |
| Color::from_hsl | ratatui-core/src/style/color.rs:416 | ✅ |
| Color::from_hsluv | ratatui-core/src/style/color.rs:469 | ✅ |
| Style struct | ratatui-core/src/style.rs:239 | ✅ |
| Style::fg | ratatui-core/src/style.rs:335 | ✅ |
| Style::bg | ratatui-core/src/style.rs:352 | ✅ |
| Style::underline_color | ratatui-core/src/style.rs:387 | ✅ |
| Style::add_modifier | ratatui-core/src/style.rs:408 | ✅ |
| Style::remove_modifier | ratatui-core/src/style.rs:430 | ✅ |
| Modifier::BOLD | ratatui-core/src/style.rs:105 | ✅ |
| Modifier::DIM | ratatui-core/src/style.rs:106 | ✅ |
| Modifier::ITALIC | ratatui-core/src/style.rs:107 | ✅ |
| Modifier::UNDERLINED | ratatui-core/src/style.rs:108 | ✅ |
| Modifier::SLOW_BLINK | ratatui-core/src/style.rs:109 | ✅ |
| Modifier::RAPID_BLINK | ratatui-core/src/style.rs:110 | ✅ |
| Modifier::REVERSED | ratatui-core/src/style.rs:111 | ✅ |
| Modifier::HIDDEN | ratatui-core/src/style.rs:112 | ✅ |
| Modifier::CROSSED_OUT | ratatui-core/src/style.rs:113 | ✅ |
| Styled trait | ratatui-core/src/style/stylize.rs:15 | ❌ |
| Stylize trait | ratatui-core/src/style/stylize.rs:* | ❌ |

## Text Features

| Feature Name | File/Line | Status |
|--------------|-----------| -------|
| Masked struct | ratatui-core/src/text/masked.rs:26 | ❌ |
| Text struct | ratatui-core/src/text/text.rs:196 | ✅ |
| ToText trait | ratatui-core/src/text/text.rs:721 | ❌ |
| Span struct | ratatui-core/src/text/span.rs:99 | ✅ |
| ToSpan trait | ratatui-core/src/text/span.rs:481 | ❌ |
| StyledGrapheme struct | ratatui-core/src/text/grapheme.rs:12 | ❌ |
| Line struct | ratatui-core/src/text/line.rs:183 | ✅ |
| ToLine trait | ratatui-core/src/text/line.rs:810 | ❌ |

## Symbol Sets

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| half_block::UPPER | ratatui-core/src/symbols/half_block.rs:1 | ✅ |
| half_block::LOWER | ratatui-core/src/symbols/half_block.rs:3 | ✅ |
| half_block::FULL | ratatui-core/src/symbols/half_block.rs:5 | ✅ |
| Marker::Dot | ratatui-core/src/symbols/marker.rs:11 | ✅ |
| Marker::Block | ratatui-core/src/symbols/marker.rs:13 | ✅ |
| Marker::Bar | ratatui-core/src/symbols/marker.rs:17 | ✅ |
| Marker::Braille | ratatui-core/src/symbols/marker.rs:21 | ✅ |
| Marker::HalfBlock | ratatui-core/src/symbols/marker.rs:25 | ✅ |
| bar::Set struct | ratatui-core/src/symbols/bar.rs:8 | ✅ |
| bar::THREE_LEVELS | ratatui-core/src/symbols/bar.rs:29 | ✅ |
| bar::NINE_LEVELS | ratatui-core/src/symbols/bar.rs:41 | ✅ |
| border::Set struct | ratatui-core/src/symbols/border.rs:12 | ✅ |
| border::PLAIN | ratatui-core/src/symbols/border.rs:43 | ✅ |
| border::ROUNDED | ratatui-core/src/symbols/border.rs:62 | ✅ |
| border::DOUBLE | ratatui-core/src/symbols/border.rs:81 | ✅ |
| border::THICK | ratatui-core/src/symbols/border.rs:100 | ✅ |
| border::QUADRANT_OUTSIDE | ratatui-core/src/symbols/border.rs:195 | ✅ |
| border::QUADRANT_INSIDE | ratatui-core/src/symbols/border.rs:214 | ✅ |
| line::Set struct | ratatui-core/src/symbols/line.rs:62 | ✅ |
| line::NORMAL | ratatui-core/src/symbols/line.rs:82 | ✅ |
| line::DOUBLE | ratatui-core/src/symbols/line.rs:104 | ✅ |
| line::THICK | ratatui-core/src/symbols/line.rs:118 | ✅ |

## Widgets

### Paragraph Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Paragraph struct | ratatui-widgets/src/paragraph.rs:80 | ✅ |
| Paragraph::block | ratatui-widgets/src/paragraph.rs:174 | ✅ |
| Paragraph::style | ratatui-widgets/src/paragraph.rs:198 | ✅ |
| Paragraph::wrap | ratatui-widgets/src/paragraph.rs:115 | ✅ |
| Paragraph::scroll | ratatui-widgets/src/paragraph.rs:161 | ✅ |
| Paragraph::alignment | ratatui-widgets/src/paragraph.rs:199 | ✅ |
| Wrap struct | ratatui-widgets/src/paragraph.rs:240 | ✅ |
| Wrap::trim | ratatui-widgets/src/paragraph.rs:242 | ✅ |

### Block Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Block struct | ratatui-widgets/src/block.rs:75 | ✅ |
| Block::borders | ratatui-widgets/src/block.rs:85 | ✅ |
| Block::border_style | ratatui-widgets/src/block.rs:89 | ✅ |
| Block::border_set | ratatui-widgets/src/block.rs:91 | ✅ |
| Block::padding | ratatui-widgets/src/block.rs:97 | ✅ |
| Padding struct | ratatui-widgets/src/block/padding.rs:27 | ✅ |
| Padding::ZERO | ratatui-widgets/src/block/padding.rs:40 | ✅ |
| Padding::new | ratatui-widgets/src/block/padding.rs:50 | ✅ |
| Padding::horizontal | ratatui-widgets/src/block/padding.rs:66 | ✅ |
| Padding::vertical | ratatui-widgets/src/block/padding.rs:76 | ✅ |
| Padding::uniform | ratatui-widgets/src/block/padding.rs:86 | ✅ |
| Padding::proportional | ratatui-widgets/src/block/padding.rs:99 | ✅ |
|  Padding::symmetric | ratatui-widgets/src/block/padding.rs:112 | ✅ |
| Padding::left | ratatui-widgets/src/block/padding.rs:122 | ✅ |
| Padding::right | ratatui-widgets/src/block/padding.rs:132 | ✅ |
| Padding::top | ratatui-widgets/src/block/padding.rs:142 | ✅ |
| Padding::bottom | ratatui-widgets/src/block/padding.rs:152 | ✅ |
| Borders::TOP | ratatui-widgets/src/borders.rs:33 | ✅ |
| Borders::RIGHT | ratatui-widgets/src/borders.rs:35 | ✅ |
| Borders::BOTTOM | ratatui-widgets/src/borders.rs:37 | ✅ |
| Borders::LEFT | ratatui-widgets/src/borders.rs:39 | ✅ |
| Borders::ALL | ratatui-widgets/src/borders.rs:41 | ✅ |
| Borders::NONE | ratatui-widgets/src/borders.rs:43 | ✅ |
| BorderType::Plain | ratatui-widgets/src/borders.rs:64 | ✅ |
| BorderType::Rounded | ratatui-widgets/src/borders.rs:66 | ✅ |
| BorderType::Double | ratatui-widgets/src/borders.rs:71 | ✅ |
| BorderType::Thick | ratatui-widgets/src/borders.rs:81 | ✅ |
| BorderType::LightDoubleDashed | ratatui-widgets/src/borders.rs:89 | ❌ |
| BorderType::HeavyDoubleDashed | ratatui-widgets/src/borders.rs:97 | ❌ |
| BorderType::LightTripleDashed | ratatui-widgets/src/borders.rs:105 | ❌ |
| BorderType::HeavyTripleDashed | ratatui-widgets/src/borders.rs:113 | ❌ |
| BorderType::LightQuadrupleDashed | ratatui-widgets/src/borders.rs:121 | ❌ |
| BorderType::HeavyQuadrupleDashed | ratatui-widgets/src/borders.rs:129 | ❌ |
| BorderType::QuadrantInside | ratatui-widgets/src/borders.rs:139 | ✅ |
| BorderType::QuadrantOutside | ratatui-widgets/src/borders.rs:144 | ✅ |
| TitlePosition::Top | ratatui-widgets/src/block.rs:49 | ✅ |
| TitlePosition::Bottom | ratatui-widgets/src/block.rs:51 | ✅ |

### Table Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Table struct | ratatui-widgets/src/table.rs:233 | ✅ |
| Table::rows | ratatui-widgets/src/table.rs:235 | ✅ |
| Table::header | ratatui-widgets/src/table.rs:238 | ✅ |
| Table::footer | ratatui-widgets/src/table.rs:241 | ✅ |
| Table::widths | ratatui-widgets/src/table.rs:244 | ✅ |
| Table::column_spacing | ratatui-widgets/src/table.rs:247 | ✅ |
| Table::row_highlight_style | ratatui-widgets/src/table.rs:256 | ✅ |
| Table::column_highlight_style | ratatui-widgets/src/table.rs:259 | ✅ |
| Table::cell_highlight_style | ratatui-widgets/src/table.rs:262 | ✅ |
|  Table::highlight_symbol | ratatui-widgets/src/table.rs:265 | ✅ |
| Table::highlight_spacing | ratatui-widgets/src/table.rs:268 | ✅ |
| Table::flex | ratatui-widgets/src/table.rs:271 | ✅ |
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
| Row struct | ratatui-widgets/src/table/row.rs:75 | ✅ |
| Cell struct | ratatui-widgets/src/table/cell.rs:51 | ✅ |
| HighlightSpacing::Always | ratatui-widgets/src/table/highlight_spacing.rs:10 | ✅ |
| HighlightSpacing::WhenSelected | ratatui-widgets/src/table/highlight_spacing.rs:14 | ✅ |
| HighlightSpacing::Never | ratatui-widgets/src/table/highlight_spacing.rs:18 | ✅ |

**Notes:**
- **TableState**: Implemented as Data.define attributes on Table widget itself (selected_row, selected_column, offset) instead of separate state object

### List Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| List struct | ratatui-widgets/src/list.rs:109 | ✅ |
| List::items | ratatui-widgets/src/list.rs:113 | ✅ |
| List::direction | ratatui-widgets/src/list.rs:117 | ✅ |
| List::highlight_style | ratatui-widgets/src/list.rs:119 | ✅ |
| List::highlight_symbol | ratatui-widgets/src/list.rs:121 | ✅ |
| List::repeat_highlight_symbol | ratatui-widgets/src/list.rs:123 | ✅ |
| List::highlight_spacing | ratatui-widgets/src/list.rs:125 | ✅ |
| List::scroll_padding | ratatui-widgets/src/list.rs:127 | ✅ |
| ListDirection::TopToBottom | ratatui-widgets/src/list.rs:140 | ✅ |
| ListDirection::BottomToTop | ratatui-widgets/src/list.rs:142 | ✅ |
| ListItem struct | ratatui-widgets/src/list/item.rs:73 | ✅ |
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

### BarChart Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| BarChart struct | ratatui-widgets/src/barchart.rs:83 | ✅ |
| BarChart::bar_width | ratatui-widgets/src/barchart.rs:87 | ✅ |
| BarChart::bar_gap | ratatui-widgets/src/barchart.rs:89 | ✅ |
| BarChart::group_gap | ratatui-widgets/src/barchart.rs:91 | ✅ |
| BarChart::bar_set | ratatui-widgets/src/barchart.rs:93 | ✅ |
| BarChart::max | ratatui-widgets/src/barchart.rs:106 | ✅ |
| BarChart::direction | ratatui-widgets/src/barchart.rs:108 | ✅ |
| Bar struct | ratatui-widgets/src/barchart/bar.rs:34 | ✅ |
| BarGroup struct | ratatui-widgets/src/barchart/bar_group.rs:21 | ✅ |

### Chart Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Chart struct | ratatui-widgets/src/chart.rs:510 | ✅ |
| Axis struct | ratatui-widgets/src/chart.rs:40 | ✅ |
| Axis::bounds | ratatui-widgets/src/chart.rs:44 | ✅ |
| Axis::labels | ratatui-widgets/src/chart.rs:46 | ✅ |
| Axis::labels_alignment | ratatui-widgets/src/chart.rs:50 | ✅ |
| Dataset struct | ratatui-widgets/src/chart.rs:320 | ✅ |
| Dataset::marker | ratatui-widgets/src/chart.rs:326 | ✅ |
| Dataset::graph_type | ratatui-widgets/src/chart.rs:328 | ✅ |
| GraphType::Scatter | ratatui-widgets/src/chart.rs:161 | ✅ |
| GraphType::Line | ratatui-widgets/src/chart.rs:167 | ✅ |
| GraphType::Bar | ratatui-widgets/src/chart.rs:170 | ✅ |
| LegendPosition::TopLeft | ratatui-widgets/src/chart.rs:184 | ✅ |
| LegendPosition::Top | ratatui-widgets/src/chart.rs:179 | ✅ |
| LegendPosition::TopRight | ratatui-widgets/src/chart.rs:182 | ✅ |
| LegendPosition::Left | ratatui-widgets/src/chart.rs:186 | ✅ |
| LegendPosition::Right | ratatui-widgets/src/chart.rs:187 | ✅ |
| LegendPosition::BottomLeft | ratatui-widgets/src/chart.rs:194 | ✅ |
| LegendPosition::Bottom | ratatui-widgets/src/chart.rs:190 | ✅ |
| LegendPosition::BottomRight | ratatui-widgets/src/chart.rs:192 | ✅ |

### Gauge Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Gauge struct | ratatui-widgets/src/gauge.rs:45 | ✅ |
| Gauge::ratio | ratatui-widgets/src/gauge.rs:47 | ✅ |
| Gauge::label | ratatui-widgets/src/gauge.rs:48 | ✅ |
| Gauge::use_unicode | ratatui-widgets/src/gauge.rs:49 | ✅ |
| Gauge::gauge_style | ratatui-widgets/src/gauge.rs:51 | ✅ |
| LineGauge struct | ratatui-widgets/src/gauge.rs:269 | ✅ |
| LineGauge::filled_symbol | ratatui-widgets/src/gauge.rs:274 | ✅ |
| LineGauge::unfilled_symbol | ratatui-widgets/src/gauge.rs:275 | ✅ |
| LineGauge::filled_style | ratatui-widgets/src/gauge.rs:276 | ✅ |
| LineGauge::unfilled_style | ratatui-widgets/src/gauge.rs:277 | ✅ |

### Sparkline Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Sparkline struct | ratatui-widgets/src/sparkline.rs:66 | ✅ |
| RenderDirection::LeftToRight | ratatui-widgets/src/sparkline.rs:93 | ✅ |
| RenderDirection::RightToLeft | ratatui-widgets/src/sparkline.rs:96 | ✅ |
| SparklineBar struct | ratatui-widgets/src/sparkline.rs:253 | ❌ |

### Scrollbar Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Scrollbar struct | ratatui-widgets/src/scrollbar.rs:87 | ✅ |
| ScrollbarOrientation::VerticalRight | ratatui-widgets/src/scrollbar.rs:112 | ✅ |
| ScrollbarOrientation::VerticalLeft | ratatui-widgets/src/scrollbar.rs:115 | ✅ |
| ScrollbarOrientation::HorizontalBottom | ratatui-widgets/src/scrollbar.rs:118 | ✅ |
| ScrollbarOrientation::HorizontalTop | ratatui-widgets/src/scrollbar.rs:121 | ✅ |
| ScrollbarState struct | ratatui-widgets/src/scrollbar.rs:149 | ⚠️ |
| ScrollDirection::Forward | ratatui-widgets/src/scrollbar.rs:169 | ❌ |
| ScrollDirection::Backward | ratatui-widgets/src/scrollbar.rs:172 | ❌ |

**Notes:**
- **ScrollbarState**: Implemented as Data.define attributes on Scrollbar widget itself (content_length, position) instead of separate state object

### Calendar Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Monthly struct | ratatui-widgets/src/calendar.rs:26 | ✅ |
| CalendarEventStore struct | ratatui-widgets/src/calendar.rs:258 | ❌ |

### Canvas Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Canvas struct | ratatui-widgets/src/canvas.rs:721 | ✅ |
| Context struct | ratatui-widgets/src/canvas.rs:515 | ❌ |
| Painter struct | ratatui-widgets/src/canvas.rs:403 | ❌ |
| Label struct | ratatui-widgets/src/canvas.rs:61 | ❌ |
| Line shape | ratatui-widgets/src/canvas/line.rs:8 | ✅ |
| Circle shape | ratatui-widgets/src/canvas/circle.rs:9 | ✅ |
| Rectangle shape | ratatui-widgets/src/canvas/rectangle.rs:10 | ✅ |
| Points shape | ratatui-widgets/src/canvas/points.rs:7 | ❌ |
| Map struct | ratatui-widgets/src/canvas/map.rs:38 | ✅ |
| MapResolution::Low | ratatui-widgets/src/canvas/map.rs:13 | ✅ |
| MapResolution::High | ratatui-widgets/src/canvas/map.rs:16 | ✅ |

### Tabs Widget

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Tabs struct | ratatui-widgets/src/tabs.rs:51 | ✅ |

### Other Widgets

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Clear widget | ratatui-widgets/src/clear.rs:30 | ✅ |
| RatatuiLogo widget | ratatui-widgets/src/logo.rs:59 | ✅ |
| RatatuiLogo Size::Tiny | ratatui-widgets/src/logo.rs:68 | ✅ |
| RatatuiLogo Size::Small | ratatui-widgets/src/logo.rs:71 | ✅ |
| RatatuiLogo Size::Medium | ratatui-widgets/src/logo.rs:74 | ✅ |
| RatatuiLogo Size::Large | ratatui-widgets/src/logo.rs:77 | ✅ |

## Buffer Features

| Feature Name | File/Line | Status |
|--------------|-----------|--------|
| Buffer struct | ratatui-core/src/buffer/buffer.rs:66 | ✅ |
| Buffer::empty | ratatui-core/src/buffer/buffer.rs:77 | ❌ |
| Buffer::filled | ratatui-core/src/buffer/buffer.rs:83 | ❌ |
| Buffer::with_lines | ratatui-core/src/buffer/buffer.rs:91 | ❌ |
| Buffer::content | ratatui-core/src/buffer/buffer.rs:107 | ✅ |
| Buffer::get | ratatui-core/src/buffer/buffer.rs:130 | ✅ |
| Buffer::get_mut | ratatui-core/src/buffer/buffer.rs:150 | ❌ |
| Buffer::index_of | ratatui-core/src/buffer/buffer.rs:248 | ❌ |
| Buffer::set_string | ratatui-core/src/buffer/buffer.rs:323 | ❌ |
| Buffer::set_stringn | ratatui-core/src/buffer/buffer.rs:335 | ❌ |
| Buffer::set_line | ratatui-core/src/buffer/buffer.rs:372 | ❌ |
| Buffer::set_span | ratatui-core/src/buffer/buffer.rs:394 | ❌ |
| Buffer::set_style | ratatui-core/src/buffer/buffer.rs:404 | ❌ |
| Buffer::reset | ratatui-core/src/buffer/buffer.rs:427 | ❌ |
| Cell struct | ratatui-core/src/buffer/cell.rs:9 | ✅ |
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
| TestBackend | ratatui-core/src/backend/test.rs:* | ✅ |
| CrosstermBackend | ratatui-crossterm/src/lib.rs:* | ✅ |
| TermionBackend | ratatui-termion/src/lib.rs:* | ❌ |
| TermwizBackend | ratatui-termwiz/src/lib.rs:* | ❌ |

**Notes:**
- **Backend trait**: Abstracted away. Terminal uses Crossterm backend internally, not exposed to Ruby API
- **ClearType**: Not exposed. Clearing handled via `Clear` widget
