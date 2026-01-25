<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Feature Request: Expose Paragraph Span Rects

## Summary

`Paragraph` computes the bounding rect for each span during word-wrapping and rendering, but does not expose this information. Interactive applications need these rects for:

- Mouse click hit-testing on clickable text (links, buttons)
- Accessibility tooling that needs semantic element positions
- Tooltip positioning relative to specific text spans

## The Problem

Building clickable text within paragraphs requires knowing where each span renders after word wrapping. When a user clicks within a paragraph, the application cannot determine which specific span was clicked without duplicating the internal word-wrapping algorithm.

Currently, the only options are:

1. **Recompute the layout manually.** Duplicate the logic from `WordWrapper` and `LineTruncator`, accounting for word boundaries, trimming, and alignment. This is extremely fragile—the wrapping algorithm is complex and any upstream change breaks the user's code.

2. **Use character counting.** Calculate `chars_before / width` for y-offset and `chars_before % width` for x-offset. This breaks with:
   - Non-monospace Unicode (CJK, emoji)
   - Word-level wrapping (spans don't split at character boundaries)
   - Alignment (center/right shifts all positions)
   - Trimmed leading whitespace

Neither approach is satisfactory.

## Use Case

Consider a TUI welcome screen with a clickable link:

```
┌Hello, Rooibos!───────────────────────────────────────┐
│                                                       │
│ Welcome to Rooibos! You will find the Ruby code for  │
│ this application in lib/saturday.rb. The tests that  │
│ verify it are at test/test_saturday.rb. You can run  │
│ the tests with bundle exec rake test. Visit          │
│  www.rooibos.run  to learn about Rooibos and to find │
│ other Rooibos developers. You can press Control + C  │
│ to exit at any time.                                  │
│                                                       │
└───────────────────────────────────────────────────────┘
```

The link ` www.rooibos.run ` appears on row 5 after word-wrapping. The application wants to:

1. Detect clicks on the link span
2. Highlight the link on hover
3. Open the URL when clicked

Without span rects, the application must manually compute where the link renders after wrapping:

<!--
SPDX-SnippetBegin
SPDX-FileCopyrightText: 2026 Kerrick Long
SPDX-License-Identifier: MIT-0
-->
```rust
// Manual calculation - fragile and duplicates internal logic
let text_before_link = "Welcome to Rooibos! You will find the Ruby code for \
    this application in lib/saturday.rb. The tests that verify it are at \
    test/test_saturday.rb. You can run the tests with bundle exec rake test. Visit ";
let chars_before = text_before_link.width(); // ~204 characters
let inner_width = block.inner(area).width; // ~74 characters

let y_offset = chars_before / inner_width; // Wrong: doesn't account for word wrapping
let x_offset = chars_before % inner_width; // Wrong: words don't wrap mid-word
```
<!--
SPDX-SnippetEnd
-->

This fails because `WordWrapper`:

- Wraps at word boundaries, not character positions
- May trim leading whitespace on wrapped lines
- Produces lines of varying length

The computed position is always wrong by several cells.

## Current State (v0.30.0)

`Paragraph::render_paragraph` uses `WordWrapper` or `LineTruncator` to compose lines:

<!--
SPDX-SnippetBegin
SPDX-FileCopyrightText: 2016-2022 Florian Dehau
SPDX-FileCopyrightText: 2023-2025 The Ratatui Developers
SPDX-License-Identifier: MIT
-->
```rust
// From src/widgets/paragraph.rs - private rendering logic
fn render_paragraph(&self, text_area: Rect, buf: &mut Buffer) {
    let styled = self.text.iter().map(|line| {
        let graphemes = line.styled_graphemes(self.text.style);
        let alignment = line.alignment.unwrap_or(self.alignment);
        (graphemes, alignment)
    });

    if let Some(Wrap { trim }) = self.wrap {
        let mut line_composer = WordWrapper::new(styled, text_area.width, trim);
        render_lines(line_composer, text_area, buf);
    } else {
        // ...LineTruncator path...
    }
}

fn render_line(wrapped: &WrappedLine<'_, '_>, area: Rect, buf: &mut Buffer, y: u16) {
    let mut x = get_line_offset(wrapped.width, area.width, wrapped.alignment);
    for StyledGrapheme { symbol, style } in wrapped.graphemes {
        // Position is computed here but not exposed
        let position = Position::new(area.left() + x, area.top() + y);
        buf[position].set_symbol(symbol).set_style(*style);
        x += u16::try_from(width).unwrap_or(u16::MAX);
    }
}
```
<!--
SPDX-SnippetEnd
-->

The grapheme positions are computed during rendering but never associated back to the source spans.

## Proposed API

Following the pattern established by `Block::inner(area)` and `Layout::split()`, add a pure computation method that takes an area and returns computed span rects without rendering:

### Option 1: Return all span rects

<!--
SPDX-SnippetBegin
SPDX-FileCopyrightText: 2026 Kerrick Long
SPDX-License-Identifier: MIT-0
-->
```rust
impl Paragraph {
    /// Returns the bounding rect for each span given an area.
    ///
    /// For wrapped paragraphs, a span that wraps across multiple lines
    /// returns a rect covering all lines it occupies.
    ///
    /// # Example
    ///
    /// ```rust
    /// let link_span = Span::styled(" www.rooibos.run ", Style::new().underlined());
    /// let text = Text::from(Line::from(vec![
    ///     Span::raw("Visit "),
    ///     link_span.clone(),
    ///     Span::raw(" for more info."),
    /// ]));
    /// let paragraph = Paragraph::new(text).wrap(Wrap { trim: true });
    ///
    /// let span_rects = paragraph.span_rects(area);
    /// if span_rects[1].contains(mouse_position) {
    ///     // User clicked the link!
    /// }
    /// ```
    pub fn span_rects(&self, area: Rect) -> Vec<Rect> { ... }
}
```
<!--
SPDX-SnippetEnd
-->

### Option 2: Lookup by span index

<!--
SPDX-SnippetBegin
SPDX-FileCopyrightText: 2026 Kerrick Long
SPDX-License-Identifier: MIT-0
-->
```rust
/// Returns the rect for the span at the given index.
pub fn span_rect(&self, area: Rect, line_index: usize, span_index: usize) -> Option<Rect> { ... }
```
<!--
SPDX-SnippetEnd
-->

### Option 3: Iterator-based (memory efficient)

<!--
SPDX-SnippetBegin
SPDX-FileCopyrightText: 2026 Kerrick Long
SPDX-License-Identifier: MIT-0
-->
```rust
/// Returns an iterator over (line_index, span_index, Rect) tuples.
pub fn span_rects_iter(&self, area: Rect) -> impl Iterator<Item = (usize, usize, Rect)> { ... }
```
<!--
SPDX-SnippetEnd
-->

## Implementation Notes

The implementation would reuse `WordWrapper`/`LineTruncator` in a non-rendering mode:

1. Process the text through the line composer (same as `render_paragraph`)
2. Track grapheme positions as they're composed (same loop as `render_line`)
3. Group grapheme positions by source span
4. Return span bounding rects

Key considerations:

- **Wrapped spans**: A span that wraps to the next line should return a rect covering both lines (bounding box) or multiple rects (one per line fragment)
- **Empty spans**: Zero-width spans should return the position where they would appear
- **Scroll offset**: Rects should be adjusted by the paragraph's scroll offset
- **Block**: The area should be the inner area after block borders/padding

## Workaround

Without this API, users must reimplement word wrapping. This is impractical for production use—the workaround in RatatuiRuby uses simple character math that produces incorrect positions:

<!--
SPDX-SnippetBegin
SPDX-FileCopyrightText: 2026 Kerrick Long
SPDX-License-Identifier: MIT-0
-->
```rust
// This is WRONG but the only option without span_rects
let chars_before = preceding_spans.iter().map(|s| s.width()).sum();
let x = area.x + (chars_before % area.width);
let y = area.y + (chars_before / area.width);
```
<!--
SPDX-SnippetEnd
-->

The correct implementation requires processing the entire text through `WordWrapper`, which is private.

## Impact

This feature benefits any application with clickable or interactive text:

- **Hyperlinks**: Click to open URLs in wrapped text
- **Command help**: Click command names to execute them
- **Error messages**: Click file paths to open editors
- **Documentation viewers**: Interactive code examples
- **Accessibility**: Screen readers need element positions

Rich text interaction is a natural expectation for modern TUI applications. Word-wrapped paragraphs with clickable elements are common in web UIs—TUIs should offer the same capability.

## Related

- `Block::inner(area)` - Same pattern: pure computation of content area
- `Layout::split(area, constraints)` - Same pattern: pure computation of child areas
- `Tabs::title_rects(area)` (proposed in separate issue) - Same pattern for tab hit-testing

---

This issue includes creative contributions from Claude (Anthropic) via Antigravity (Google). [https://declare-ai.org/1.0.0/creative.html](https://declare-ai.org/1.0.0/creative.html)

*Discovered while implementing link click handling for RatatuiRuby's Saturday demo app.*
