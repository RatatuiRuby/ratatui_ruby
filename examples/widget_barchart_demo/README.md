<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# BarChart Widget Example

Visualizes categorical data with interactive attribute cycling.

Comparing magnitudes in raw tables requires mental arithmetic. Bar charts make these comparisons instant and intuitive.

## Features Demonstrated

- **Data Formats**: Supports simple Hashes, Arrays with individual styles, and Groups (stacked/grouped bars).
- **Orientation**: Switch between Vertical and Horizontal layouts.
- **Customization**:
    - Adjustable bar widths and gaps.
    - Custom characters for bars (ASCII art support).
    - Detailed styling for labels and values.
- **Mini Mode**: Compact rendering for dashboard widgets.

## Hotkeys

- **d**: Cycle Data Source (`data`)
- **v**: Toggle Direction (`direction`)
- **w**: Adjust Bar Width (`bar_width`)
- **a**: Adjust Bar Gap (`bar_gap`)
- **g**: Adjust Group Gap (`group_gap`)
- **b**: Cycle Bar Character Set (`bar_set`)
- **s**: Cycle Chart Style (`style`)
- **x**: Cycle Label Style (`label_style`)
- **z**: Cycle Value Style (`value_style`)
- **m**: Toggle Mini Mode (Compact View)
- **q**: Quit

## Usage

```bash
ruby examples/widget_barchart_demo/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Visualize categorical data (e.g., sales by quarter, CPU usage by core).
- Create "stats" dashboards with compact visualizations.
- Understand how `RatatuiRuby::BarChart` handles different data structures.

![Demo](/doc/images/widget_barchart_demo.png)
