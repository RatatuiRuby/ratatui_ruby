<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# List Styles Example

Demonstrates styling specificities for the List widget.

While `widget_list_demo` covers behavioral features like scrolling and offsets, this example focuses purely on visual configurations like highlight spacing and symbols.

## Features Demonstrated

- **Highlight Spacing**: Controlling when the highlight symbol space is reserved.
- **Repeat Symbol**: repeating the highlight symbol on every line vs just the selected line.
- **Direction**: Rendering lists from bottom-to-top (chat style) vs top-to-bottom.

## Hotkeys

- **Arrow Keys (↑/↓)**: Navigate (`selected_index`)
- **x**: Toggle Selection (`selected_index`)
- **d**: Toggle Direction (`direction`)
- **s**: Cycle Spacing Mode (`highlight_spacing`)
- **r**: Toggle Repeat Symbol (`repeat_highlight_symbol`)
- **q**: Quit

## Usage

```bash
ruby examples/widget_list_styles/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Understand how `highlight_spacing` affects layout width.
- Create specific visual styles for menus.

![Demo](/doc/images/widget_list_styles.png)
