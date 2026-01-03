<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Priority 1: High (Polish & Ecosystem)

Important for v1.0.0 quality and ecosystem goals. Not blocking release, but recommended before ship.

---

## 1. Fix API Violations in 6 Examples

**Status:** Important for API consistency — Examples currently violate established patterns

### Event Handling (5 examples)

widget_block_padding, widget_block_titles, widget_cell_demo, widget_scroll_text

**Current (WRONG):**
```ruby
break if event == "q" || event == :ctrl_c
```

**Should be:**
```ruby
case @tui.poll_event
in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
  break
else
  nil
end
```

### Session API (2 examples)

widget_block_padding, widget_cell_demo

**Current (WRONG):**
```ruby
RatatuiRuby::Block.new(...)
RatatuiRuby::Layout.split(...)
RatatuiRuby::Constraint.length(...)
```

**Should use:**
```ruby
@tui.block(...)
@tui.layout_split(...)
@tui.constraint_length(...)
```

### Other Fixes

**widget_block_titles:** Replace `tui.constraint(:length, 10)` with `tui.constraint_length(10)`

**widget_cell_demo:** Rename `main` method to `run`

**widget_scroll_text, widget_table_demo:** Remove executable bit (`chmod -x`)

---

## 2. Improve Default States

**Status:** Important for visual polish — Examples should look impressive on first launch

Several examples use plain or minimal defaults that don't showcase the library well.

### widget_barchart_demo

**Current:** Flat bar chart display
**Improve:** Enable grouped visualization mode (more visually interesting)

### widget_sparkline_demo

**Current:** Linear/boring data
**Improve:** Default to interesting data pattern (ups/downs/volatility)

### widget_list_styles

**Current:** Generic numbered items with no visual distinction
**Improve:** Show selection state visibly (highlight one item)

### widget_block_padding, widget_block_titles

**Current:** Minimal styling
**Improve:** Use colors or visually striking layouts to highlight block features

---

## 3. Ensure All Widgets Have Examples

**Status:** Important for completeness — Every widget type should be demonstrable

Verify that all widget types shipped with ratatui_ruby have at least one example showing how to use them.

**Action:** Check widget manifest against example inventory and create examples for any missing widgets.
