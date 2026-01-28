<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Smoke Test

Verifies gem packaging by exercising multiple viewport modes and common APIs.

Used by `rake verify_gem` to catch broken gem builds.

## Features Demonstrated

- **Inline viewport**: 1-line viewport preserving terminal scrollback
- **Fullscreen viewport**: Block with borders, layout_split, centered mascot
- **Scrollback insertion**: `insert_before` to push content into scrollback
- **Scrollback restoration**: Cursor positioning after inline viewport exit
