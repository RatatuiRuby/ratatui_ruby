<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# v0.7.0 Alignment Audit (Parameter-Level)

This document audits alignment between RatatuiRuby v0.7.0 and the upstream Ratatui/Crossterm Rust libraries at the **parameter and enum value level**. Only gaps are listed.

> [!IMPORTANT]
> **MISSING** = Can be added as new features, backwards-compatible.
> **MISALIGNED** = Requires breaking changes before v1.0.0 release.

---

## MISALIGNED (Breaking Changes Required)

These require breaking changes before v1.0.0.

### `Text::Line` — ~~Missing `style` Field~~ ✅ Fixed

| Current Ruby API | Ratatui API | Status |
|------------------|-------------|--------|
| `Line.new(spans:, alignment:, style:)` | `Line { style, alignment, spans }` | ✅ Aligned |

**Fixed in v0.7.0**: Added `style:` parameter.

---

### `Widgets::Table` — ~~Deprecated Parameter Name~~ ✅ Fixed

| Ruby Parameter | Ratatui Parameter | Status |
|----------------|-------------------|--------|
| `row_highlight_style:` | `row_highlight_style` | ✅ Aligned |

**Fixed in v0.7.0**: Renamed `highlight_style:` → `row_highlight_style:`.

---

## MISSING — Layout Module

### `Layout::Rect` — Missing Methods

| Missing Method | Signature | Notes |
|----------------|-----------|-------|
| `area` | `rect.area` → `Integer` | Returns `width * height` |
| `left` | `rect.left` → `Integer` | Returns `x` (alias) |
| `right` | `rect.right` → `Integer` | Returns `x + width` |
| `top` | `rect.top` → `Integer` | Returns `y` (alias) |
| `bottom` | `rect.bottom` → `Integer` | Returns `y + height` |
| `union` | `rect.union(other)` → `Rect` | Bounding box of both rects |
| `inner` | `rect.inner(margin)` → `Rect` | Shrink by margin |
| `offset` | `rect.offset(dx, dy)` → `Rect` | Translate position |
| `clamp` | `rect.clamp(other)` → `Rect` | Clamp to bounds |
| `rows` | `rect.rows` → `Iterator` | Iterate row positions |
| `columns` | `rect.columns` → `Iterator` | Iterate column positions |
| `positions` | `rect.positions` → `Iterator` | Iterate all positions |
| `is_empty` | `rect.empty?` → `Boolean` | True if zero area |

---

### `Layout::Constraint` — Missing Batch Constructors

| Missing Method | Signature |
|----------------|-----------|
| `from_lengths` | `Constraint.from_lengths([10, 20, 30])` → `[Constraint]` |
| `from_percentages` | `Constraint.from_percentages([25, 50, 25])` → `[Constraint]` |
| `from_mins` | `Constraint.from_mins([5, 10, 15])` → `[Constraint]` |
| `from_maxes` | `Constraint.from_maxes([20, 30, 40])` → `[Constraint]` |
| `from_fills` | `Constraint.from_fills([1, 2, 1])` → `[Constraint]` |
| `from_ratios` | `Constraint.from_ratios([[1,4], [2,4], [1,4]])` → `[Constraint]` |

---

### `Layout::Layout` — Missing Parameters

| Missing Parameter | Ratatui Type | Notes |
|-------------------|--------------|-------|
| `margin` | `Margin { horizontal, vertical }` | Edge margins |
| `spacing` | `u16` | Gap between segments |

---

## MISSING — Style Module

### `Style::Style` — Missing Parameters/Methods

| Missing | Ratatui API | Notes |
|---------|-------------|-------|
| `sub_modifier` | `style.remove_modifier(Modifier::BOLD)` | Remove specific modifiers |
| `underline_color` | `style.underline_color(Color::Red)` | Set underline color separately |

---

## MISSING — Text Module

### `Text::Span` — Missing Methods

| Missing Method | Signature | Notes |
|----------------|-----------|-------|
| `width` | `span.width` → `Integer` | Display width in terminal cells |
| `raw` | `Span.raw(content)` → `Span` | Constructor without style (alias for `new(content:)`) |
| `patch_style` | `span.patch_style(style)` → `Span` | Merge style on top of existing |
| `reset_style` | `span.reset_style` → `Span` | Clear style |

---

### `Text::Line` — Missing Methods

| Missing Method | Signature | Notes |
|----------------|-----------|-------|
| `left_aligned` | `line.left_aligned` → `Line` | Fluent setter for `:left` alignment |
| `centered` | `line.centered` → `Line` | Fluent setter for `:center` alignment |
| `right_aligned` | `line.right_aligned` → `Line` | Fluent setter for `:right` alignment |
| `push_span` | `line.push_span(span)` → `Line` | Append span |
| `patch_style` | `line.patch_style(style)` → `Line` | Merge style on all spans |
| `reset_style` | `line.reset_style` → `Line` | Clear style on all spans |

---

## MISSING — Widgets Module

### `Widgets::List` — Missing Parameters

| Missing Parameter | Ratatui Name | Notes |
|-------------------|--------------|-------|
| N/A | N/A | List is fully aligned |

---

### `Widgets::Table` — Missing Row Methods (via `Widgets::Row`)

| Missing | Ratatui API | Notes |
|---------|-------------|-------|
| `enable_strikethrough` | `row.enable_strikethrough()` | Enable strikethrough on row |

---

### `Widgets::Gauge` — Widget Not Implemented

Ratatui has `Gauge` and `LineGauge` widgets. These are not currently exposed in RatatuiRuby.

---

### `Widgets::Sparkline` — Missing Parameters

| Missing Parameter | Ratatui Name | Notes |
|-------------------|--------------|-------|
| `max` | `max` | Maximum value for scaling |
| `bar_set` | `bar_set` | Custom bar symbols |

---

### `Widgets::Tabs` — Missing Parameters

| Missing Parameter | Ratatui Name | Notes |
|-------------------|--------------|-------|
| `padding` | `padding` | Padding between tabs |
| `divider` | `divider` | Divider between tabs |

---

### `Widgets::Chart` — Fully Aligned

Chart, Axis, and Dataset parameters are all aligned with Ratatui equivalents.

---

## MISSING — Event Module (Crossterm)

### `MediaKeyCode` — All Values Aligned

Ruby exposes all crossterm `MediaKeyCode` variants with snake_case mapping:

| Crossterm | Ruby |
|-----------|------|
| `Play` | `:play` / `"play"` |
| `Pause` | `:media_pause` / `"media_pause"` |
| `PlayPause` | `:play_pause` / `"play_pause"` |
| `Reverse` | `:reverse` / `"reverse"` |
| `Stop` | `:stop` / `"stop"` |
| `FastForward` | `:fast_forward` / `"fast_forward"` |
| `Rewind` | `:rewind` / `"rewind"` |
| `TrackNext` | `:track_next` / `"track_next"` |
| `TrackPrevious` | `:track_previous` / `"track_previous"` |
| `Record` | `:record` / `"record"` |
| `LowerVolume` | `:lower_volume` / `"lower_volume"` |
| `RaiseVolume` | `:raise_volume` / `"raise_volume"` |
| `MuteVolume` | `:mute_volume` / `"mute_volume"` |

---

### `ModifierKeyCode` — All Values Aligned

Ruby exposes all crossterm `ModifierKeyCode` variants:

| Crossterm | Ruby |
|-----------|------|
| `LeftShift` | `:left_shift` |
| `LeftControl` | `:left_control` |
| `LeftAlt` | `:left_alt` |
| `LeftSuper` | `:left_super` |
| `LeftHyper` | `:left_hyper` |
| `LeftMeta` | `:left_meta` |
| `RightShift` | `:right_shift` |
| `RightControl` | `:right_control` |
| `RightAlt` | `:right_alt` |
| `RightSuper` | `:right_super` |
| `RightHyper` | `:right_hyper` |
| `RightMeta` | `:right_meta` |
| `IsoLevel3Shift` | `:iso_level3_shift` |
| `IsoLevel5Shift` | `:iso_level5_shift` |

---

### `KeyModifiers` — All Values Aligned

| Crossterm | Ruby |
|-----------|------|
| `SHIFT` | `"shift"` |
| `CONTROL` | `"ctrl"` |
| `ALT` | `"alt"` |
| `SUPER` | `"super"` |
| `HYPER` | `"hyper"` |
| `META` | `"meta"` |

---

## Summary

| Category | Count | Priority |
|----------|-------|----------|
| **MISALIGNED** (breaking) | ~~2~~ 0 | ✅ All fixed in v0.7.0 |
| **MISSING methods** | ~25 | Low (additive) |
| **MISSING parameters** | ~10 | Low (additive) |
| **MISSING widgets** | Gauge, LineGauge | Medium (new features) |

### Pre-v1.0.0 Checklist

- [x] Add `style:` parameter to `Text::Line`
- [x] Rename `highlight_style:` → `row_highlight_style:` in `Widgets::Table`