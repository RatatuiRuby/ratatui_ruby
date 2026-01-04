<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Scroll Text Example

[![widget_scroll_text](../../doc/images/widget_scroll_text.png)](app.rb)

Demonstrates scrolling long text content within a fixed viewport.

Sometimes text exceeds the available space. The `Paragraph` widget supports a `scroll` parameter to simulate a viewport, allowing users to pan vertically and horizontally.

## Features Demonstrated

- **Vertical Scrolling**: Moving through lines of text.
- **Horizontal Scrolling**: Panning across long, unwrapped lines.
- **State Management**: tracking `scroll_x` and `scroll_y` offsets in the application state.

## Hotkeys

- **Arrows (↑/↓)**: Scroll Vertically (`scroll`)
- **Arrows (←/→)**: Scroll Horizontally (`scroll`)
- **q**: Quit

## Usage

```bash
ruby examples/widget_scroll_text/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Build a log viewer.
- Create a "terms and conditions" scrollbox.
- Display code snippets that might be wider than the terminal.