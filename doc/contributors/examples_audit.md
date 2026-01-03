<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Examples Audit Report

Audit of ratatui_ruby `examples/` directory for v1.0.0 readiness.

## P0: Critical (Completed ✓)

All P0 critical items have been completed:

1. **Migrate Example Tests to Snapshot API** ✓
   - Migrated 31 test files from manual `buffer_content` assertions to `assert_snapshot` and `assert_rich_snapshot`
   - Added deterministic seeding for tests with random content (Faker, RATA_SEED)
   - Generates `.txt` (plain) and `.ansi` (styled) snapshots for mutation-testing capability

---

## [P1: High (Polish)](./examples_audit/p1_high.md)

1. **[Improve Default States](./examples_audit/p1_high.md#1-improve-default-states)** (Visual polish)
   - widget_barchart_demo (enable grouped visualization)
   - widget_sparkline_demo (interesting data patterns)
   - widget_list_styles (visible selection state)
   - widget_block_padding, widget_block_titles (visually striking layouts)

2. **[Ensure All Widgets Have Examples](./examples_audit/p1_high.md#2-ensure-all-widgets-have-examples)** (Completeness)
   - Check widget manifest against example inventory
   - Create examples for any missing widgets

---

## [P2: Moderate (Quality)](./examples_audit/p2_moderate.md)

1. **[Add RDoc Cross-Links](./examples_audit/p2_moderate.md#1-add-rdoc-cross-links-examples--aliases)** (Documentation discoverability)
   - Link library classes/methods to examples
   - Link DWIM/TIMTOWTDI aliases
   - Create consistent pattern across public APIs

---

## Success Criteria for v1.0.0

- ✓ All P0 items are fixed
- ✓ All P1 items are mitigated (or time has run out)
