<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Popup (Clear) Widget Example

Demonstrates how to render opaque overlays on top of content.

Terminal renders are additive. If you draw a new widget over an old one, the background colors might mix if not handled correctly. The `Clear` widget resets the area to default (usually transparent/black) to ensure a clean canvas for popups.

## Features Demonstrated

- **The `Clear` Widget**: Printing spaces over an area to "erase" what was underneath.
- **Centering**: Using `Layout` constraints to perfectly center a block on screen.
- **Style Bleed**: showing what happens when you *don't* use `Clear` (background colors leak through).

## Hotkeys

- **Space**: Toggle Clear Widget (Observe the red background effect when disabled)
- **q**: Quit

## Usage

```bash
ruby examples/widget_popup_demo/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Create a modal dialog (Confirm, Alert, Form).
- Implement a dropdown menu that overlays other content.
- Fix visual artifacts where old text shows through new widgets.

![Demo](/doc/images/widget_popup_demo.png)
