<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Examples Audit Report

Audit of ratatui_ruby `examples/` directory for v1.0.0 readiness.

---

## [P0: Critical (Must Fix Before v1.0.0) ](./examples_audit/p0_critical.md)


1. **[Migrate Example Tests to Snapshot API](./examples_audit/p0_critical.md#2-migrate-example-tests-to-snapshot-api)**
   - Pattern change (old vs new)
   - Why snapshots are better
   - Example update pattern
   - Handling dynamic content with normalization

---

## [P1: High (Polish)](./examples_audit/p1_high.md)

1. **[Fix API Violations in 6 Examples](./examples_audit/p1_high.md#1-fix-api-violations-in-6-examples)** (API consistency/polish)
   - Event handling (5 examples)
   - Session API (2 examples)
   - Other fixes (constraint calls, method names, permissions)

2. **[Improve Default States](./examples_audit/p1_high.md#2-improve-default-states)** (Visual polish)
   - widget_barchart_demo (enable grouped visualization)
   - widget_sparkline_demo (interesting data patterns)
   - widget_list_styles (visible selection state)
   - widget_block_padding, widget_block_titles (visually striking layouts)

3. **[Ensure All Widgets Have Examples](./examples_audit/p1_high.md#3-ensure-all-widgets-have-examples)** (Completeness)
   - Check widget manifest against example inventory
   - Create examples for any missing widgets

---

## [P2: Moderate (Quality)](./examples_audit/p2_moderate.md)

1. **[Consolidate 3 Redundant Example Pairs](./examples_audit/p2_moderate.md#1-consolidate-3-redundant-example-pairs)**
   - widget_list_styles + widget_list_demo
   - app_table_select + widget_table_flex
   - widget_block_padding + widget_block_titles

2. **[Result of Consolidation](./examples_audit/p2_moderate.md#result-of-consolidation)** (35 → 32 examples)

3. **[Benefits](./examples_audit/p2_moderate.md#2-benefits)**

4. **[Add RDoc Cross-Links](./examples_audit/p2_moderate.md#3-add-rdoc-cross-links-examples--aliases)** (Documentation discoverability)
   - Link library classes/methods to examples
   - Link DWIM/TIMTOWTDI aliases
   - Create consistent pattern across public APIs

---

## Success Criteria for v1.0.0

- ✓ All P0 items are fixed
- ✓ All P1 items are mitigated (or time has run out)
