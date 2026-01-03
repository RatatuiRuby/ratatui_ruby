<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Priority 2: Moderate (Quality Gates)

These are v1.0.0 quality improvements that refine the example suite after P0 is complete. Not blocking, but recommended for maintainability and API consistency.

---

## 1. Consolidate 3 Redundant Example Pairs

### 1a. widget_list_styles + widget_list_demo → widget_list_demo

**Overlap:** Both demonstrate List widgets with highlighting and cycling behavior.

**Action:** Merge widget_list_styles styling attributes into widget_list_demo as additional hotkey cycles. Delete widget_list_styles.

**Files to delete:**
- examples/widget_list_styles/
- test/examples/widget_list_styles/
- sig/examples/widget_list_styles/

**Effort:** 2 hours

---

### 1b. app_table_select + widget_table_flex → widget_table_demo

**Overlap:** Both demonstrate Table widgets with different focuses.

**app_table_select:** Row/column selection, highlight styles, real-world data (processes)
**widget_table_flex:** Flex modes (:legacy, :space_between, :space_around), dummy data

**Action:** Create unified widget_table_demo combining:
- Row/column selection mechanics
- Flex mode cycling via hotkeys
- Real-world process data for context
- Correct event handling and Session API

**Files to delete:**
- widget_table_flex/ (or merge into new widget_table_demo)
- app_table_select/ (or merge into new widget_table_demo)
- Corresponding test and sig entries

**Effort:** 3 hours

---

### 1c. widget_block_padding + widget_block_titles → widget_block_demo

**Overlap:** Both demonstrate Block widget attributes.

**widget_block_padding:** Uniform and directional padding
**widget_block_titles:** Titles at multiple positions (top/bottom, left/center/right)

**Action:** Create unified widget_block_demo combining:
- All padding variations (uniform and directional)
- All title positions and alignments
- Interactive cycling via hotkeys
- Session API throughout

**Files to delete:**
- examples/widget_block_padding/
- examples/widget_block_titles/
- Corresponding test and sig entries

**Effort:** 2 hours

---

## Result of Consolidation

- **Before:** 35 examples
- **After:** 32 examples (3 pairs consolidated)
- **Examples deleted:** 6 directories
- **Tests merged:** 3 consolidations
- **Signatures merged:** 3 consolidations

---

## 2. Benefits

- **Reduced maintenance burden** (fewer examples to document, test, maintain)
- **Cleaner example suite** (no redundant demonstrations)
- **More comprehensive coverage** (consolidated examples demonstrate more attributes)

---

## 3. Add RDoc Cross-Links (Examples & Aliases)

**Status:** Important for API discoverability — Documentation should link library and examples

RDoc should cross-link between:
- **Library classes/methods** ↔ **Examples that use them** (See also: examples/widget_foo_demo)
- **Primary methods** ↔ **DWIM/TIMTOWTDI aliases** (See also: tui.foo_bar as alias for tui.foo(:bar))

### Current Practice

Done for:
- `RatatuiRuby::Frame#set_cursor_position` ↔ `RatatuiRuby::Cursor` (cross-linking)
- Limited elsewhere

### Gaps

- Most widget classes have no "See also: example_foo_demo" links
- Aliases/TIMTOWTDI variants are not documented as such
- Users can't easily find examples for a given class/method

### Action

1. Add `# See also: examples/widget_foo_demo/app.rb` to class/method RDoc
2. Link DWIM methods to TIMTOWTDI variants: `# Also available as: tui.constraint_length (DWIM) vs tui.constraint(:length) (TIMTOWTDI)`
3. Create consistent pattern across all public APIs in `lib/ratatui_ruby/`

### Example Pattern

```ruby
# Renders text with styling.
#
# See also: examples/widget_paragraph_demo/app.rb (basic paragraph rendering)
class Paragraph < Data.define(...)
  # ...
end

# DWIM version of constraint creation
# Also available as: constraint(type, value) for explicit control
def constraint_length(length)
  constraint(:length, length)
end
```

---

## Dependencies

- P0 (developing_examples.md, README.md, tests) should be complete before consolidation

---

## 4. Enhance Widget Examples with Functional Context

**Status:** Recommended — Move beyond "parameter playgrounds" to "real-world patterns"

Current `widget_*` examples mostly focus on interactive parameter turning (changing colors, borders, etc.). While useful for API discovery, they don't show *how* to use the widget in a real application logic flow.

### The Standard: widget_tabs_demo

The `widget_tabs_demo` was enhanced to show **conditional rendering** of content based on the selected tab in git commit `38ceed39a011d557cc66e11a4598d3341dc7a0cc`. It doesn't just highlight the tab; it changes the screen content. This connects the widget (the tabs) to the problem it solves (view segregation).

### Action

Identify other widget examples that could benefit from this "functional context" treatment:

-   **widget_popup_demo:** Show a multi-step modal flow (e.g., Confirm -> Success) rather than just a static overlay.
-   **widget_list_demo:** Show a master-detail view where selecting a list item updates a detail pane.
-   **widget_input_demo:** (If created) Show specific validation logic (email vs number).

**Goal:** Every widget example should answer "How do I build a feature with this?" not just "What does this parameter do?"
