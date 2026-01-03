<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Chart Widget Example

Demonstrates Cartesian plotting with interactive styling and configuration.

Trends and patterns are invisible in raw logs. Charts visualize X/Y datasets to reveal the story behind the data.

## Features Demonstrated

- **Dataset Types**: Line charts and Scatter plots.
- **Markers**: Braille patterns, dots, blocks, and bars.
- **Axis Configuration**: Controlling labels, bounds, and alignment (Left/Center/Right).
- **Legend**: Positioning the legend in any of the four corners or hiding it based on constraints.

## Hotkeys

- **m**: Cycle Marker Type (`marker`)
- **s**: Cycle Dataset Style (`style`)
- **x**: Cycle X-Axis Alignment (`labels_alignment`)
- **y**: Cycle Y-Axis Alignment (`labels_alignment`)
- **l**: Cycle Legend Position (`legend_position`)
- **q**: Quit

## Usage

```bash
ruby examples/widget_chart_demo/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Plot real-time data monitoring (CPU history, request latency).
- Visualize mathematical functions.
- Compare multiple datasets on the same axis.

![Demo](/doc/images/widget_chart_demo.png)
