<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Migration Plan: Adopting the Frame-Based API

Status: Approved  

Target Version: v0.5.0  

## Context:  

The current `RatatuiRuby.draw(tree)` API abstracts away the layout
process, forcing developers to duplicate constraint logic for
hit-testing (once for math, once for rendering). To align with native
Ratatui (Rust) and enable precise hit-testing without duplication, we
are adopting a Frame-Based API.  

This exposes a `Frame` object to Ruby that mirrors the Rust backend,
allowing explicit widget placement and coordinate access.

## Architecture: The "Frame" Pattern

We are moving from an implicit tree render to an explicit frame render.  

**Current (Implicit):**

```ruby
RatatuiRuby.draw(  
  Layout.new(children: [Sidebar.new, Main.new])  
)
```

**Target (Explicit):**

```ruby
RatatuiRuby.draw do |frame|  
  sidebar_rect, main_rect = Layout.split(frame.area, ...)

  frame.render_widget(Sidebar.new, sidebar_rect)  
  frame.render_widget(Main.new, main_rect)

  # DX Win: We now have `sidebar_rect` available for hit-testing logic immediately.  
end
```

---

## Phase 1: The Rust Foundation

**Goal:** Expose the `Frame` and `render_widget` logic to Ruby via Magnus.

### Step 1.1: Define the `RubyFrame` Struct

* **File:** `ext/ratatui_ruby/src/frame.rs` (Create new file)

* **Action:**

    * Define a struct `RubyFrame` that wraps a mutable reference to `ratatui::Frame`.

    * *Note:* Since `Frame` in Ratatui has a lifetime, the wrapper must handle this safety (likely via `RefCell` or unsafe pointer casting for the duration of the block—ensure safety invariants).

    * Implement `area()`: Returns the `Rect` of the full terminal buffer.

    * Implement `render_widget(widget, area)`:

        * Accepts a Ruby widget object (which we already know how to parse).

        * Accepts a `Rect`.

        * Calls `frame.render_widget(converted_widget, area)`.

### Step 1.2: Update `lib.rs` and `rendering.rs`

* **File:** `ext/ratatui_ruby/src/lib.rs`

* **Action:**

    * Modify the `draw` function.

    * It currently accepts a generic `Value` (the tree).

    * Update signature to accept an optional `Block`.

    * **Logic:**

        * Lock `Terminal`.

        * Call `terminal.draw(|f| { ... })`.

        * Inside the Rust closure:

            * Instantiate `RubyFrame` wrapping `f`.

            * If a block is given: `block.call(ruby_frame)`.

            * If no block (Legacy Mode): `f.render_widget(tree, f.size())` (Keep existing logic for backward compatibility).

---

## Phase 2: The Ruby Schema & Helpers

**Goal:** Create the Ruby-side interface for the new Rust capabilities.

### Step 2.1: Define `RatatuiRuby::Frame`

* **File:** `lib/ratatui_ruby/frame.rb`

* **Action:**

    * Define the class `Frame`.

    * Document methods:

        * `#area -> Rect`

        * `#render_widget(widget, rect) -> nil`

    * *Note:* The actual implementation is in Rust, but having the Ruby file helps RDoc/RBS.

### Step 2.2: Update `RatatuiRuby.draw` Signature

* **File:** `lib/ratatui_ruby.rb`

* **Action:**

    * Update `def self.draw(tree = nil, &block)`.

    * Add validation: Must provide *either* a tree *or* a block, not both/neither.

---

## Phase 3: Layout Integration

**Goal:** Ensure `Layout.split` is the primary way users slice the `Frame`.

### Step 3.1: Verify `Layout.split`

* **Context:** We added `Layout.split` recently.

* **Action:** Ensure it is robust and returns `Array<Rect>`.

* **Test:** Add a unit test in `test/ratatui_ruby/layout_test.rb` verifying it returns correct coordinates without drawing anything.

---

## Phase 4: Migration & Verification

**Goal:** Prove the new API works by refactoring an example.

### Step 4.1: Create `examples/frame_demo.rb`

* **Action:** Create a new demo app that uses the new block syntax.

* **Logic:**

    * `RatatuiRuby.draw do |frame| ... end`

    * Calculate layout: `left, right = Layout.split(frame.area, ...)`

    * Render widgets: `frame.render_widget(w1, left)`

    * **Hit Test Verification:** Store left rect in an instance variable. In `handle_input`, check if `@left_rect.contains?(mouse)`.

### Step 4.2: Update `examples/hit_test.rb`

* **Action:** Refactor the existing "Hit Test" example (which currently manually calculates layout) to use the `Frame` API.

* **Goal:** Delete the manual `calculate_layout` method. Use the rects returned from `Layout.split` inside the `draw` block.

---

## Execution Order for Development Agents

1. **Agent 1 (Rust Core):** Implement `ext/ratatui_ruby/src/frame.rs` and update `lib.rs` to expose the `Frame` class and modify `draw` to accept a block.

2. **Agent 2 (Ruby Core):** Create `lib/ratatui_ruby/frame.rb`, update `RatatuiRuby.draw` interface, and ensure `Layout.split` is fully documented and tested.

3. **Agent 3 (Validation):** Create `examples/frame_demo.rb` and refactor `examples/hit_test.rb` to demonstrate the removal of redundant layout logic.

## Definition of Done:

* `RatatuiRuby.draw` accepts a block.

* The block receives a `Frame` object.

* `frame.render_widget(widget, rect)` successfully draws to the screen.

* `frame.area` returns the correct terminal dimensions.

* Backward compatibility for `RatatuiRuby.draw(tree)` is preserved.
