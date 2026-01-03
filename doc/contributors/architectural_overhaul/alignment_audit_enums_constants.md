<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# TODO

Audit enum and constant alignment between Ratatui/Crossterm and RatatuiRuby.

## Scope

- `BorderType` variants (Plain, Rounded, Double, Thick, QuadrantInside, etc.)
- `Borders` bitflags (TOP, BOTTOM, LEFT, RIGHT, ALL, NONE)
- `Alignment` (Left, Center, Right)
- `Flex` variants (Start, Center, End, SpaceBetween, SpaceAround, Legacy)
- `GraphType` (Scatter, Line)
- `LegendPosition` (TopLeft, TopRight, BottomLeft, BottomRight, etc.)
- `ListDirection` (TopToBottom, BottomToTop)
- `HighlightSpacing` (Always, WhenSelected, Never)

## Questions to Answer

1. Are all enum variants exposed and correctly mapped to Ruby symbols?
2. Are naming conventions consistent (snake_case for Ruby)?
3. Any missing variants that users might need?
