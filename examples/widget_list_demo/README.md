<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# List Widget Example

Demonstrates a selectable list with extensive configuration options.

Lists are the workhorse of terminal interfaces. Managing selection state, scrolling windows, and highlight styles logic is complex. The `List` widget handles all of this.

## Features Demonstrated

- **Scrolling**: Automatically handles lists larger than the view area.
- **Selection**: Maintains selected index and supports "no selection" state.
- **Highlighting**: Custom styles and symbols (e.g., `>>`) for the selected item.
- **Offset Modes**: Manual control over the scroll offset vs automatic "scroll to selection" behavior.
- **Scroll Padding**: Keeping a margin of items visible above/below the selection.

## Hotkeys

- **i**: Cycle Item Data (`items`)
- **Arrow Keys (↑/↓)**: Navigate (`selected_index`)
- **x**: Toggle Selection (`selected_index`)
- **h**: Cycle Highlight Style (`highlight_style`)
- **y**: Cycle Highlight Symbol (`highlight_symbol`)
- **d**: Toggle Direction (`direction`)
- **s**: Cycle Highlight Spacing (`highlight_spacing`)
- **p**: Cycle Scroll Padding (`scroll_padding`)
- **b**: Cycle Base Style (`style`)
- **r**: Toggle Repeat Highlight Symbol (`repeat_highlight_symbol`)
- **o**: Cycle Offset Mode (`offset`)
- **q**: Quit

## Usage

```bash
ruby examples/widget_list_demo/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Create a file explorer.
- Build a navigation menu.
- Display a log where users can scroll back to read history.
- Implement "infinite select" behaviors.

![Demo](/doc/images/widget_list_demo.png)
