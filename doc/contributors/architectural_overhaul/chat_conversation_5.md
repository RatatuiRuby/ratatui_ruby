<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Chat Conversation

Note: _This is purely the output of the chat conversation and does not contain any raw data, codebase snippets, etc. used to generate the output._

### User Input

We have just finished @[../ratatui_ruby/doc/contributors/table_row_cell_and_namespacing_response.md] (@[../ratatui_ruby/doc/v0.7.0_migration.md])Look at the diff since `trunk`. Everything is covered in @[/Users/kerrick/Developer/ratatui_ruby/CHANGELOG.md:L11-L38]. I need you to read @[/Users/kerrick/Developer/ratatui_ruby/doc/contributors/design/ruby_frontend.md:L32-L162] and then audit the _entire_ TUI API (method names in lib/**/*.rb **and** signatures in sig/**/*.rbs). These used to be named based on metaprogamming with the old class/module layout. That means their current names are legacy cruft. I want you to audit ALL methods exposed for being as terse-but-clear, conventient, and obvious as possible. I suspect many are not, such as `shape_circle` -- there is no need to disambiguate via `shape_` because there is not another `circle` anywhere. Before we launch to v1.0.0 we need this API to be as streamlined as possible. While our primary goal with the module/class API was alignment with Ratatui, our primary goal with the TUI API is developer experience (DX). Programmer Happiness, DWIM, and TIMTOWTDI, in the style of Rubyists (see below). Put your audit findings into doc/contributors/alignment_audit_tui.md. It must include the following sections:

```
## User Feedback Needed

## Suggested: Method Names

### Leave As-Is

### Rename (Breaking)

### Rename and Alias (Non-Breaking)

### Alias Only (Non-Breaking)

## Suggested: Parameter Names

### Leave As-Is

### Rename (Breaking)

### Rename and Alias (Non-Breaking)

### Alias Only (Non-Breaking)
```

Each section should have a bulleted list of recommendations (if any), such as:

```
- `shape_circle` -> `circle`
```

(Depending upon context, that might mean rename or alias, for example)



**The Style of Rubyists**: Eloquent Ruby (Russ Olsen), POODR (Sandi Metz), The Rails Way (Obie Fernandez), Omakase (DHH), TIMTOWTDI / DWIM (Perl roots), Pure OOP (Smalltalk roots), SOLID (Robert C. Martin), PickAxe (Dave Thomas), Focus on Programmer Happiness (Yukihiro Matsumoto aka Matz)

*Viewed [table_row_cell_and_namespacing_response.md](file:///Users/kerrick/Developer/ratatui_ruby/doc/contributors/table_row_cell_and_namespacing_response.md) *

*Viewed [v0.7.0_migration.md](file:///Users/kerrick/Developer/ratatui_ruby/doc/v0.7.0_migration.md) *

*Searched filesystem*

*Viewed [tui.rbs](file:///Users/kerrick/Developer/ratatui_ruby/sig/ratatui_ruby/tui.rbs) *

### Planner Response

Now I need to view all the TUI mixin files to understand the full API surface. Let me also view the RBS signature files for more complete type information.

*Viewed [core.rb](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/core.rb) *

*Viewed [buffer_factories.rb](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/buffer_factories.rb) *

*Viewed [canvas_factories.rb](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/canvas_factories.rb) *

*Viewed [layout_factories.rb](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb) *

*Viewed [state_factories.rb](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/state_factories.rb) *

*Viewed [style_factories.rb](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/style_factories.rb) *

*Viewed [text_factories.rb](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/text_factories.rb) *

*Viewed [widget_factories.rb](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb) *

### Planner Response

Now I have a good view of the current TUI API. Let me also check the RBS signature files for the mixins to see the complete type signatures, and then look for any other methods or potential naming conflicts in the codebase.

*Searched filesystem*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Listed directory [widgets](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/widgets) *

### Planner Response

I can see that [line](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/text_factories.rb:30:6-34:9) is already used for `Text::Line` in the TUI API, which creates a conflict with [shape_line](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/canvas_factories.rb:18:6-22:9) (Canvas line). This confirms the need for namespacing shapes. Let me now look at the RBS files for complete signatures and also check the widget parameters to audit parameter names.

*Viewed [canvas_factories.rbs](file:///Users/kerrick/Developer/ratatui_ruby/sig/ratatui_ruby/tui/canvas_factories.rbs) *

*Viewed [widget_factories.rbs](file:///Users/kerrick/Developer/ratatui_ruby/sig/ratatui_ruby/tui/widget_factories.rbs) *

*Viewed [layout_factories.rbs](file:///Users/kerrick/Developer/ratatui_ruby/sig/ratatui_ruby/tui/layout_factories.rbs) *

*Viewed [text_factories.rbs](file:///Users/kerrick/Developer/ratatui_ruby/sig/ratatui_ruby/tui/text_factories.rbs) *

*Viewed [state_factories.rbs](file:///Users/kerrick/Developer/ratatui_ruby/sig/ratatui_ruby/tui/state_factories.rbs) *

*Viewed [buffer_factories.rbs](file:///Users/kerrick/Developer/ratatui_ruby/sig/ratatui_ruby/tui/buffer_factories.rbs) *

*Viewed [core.rbs](file:///Users/kerrick/Developer/ratatui_ruby/sig/ratatui_ruby/tui/core.rbs) *

*Viewed [style_factories.rbs](file:///Users/kerrick/Developer/ratatui_ruby/sig/ratatui_ruby/tui/style_factories.rbs) *

### Planner Response

Now I have a complete picture of the TUI API. Let me also look at the underlying widget classes to understand the parameter names being used, and check for any parameter naming issues.

*Viewed [table.rb](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/widgets/table.rb) *

*Viewed [list.rb](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/widgets/list.rb) *

*Viewed [scrollbar.rb](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/widgets/scrollbar.rb) *

*Viewed [chart.rb](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/widgets/chart.rb) *

### Planner Response

Now I have a comprehensive understanding of the TUI API. This is a documentation/audit task, not a code change task, so I can write the audit document directly. Let me also check the shape files to understand the full Shape API.

*Listed directory [shape](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/widgets/shape) *

### Planner Response

Let me find where the Shape classes are defined, as they seem to be somewhere else:

*Grep searched codebase*

*Grep searched codebase*

### Planner Response

Now I have a complete picture. The Shape classes (Circle, Line, Point, Rectangle, Map) are nested inside `Widgets::Shape` module. Since this is a documentation/audit task (not a code change), I don't need an implementation plan. I'll create the audit document directly.

*Edited relevant file*

### Planner Response

The audit document is complete. Now I need to notify the user for their review and feedback on the questions raised in the "User Feedback Needed" section.

### User Input

@[/Users/kerrick/Developer/ratatui_ruby/doc/contributors/alignment_audit_tui.md:L29] We have this habit already, especially around key events. @[../ratatui_ruby/lib/ratatui_ruby/event/key.rb] 

@[/Users/kerrick/Developer/ratatui_ruby/doc/contributors/alignment_audit_tui.md:L30] This could be aliased in both directions, though. `shape_line`, `line_shape`, `text_line`, `line_text`. The bare shape could take a symbol/string argument prefix `shape(type = nil, ...)` and delegate to the right one, erroring/crashing on type nil (unless you can think of a better DX than "fail fast" for folks who type `shape` expecting it to work).

@[/Users/kerrick/Developer/ratatui_ruby/doc/contributors/alignment_audit_tui.md:L31] Grouping is not more valuable than being shorter. But having _both_ is good.Having more than both is probably better... if Ratatui's module structure dictated we have RatatuiRuby::Foo::Bar::Baz::MyThing, we might consider supporting `tui.my_thing` _and_ `tui.foo_bar_baz_my_thing` _and_ `tui.foo.bar.baz.my_thing`, and maybe more? Where does DWIM/TIMTOWTDO stop being heplful, and start being harmful?

@[/Users/kerrick/Developer/ratatui_ruby/doc/contributors/alignment_audit_tui.md:L33-L36] Same as for schema classes

@[/Users/kerrick/Developer/ratatui_ruby/doc/contributors/alignment_audit_tui.md:L38] Given the kinds of things Ratatui does and does not implement (see /Users/kerrick/Developer/ratatui/ for source code and documentation), do you think this is a likely enough future scenario that we must reserve the word?

----

@[/Users/kerrick/Developer/ratatui_ruby/doc/contributors/alignment_audit_tui.md:L58] I'm curious why `item` didn't come to mind here, either as a change or alias.

@[/Users/kerrick/Developer/ratatui_ruby/doc/contributors/alignment_audit_tui.md:L80] I'm curious why `split` didn't come to mind here.

(and  more like that).

Think about the DX first and foremost. Folks are typing things like `@tui.layout_split` _all over_ the place. Grep examples/**/*.rb for layout_split with 10 lines of context to see what I mean.

----

@[/Users/kerrick/Developer/ratatui_ruby/doc/contributors/alignment_audit_tui.md:L108] Could this get confused with `text_width` or is that pretty clear?

----

You seem to hahve prioritized a lack of breaking changes. Don't forget: @[/Users/kerrick/Developer/ratatui_ruby/AGENTS.md:L19-L24] 

----

@[/Users/kerrick/Developer/ratatui_ruby/doc/contributors/alignment_audit_tui.md:L175] Doesn't this ignore DWIM? Look at our Key aliases. Look at @[/Users/kerrick/Developer/ratatui_ruby/CHANGELOG.md:L58] .

----

Before changing anything, discuss my feedback with me.

### Planner Response

Let me examine the referenced files to better understand your feedback and the established patterns:

*Viewed [key.rb](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/event/key.rb) *

*Grep searched codebase*

*Viewed [dwim_dx.md](file:///Users/kerrick/Developer/ratatui_ruby/doc/contributors/dwim_dx.md) *

### Planner Response

This is excellent feedback! Let me now check the Ratatui source to answer your question about [label](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:187:6-191:9) and understand the likelihood of a future conflict:

*Grep searched codebase*

*Grep searched codebase*

### Planner Response

I now have a complete picture. Let me discuss your feedback:

---

## Discussion of Feedback

### 1. On Shape Method Naming (Bidirectional Aliases)

Great point about bidirectional aliases! Looking at `Event::Key`, you have patterns like:
- `pause?` matches both `"pause"` (system) and `"media_pause"` (media)
- DWIM via [method_missing](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/event/key.rb:198:6-250:9) that is flexible and forgiving

Your suggestion for shapes is compelling:
- [shape_line](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/canvas_factories.rb:18:6-22:9) / `line_shape` / (both work)
- [shape_circle](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/canvas_factories.rb:30:6-34:9) / `circle_shape` / [circle](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/canvas_factories.rb:30:6-34:9) (all work)
- A dispatch method [shape(type = nil, ...)](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/canvas_factories.rb:14:6-16:9) that errors on nil with a helpful message

This matches the Ruby ethos perfectly. The [shape(:circle, ...)](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/canvas_factories.rb:14:6-16:9) pattern is elegant—it's almost like a mini-DSL.

**My take**: The fail-fast on [shape()](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/canvas_factories.rb:14:6-16:9) with no type is correct. An error like `"Shape type required. Valid types: :circle, :line, :point, :rectangle, :map, :label"` would be DWIM-friendly.

### 2. On "Where does TIMTOWTDI stop being helpful?"

You raise a profound question. For `RatatuiRuby::Foo::Bar::Baz::MyThing`:
- `tui.my_thing` — always
- `tui.foo_bar_baz_my_thing` — rarely useful, adds noise
- `tui.foo.bar.baz.my_thing` — interesting, but creates method chaining complexity

I think the answer is **two levels max**:
1. **Terse**: `tui.circle` (most common)
2. **Scoped**: `tui.shape_circle` (for disambiguation when in doubt)

A third level (`tui.widgets.shape.circle`) starts feeling like Java and defeats the purpose of the facade.

### 3. On Constraint Methods (Same as Schema Classes)

I now understand you mean the constraint factory methods should follow the same pattern as whatever we decide for the schema classes. Makes sense—consistency across the API.

### 4. On [label](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:187:6-191:9) Reservation

Looking at Ratatui's source, `Label` **only exists in [widgets/canvas.rs](cci:7://file:///Users/kerrick/Developer/ratatui/src/widgets/canvas.rs:0:0-0:0)** as `pub struct Label`. There is no standalone `Label` widget, form label, or accessibility label. Ratatui is a TUI framework, not a GUI framework—form labels and accessibility annotations are outside its scope.

**Conclusion**: [label](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:187:6-191:9) is safe to add as a short alias for [shape_label](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:187:6-191:9). The risk is negligible.

### 5. On [list_item](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:31:6-35:9) → [item](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:31:6-35:9)

You're right—I didn't consider [item](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:31:6-35:9) as an alias. In context (`tui.list(items: [...])` paired with `tui.item(...)`), it's clear. However, [item](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:31:6-35:9) is quite generic. In the context of a TUI:
- Could [item](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:31:6-35:9) be confused with a "menu item"?
- Could it conflict with future widgets like `MenuItem`?

Looking at Ratatui's source, there's no `MenuItem` struct, and menus are typically built with [List](cci:2://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/widgets/list.rb:30:4-124:7). So [item](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:31:6-35:9) as an alias for [list_item](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:31:6-35:9) seems reasonable. But I'd lean toward **keeping both** ([list_item](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:31:6-35:9) and [item](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:31:6-35:9)) rather than renaming.

### 6. On [layout_split](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:66:6-70:9) → [split](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:66:6-70:9)

You're absolutely right. Looking at the examples, `@tui.layout_split` appears **52 times** across examples. That's a lot of typing.

[split](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:66:6-70:9) alone is clear in context:
```ruby
top, bottom = @tui.split(frame.area, constraints: [...])
```

Should there be a conflict worry? `String#split` exists, but [TUI](cci:2://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:6:2-193:5) isn't a String. The only potential ruby-level conflict would be if [TUI](cci:2://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:6:2-193:5) is ever mixed into modules that have [split](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:66:6-70:9), but that's unlikely.

**My vote**: Add [split](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:66:6-70:9) as an alias for [layout_split](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:66:6-70:9).

### 7. On [length](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:24:6-28:9) vs [text_width](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/text_factories.rb:36:6-40:9)

Could [length](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:24:6-28:9) get confused with [text_width](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/text_factories.rb:36:6-40:9)?

- [text_width("hello")](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/text_factories.rb:36:6-40:9) — measures display width in terminal cells
- [length](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:24:6-28:9) (constraint) — specifies a fixed size constraint

These are semantically different:
- [length](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:24:6-28:9) is about **layout constraints** (how much space to allocate)
- [text_width](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/text_factories.rb:36:6-40:9) is about **text measurement** (how much space text needs)

I think they're clear, but both operating on "sizes" could cause confusion for newcomers. Possible solutions:
- Keep [constraint_length](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:24:6-28:9) (verbose but explicit)
- Use `fixed` instead of [length](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:24:6-28:9) (e.g., `tui.fixed(20)` for a fixed-size constraint)

Actually, `fixed` might be even clearer than [length](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:24:6-28:9). What do you think?

### 8. On Pre-1.0 Breaking Changes

You're right—I was overly cautious. AGENTS.md explicitly says:
> Breaking changes are **NOT** a priority at this stage. Since there are no external users, you are encouraged to refactor APIs for better ergonomics.

I should have considered **renames** more seriously, not just aliases.

### 9. On Deprecating Redundant Aliases (DWIM Argument)

You make a compelling DWIM argument with the Key event example. The `pause?` predicate matching both `"pause"` and `"media_pause"` is **adding aliases**, not deprecating them.

For the TUI:
- [table_row](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:49:6-53:9) isn't hurting anyone—keep it as an alias alongside [row](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:43:6-47:9)
- [bar_chart_bar](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:103:6-107:9) is verbose, but if someone prefers it, DWIM says let them

**Revised thinking**: Don't deprecate. DWIM means more ways to express the same thing, not fewer.

---

## Summary of Revised Recommendations

Based on your feedback:

| Original | Revised |
|----------|---------|
| Add short aliases for shapes | Add bidirectional aliases (`shape_*`, `*_shape`, bare `*`) + [shape(type, ...)](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/canvas_factories.rb:14:6-16:9) dispatcher |
| [shape_label](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:187:6-191:9) keep as-is | [label](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:187:6-191:9) is safe to add as alias (no Ratatui conflict) |
| [list_item](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:31:6-35:9) leave as-is | Add [item](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/widget_factories.rb:31:6-35:9) as alias |
| [layout_split](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:66:6-70:9) leave as-is | Add [split](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:66:6-70:9) as alias |
| [constraint_length](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:24:6-28:9) alias [length](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:24:6-28:9) | Consider `fixed` instead of [length](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/layout_factories.rb:24:6-28:9) to avoid confusion with [text_width](cci:1://file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/tui/text_factories.rb:36:6-40:9) |
| Deprecate verbose aliases | Don't deprecate—DWIM says "more ways is better" |

Should I update the audit document with these revised recommendations?

### User Input

> 1. On Shape Method Naming (Bidirectional Aliases)

I hadn't even thought of offering dispatch methods for more than just disambiguation, but now I kinda love also offering it on... everything? If you don't disagree, go with that.

---

> 2. On "Where does TIMTOWTDI stop being helpful?"

Okay, I agree. Two levels max, no dots.

----

> 5. On list_item → item
Yes, both.

----

> Actually, fixed might be even clearer than length. What do you think?
I think we should KEEP the one that aligns with ratatui, but ALSO add the clear one(s). In addition to fixed, consider whether these constraints have anything to do with CSS grid and/or flexbox, and what other aliases we could use to make front-end developers happy.

----

> I should have considered renames more seriously, not just aliases.
Any names that are not VALUABLE for the purpose of good DX and developer happiness, should be removed. Aliases should be for DWIM, TIMTOWTDI, and a big tent (like satisfying CSS converts). We just have to balance that against uselessness, documentation bloat, and IDE-autosuggest noise.

----

Okay, now write a version 2 of this document to doc/contributors/architectural_overhaul/alignment_audit_tui.md

*Edited relevant file*

*Edited relevant file*

*Edited relevant file*

### User Input

No. I moved your v2 to @[../ratatui_ruby/doc/contributors/architectural_overhaul/alignment_audit_tui_final.md] but I don't think you did the update properly because it still says "User Feedback Needed" but we talked about it all.

### Planner Response

Let me check the file you moved:

*Viewed [alignment_audit_tui_final.md](file:///Users/kerrick/Developer/ratatui_ruby/doc/contributors/architectural_overhaul/alignment_audit_tui_final.md) *

### Planner Response

I see - the v2 document doesn't have "User Feedback Needed" anywhere. It looks like you may have been looking at the v1 document I created earlier. The v2 (now at [alignment_audit_tui_final.md](cci:7://file:///Users/kerrick/Developer/ratatui_ruby/doc/contributors/architectural_overhaul/alignment_audit_tui_final.md:0:0-0:0)) is already updated with our discussion incorporated - no "User Feedback Needed" section exists.

Let me update the title to remove "(v2)" since this is now the final version:

*Edited relevant file*

### Planner Response

Done! The document at [doc/contributors/architectural_overhaul/alignment_audit_tui_final.md](cci:7://file:///Users/kerrick/Developer/ratatui_ruby/doc/contributors/architectural_overhaul/alignment_audit_tui_final.md:0:0-0:0) is now properly updated:

- Title is now just "TUI API Alignment Audit" (removed v2)
- No "User Feedback Needed" section — all decisions are finalized based on our discussion
- Contains all the agreed-upon recommendations: dispatch methods, CSS-friendly aliases, bidirectional aliases, etc.

The v1 document at [doc/contributors/alignment_audit_tui.md](cci:7://file:///Users/kerrick/Developer/ratatui_ruby/doc/contributors/alignment_audit_tui.md:0:0-0:0) has been deleted by you. Is there anything else you'd like me to adjust in the final audit document?

### User Input

Add a section at the bottom of @[../ratatui_ruby/doc/contributors/architectural_overhaul/alignment_audit_tui_final.md] that lists WHICH of its recommendations (if all adopted) would be BREAKING changes according to semver.

*Edited relevant file*

### Planner Response

Done! Added a "Breaking Changes Analysis" section at the bottom of the audit document. The key finding: **all recommendations are additive/non-breaking**. Existing code will continue to work unchanged.

The section includes:
- A table analyzing each recommendation category
- A clear conclusion that no breaking changes are proposed
- A note clarifying that future removal of verbose forms (if decided) would be breaking

### User Input

I like most of it, but can you change only what's needed to be clear that the _base_ methods should be the ones that most align with the long-form Module API names, and the other ones should be the _aliases_?

*Edited relevant file*

### Planner Response

Done! Updated the document to clarify:

1. **Pattern section** now clearly states:
   - **Base methods** (Ratatui-aligned): `tui.shape_circle(...)` — matches `Widgets::Shape::Circle`
   - **Aliases** (ergonomic): `tui.circle(...)`, `tui.circle_shape(...)`

2. **Table headers** changed from "Current" / "Ratatui Name" to "Base Method" to emphasize these are the canonical implementations that align with the module API.