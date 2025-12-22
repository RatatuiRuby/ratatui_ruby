<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->
# Design

## Architecture

RatatuiRuby follows an immediate-mode TUI architecture.

### Frontend (Ruby)

The UI is defined using immutable `Data` objects. Every frame, the entire View Tree is recreated and passed to the Rust backend.

### Backend (Rust)

The backend is a single generic renderer implemented in Rust using `ratatui` and `magnus`. It recursively traverses the Ruby Data tree, extracts information using `funcall`, and renders to the terminal buffer.

### Bridge

The bridge uses `magnus` to provide high-performance bindings between Ruby and Rust.

## Rendering Logic

The Rust renderer matches on the class name of the Ruby objects (e.g., `RatatuiRuby::Paragraph`) to determine how to render each node.