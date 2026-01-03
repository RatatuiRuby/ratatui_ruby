<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Sparkline Widget Example

Demonstrates high-density data visualization in a condensed footprint.

Users need context. A single number ("90% CPU") tells you status, but not the trend. Full charts take up too much space. Sparklines condense history into a single line, perfect for headers and dashboards.

## Features Demonstrated

- **High Density**: Showing dozens of data points in a small area.
- **Direction**: Rendering Left-to-Right (standard) or Right-to-Left (like a scrolling ticker).
- **Gaps**: Handling `nil` values with "absent symbols" to indicate missing data.
- **Styling**: Using colors and custom characters to indicate severity or type.

## Hotkeys

- **Up/Down (↑/↓)**: Cycle Data Set (`data`)
- **d**: Cycle Direction (`direction`)
- **c**: Cycle Color (`style`)
- **m**: Cycle Absent Value Marker Symbol (`absent_value_symbol`)
- **s**: Cycle Absent Value Marker Style (`absent_value_style`)
- **b**: Cycle Bar Character Set (`bar_set`)
- **q**: Quit

## Usage

```bash
ruby examples/widget_sparkline_demo/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Add a "CPU Load" graph to your header.
- Visualize stock price trends in a list row.
- Monitor memory usage over the last 60 seconds.

![Demo](/doc/images/widget_sparkline_demo.png)
