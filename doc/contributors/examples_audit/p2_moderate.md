<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Priority 2: Moderate (Quality Gates)

These are v1.0.0 quality improvements that refine the example suite after P0 is complete. Not blocking, but recommended for maintainability and API consistency.

---

## 1. Add RDoc Cross-Links (Examples & Aliases)

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
