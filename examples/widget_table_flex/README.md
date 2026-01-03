<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Table Flex Layout Example

Demonstrates flexible column distribution in tables.

Aligning columns in a terminal is hard. The `Table` widget's flex modes allow you to distribute extra space intelligently, similar to CSS Flexbox.

## Features Demonstrated

- **Legacy Mode**: Standard rendering where widths are respected exactly.
- **Space Between**: Distributing extra space between columns.
- **Space Around**: Distributing extra space around all columns.

## Hotkeys

- **q** / **Ctrl+c**: Quit

## Usage

```bash
ruby examples/widget_table_flex/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Build responsive tables that look good at any width.
- Spread columns out to fill a wide screen without manually calculating padding.

![Demo](/doc/images/widget_table_flex.png)
