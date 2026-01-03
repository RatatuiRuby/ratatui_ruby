<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Line Gauge Widget Example

Demonstrates compact progress bars for constrained spaces.

Standard block gauges take up vertical space. Sometimes you only have one line to show status. The `LineGauge` provides a compact, high-density progress indicator.

## Features Demonstrated

- **Compact Rendering**: Visualizing progress in a single character height.
- **Custom Symbols**: Replacing the standard line with Blocks, Shades, Dashes, or ASCII characters.
- **Styling**: Independent styling for the filled (progress) and unfilled (track) portions.

## Hotkeys

- **Arrows (←/→)**: Adjust Ratio (`ratio`)
- **f**: Cycle Filled Symbol (`filled_symbol`)
- **u**: Cycle Unfilled Symbol (`unfilled_symbol`)
- **c**: Cycle Filled Color (`filled_style`)
- **x**: Cycle Unfilled Color (`unfilled_style`)
- **b**: Cycle Base Style (`style`)
- **q**: Cycle Quit

## Usage

```bash
ruby examples/widget_line_gauge_demo/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Add a progress bar to a list item or table row.
- Create a status line at the bottom of the screen.
- Show multiple metrics (CPU, RAM, Net) in a compact list.

![Demo](/doc/images/widget_line_gauge_demo.png)
