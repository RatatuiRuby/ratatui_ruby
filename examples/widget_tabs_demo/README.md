<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Tabs Widget Example

Demonstrates view segregation with interactive navigation.

Screen real estate is limited. You cannot show everything at once. Tabs segregate content into specialized views (modes), allowing users to switch contexts easily.

## Features Demonstrated

- **Condition Rendering**: Changing the *content* of the screen based on the selected tab (Revenue vs Traffic vs Errors).
- **Styling**: Configurable highlight styles, dividers, and padding.
- **Interaction**: Keyboard navigation to cycle through tabs.

## Hotkeys

- **Left/Right (←/→)**: Select Tab (`selected_index`)
- **d**: Cycle Divider Character (`divider`)
- **s**: Cycle Highlight Style (`highlight_style`)
- **b**: Cycle Base Style (`style`)
- **h/l**: Adjust Left Padding (`padding_left`)
- **j/k**: Adjust Right Padding (`padding_right`)
- **q**: Quit

## Usage

```bash
ruby examples/widget_tabs_demo/app.rb
```

## Learning Outcomes

Use this example if you need to...
- Build a multi-pane dashboard.
- Create a "Settings" screen with different categories.
- Implement a "wizard" interface with steps.

![Demo](/doc/images/widget_tabs_demo.png)
