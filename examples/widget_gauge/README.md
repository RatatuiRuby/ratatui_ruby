<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Gauge Widget Example

[![widget_gauge](../../doc/images/widget_gauge.png)](app.rb)

Demonstrates progress bars with interactive configuration.

Long-running tasks create anxiety. Users need to know the system is working. Gauges provide visual feedback on completion status.

## Features Demonstrated

- **Progress styles**: standard block characters or Unicode bars.
- **Labels**: Customizing the text overlay (Percentage, Ratio, etc.).
- **Styling**: Independent control of the filled gauge color and the background track.
- **Thresholds**: Implementing multi-colored gauges based on values.

## Hotkeys

- **Arrows (←/→)**: Adjust Ratio (`ratio`)
- **g**: Cycle Gauge Color (`gauge_style`)
- **b**: Cycle Background Style (`style`)
- **u**: Toggle Unicode Mode (`use_unicode`)
- **l**: Cycle Label Mode (`label`)
- **q**: Quit

## Usage

```bash
ruby examples/widget_gauge/app.rb
```

## Learning Outcomes

Use this example if you need to...

- Show download or upload progress.
- Visualize resource quotas (disk space, memory usage).
- Create "health bars" or status indicators.

[Read the source code →](app.rb)
