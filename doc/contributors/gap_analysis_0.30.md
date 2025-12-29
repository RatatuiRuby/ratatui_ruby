<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Ratatui 0.30 Gap Analysis

Comparison of ratatui 0.30 features vs ratatui_ruby current implementation.

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
| `border_style()` | `border_color:` | ⚠️ Partial (color only, not full style) |
| `border_type()` | `border_type:` | ✅ |
| `border_set()` | — | ❌ **MISSING** (custom border chars) |
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
| `repeat_highlight_symbol()` | — | ❌ **MISSING** |
| `highlight_spacing()` | — | ❌ **MISSING** |
| `direction()` | `direction:` | ✅ |
| `scroll_padding()` | — | ❌ **MISSING** |

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
| `column_highlight_style()` | — | ❌ **MISSING** |
| `cell_highlight_style()` | — | ❌ **MISSING** |
| `highlight_symbol()` | `highlight_symbol:` | ✅ |
| `highlight_spacing()` | — | ❌ **MISSING** |
| `column_spacing()` | — | ❌ **MISSING** |
| `flex()` | `flex:` | ✅ |

Note: Table widths support all constraints (`:length`, `:percentage`, `:min`, `:max`, `:fill`, `:ratio`).

---

## Tabs Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `titles()` | `titles:` | ✅ |
| `select()` | `selected_index:` | ✅ |
| `block()` | `block:` | ✅ |
| `style()` | — | ❌ **MISSING** |
| `highlight_style()` | `highlight_style:` | ✅ |
| `divider()` | `divider:` | ✅ |
| `padding()` / `padding_left()` / `padding_right()` | — | ❌ **MISSING** |

---

## Paragraph Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `text` | `text:` | ✅ |
| `block()` | `block:` | ✅ |
| `style()` | `style:` | ✅ |
| `wrap()` | `wrap:` | ✅ |
| `scroll()` | `scroll:` | ✅ |
| `alignment()` | `align:` | ✅ |
| `line_count()` | — | ❌ **MISSING** (read-only, not critical) |
| `line_width()` | — | ❌ **MISSING** (read-only, not critical) |

---

## Scrollbar Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `content_length` | `content_length:` | ✅ |
| `position` | `position:` | ✅ |
| `orientation()` | `orientation:` | ⚠️ Partial |
| `thumb_symbol()` | `thumb_symbol:` | ✅ |
| `thumb_style()` | `thumb_style:` | ✅ |
| `track_symbol()` | `track_symbol:` | ✅ |
| `track_style()` | `track_style:` | ✅ |
| `begin_symbol()` | `begin_symbol:` | ✅ |
| `begin_style()` | `begin_style:` | ✅ |
| `end_symbol()` | `end_symbol:` | ✅ |
| `end_style()` | `end_style:` | ✅ |
| `style()` | `style:` | ✅ |

Orientation: Ruby supports `:vertical`/`:horizontal` but ratatui has 4 variants:
- `VerticalRight`, `VerticalLeft`, `HorizontalBottom`, `HorizontalTop`

---

## Gauge Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `ratio()` | `ratio:` | ✅ |
| `percent()` | `percent:` | ✅ (alternative to ratio) |
| `label()` | `label:` | ✅ |
| `block()` | `block:` | ✅ |
| `style()` | — | ❌ **MISSING** |
| `gauge_style()` | `style:` | ✅ (mapped) |
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
| `style()` | — | ❌ **MISSING** |
| `gauge_style()` | — | ❌ **MISSING** |
| `line_set()` | — | ❌ **MISSING** (deprecated) |

---

## Sparkline Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `data()` | `data:` | ✅ |
| `max()` | `max:` | ✅ |
| `block()` | `block:` | ✅ |
| `style()` | `style:` | ✅ |
| `bar_set()` | — | ❌ **MISSING** |
| `direction()` | — | ❌ **MISSING** (LeftToRight/RightToLeft) |
| `absent_value_style()` | — | ❌ **MISSING** |
| `absent_value_symbol()` | — | ❌ **MISSING** |

---

## BarChart Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `data()` | `data:` | ✅ |
| `bar_width()` | `bar_width:` | ✅ |
| `bar_gap()` | `bar_gap:` | ✅ |
| `max()` | `max:` | ✅ |
| `block()` | `block:` | ✅ |
| `bar_style()` | `style:` | ✅ (mapped) |
| `value_style()` | — | ❌ **MISSING** |
| `label_style()` | — | ❌ **MISSING** |
| `bar_set()` | — | ❌ **MISSING** |
| `group_gap()` | — | ❌ **MISSING** |
| `direction()` | — | ❌ **MISSING** |
| Grouped bar charts | — | ❌ **MISSING** (BarGroup API) |

---

## Chart Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `datasets` | `datasets:` | ✅ |
| `x_axis` / `y_axis` | `x_axis:` / `y_axis:` | ✅ |
| `block()` | `block:` | ✅ |
| `style()` | `style:` | ✅ |
| `legend_position()` | — | ❌ **MISSING** |
| `hidden_legend_constraints()` | — | ❌ **MISSING** |

### Axis

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `title()` | `title:` | ✅ |
| `bounds()` | `bounds:` | ✅ |
| `labels()` | `labels:` | ✅ |
| `style()` | `style:` | ✅ |
| `labels_alignment()` | — | ❌ **MISSING** |

### Dataset

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `name()` | `name:` | ✅ |
| `data()` | `data:` | ✅ |
| `marker()` | `marker:` | ✅ |
| `graph_type()` | `graph_type:` | ✅ |
| `style()` | `color:` | ⚠️ Partial (color only) |

---

## Calendar Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `display_date` | `year:` / `month:` | ✅ |
| `block()` | `block:` | ✅ |
| `default_style()` | `day_style:` | ✅ |
| `show_month_header()` | `header_style:` | ⚠️ Partial |
| `show_weekdays_header()` | — | ❌ **MISSING** |
| `show_surrounding()` | — | ❌ **MISSING** |
| Event highlighting (`DateStyler`) | — | ❌ **MISSING** |

---

## Canvas Widget

| Ratatui Feature | ratatui_ruby | Status |
|-----------------|--------------|--------|
| `x_bounds` / `y_bounds` | ✅ | ✅ |
| `marker()` | `marker:` | ✅ |
| `block()` | `block:` | ✅ |
| `background_color()` | — | ❌ **MISSING** |
| Labels (ctx.print) | — | ❌ **MISSING** |

### Markers

| Ratatui 0.30 | ratatui_ruby | Status |
|--------------|--------------|--------|
| `Marker::Dot` | `:dot` | ✅ |
| `Marker::Block` | `:block` | ✅ |
| `Marker::Bar` | `:bar` | ✅ |
| `Marker::Braille` | `:braille` | ✅ |
| `Marker::HalfBlock` | — | ❌ **MISSING** |
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

## Missing Widgets

| Ratatui 0.30 Widget | Status |
|---------------------|--------|
| `RatatuiLogo` | ❌ Not needed (branding widget) |
| `RatatuiMascot` | ❌ Not needed (branding widget) |

---

## Priority Recommendations

### High Priority (Common Use Cases)
1. **Scrollbar orientation variants** - VerticalLeft, HorizontalTop


### Medium Priority
3. **Chart::legend_position** - Nice to have
4. **Sparkline::direction** - Niche use case

### Lower Priority
5. **Canvas labels** - Advanced use case
6. **BarChart grouped** - Advanced charting
