# Architectural Overhaul: Strict Modularization

## Phase 1: The Great Rename
- [x] Create `lib/ratatui_ruby/layout/` module with Rect, Constraint, Layout
- [x] Create `lib/ratatui_ruby/widgets/` module with Table, List, Paragraph, Block, etc.
- [x] Create `lib/ratatui_ruby/style/` module with Style
- [x] Create `lib/ratatui_ruby/buffer/` module with Cell (renamed from current)
- [x] Update `lib/ratatui_ruby.rb` requires
- [x] Update Rust backend for new class names in rendering.rs
- [x] Update all tests for new namespaces (0 errors, from 471)
- [ ] Fix RuboCop issues

## Phase 2: Session Hardening
- [x] Rewrite Session with explicit factory methods (no metaprogramming)
- [x] Add RDoc to each factory method
- [x] Ensure IDE autocomplete works

## Phase 3: Table Enhancements
- [ ] Implement `Widgets::Cell` (content + style)
- [ ] Move Row to `Widgets::Row`
- [ ] Add `table_row` and `table_cell` helpers to Session
- [ ] Update table.rs for new types

## Phase 4: Fix Examples
- [ ] Update all examples to use Session API
- [ ] Update CHANGELOG with migration guide

## Definition of Done
- [ ] `bin/agent_rake` passes
- [ ] CHANGELOG updated with breaking changes

