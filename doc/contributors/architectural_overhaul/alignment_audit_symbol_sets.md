<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# v0.7.0 Alignment Audit: Symbol Sets

Audit of symbol set alignment between Ratatui's `symbols::` module and RatatuiRuby.

> [!IMPORTANT]
> **MISSING** = Can be added as new features, backwards-compatible.
> **MISALIGNED** = Requires breaking changes before v1.0.0.

---

## Summary

| Symbol Category | Ratatui | RatatuiRuby | Status |
|-----------------|---------|-------------|--------|
| `Marker` enum | 5 variants | 4 exposed | ⚠️ MISSING 1 |
| `border::Set` | 12 predefined sets | Via `border_type:` symbols | ✅ Aligned |
| Custom `border::Set` | Custom struct | Via `border_set:` hash | ✅ Aligned |
| `line::Set` | 4 predefined sets | ❌ Not exposed | MISSING |
| `bar::Set` | 2 predefined sets | ❌ Not exposed | MISSING |
| `block::Set` | 2 predefined sets | ❌ Not exposed | MISSING |
| `scrollbar::Set` | 4 predefined sets | ❌ Not exposed | MISSING |
| `shade` constants | 5 constants | ❌ Not exposed | MISSING |

---

## MISALIGNED (Breaking Changes Required)

**None.** All exposed symbol sets are correctly aligned.

---

## MISSING — Marker Enum

### `Marker::HalfBlock`

| Ratatui | RatatuiRuby | Status |
|---------|-------------|--------|
| `Marker::Dot` | `:dot` | ✅ |
| `Marker::Block` | `:block` | ✅ |
| `Marker::Bar` | `:bar` | ✅ |
| `Marker::Braille` | `:braille` | ✅ |
| `Marker::HalfBlock` | ❌ Not exposed | MISSING |

**Impact**: Users cannot use the `HalfBlock` marker type, which provides double-resolution square pixels using `█`, `▄`, and `▀` characters.

---

## MISSING — Line Set Customization

Ratatui provides `symbols::line::Set` with predefined sets:
- `NORMAL` — Standard box-drawing characters
- `ROUNDED` — Rounded corners
- `DOUBLE` — Double-line characters
- `THICK` — Thick line characters

**Ruby Status**: Not directly exposed. Users cannot customize line symbols for widgets that use them internally.

---

## MISSING — Bar Set Customization

Ratatui provides `symbols::bar::Set` with predefined sets:
- `THREE_LEVELS` — 3 distinct fill levels
- `NINE_LEVELS` — 9 distinct fill levels (default)

**Ruby Status**: Not exposed. Used internally by widgets like `Sparkline` but not configurable.

---

## MISSING — Block Set Customization

Ratatui provides `symbols::block::Set` with predefined sets:
- `THREE_LEVELS` — 3 distinct fill levels
- `NINE_LEVELS` — 9 distinct fill levels (default)

**Ruby Status**: Not exposed. Used internally by `Gauge` widget but not configurable.

---

## MISSING — Scrollbar Set Customization

Ratatui provides `symbols::scrollbar::Set` with predefined sets:
- `DOUBLE_VERTICAL` — Double-line vertical scrollbar
- `DOUBLE_HORIZONTAL` — Double-line horizontal scrollbar
- `VERTICAL` — Single-line vertical scrollbar
- `HORIZONTAL` — Single-line horizontal scrollbar

**Ruby Status**: Not exposed. Scrollbar widget not currently implemented in RatatuiRuby.

---

## MISSING — Shade Constants

Ratatui provides `symbols::shade` constants:
- `EMPTY` — ` ` (space)
- `LIGHT` — `░`
- `MEDIUM` — `▒`
- `DARK` — `▓`
- `FULL` — `█`

**Ruby Status**: Not exposed as constants.

---

## Currently Aligned

### `border_type:` Parameter

Ruby's `Block.new(border_type:)` maps to Ratatui's `border::Set`:

| Ruby Symbol | Ratatui Constant | Characters |
|-------------|------------------|------------|
| `:plain` | `border::PLAIN` | `┌─┐│└┘` |
| `:rounded` | `border::ROUNDED` | `╭─╮│╰╯` |
| `:double` | `border::DOUBLE` | `╔═╗║╚╝` |
| `:thick` | `border::THICK` | `┏━┓┃┗┛` |
| `:quadrant_outside` | `border::QUADRANT_OUTSIDE` | `▛▀▜▌▙▟` |
| `:quadrant_inside` | `border::QUADRANT_INSIDE` | `▗▄▖▐▝▘` |
| `:hidden` | ❌ Custom Ruby | Empty borders (spaces) |

### `border_set:` Parameter

Ruby supports custom border characters via hash:

```ruby
Block.new(border_set: {
  top_left: "╭",
  top_right: "╮",
  bottom_left: "╰",
  bottom_right: "╯",
  vertical_left: "│",
  vertical_right: "│",
  horizontal_top: "─",
  horizontal_bottom: "─"
})
```

This is functionally equivalent to Ratatui's custom `border::Set`.

---

## Recommendations

| Priority | Item | Notes |
|----------|------|-------|
| Low | Add `:half_block` marker | Single symbol addition |
| Low | Expose `line::Set` customization | For LineGauge widget |
| Low | Expose `bar::Set` customization | For Sparkline widget |
| Low | Expose `block::Set` customization | For Gauge widget |
| Medium | Implement Scrollbar widget | Would include scrollbar::Set |

All missing items are **additive** and do not require breaking changes.
