<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Cell Widget Example

[![widget_cell](../../doc/images/widget_cell.png)](app.rb)

Demonstrates using `Cell` objects for granular control over individual character grid units.

Sometimes you need to render specific characters with unique styles outside of standard widgets. The `Cell` primitive allows you to build custom widgets or inject styled content into Tables.

## Features Demonstrated

- **Custom Widgets**: A `CheckeredBackground` widget built by rendering `Cell`s in a loop.
- **Table Integration**: Mixing simple Strings and rich `Cell` objects in a Table row.
- **Overlays**: Using `RatatuiRuby::Overlay` to stack widgets on top of each other.
- **Modifiers**: Using `rapid_blink`, `bold`, and `dim` on individual cells.

## Hotkeys

- **q** / **Ctrl+c**: Quit

## Usage

```bash
ruby examples/widget_cell/app.rb
```

## Learning Outcomes

Use this example if you need to...

- Create a custom widget (like a game board or specialized graph).
- Style specific cells in a Table (e.g., Green "OK", Red "FAIL").
- Understand how to position content precisely with `Cell`.

[Read the source code →](app.rb)
