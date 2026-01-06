<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Parity Auditing Process

This guide describes the **process** for auditing RatatuiRuby against upstream Rust Ratatui to find API parity gaps of any kind.

## Philosophy

RatatuiRuby should behave identically to Rust Ratatui. When a Rust user can do something with a widget, a Ruby user should be able to do the equivalent. Deviations are bugs.

## The Audit Mindset

### Ask the Right Questions

Every audit begins with a question:

- "Does RatatuiRuby support everything upstream supports for widget X?"
- "When I pass type Y to parameter Z, does Ruby do what Rust does?"
- "Are there features in upstream that we haven't exposed at all?"

### Symptoms That Trigger Audits

- **Inspect strings in output** (`#<data RatatuiRuby::...>`) — type conversion failure
- **Missing methods** — user can't access upstream functionality
- **Wrong behavior** — code runs but produces different results than Rust
- **Type mismatches** — Ruby API accepts different types than Rust API

## The Three-Layer Model

Every RatatuiRuby feature has three layers. Gaps can occur at any layer:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```
┌─────────────────────────────┐
│  Ruby API (lib/**/*.rb)    │  ← What users see
├─────────────────────────────┤
│  Rust Bindings (ext/**/*.rs)│  ← Bridge layer
├─────────────────────────────┤
│  Upstream Ratatui          │  ← Source of truth
└─────────────────────────────┘
```
<!-- SPDX-SnippetEnd -->

### Layer 1: Ruby API Gaps
Ruby doesn't expose a parameter that upstream supports.

### Layer 2: Binding Gaps  
Ruby exposes a parameter, but the Rust binding converts it incorrectly.

### Layer 3: Upstream Changes
New upstream features we haven't implemented yet.

## Audit Process

### 1. Choose an Audit Scope

Define what you're auditing:
- **Single widget**: All parameters of `Tabs`
- **Single feature**: All places that accept styled text
- **Version delta**: Everything new in Ratatui 0.29

### 2. Establish Source of Truth

For any scope, identify the authoritative upstream source:
- **Method signatures** → Rust source files
- **Type constraints** → Generic bounds (`Into<Line>`, `&str`, etc.)
- **Behavior** → Upstream documentation and tests

### 3. Inventory Our Implementation

List everything in our codebase related to the scope:
- Ruby classes and methods
- Rust binding functions
- Conversion/parsing logic

### 4. Compare Systematically

For each item in the upstream source of truth, ask:
1. Do we expose this at all?
2. If yes, does our implementation match the type signature?
3. If yes, does our behavior match?

### 5. Document Findings

For each gap found, record:
- What the gap is
- Where it occurs (files, lines)
- What upstream expects
- What we currently do

### 6. Fix and Verify

Apply fixes, then verify:
- Compiles without errors
- Tests pass
- Visual/manual verification if applicable

## Verifying Completeness

Finding gaps is not enough. You must verify you've found **all** gaps within your scope.

### The Completeness Mindset

An initial audit pass often finds the obvious issues. But "obvious" means "incomplete." After your first pass, stop and ask:

- Did I search for **every variation** of the pattern I was looking for?
- Are there **synonyms or related terms** I should also search?
- Did I check **all code paths**, not just the happy path?
- Are there **duplicate implementations** (e.g., `render` vs `render_stateful`)?

### Broaden Your Search Terms

Your first search term won't catch everything. For each pattern, think of variations:

| If you searched for... | Also search for... |
|------------------------|-------------------|
| `funcall("to_s"` | `String::try_convert` |
| `Into<Line>` | `Into<Span>`, `Into<Text>` |
| One widget's file | All widget files |
| The method you're fixing | Related methods in the same file |

### Work From the Complete List

Don't spot-check. Generate the **complete list** of potential issues, then classify each one:

1. Run a search that catches all possible instances
2. Count them (e.g., "31 `to_s` call sites")
3. Review **every single one**, marking each as "gap" or "correct"

Half-measures lead to half-fixes.

### Verify Against Upstream Exhaustively

For type-related gaps, don't just check the methods you already know about. Search upstream for **all uses of the pattern**:

- `grep -rn 'Into<Line' /path/to/ratatui/src/widgets` finds EVERY place upstream accepts `Line`
- Then verify we handle EACH of those correctly

### Question Your Assumptions

After completing your audit, challenge yourself:

- "Is there anywhere I should look that I haven't?"
- "Is there any term I should search that I haven't?"
- "Am I sure I didn't miss anything?"

If you can't answer confidently, keep searching.

### The "One More Pass" Rule

When you think you're done, do one more verification pass with a different approach:

- If you searched our code first, now search upstream first
- If you searched for method names, now search for type signatures
- If you audited file-by-file, now audit feature-by-feature

This catches gaps your initial framing missed.


## Search Strategies

Different gap types require different search approaches:

### Finding Type Conversion Gaps

Look for places where we convert Ruby objects to simpler types:
- `funcall("to_s", ...)` — converting to string
- `String::try_convert(...)` — same
- `u16::try_convert(...)` — numeric conversion

Then check: does upstream accept richer types?

### Finding Missing Features

Compare file structure:
- What files/modules exist upstream?
- What methods exist in each upstream struct?
- What parameters does each upstream method accept?

### Finding Behavioral Differences

Run equivalent code in both environments and compare output.

## Red Flags in Our Code

When reviewing RatatuiRuby code, these patterns suggest potential gaps:

| Pattern | Potential Gap |
|---------|---------------|
| `funcall("to_s", ...)` | Upstream may accept styled types |
| `usize` or `u16` for padding | Upstream may accept content types |
| Missing `parse_*` call before using a value | Type not being converted properly |
| Widget with fewer Ruby methods than Rust methods | Missing functionality |
| `// TODO` or `// FIXME` comments | Known gaps |

## Upstream Patterns to Watch For

When reading upstream Rust code, these signatures indicate rich type support:

| Rust Signature | Meaning | Ruby Should Accept |
|----------------|---------|-------------------|
| `Into<Span<'a>>` | Styled single fragment | `Text::Span` or `String` |
| `Into<Line<'a>>` | Styled line | `Text::Line`, `Text::Span`, or `String` |
| `Into<Text<'a>>` | Multi-line styled | `Text::Text`, `Text::Line`, or `String` |
| `T: AsRef<str>` | Any string-like | `String` (OK) |
| `&'a str` | String slice | `String` (OK) |

## Keeping Audits Maintainable

### Create Checklists

For each widget or feature area, maintain a checklist of all parameters with their expected types.

### Track Upstream Changes

When upgrading Ratatui versions:
1. Read the changelog
2. Search for new `pub fn` in widget files
3. Audit new functionality before exposing it

### Automate Where Possible

Consider tooling that:
- Compares upstream method counts to ours
- Flags new `to_s` calls in code review
- Tests styled content rendering

## Example Audit Narrative

> "I noticed inspect strings appearing in my tabs. I asked: 'What types does upstream accept for the divider parameter?' I found `Into<Span>`. I then asked: 'What does our binding do?' I found we call `to_s`. Gap identified."

This narrative approach—asking questions, finding answers, comparing—works for any parity issue.
