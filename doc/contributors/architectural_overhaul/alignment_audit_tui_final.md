<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# TUI API Alignment Audit

This document audits the `RatatuiRuby::TUI` facade API for method and parameter naming, with a focus on **Developer Experience (DX)** before the v1.0.0 release.

## Design Philosophy

The TUI API follows a "Mullet Architecture": structured namespaces in the library, flat ergonomic DSL for users.

**Guiding Principles:**

1. **Terseness** — Fewer keystrokes for common operations
2. **DWIM** — Do What I Mean; intuitive defaults
3. **TIMTOWTDI** — Multiple valid ways to express the same thing
4. **Big Tent** — Aliases for CSS/frontend developers, Ratatui natives, and Ruby purists
5. **Two Levels Max** — `tui.thing` and `tui.scope_thing`, never `tui.scope.thing`, never `tui.ascope_bscope_thing`

**Breaking Changes:** Pre-1.0 with few external users. Rename aggressively for DX. Document in CHANGELOG.

---

## Method Naming Recommendations

### Pattern: Base Methods + Aliases + Dispatchers

Base methods align with Ratatui's module API names. Aliases provide ergonomic shortcuts.

1. **Base method** (Ratatui-aligned): `tui.shape_circle(...)` — matches `Widgets::Shape::Circle`
2. **Aliases** (ergonomic): `tui.circle(...)`, `tui.circle_shape(...)`
3. **Dispatcher**: `tui.shape(:circle, ...)` — errors helpfully on missing type

This pattern applies to: shapes, constraints, text elements.

---

### Canvas Shapes

| Base Method | Add Aliases | Dispatcher |
|-------------|-------------|------------|
| `shape_circle` | `circle`, `circle_shape` | `shape(:circle, ...)` |
| `shape_line` | `line_shape` *(not bare `line` — conflicts with `Text::Line`)* | `shape(:line, ...)` |
| `shape_point` | `point`, `point_shape` | `shape(:point, ...)` |
| `shape_rectangle` | `rectangle`, `rectangle_shape` | `shape(:rectangle, ...)` |
| `shape_map` | `map`, `map_shape` | `shape(:map, ...)` |
| `shape_label` | `label`, `label_shape` | `shape(:label, ...)` |

**Dispatcher signature:**
```ruby
def shape(type, **kwargs)
  case type
  when :circle then shape_circle(**kwargs)
  when :line then shape_line(**kwargs)
  # ...
  else
    raise ArgumentError, "Unknown shape type: #{type.inspect}. " \
      "Valid types: :circle, :line, :point, :rectangle, :map, :label"
  end
end
```

---

### Layout Constraints

Ratatui's constraints map well to CSS layout concepts. Offer aliases for both communities:

| Base Method | Add Aliases (CSS-Friendly) | Dispatcher |
|-------------|---------------------------|------------|
| `constraint_length(n)` | `fixed(n)`, `length(n)` | `constraint(:length, n)` |
| `constraint_percentage(n)` | `percent(n)`, `percentage(n)` | `constraint(:percentage, n)` |
| `constraint_min(n)` | `min(n)`, `min_content(n)` | `constraint(:min, n)` |
| `constraint_max(n)` | `max(n)`, `max_content(n)` | `constraint(:max, n)` |
| `constraint_fill(n)` | `fill(n)`, `flex(n)`, `fr(n)` | `constraint(:fill, n)` |
| `constraint_ratio(a,b)` | `ratio(a,b)`, `aspect(a,b)` | `constraint(:ratio, a, b)` |

**CSS Flexbox/Grid parallels:**
- `fill(1)` ≈ CSS `flex: 1` or `1fr`
- `fixed(100)` ≈ CSS `width: 100px`
- `min(50)` ≈ CSS `min-width: 50px`
- `percent(25)` ≈ CSS `width: 25%`

**Dispatcher signature:**
```ruby
def constraint(type, *args)
  case type
  when :length, :fixed then constraint_length(*args)
  when :percentage, :percent then constraint_percentage(*args)
  when :min then constraint_min(*args)
  when :max then constraint_max(*args)
  when :fill, :flex, :fr then constraint_fill(*args)
  when :ratio, :aspect then constraint_ratio(*args)
  else
    raise ArgumentError, "Unknown constraint type: #{type.inspect}. " \
      "Valid types: :length, :percentage, :min, :max, :fill, :ratio"
  end
end
```

---

### Layout Operations

| Current | Add Alias | Rationale |
|---------|-----------|-----------|
| `layout_split` | `split` | 52 usages in examples; clear in context |

---

### Text Factories

| Current | Status | Notes |
|---------|--------|-------|
| `text_span` | ✓ Has alias `span` | |
| `text_line` | ✓ Has alias `line` | |
| `text_width` | Keep as-is | Distinct from `length` (constraint) |

Add dispatcher:
```ruby
def text(type, **kwargs)
  case type
  when :span then text_span(**kwargs)
  when :line then text_line(**kwargs)
  else
    raise ArgumentError, "Unknown text type: #{type.inspect}. Valid types: :span, :line"
  end
end
```

---

### Widget Factories

| Current | Add Alias | Rationale |
|---------|-----------|-----------|
| `list_item` | `item` | Clear in list context |
| `table_row` | Keep alongside `row` | DWIM — both valid mental models |
| `table_cell` | Keep as-is | `cell` means `Buffer::Cell` |
| `bar_chart_bar` | Keep alongside `bar` | DWIM — don't deprecate |
| `bar_chart_bar_group` | Keep alongside `bar_group` | DWIM — don't deprecate |

Add dispatcher:
```ruby
def widget(type, **kwargs)
  case type
  when :block then block(**kwargs)
  when :paragraph then paragraph(**kwargs)
  when :list then list(**kwargs)
  when :table then table(**kwargs)
  # ... all widgets
  else
    raise ArgumentError, "Unknown widget type: #{type.inspect}."
  end
end
```

---

### State Factories

| Current | Status |
|---------|--------|
| `list_state` | Keep as-is |
| `table_state` | Keep as-is |
| `scrollbar_state` | Keep as-is |

Add dispatcher:
```ruby
def state(type, **kwargs)
  case type
  when :list then list_state(**kwargs)
  when :table then table_state(**kwargs)
  when :scrollbar then scrollbar_state(**kwargs)
  else
    raise ArgumentError, "Unknown state type: #{type.inspect}."
  end
end
```

---

## Parameter Names

All current parameter names are well-chosen. No changes recommended.

| Widget | Parameter | Status |
|--------|-----------|--------|
| `List` | `selected_index`, `highlight_style`, etc. | ✓ |
| `Table` | `row_highlight_style`, `selected_row`, etc. | ✓ |
| `Scrollbar` | `content_length`, `position`, etc. | ✓ |
| All | `block`, `style`, `offset` | ✓ Consistent |

---

## Summary of Changes

### High Priority (Immediate DX Wins)

1. **Add `split` alias** for `layout_split`
2. **Add `item` alias** for `list_item`
3. **Add terse shape aliases**: `circle`, `point`, `rectangle`, `map`, `label`
4. **Add CSS-friendly constraint aliases**: `fixed`, `percent`, `fill`, `flex`, `fr`, `min`, `max`

### Medium Priority (Pattern Completion)

5. **Add dispatcher methods**: `shape(type, ...)`, `constraint(type, ...)`, `text(type, ...)`, `widget(type, ...)`, `state(type, ...)`
6. **Add bidirectional shape aliases**: `circle_shape`, `point_shape`, etc.

### Not Changing

- Don't deprecate verbose forms (`table_row`, `bar_chart_bar`, etc.) — DWIM
- Don't rename parameters — already optimal
- Don't add third level aliases (`tui.widgets.paragraph`) — two levels max

---

## Implementation Checklist

- [ ] Add `split` alias to `LayoutFactories`
- [ ] Add `item` alias to `WidgetFactories`
- [ ] Add terse shape aliases to `CanvasFactories`
- [ ] Add CSS-friendly constraint aliases to `LayoutFactories`
- [ ] Add `shape(type, ...)` dispatcher
- [ ] Add `constraint(type, ...)` dispatcher
- [ ] Add bidirectional shape aliases (`*_shape`)
- [ ] Add `text(type, ...)`, `widget(type, ...)`, `state(type, ...)` dispatchers
- [ ] Update RBS signatures for all new methods
- [ ] Update RDoc for all new methods
- [ ] Update CHANGELOG.md

---

## Breaking Changes Analysis

If all recommendations in this audit are adopted, **none constitute breaking changes** under semver.

| Recommendation | Breaking? | Rationale |
|----------------|-----------|-----------|
| Add `split` alias | No | Additive; `layout_split` unchanged |
| Add `item` alias | No | Additive; `list_item` unchanged |
| Add terse shape aliases (`circle`, etc.) | No | Additive; `shape_*` methods unchanged |
| Add CSS-friendly constraint aliases | No | Additive; `constraint_*` methods unchanged |
| Add bidirectional aliases (`*_shape`) | No | Additive; does not remove existing forms |
| Add dispatcher methods | No | Additive; new methods only |
| Keep verbose forms (`table_row`, etc.) | No | No removal or rename |

**Conclusion:** This audit recommends only additive changes. All existing code will continue to work unchanged.

> [!NOTE]
> If we later decide to **remove** verbose forms like `bar_chart_bar` or `bar_chart_bar_group`, that would be a breaking change requiring a major version bump. This audit explicitly recommends **keeping** them (DWIM philosophy).

