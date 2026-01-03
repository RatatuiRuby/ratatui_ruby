<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Block Padding Example

Demonstrates how to add spacing between a Block's border and its content.

Without padding, text touches the borders, which can look cramped and unprofessional. Padding provides necessary whitespace for readability.

## Features Demonstrated

- **Uniform Padding**: Setting a single integer value applies padding to all sides.
- **Directional Padding**: Setting an array `[left, right, top, bottom]` allows specific control per side.
- **Visual Hierarchy**: Shows how padding affects the internal content area vs the border.

## Hotkeys

- **q** / **Ctrl+c**: Quit

## Usage

```bash
ruby examples/widget_block_padding/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Add "breathing room" to your widgets.
- Control precise spacing for complex layouts.
- Understand the `padding` attribute of `RatatuiRuby::Block`.

![Demo](/doc/images/widget_block_padding.png)
