<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# v0.7.0 Alignment Audit

This document audits strict alignment between RatatuiRuby v0.7.0 and the upstream Ratatui/Crossterm Rust libraries. The audit covers modules, classes, static methods, and constructor arguments as specified in the [Ruby Frontend Design](../design/ruby_frontend.md#1-ratatui-alignment).

> [!NOTE]
> The TUI facade API is explicitly excluded from this audit. It provides ergonomic shortcuts that intentionally diverge from Ratatui naming.

---

## Module Structure Alignment

| Rust Module | Ruby Module | Status | Notes |
|-------------|-------------|--------|-------|
| `ratatui::layout` | `RatatuiRuby::Layout` | ✅ Aligned | Rect, Constraint, Layout |
| `ratatui::widgets` | `RatatuiRuby::Widgets` | ✅ Aligned | All widgets |
| `ratatui::widgets::table` | `RatatuiRuby::Widgets` | ✅ Aligned | Row, Cell in Widgets (Rust has table submodule) |
| `ratatui::style` | `RatatuiRuby::Style` | ✅ Aligned | Style, Color support |
| `ratatui::text` | `RatatuiRuby::Text` | ✅ Aligned | Span, Line |
| `ratatui::buffer` | `RatatuiRuby::Buffer` | ✅ Aligned | Cell for inspection |

---

## Class-by-Class Audit

### Layout Module

#### `Layout::Rect`

| Attribute | Ratatui | RatatuiRuby | Status |
|-----------|---------|-------------|--------|
| `x` | `u16` | `Integer` | ✅ |
| `y` | `u16` | `Integer` | ✅ |
| `width` | `u16` | `Integer` | ✅ |
| `height` | `u16` | `Integer` | ✅ |

| Method | Ratatui | RatatuiRuby | Status |
|--------|---------|-------------|--------|
| `new(x, y, width, height)` | ✅ | ✅ | ✅ Aligned |
| `contains(position)` | ✅ | `contains?(px, py)` | ✅ Aligned (Ruby uses two args) |
| `intersects(other)` | ✅ | `intersects?(other)` | ✅ Aligned |
| `intersection(other)` | ✅ | ✅ | ✅ Aligned |
| `area()` | ✅ | ❌ Missing | Gap |
| `left()`, `right()`, `top()`, `bottom()` | ✅ | ❌ Missing | Gap (trivial: `x`, `x+width`, etc.) |
| `union(other)` | ✅ | ❌ Missing | Gap |
| `inner(margin)` | ✅ | ❌ Missing | Gap |
| `offset(offset)` | ✅ | ❌ Missing | Gap |

**Verdict**: Core constructor and hit-testing aligned. Additional geometric methods are gaps for future work.

---

#### `Layout::Constraint`

| Constructor | Ratatui | RatatuiRuby | Status |
|-------------|---------|-------------|--------|
| `Length(u16)` | ✅ | `length(v)` | ✅ Aligned |
| `Percentage(u16)` | ✅ | `percentage(v)` | ✅ Aligned |
| `Min(u16)` | ✅ | `min(v)` | ✅ Aligned |
| `Max(u16)` | ✅ | `max(v)` | ✅ Aligned |
| `Fill(u16)` | ✅ | `fill(v=1)` | ✅ Aligned |
| `Ratio(u32, u32)` | ✅ | `ratio(num, denom)` | ✅ Aligned |

| Batch Constructor | Ratatui | RatatuiRuby | Status |
|-------------------|---------|-------------|--------|
| `from_lengths([...])` | ✅ | ❌ Missing | Gap |
| `from_percentages([...])` | ✅ | ❌ Missing | Gap |
| `from_mins([...])` | ✅ | ❌ Missing | Gap |
| `from_maxes([...])` | ✅ | ❌ Missing | Gap |
| `from_fills([...])` | ✅ | ❌ Missing | Gap |
| `from_ratios([...])` | ✅ | ❌ Missing | Gap |

**Verdict**: All constraint variants aligned. Batch constructors are convenience gaps.

---

#### `Layout::Layout`

| Attribute | Ratatui | RatatuiRuby | Status |
|-----------|---------|-------------|--------|
| `direction` | `:horizontal` / `:vertical` | `:horizontal` / `:vertical` | ✅ Aligned |
| `constraints` | `Vec<Constraint>` | `Array<Constraint>` | ✅ Aligned |
| `flex` | `Flex` enum | Symbol (`:start`, `:center`, etc.) | ✅ Aligned |
| `margin` | `Margin` | ❌ Missing | Gap |
| `spacing` | `u16` | ❌ Missing | Gap |

**Verdict**: Core layout aligned. Margin and spacing are gaps.

---

### Widgets Module

#### `Widgets::Row`

| Attribute | Ratatui | RatatuiRuby | Status |
|-----------|---------|-------------|--------|
| `cells` | `Vec<Cell>` | `Array` | ✅ Aligned |
| `style` | `Style` | `Style` | ✅ Aligned |
| `height` | `u16` | `Integer` | ✅ Aligned |
| `top_margin` | `u16` | `Integer` | ✅ Aligned |
| `bottom_margin` | `u16` | `Integer` | ✅ Aligned |

**Verdict**: ✅ Fully aligned.

---

#### `Widgets::Cell`

| Attribute | Ratatui | RatatuiRuby | Status |
|-----------|---------|-------------|--------|
| `content` | `Text` | `String`/`Span`/`Line` | ✅ Aligned |
| `style` | `Style` | `Style` | ✅ Aligned |

**Verdict**: ✅ Fully aligned.

---

#### `Widgets::Table`

| Attribute | Ratatui | RatatuiRuby | Status |
|-----------|---------|-------------|--------|
| `rows` | `Vec<Row>` | `Array` | ✅ Aligned |
| `header` | `Option<Row>` | `Array` or `nil` | ✅ Aligned |
| `footer` | `Option<Row>` | `Array` or `nil` | ✅ Aligned |
| `widths` | `Vec<Constraint>` | `Array<Constraint>` | ✅ Aligned |
| `column_spacing` | `u16` | `Integer` | ✅ Aligned |
| `style` | `Style` | `Style` | ✅ Aligned |
| `highlight_style` | `Style` | `Style` | ✅ Aligned |
| `highlight_symbol` | `Option<Text>` | `String` | ✅ Aligned |
| `selected_row` | via state | `selected_row` | ✅ Aligned |
| `selected_column` | via state | `selected_column` | ✅ Aligned |
| `highlight_spacing` | `HighlightSpacing` | Symbol | ✅ Aligned |
| `flex` | `Flex` | Symbol | ✅ Aligned |
| `offset` | via state | `offset` | ✅ Aligned |
| `block` | `Option<Block>` | `Block` | ✅ Aligned |

**Verdict**: ✅ Fully aligned.

---

### Style Module

#### `Style::Style`

| Attribute | Ratatui | RatatuiRuby | Status |
|-----------|---------|-------------|--------|
| `fg` | `Option<Color>` | `Symbol`/`String`/`Integer` | ✅ Aligned |
| `bg` | `Option<Color>` | `Symbol`/`String`/`Integer` | ✅ Aligned |
| `add_modifier` | `Modifier` | `modifiers: Array` | ⚠️ Different API |
| `sub_modifier` | `Modifier` | ❌ Missing | Gap |
| `underline_color` | `Option<Color>` | ❌ Missing | Gap |

**API Difference**: Ratatui uses `add_modifier(Modifier::BOLD)` and `sub_modifier()`. Ruby uses `modifiers: [:bold]` array. This is an intentional Rubyism for ergonomics while being functionally equivalent.

**Verdict**: Functionally aligned with idiomatic Ruby API.

---

### Text Module

#### `Text::Span`

| Attribute | Ratatui | RatatuiRuby | Status |
|-----------|---------|-------------|--------|
| `content` | `Cow<str>` | `String` | ✅ Aligned |
| `style` | `Style` | `Style` | ✅ Aligned |

| Constructor | Ratatui | RatatuiRuby | Status |
|-------------|---------|-------------|--------|
| `raw(content)` | ✅ | ❌ (use `new`) | Gap (trivial) |
| `styled(content, style)` | ✅ | `styled(content, style)` | ✅ Aligned |

| Method | Ratatui | RatatuiRuby | Status |
|--------|---------|-------------|--------|
| `width()` | ✅ | ❌ Missing | Gap |

**Verdict**: Core aligned. Missing `width()` instance method and `raw()` constructor.

---

#### `Text::Line`

| Attribute | Ratatui | RatatuiRuby | Status |
|-----------|---------|-------------|--------|
| `spans` | `Vec<Span>` | `Array<Span>` | ✅ Aligned |
| `style` | `Style` | ❌ Missing | Gap |
| `alignment` | `Option<Alignment>` | `alignment` | ✅ Aligned |

| Method | Ratatui | RatatuiRuby | Status |
|--------|---------|-------------|--------|
| `width()` | ✅ | ✅ | ✅ Aligned |
| `left_aligned()` | ✅ | ❌ (use constructor) | Gap |
| `centered()` | ✅ | ❌ (use constructor) | Gap |
| `right_aligned()` | ✅ | ❌ (use constructor) | Gap |

**Verdict**: Core aligned. Missing `style` field on Line (Ratatui has line-level style separate from span styles).

---

### Buffer Module

#### `Buffer::Cell`

| Attribute | Ratatui | RatatuiRuby | Status |
|-----------|---------|-------------|--------|
| `char` / `symbol` | `String` | `char` | ✅ Aligned |
| `fg` | `Color` | `Symbol`/`String`/`Integer` | ✅ Aligned |
| `bg` | `Color` | `Symbol`/`String`/`Integer` | ✅ Aligned |
| `modifiers` | `Modifier` | `Array<Symbol>` | ⚠️ Ruby array vs Rust bitflags |

**Verdict**: ✅ Aligned (read-only inspection).

---

## Summary

### Fully Aligned ✅

- **Module structure**: All 5 modules map correctly
- **Widgets::Row**: All 5 attributes aligned
- **Widgets::Cell**: Both attributes aligned  
- **Widgets::Table**: All major attributes aligned
- **Layout::Constraint**: All 6 variants aligned
- **Layout::Rect**: Constructor and hit-testing aligned

### Intentional Ruby Idioms ⚠️

These are **not misalignments**. They are deliberate API choices that provide functional equivalence with idiomatic Ruby patterns:

- **Style modifiers**: Array `[:bold, :italic]` vs Rust's `add_modifier(BOLD | ITALIC)`
- **Buffer::Cell modifiers**: Same array-based approach

---

## Gaps Analysis: MISSING vs MISALIGNED

> [!IMPORTANT]
> **MISSING** = Can be added as new features without breaking backwards compatibility.  
> **MISALIGNED** = Requires breaking changes before v1.0.0 to fix API shape.

### MISSING Features (Additive, Backwards-Compatible) ✅

These are gaps that can be filled in future minor releases without breaking existing code:

| Component | Missing Feature | Notes |
|-----------|-----------------|-------|
| `Rect` | `area()`, `left()`, `right()`, `top()`, `bottom()` | New instance methods |
| `Rect` | `union(other)`, `inner(margin)`, `offset(offset)` | New instance methods |
| `Constraint` | `from_lengths()`, `from_percentages()`, etc. | New class methods |
| `Layout` | `margin`, `spacing` | New optional constructor args |
| `Style` | `sub_modifier`, `underline_color` | New optional constructor args |
| `Span` | `width()` instance method | New instance method |
| `Span` | `raw()` constructor | New class method (alias for `new`) |
| `Line` | `left_aligned()`, `centered()`, `right_aligned()` | New instance methods (fluent) |

### MISALIGNED Structure (Breaking Changes Required) ⚠️

> [!CAUTION]
> These gaps represent **structural misalignment** where the current API shape differs from Ratatui in a way that cannot be fixed without breaking changes. **Must be addressed before v1.0.0.**

| Component | Current API | Ratatui API | Required Change |
|-----------|-------------|-------------|-----------------|
| `Text::Line` | No `style` field | Has `style: Style` | Add `style:` parameter to `Line.new()` |

**Details:**

#### `Text::Line` Missing `style` Field

Ratatui's `Line` has three fields:
```rust
pub struct Line<'a> {
    pub style: Style,        // ← Missing in Ruby
    pub alignment: Option<Alignment>,
    pub spans: Vec<Span<'a>>,
}
```

Ruby's `Line` has only two:
```ruby
class Line < Data.define(:spans, :alignment)
```

**Impact**: Users cannot set a line-level style that applies uniformly across all spans. They must either:
1. Apply the same style to every span manually, or
2. Wrap the line in a styled container

**Required Fix**: Add `style:` parameter to `Line.new()`. This is a **breaking change** because:
- Positional argument order changes (if used positionally)
- `Data.define` member list changes

**Recommendation**: Fix in v0.8.0 or earlier, before v1.0.0 API freeze.

---

## Conclusion

The v0.7.0 namespace restructuring achieves **strict alignment** with Ratatui's module hierarchy as specified in the design principles. All new types (`Widgets::Row`, `Widgets::Cell`, `Buffer::Cell`) follow the established pattern.

### Release Guidance

| Category | Count | Action |
|----------|-------|--------|
| **Fully Aligned** | 6 components | ✅ No action needed |
| **Intentional Idioms** | 2 items | ✅ Document as Ruby conventions |
| **MISSING (additive)** | 14 features | 📋 Add in future minor releases |
| **MISALIGNED (breaking)** | 1 issue | ⚠️ **Must fix before v1.0.0** |

The single misalignment (`Text::Line` missing `style` field) is the only blocking issue for v1.0.0 API stability. All other gaps are additive and can be addressed incrementally.