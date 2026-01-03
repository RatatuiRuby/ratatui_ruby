<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->
# Block Widget Demo

This example demonstrates the versatile `Block` widget, which provides the visual container, borders, and titles for almost every other widget in `ratatui_ruby`.

## Key Concepts

- **Borders:** Choose which sides to show and apply different border types (plain, rounded, double, thick, etc.).
- **Titles:** Add a main title with alignment or multiple titles at the top and bottom with independent styles and positions.
- **Padding:** Define inner spacing using uniform or directional (L/R/T/B) values.
- **Styling:** Individually style the block's content area, its borders, and its titles.
- **Custom Border Sets:** Create entirely custom border appearances by defining each character in the border set.

## Hotkeys

- `t`: Cycle **Title** (None, Main Title)
- `a`: Cycle **Title Alignment** (Left, Center, Right)
- `s`: Cycle **Title Style** (None, Cyan Bold, Yellow Italic)
- `e`: Cycle **Additional Titles** (None, Top+Bottom, Complex)
- `b`: Cycle **Borders** (All, Top/Bottom, Left/Right, None)
- `y`: Cycle **Border Type** (Rounded, Plain, Double, Thick, Quadrant, Custom)
- `c`: Cycle **Border Style** (Magenta Bold, None, Green, Blue on White)
- `p`: Cycle **Padding** (Uniform, None, Directional, Narrow)
- `f`: Cycle **Base Style** (Dark Gray, None, White on Black)
- `q`: **Quit**

## Usage

```bash
ruby examples/widget_block_demo/app.rb
```
