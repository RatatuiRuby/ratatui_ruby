<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Documentation Style Guide

This project follows a strict and specific documentation style designed to be helpful, readable, and consistent. It combines the structural clarity of Christopher Alexander's Pattern Language with the prose style of William Zinsser's *On Writing Well* and the usability of the U.S. Federal Plain Language Guidelines.

**All agents and contributors must adhere to these standards.**

## 1. Core Philosophy

*   **Context, Problem, Solution (Alexandrian Form):** Do not just say *what* a class does. Explain *why* it exists. Start with the context, state the problem (the pain point without this tool), and then present the class as the solution.
*   **Prose Style (Zinsser/Klinkenborg):** Use short, punchy sentences. Use active voice. Cut unnecessary words. Avoid "allow," "enable," "provide," "support," "functionality," and "capability" where possible. Weak verbs hide the action. Strong verbs drive the sentence.
*   **User-Centric (Plain Language):** Speak directly to the user ("You"). Don't abstract them away ("The developer"). Focus on their goals and how this tool helps them achieve those goals.

## 2. Class Documentation

Every public class must begin with a **Context-Problem-Solution** narrative.

### Structure

1.  **Summary Line:** A single line explaining the class's role.
2.  **Context (Narrative):** A short paragraph establishing the domain or situation.
3.  **Problem (Narrative):** A sentence or two identifying the specific difficulty, complexity, or "pain" the user faces in this context without the widget.
4.  **Solution (Narrative):** A sentence explaining how this widget solves that problem, often starting with "This widget..." or "Use it to...".
5.  **Usage (Narrative):** A concrete "Use it to..." sentence listing common applications.
6.  **Example:** A comprehensive, copy-pasteable code example using `=== Examples`. Provide **multiple** examples to cover different use cases (e.g., basic usage vs. advanced configuration).

### Example

**Bad (Generic/Descriptive):**
```ruby
# A widget for displaying list items.
# It allows the user to select an item from an array of strings.
# Supports scrolling and custom styling.
```

**Good (Alexandrian/Zinsser/Plain Language):**
```ruby
# Displays a selectable list of items.
#
# Users need to choose from options. Menus, file explorers, and selectors are everywhere.
# Implementing navigation, highlighting, and scrolling state from scratch is tedious.
#
# This widget manages the list. It renders the items. It highlights the selection. It handles the scrolling window.
#
# Use it to build main menus, navigation sidebars, or logs.
```

## 3. Method and Attribute Documentation

### Prose Style

*   **Attributes:** Use concise noun phrases. Avoid "This attribute returns..." or "Getter for...".
    *   *Bad:* "This is the width of the widget."
    *   *Good:* "Width of the widget in cells."
*   **Methods:** Use active, third-person present tense verbs.
    *   *Bad:* "Will calculate the total."
    *   *Good:* "Calculates the total."
*   **Context:** For complex methods, you may use a condensed version of the Context-Problem-Solution pattern, but keep it brief.

### Syntax Standards

*   **Examples:** All public methods must include at least one usage example. Use `=== Example`.
*   **Attributes:** Use `attr_reader` with documentation comments immediately preceding them.
*   **Parameters:** Use strict RDoc definition lists `[name] description` for parameters in the `initialize` method.
*   **Formatting:** Use `<tt>` tags for code literals, symbols, and values (e.g., `<tt>:vertical</tt>`).
    *   Do **not** use backticks (\`) or markdown-style links `[text](url)`. RDoc does not render them correctly in all contexts.
    *   Do **not** use smart quotes.

### Example

```ruby
  # The styling to apply to the content.
  attr_reader :style

  # Creates a new List.
  #
  # [items] Array of Strings.
  # [selected_index] Integer (nullable).
  def initialize(items: [], selected_index: nil)
    super
  end
```

## 4. RDoc Specifics

*   **No Endless Methods:** Do **not** use Ruby 3.0+ endless method definitions (`def foo = bar`). RDoc currently has a bug where it fails to correctly parse the end of the method, causing subsequent methods to be nested incorrectly in the documentation tree. Always use standard `def ... end` blocks.
*   **No YARD:** Do not use `@param`, `@return`, or other YARD tags. Use standard RDoc formats.
*   **Directives:** Use `:nodoc:` for private or internal methods that should not appear in the API docs.
*   **Headings:** Use `===` for section headers like `=== Examples`.

## 5. Checklist for Agents

Before finalizing documentation, ask:
1.  Did I explain the *problem* this code solves?
2.  Are my sentences short and active? (Did I remove "allows the user to"?)
3.  Is the code example valid and copy-pasteable?
4.  Did I use `<tt>` for symbols and code values?
5.  Did I document every attribute and parameter?
