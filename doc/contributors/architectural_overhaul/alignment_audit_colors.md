<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# TODO

Audit color alignment between Ratatui/Crossterm and RatatuiRuby.

## Scope

- Named colors (Black, Red, Green, Yellow, Blue, Magenta, Cyan, White, Gray, etc.)
- Light/Dark variants (DarkGray, LightRed, LightGreen, etc.)
- RGB support (`Color::Rgb(r, g, b)`)
- Indexed colors (`Color::Indexed(u8)`)
- Reset color

## Questions to Answer

1. Are all named colors from Crossterm available as Ruby symbols?
2. Is RGB color specification fully supported (hex strings, integer tuples)?
3. Is 256-color indexed palette accessible?
4. Any platform-specific color considerations?
