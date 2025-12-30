<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Ratatui 0.30 Gap Analysis

Comparison of ratatui 0.30 features vs ratatui_ruby current implementation.

**Last Updated:** Dec 30, 2025 - Audited against Ratatui 0.30.0 official docs. Removed deprecated items, added missing features.

## Layout & Constraints

### Flex Modes

| Ratatui 0.30 | ratatui_ruby | Status |
|--------------|--------------|--------|
| `Flex::Legacy` | `:legacy` | ✅ |
| `Flex::Start` | `:start` | ✅ |
| `Flex::End` | `:end` | ✅ |
| `Flex::Center` | `:center` | ✅ |
| `Flex::SpaceBetween` | `:space_between` | ✅ |
| `Flex::SpaceAround` | `:space_around` | ✅ |
| `Flex::SpaceEvenly` | `:space_evenly` | ✅ |

### Constraints

| Ratatui 0.30 | ratatui_ruby | Status |
|--------------|--------------|--------|
| `Constraint::Length` | `:length` | ✅ |
| `Constraint::Percentage` | `:percentage` | ✅ |
| `Constraint::Min` | `:min` | ✅ |
| `Constraint::Max` | `:max` | ✅ |
| `Constraint::Fill` | `:fill` | ✅ |
| `Constraint::Ratio(n, d)` | `:ratio` | ✅ |

---

## Block Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `title()` | `title:` (and `titles:`) | ✅ |
| `title_top()` | `titles: [{position: :top}]` | ✅ |
| `title_bottom()` | `titles: [{position: :bottom}]` | ✅ |
| `title_style()` | `title_style:` | ✅ |
| `title_style()` | `titles: [{style: ...}]` | ✅ |
| `title_alignment()` | `title_alignment:` / `titles: [{alignment: ...}]` | ✅ |
| `title_position()` | `titles: [{position: ...}]` | ✅ |
| `title_position()` | `titles: [{position: ...}]` | ✅ |
| `borders()` | `borders:` | ✅ |
| `border_style()` | `border_style:` | ✅ |
| `border_type()` | `border_type:` | ✅ |
| `border_set()` | `border_set:` | ✅ |
| `style()` | `style:` | ✅ |
| `padding()` | `padding:` | ✅ |

---

## List Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `items()` | `items:` | ✅ |
| `block()` | `block:` | ✅ |
| `style()` | `style:` | ✅ |
| `highlight_symbol()` | `highlight_symbol:` | ✅ |
| `highlight_style()` | `highlight_style:` | ✅ |
| `repeat_highlight_symbol()` | `repeat_highlight_symbol:` | ✅ |
| `highlight_spacing()` | `highlight_spacing:` | ✅ |
| `direction()` | `direction:` | ✅ |
| `scroll_padding()` | `scroll_padding:` | ✅ |

---

## Table Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `rows()` | `rows:` | ✅ |
| `widths()` | `widths:` | ✅ |
| `header()` | `header:` | ✅ |
| `footer()` | `footer:` | ✅ |
| `block()` | `block:` | ✅ |
| `style()` | `style:` | ✅ |
| `row_highlight_style()` | `highlight_style:` | ✅ |
| `column_highlight_style()` | `column_highlight_style:` | ✅ |
| `cell_highlight_style()` | `cell_highlight_style:` | ✅ |
| `state.select_column()` | `selected_column:` | ✅ |
| `highlight_symbol()` | `highlight_symbol:` | ✅ |
| `highlight_spacing()` | `highlight_spacing:` | ✅ |
| `column_spacing()` | `column_spacing:` | ✅ |
| `flex()` | `flex:` | ✅ |

Note: Table widths support all constraints (`:length`, `:percentage`, `:min`, `:max`, `:fill`, `:ratio`).

---

## Tabs Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `titles()` | `titles:` | ✅ |
| `select()` | `selected_index:` | ✅ |
| `block()` | `block:` | ✅ |
| `style()` | `style:` | ✅ |
| `highlight_style()` | `highlight_style:` | ✅ |
| `divider()` | `divider:` | ✅ |
| `padding()` / `padding_left()` / `padding_right()` | `padding_left:` / `padding_right:` | ✅ |
| `width()` | `width` | ✅ |

---

## Paragraph Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `text` | `text:` | ✅ |
| `block()` | `block:` | ✅ |
| `style()` | `style:` | ✅ |
| `wrap()` | `wrap:` | ✅ |
| `scroll()` | `scroll:` | ✅ |
| `alignment()` | `alignment:` | ✅ |
| `line_count()` | `line_count` | ✅ |
| `line_width()` | `line_width` | ✅ |

---

## Scrollbar Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `content_length` | `content_length:` | ✅ |
| `position` | `position:` | ✅ |
| `orientation()` | `orientation:` | ✅ |
| `thumb_symbol()` | `thumb_symbol:` | ✅ |
| `thumb_style()` | `thumb_style:` | ✅ |
| `track_symbol()` | `track_symbol:` | ✅ |
| `track_style()` | `track_style:` | ✅ |
| `begin_symbol()` | `begin_symbol:` | ✅ |
| `begin_style()` | `begin_style:` | ✅ |
| `end_symbol()` | `end_symbol:` | ✅ |
| `end_style()` | `end_style:` | ✅ |
| `style()` | `style:` | ✅ |
| `get_position()` | `position` (attr_reader) | ✅ |


---

## Gauge Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `ratio()` | `ratio:` | ✅ |
| `percent()` | `percent:` | ✅ (alternative to ratio) |
| `label()` | `label:` | ✅ |
| `block()` | `block:` | ✅ |
| `style()` | `style:` | ✅ |
| `gauge_style()` | `gauge_style:` | ✅ |
| `use_unicode()` | `use_unicode:` | ✅ |

---

## LineGauge Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `ratio()` | `ratio:` | ✅ |
| `label()` | `label:` | ✅ |
| `block()` | `block:` | ✅ |
| `filled_symbol()` | `filled_symbol:` | ✅ |
| `unfilled_symbol()` | `unfilled_symbol:` | ✅ |
| `filled_style()` | `filled_style:` | ✅ |
| `unfilled_style()` | `unfilled_style:` | ✅ |
| `style()` | `style:` | ✅ |

---

## Sparkline Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `data()` | `data:` | ✅ |
| `max()` | `max:` | ✅ |
| `block()` | `block:` | ✅ |
| `style()` | `style:` | ✅ |
| `bar_set()` | `bar_set:` | ✅ |
| `direction()` | `direction:` | ✅ |
| `absent_value_style()` | `absent_value_style:` | ✅ |
| `absent_value_symbol()` | `absent_value_symbol:` | ✅ |

**Note on absent_value_symbol/style:** The data array accepts `Integer` or `nil`. A `nil` value marks an absent value (distinct from a `0` value). Absent values render with the style set by `absent_value_style:` and the symbol set by `absent_value_symbol:`. These features are fully implemented in ratatui 0.30.0+.


---

## BarChart Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `data()` | `data:` | ✅ |
| `bar_width()` | `bar_width:` | ✅ |
| `bar_gap()` | `bar_gap:` | ✅ |
| `max()` | `max:` | ✅ |
| `block()` | `block:` | ✅ |
| `style()` (on BarChart) | `style:` | ✅ |
| `value_style()` | `value_style:` | ✅ |
| `label_style()` | `label_style:` | ✅ |
| `bar_set()` | `bar_set:` | ✅ |
| `group_gap()` | `group_gap:` | ✅ |
| `direction()` | `direction:` | ✅ |
| Grouped bar charts | `data: [BarGroup...]` | ✅ |

---

## Chart Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `datasets` | `datasets:` | ✅ |
| `x_axis` / `y_axis` | `x_axis:` / `y_axis:` | ✅ |
| `block()` | `block:` | ✅ |
| `style()` | `style:` | ✅ |
| `legend_position()` | `legend_position:` | ✅ |
| `hidden_legend_constraints()` | `hidden_legend_constraints:` | ✅ |

### Axis

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `title()` | `title:` | ✅ |
| `bounds()` | `bounds:` | ✅ |
| `labels()` | `labels:` | ✅ |
| `style()` | `style:` | ✅ |
| `labels_alignment()` | `labels_alignment:` | ✅ |

### Dataset

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `name()` | `name:` | ✅ |
| `data()` | `data:` | ✅ |
| `marker()` | `marker:` | ✅ |
| `graph_type()` | `graph_type:` | ✅ |
| `style()` | `style:` | ✅ |

---

## Calendar Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `display_date` | `year:` / `month:` | ✅ |
| `block()` | `block:` | ✅ |
| `default_style()` | `default_style:` | ✅ |
| `show_month_header()` | `show_month_header:` | ✅ |
| `show_weekdays_header()` | `show_weekdays_header:` | ✅ |
| `show_surrounding()` | `show_surrounding:` | ✅ |
| `Event highlighting` | `events:` | ✅ |

---

## Canvas Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `x_bounds` / `y_bounds` | ✅ | ✅ |
| `marker()` | `marker:` | ✅ |
| `block()` | `block:` | ✅ |
| `background_color()` | `background_color:` | ✅ |
| Labels (ctx.print) | `Shape::Label` | ✅ |
| Block border merging (0.30.0) | Automatic in Ratatui | ✅ |

### Markers

| Ratatui 0.30 | ratatui_ruby | Status |
|--------------|--------------|--------|
| `Marker::Dot` | `:dot` | ✅ |
| `Marker::Block` | `:block` | ✅ |
| `Marker::Bar` | `:bar` | ✅ |
| `Marker::Braille` | `:braille` | ✅ |
| `Marker::HalfBlock` | `:half_block` | ✅ |
| `Marker::Quadrant` | `:quadrant` | ✅ |
| `Marker::Sextant` | `:sextant` | ✅ |
| `Marker::Octant` | `:octant` | ✅ |

---

## Style / Modifiers

| Ratatui Modifier | ratatui_ruby | Status |
|------------------|--------------|--------|
| `BOLD` | `:bold` | ✅ |
| `DIM` | `:dim` | ✅ |
| `ITALIC` | `:italic` | ✅ |
| `UNDERLINED` | `:underlined` | ✅ |
| `SLOW_BLINK` | `:slow_blink` | ✅ |
| `RAPID_BLINK` | `:rapid_blink` | ✅ |
| `REVERSED` | `:reversed` | ✅ |
| `HIDDEN` | `:hidden` | ✅ |
| `CROSSED_OUT` | `:crossed_out` | ✅ |

All modifiers are covered. ✅

---

## Additional Widgets

| Ratatui 0.30 Widget | Status |
|---------------------|--------|
| `RatatuiLogo` | ✅ (No custom style support) |
| `RatatuiMascot` | ⏳ Planned #8 (useful for demos, lowest priority) |


