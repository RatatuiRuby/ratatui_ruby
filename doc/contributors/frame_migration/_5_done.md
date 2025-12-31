<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Prompt for Verification Agent: Final Review

You are a Tech Lead Agent. Multiple Developer Agents have attempted to implement the Frame Migration. Your task is to verify the end-to-end feature works, identify gaps, and fix issues.

## Context

The goal was to implement a Frame-based rendering API as described in [frame_migration.md](../../../doc/contributors/frame_migration.md) and [frame_proposal.md](../../frame_proposal.md).

**The core outcome**: Users can call `RatatuiRuby.draw { |frame| ... }` where the block receives a `Frame` object with `area` and `render_widget` methods. This eliminates duplicated layout logic for hit-testing.

Agents may have:
- Made different design decisions than originally specified.
- Used different file paths or method names.
- Encountered issues that required workarounds.
- Left work incomplete or with bugs.

**Your job is not to enforce the original specs, but to ensure the feature works.**

## Verification Approach

### Step 1: Understand What Was Built

Before checking anything, **explore the codebase** to understand what the agents actually implemented:

1. Search for `RubyFrame` or `Frame` in `ext/ratatui_ruby/src/`.
2. Search for `Frame` class in `lib/ratatui_ruby/`.
3. Check how `draw` is currently implemented in both Rust and Ruby.
4. Look at any new or modified examples.

Build a mental model of the actual implementation before comparing to the spec.

### Step 2: Test the Core User Journey

The feature works if a user can:

1. Call `RatatuiRuby.draw` with a block.
2. Receive a `Frame` object in the block.
3. Access `frame.area` to get terminal dimensions as a `Rect`.
4. Call `frame.render_widget(some_widget, some_rect)` to render.
5. Use `Layout.split(frame.area, ...)` to compute rects.
6. Store those rects and use them for hit-testing outside the draw block.
7. Still use legacy `RatatuiRuby.draw(tree)` if desired.

**Write a simple test script** (or find existing tests) that exercises this journey. Run it. Does it work?

### Step 3: Run the Test Suite

```bash
bundle exec rake
```

- Do all tests pass?
- Are there new tests for Frame functionality?
- Are there test failures that indicate incomplete work?

### Step 4: Check Documentation

- Does `bundle exec rake rdoc` succeed?
- Is `Frame` documented in the generated docs?
- Does the documentation follow project style (`doc/contributors/documentation_style.md`)?

### Step 5: Identify Gaps

Compare outcomes to the Definition of Done from `frame_migration.md`:

- ✅ or ❌ `RatatuiRuby.draw` accepts a block.
- ✅ or ❌ The block receives a `Frame` object.
- ✅ or ❌ `frame.render_widget(widget, rect)` successfully draws to the screen.
- ✅ or ❌ `frame.area` returns the correct terminal dimensions.
- ✅ or ❌ Backward compatibility for `RatatuiRuby.draw(tree)` is preserved.

For any ❌, investigate root cause and fix.

## Fixing Issues

When you find issues:

1. Understand why the previous agent made the choice they did (read their code, comments, commit messages if available).
2. Decide if it's a bug, incomplete work, or a valid but undocumented design decision.
3. Fix bugs and incomplete work.
4. Document valid design decisions that differ from the original spec.

## If Major Components Are Missing

If an entire phase was skipped or fundamentally broken, refer to the step-by-step prompts in this directory for guidance:
- `_1_1.1.md`, `_1_1.2.md` - Rust foundation
- `_2_2.1.md`, `_2_2.2.md` - Ruby interface
- `_3_3.1.md` - Layout.split verification
- `_4_4.1.md`, `_4_4.2.md` - Example applications

## Final Deliverable

After verification and fixes:

1. All tests pass.
2. The core user journey works end-to-end.
3. Documentation is complete.
4. Update `CHANGELOG.md` for v0.5.0 if not already done.
5. Summarize what you found and fixed.
