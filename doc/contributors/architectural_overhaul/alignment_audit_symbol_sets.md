<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# TODO

Audit symbol sets alignment between Ratatui's `symbols::` module and RatatuiRuby.

## Scope

- `symbols::line::Set` — Characters for drawing lines/borders
- `symbols::bar::Set` — Characters for bar gauges
- `symbols::block::Set` — Block element characters
- `symbols::border::Set` — Border drawing characters
- `symbols::scrollbar::Set` — Scrollbar characters

## Questions to Answer

1. Does RatatuiRuby expose symbol set customization?
2. Are all predefined sets available (NORMAL, DOUBLE, THICK, ROUNDED, etc.)?
3. Can users define custom symbol sets?
