<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# v0.7.0 Alignment Audit: Colors

Audit of color alignment between Ratatui/Crossterm and RatatuiRuby.

> [!IMPORTANT]
> **MISSING** = Can be added as new features, backwards-compatible.
> **MISALIGNED** = Requires breaking changes before v1.0.0.

---

## Summary

| Color Type | Ratatui | RatatuiRuby | Status |
|------------|---------|-------------|--------|
| Named colors (8 base) | ✅ | ✅ Symbols | ✅ Aligned |
| Named colors (8 light) | ✅ | ✅ Symbols | ✅ Aligned |
| `Reset` | ✅ | ⚠️ Not documented | MISSING |
| `Rgb(r, g, b)` | ✅ | `"#RRGGBB"` | ✅ Aligned |
| `Indexed(u8)` | ✅ | Integer (0-255) | ✅ Aligned |

---

## MISALIGNED (Breaking Changes Required)

**None.** All exposed color types are correctly aligned.

---

## MISSING — Reset Color

| Ratatui | Ruby | Status |
|---------|------|--------|
| `Color::Reset` | ❌ Not documented | MISSING |

**Impact**: Users cannot explicitly reset foreground/background to terminal default.

**Recommendation**: Document `:reset` symbol support if already implemented in Rust backend, or add support if missing.

---

## Aligned — Named Colors (Base)

| Ratatui | Ruby Symbol |
|---------|-------------|
| `Color::Black` | `:black` |
| `Color::Red` | `:red` |
| `Color::Green` | `:green` |
| `Color::Yellow` | `:yellow` |
| `Color::Blue` | `:blue` |
| `Color::Magenta` | `:magenta` |
| `Color::Cyan` | `:cyan` |
| `Color::Gray` | `:gray` |

---

## Aligned — Named Colors (Light/Bright)

| Ratatui | Ruby Symbol |
|---------|-------------|
| `Color::DarkGray` | `:dark_gray` |
| `Color::LightRed` | `:light_red` |
| `Color::LightGreen` | `:light_green` |
| `Color::LightYellow` | `:light_yellow` |
| `Color::LightBlue` | `:light_blue` |
| `Color::LightMagenta` | `:light_magenta` |
| `Color::LightCyan` | `:light_cyan` |
| `Color::White` | `:white` |

---

## Aligned — RGB Colors

| Ratatui | Ruby |
|---------|------|
| `Color::Rgb(255, 0, 0)` | `"#FF0000"` |
| `Color::Rgb(0, 255, 0)` | `"#00FF00"` |
| `Color::Rgb(0, 0, 255)` | `"#0000FF"` |

Ruby accepts hex strings in the format `"#RRGGBB"`.

---

## Aligned — Indexed Colors (256-color palette)

| Ratatui | Ruby |
|---------|------|
| `Color::Indexed(0)` | `0` |
| `Color::Indexed(42)` | `42` |
| `Color::Indexed(255)` | `255` |

Ruby accepts integers 0-255 representing the Xterm 256-color palette:
- 0-15: Standard and bright ANSI colors
- 16-231: 6×6×6 color cube
- 232-255: Grayscale ramp

---

## Supported Modifiers

Ruby supports all Ratatui style modifiers:

| Ratatui | Ruby Symbol |
|---------|-------------|
| `Modifier::BOLD` | `:bold` |
| `Modifier::DIM` | `:dim` |
| `Modifier::ITALIC` | `:italic` |
| `Modifier::UNDERLINED` | `:underlined` |
| `Modifier::SLOW_BLINK` | `:slow_blink` |
| `Modifier::RAPID_BLINK` | `:rapid_blink` |
| `Modifier::REVERSED` | `:reversed` |
| `Modifier::HIDDEN` | `:hidden` |
| `Modifier::CROSSED_OUT` | `:crossed_out` |

---

## Recommendations

| Priority | Item | Notes |
|----------|------|-------|
| Low | Document `:reset` color | May already be supported |

All missing items are **additive** and do not require breaking changes.
