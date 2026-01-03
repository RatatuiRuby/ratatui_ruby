<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# v0.7.0 Alignment Audit: Enums and Constants

Audit of enum and constant alignment between Ratatui/Crossterm and RatatuiRuby.

> [!IMPORTANT]
> **MISSING** = Can be added as new features, backwards-compatible.
> **MISALIGNED** = Requires breaking changes before v1.0.0.

---

## Summary

| Enum | Ratatui Variants | Ruby Symbols | Status |
|------|------------------|--------------|--------|
| `Alignment` | 3 | 3 | ✅ Aligned |
| `BorderType` | 6 | 6+ | ✅ Aligned (Ruby adds `:hidden`) |
| `Flex` | 6 | 6 | ✅ Aligned |
| `HighlightSpacing` | 3 | 3 | ✅ Aligned |
| `Borders` | 6 flags | 5 symbols | ✅ Aligned |
| `GraphType` | 2 | 2 | ✅ Aligned |
| `LegendPosition` | 8 | 4 | ⚠️ MISSING 4 |
| `ListDirection` | 2 | 2 | ✅ Aligned |
| `RenderDirection` (Sparkline) | 2 | 2 | ✅ Aligned |

---

## MISALIGNED (Breaking Changes Required)

**None.** All exposed enum values are correctly aligned.

---

## MISSING — LegendPosition Variants

| Ratatui | Ruby | Status |
|---------|------|--------|
| `TopLeft` | `:top_left` | ✅ |
| `TopRight` | `:top_right` | ✅ |
| `BottomLeft` | `:bottom_left` | ✅ |
| `BottomRight` | `:bottom_right` | ✅ |
| `Top` | ❌ | MISSING |
| `Bottom` | ❌ | MISSING |
| `Left` | ❌ | MISSING |
| `Right` | ❌ | MISSING |

**Impact**: Users cannot place chart legends at edge-center positions.

---

## Aligned Enums (Detail)

### `Alignment`

| Ratatui | Ruby | Used By |
|---------|------|---------|
| `Left` | `:left` | Paragraph, Line, Block title |
| `Center` | `:center` | Paragraph, Line, Block title |
| `Right` | `:right` | Paragraph, Line, Block title |

---

### `BorderType`

| Ratatui | Ruby | Characters |
|---------|------|------------|
| `Plain` | `:plain` | `┌─┐│└┘` |
| `Rounded` | `:rounded` | `╭─╮│╰╯` |
| `Double` | `:double` | `╔═╗║╚╝` |
| `Thick` | `:thick` | `┏━┓┃┗┛` |
| `QuadrantInside` | `:quadrant_inside` | `▗▄▖▐▝▘` |
| `QuadrantOutside` | `:quadrant_outside` | `▛▀▜▌▙▟` |
| N/A | `:hidden` | Ruby extension (spaces) |

---

### `Flex`

| Ratatui | Ruby |
|---------|------|
| `Legacy` | `:legacy` |
| `Start` | `:start` |
| `End` | `:end` |
| `Center` | `:center` |
| `SpaceBetween` | `:space_between` |
| `SpaceAround` | `:space_around` |

---

### `HighlightSpacing`

| Ratatui | Ruby | Used By |
|---------|------|---------|
| `Always` | `:always` | Table, List |
| `WhenSelected` | `:when_selected` | Table, List |
| `Never` | `:never` | Table, List |

---

### `Borders` (Bitflags)

| Ratatui | Ruby |
|---------|------|
| `NONE` | `[]` (empty array) |
| `TOP` | `:top` |
| `BOTTOM` | `:bottom` |
| `LEFT` | `:left` |
| `RIGHT` | `:right` |
| `ALL` | `:all` |

Ruby uses array of symbols: `borders: [:top, :bottom]` vs Ratatui's `Borders::TOP | Borders::BOTTOM`.

---

### `GraphType`

| Ratatui | Ruby |
|---------|------|
| `Scatter` | `:scatter` |
| `Line` | `:line` |

---

### `ListDirection`

| Ratatui | Ruby |
|---------|------|
| `TopToBottom` | `:top_to_bottom` |
| `BottomToTop` | `:bottom_to_top` |

---

### `RenderDirection` (Sparkline)

| Ratatui | Ruby |
|---------|------|
| `LeftToRight` | `:left_to_right` |
| `RightToLeft` | `:right_to_left` |

---

## Recommendations

| Priority | Item | Notes |
|----------|------|-------|
| Low | Add `:top`, `:bottom`, `:left`, `:right` to `legend_position` | Edge-center legend positions |

All missing items are **additive** and do not require breaking changes.
