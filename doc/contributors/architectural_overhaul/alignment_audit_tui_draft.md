<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# TUI API Alignment Audit

This document audits the `RatatuiRuby::TUI` facade API for method and parameter naming, with a focus on **Developer Experience (DX)** before the v1.0.0 release. The TUI layer exists to be terse, convenient, and obvious—"Programmer Happiness" in the style of Rubyists.

## Design Philosophy Recap

The TUI API follows a "Mullet Architecture":
- **Library (back)**: Deep, explicit namespaces matching Ratatui (`Widgets::Shape::Circle`)
- **Facade (front)**: Flat, ergonomic DSL for users (`tui.circle`)

Method names in the TUI facade should prioritize:
1. **Terseness** — Fewer keystrokes for common operations
2. **Clarity** — Unambiguous meaning without context
3. **DWIM** — Do What I Mean; intuitive defaults
4. **TIMTOWTDI** — There's More Than One Way To Do It; aliases for common mental models

---

## User Feedback Needed

> [!IMPORTANT]
> The following decisions require explicit user input before proceeding.

1. **Shape method naming**: Should we add shorter aliases (`circle`, `point`, `rectangle`, `map`) for the shape factory methods, or keep only the explicit `shape_*` prefix?
   - `shape_line` must remain prefixed (conflicts with `Text::Line`)
   - Other shapes have no conflict, but prefix provides grouping

2. **Constraint method naming**: The `constraint_*` family is verbose but clear. Should we:
   - Keep as-is for clarity (`constraint_length`, `constraint_fill`, etc.)?
   - Add shorter aliases (`length`, `fill`, `min`, `max`, `percentage`, `ratio`)?
   - Both (aliases that complement the explicit versions)?

3. **Label method naming**: `shape_label` is the only shape without a short alias candidate because `label` could plausibly mean something else (form label, accessibility label). Keep as-is?

---

## Suggested: Method Names

### Leave As-Is

These method names are already optimal:

| Method | Rationale |
|--------|-----------|
| `draw` | Core verb, maximally terse |
| `poll_event` | Clear compound, standard API pattern |
| `get_cell_at` | Explicit query, prevents confusion with `cell` factory |
| `draw_cell` | Clear command, pairs with `get_cell_at` |
| `style` | Perfect: terse, unambiguous, matches mental model |
| `block` | Perfect: matches Ratatui widget name |
| `paragraph` | Perfect: unambiguous widget |
| `list` | Perfect: terse, unambiguous |
| `list_item` | Clear compound, necessary disambiguation |
| `table` | Perfect: unambiguous widget |
| `row` | Terse, clear in table context |
| `tabs` | Perfect: terse, unambiguous |
| `gauge` | Perfect: terse, unambiguous |
| `sparkline` | Perfect: domain-specific, recognizable |
| `bar_chart` | Clear compound widget name |
| `bar` | Terse, clear in bar_chart context |
| `bar_group` | Clear compound, groups bars |
| `chart` | Perfect: terse, unambiguous |
| `dataset` | Perfect: clear data container |
| `axis` | Perfect: terse, unambiguous |
| `scrollbar` | Perfect: compound widget name |
| `calendar` | Perfect: unambiguous widget |
| `canvas` | Perfect: unambiguous widget |
| `clear` | Perfect: command verb, obvious intent |
| `cursor` | Perfect: unambiguous widget |
| `overlay` | Perfect: layout combinator |
| `center` | Perfect: layout combinator |
| `rect` | Terse, universally understood abbreviation |
| `constraint` | Base factory, clear purpose |
| `layout` | Perfect: matches class name |
| `layout_split` | Clear compound, common operation |
| `list_state` | Clear compound, matches widget |
| `table_state` | Clear compound, matches widget |
| `scrollbar_state` | Clear compound, matches widget |
| `line_gauge` | Clear compound widget name |
| `text_width` | Clear compound, utility function |
| `ratatui_logo` | Branding, self-explanatory |
| `ratatui_mascot` | Branding, self-explanatory |

### Rename (Breaking)

None recommended. Breaking renames at this stage would create unnecessary migration burden.

### Rename and Alias (Non-Breaking)

None recommended. The current primary names are well-chosen.

### Alias Only (Non-Breaking)

**High priority** — These aliases would significantly improve DX:

- `shape_circle` → alias `circle` *(no conflict, more terse)*
- `shape_point` → alias `point` *(no conflict, more terse)*
- `shape_rectangle` → alias `rectangle` *(no conflict, more terse)*
- `shape_map` → alias `map` *(no conflict, more terse; note: shadows `Enumerable#map` but TUI isn't mixed into enumerables)*

**Medium priority** — Consider these for convenience:

- `constraint_length` → alias `length` *(context usually clear)*
- `constraint_fill` → alias `fill` *(context usually clear)*
- `constraint_min` → alias `min` *(shadows `Comparable#min` but tui isn't a comparable)*
- `constraint_max` → alias `max` *(shadows `Comparable#max` but tui isn't a comparable)*
- `constraint_percentage` → alias `percentage` or `percent`
- `constraint_ratio` → alias `ratio`

**Low priority** — Already have adequate alternatives:

- `text_span` already has alias `span` ✓
- `text_line` already has alias `line` ✓
- `table_row` duplicates `row` *(consider deprecating `table_row`)*
- `bar_chart_bar` duplicates `bar` *(consider deprecating `bar_chart_bar`)*
- `bar_chart_bar_group` duplicates `bar_group` *(consider deprecating `bar_chart_bar_group`)*
- `table_cell` — keep as-is, `cell` means `Buffer::Cell`

---

## Suggested: Parameter Names

### Leave As-Is

All current parameter names are well-chosen:

| Widget | Parameter | Rationale |
|--------|-----------|-----------|
| `List` | `selected_index` | Clear, matches mental model |
| `List` | `highlight_style` | Clear, consistent across widgets |
| `List` | `highlight_symbol` | Clear, consistent |
| `List` | `highlight_spacing` | Clear, consistent |
| `List` | `repeat_highlight_symbol` | Explicit boolean intent |
| `List` | `scroll_padding` | Clear purpose |
| `Table` | `row_highlight_style` | Explicit scope (row vs column vs cell) |
| `Table` | `column_highlight_style` | Explicit scope |
| `Table` | `cell_highlight_style` | Explicit scope |
| `Table` | `selected_row` | Clear, pairs with `selected_column` |
| `Table` | `selected_column` | Clear, pairs with `selected_row` |
| `Table` | `column_spacing` | Clear purpose |
| `Scrollbar` | `content_length` | Clear, standard scrollbar term |
| `Scrollbar` | `position` | Terse, unambiguous |
| `Scrollbar` | `thumb_symbol` / `thumb_style` | Clear scrollbar terminology |
| `Scrollbar` | `track_symbol` / `track_style` | Clear scrollbar terminology |
| `Scrollbar` | `begin_symbol` / `end_symbol` | Directionally neutral |
| `Chart` | `legend_position` | Clear, compound name |
| `Chart` | `hidden_legend_constraints` | Self-documenting |
| `Dataset` | `graph_type` | Clear domain term |
| `Axis` | `labels_alignment` | Clear, explicit scope |
| All widgets | `block` | Consistent wrapper pattern |
| All widgets | `style` | Consistent base style |
| All widgets | `offset` | Consistent scroll position |

### Rename (Breaking)

None recommended.

### Rename and Alias (Non-Breaking)

None recommended.

### Alias Only (Non-Breaking)

None recommended. Parameter names are already optimal.

---

## Redundant Aliases to Consider Deprecating

The following TUI methods are verbose duplicates of terser alternatives:

| Verbose | Preferred | Recommendation |
|---------|-----------|----------------|
| `table_row` | `row` | Keep both; `table_row` aids discoverability |
| `bar_chart_bar` | `bar` | Deprecate in v1.0, remove in v2.0 |
| `bar_chart_bar_group` | `bar_group` | Deprecate in v1.0, remove in v2.0 |

---

## Summary

The TUI API is already well-designed. The primary opportunities for v1.0.0 are:

1. **Add short aliases for shapes** (`circle`, `point`, `rectangle`, `map`)
2. **Consider short aliases for constraints** (`length`, `fill`, etc.)
3. **Deprecate redundant verbose aliases** (`bar_chart_bar`, `bar_chart_bar_group`)

No breaking changes recommended. The existing names are good; adding non-breaking aliases provides TIMTOWTDI without disrupting established code.
