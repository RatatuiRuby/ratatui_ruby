<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Rich Text Example

Demonstrates styling individual words and characters.

Standard strings are monochromatic. "Rich Text" is composed of `Lines` containing multiple `Spans`, where each Span has its own style. This allows for multi-colored, multi-styled text blocks.

## Features Demonstrated

- **Spans**: Chunks of text with a specific style (e.g., "Bold Red Word").
- **Lines**: ordered collections of Spans that form a single row of text.
- **Paragraphs**: Rendering lines of rich text.

## Hotkeys

- **q**: Quit

## Usage

```bash
ruby examples/widget_rich_text/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Highlight keywords in code (Syntax highlighting).
- Create status lines with icons (e.g., "✔ Success" where the checkmark is green).
- Emphasize specific data points in a paragraph.

![Demo](/doc/images/widget_rich_text.png)
