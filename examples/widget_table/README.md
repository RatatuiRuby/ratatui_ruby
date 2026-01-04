<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Table (Row, Cell) Example

[![widget_table](../../doc/images/widget_table.png)](app.rb)

Demonstrates advanced options for the `Table` widget, including selection, row-level highlighting, and column-level highlighting.

Data grids are complex. Users expect to navigate them with keys, select rows, and clearly see which cell is active. The `Table` widget provides these features out of the box efficiently.

## Features Demonstrated

- **Selection State**: Managing `selected_row` and `selected_column` to track user focus.
- **Complex Highlighting**:
    - **Row**: Highlight the entire active row.
    - **Highlight Symbol:** Adding a visual indicator (like `> `) to the selected row.
- **Spacing:** Adjusting `column_spacing` and `highlight_spacing` to control layout density.
- **Flex Layout:** Switching between different column distribution modes (`legacy`, `start`, `space_between`, etc.).
- **Offset Control:** Manually controlling the scroll position using `offset`.

## Hotkeys

- **Arrows (↑/↓)**: Navigate Rows (`selected_row`)
- **Arrows (←/→)**: Navigate Columns (`selected_column`)
- **x**: Toggle Row Selection (`selected_row` = nil)
- **s**: Cycle Table Style (`style`)
- **p**: Cycle Spacing (`highlight_spacing`)
- **c**: Toggle Column Highlight (`column_highlight_style`)
- **z**: Toggle Cell Highlight (`cell_highlight_style`)
- **o**: Cycle Offset Mode (`offset`)
- **f**: Cycle Flex Mode (`flex`)
- **q**: Quit

## Usage

```bash
ruby examples/widget_table/app.rb
```

## Learning Outcomes

Use this example if you need to...

- Build a file explorer or process list.
- Create a data-heavy dashboard.
- Handle conflicting style requirements (e.g., "Highlight this row, but make this error cell red").

[Read the source code →](app.rb)
