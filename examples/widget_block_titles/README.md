<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Block Titles Example

Demonstrates advanced title positioning and alignment for Blocks.

Standard blocks often have one title at the top left. This example shows how to place multiple titles anywhere on the border to convey more context.

## Features Demonstrated

- **Multiple Titles**: Attaching more than one title to a single block.
- **Positioning**: Placing titles on the `:top` or `:bottom` border (`position`).
- **Alignment**: Aligning titles to `:left`, `:center`, or `:right` (`alignment`).
- **String vs Object**: Using simple strings for defaults or Hash objects for detailed control.

## Hotkeys

- **q** / **Ctrl+c**: Quit

## Usage

```bash
ruby examples/widget_block_titles/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Create sophisticated frames with status on the bottom and titles on the top.
- Place "action" hints (e.g., "Press <Enterprise>") on the bottom right of a modal.
- Understand the `titles` array configuration in `RatatuiRuby::Block`.

![Demo](/doc/images/widget_block_titles.png)
