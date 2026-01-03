<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# v0.7.0 Alignment Audit: Summary

## MISSING (additive, non-breaking)

- Colors
  - Reset (1)
- Enums and Constants
  - LegendPosition (4)
- Symbol Sets
  - Marker::HalfBlock (1)
  - line::Set, bar::Set, block::Set, scrollbar::Set
- Layout
  - Rect methods (~13)
  - Constraint batch constructors (6)
  - Layout margin, spacing (2)
- Style
  - sub_modifier, underline_color (2)
- Text
  - Span methods (4)
  - Line methods (6)

## MISALIGNED (non-additive, breaking)

- Text::Line missing `style:` field
- Widgets::Table uses `highlight_style:` (deprecated → `row_highlight_style:`)
