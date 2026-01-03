<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Canvas Widget Example

Demonstrates drawing custom graphics and maps using the standard Braille and Block patterns.

Standard widgets are great for text, but sometimes you need to draw. The `Canvas` widget gives you a high-resolution coordinate system (x, y) to render shapes, lines, and data visualizations that go beyond the grid.

## Features Demonstrated

- **High-Resolution Drawing**: Using Braille patterns (`⣿`) to effectively double the vertical and horizontal resolution of the terminal.
- **Layers**: Drawing multiple shapes (Map, Circles, Lines) in a specific order.
- **Animation**: Updating coordinates in a loop to create smooth motion.
- **World Map**: Using the built-in `Map` shape for geographic data.

## Hotkeys

- **b**: Cycle Background Color (`background_color`)
- **m**: Cycle Marker Type (`marker`)
- **l**: Toggle Labels (modifies `shapes`)
- **q**: Quit

## Usage

```bash
ruby examples/widget_map_demo/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Render geographic data (World, USA, Europe).
- Overlay custom labels and markers on a map.
- Animate visual elements on top of a static background.

![Demo](/doc/images/widget_map_demo.png)
