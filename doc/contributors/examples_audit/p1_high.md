<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Priority 1: High (Polish & Ecosystem)

Important for v1.0.0 quality and ecosystem goals. Not blocking release, but recommended before ship.

---

## 1. Improve Default States

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
**Improve:** Selection state visible on launch in `widget_list_demo` (merged)

### widget_block_padding, widget_block_titles

**Current:** Minimal styling
**Improve:** Use striking layouts/colors in unified `widget_block_demo`

---

## 2. Ensure All Widgets Have Examples

**Status:** Important for completeness — Every widget type should be demonstrable

Verify that all widget types shipped with ratatui_ruby have at least one example showing how to use them.

**Action:** Check widget manifest against example inventory and create examples for any missing widgets.
