<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Phase 4: Fix Examples and Documentation

Update all examples, RDoc, and *.md files to use the new namespace structure and TUI API.

## Proposed Changes

### Examples

#### [MODIFY] examples/app_stateful_interaction/app.rb
- Update `RatatuiRuby::ListState.new` → `RatatuiRuby::ListState.new` (already correct namespace)
- Update `RatatuiRuby::TableState.new` → `RatatuiRuby::TableState.new` (already correct)

#### [MODIFY] examples/app_all_events/view/*.rb (5 files)
- Update RDoc comments: `RatatuiRuby::Rect` → `RatatuiRuby::Layout::Rect`

---

### Library RDoc

#### [MODIFY] lib/ratatui_ruby/frame.rb
- Update examples in RDoc to use TUI API or new namespaces:
    - `RatatuiRuby::Widgets::Paragraph.new` → `Widgets::Paragraph.new` or TUI API
    - `RatatuiRuby::Layout::Constraint.length` → `Layout::Constraint.length`
    - `RatatuiRuby::ListState.new` → stays as-is (correct namespace)
    - `RatatuiRuby::Widgets::List.new` → `Widgets::List.new`
    - `RatatuiRuby::Widgets::Block.new` → `Widgets::Block.new`

#### [MODIFY] lib/ratatui_ruby/schema/layout.rb
- Update reference: `RatatuiRuby::Constraint` → `Layout::Constraint`

#### [MODIFY] lib/ratatui_ruby/table_state.rb
- Update RDoc: `RatatuiRuby::Widgets::Table.new` → `Widgets::Table.new`

#### [MODIFY] lib/ratatui_ruby/list_state.rb
- Update RDoc: `RatatuiRuby::Widgets::List.new` → `Widgets::List.new`

#### [MODIFY] lib/ratatui_ruby/test_helper/style_assertions.rb
- Update RDoc: `RatatuiRuby::Layout::Rect.new` → `Layout::Rect.new`

---

### Documentation

#### [MODIFY] doc/application_architecture.md
- Update all examples to use TUI API where possible
- Update direct class references to new namespaces

#### [MODIFY] doc/quickstart.md
- Update `RatatuiRuby::Widgets::Paragraph.new` reference
- Update `RatatuiRuby::Constraint` reference

#### [MODIFY] doc/contributors/design/ruby_frontend.md
- Update all widget examples to new namespaces

#### [MODIFY] doc/contributors/design/rust_backend.md
- Update `RatatuiRuby::Paragraph` reference

#### [MODIFY] doc/contributors/table_row_cell_and_namespacing_response.md
- This file documents the migration - keep as-is (historical reference)

---

## Execution Strategy

Use `sed` for bulk updates:
1. Update examples RDoc: `RatatuiRuby::Rect` → `RatatuiRuby::Layout::Rect`
2. Update lib RDoc: Use TUI API in examples where practical
3. Update doc/*.md: Use TUI API or new namespaces

## Verification Plan

### Automated Tests
- `bin/agent_rake` — All 747 tests must pass
- RDoc coverage must pass (no undocumented public methods)

### Manual Verification
- Review key documentation files for correctness after sed replacements
