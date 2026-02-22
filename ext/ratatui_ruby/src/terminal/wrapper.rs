// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: LGPL-3.0-or-later

//! Terminal wrapper enum for different backend types.

use ratatui::{
    backend::{CrosstermBackend, TestBackend},
    Terminal,
};
use std::io;

/// Unified terminal type supporting different backends.
pub enum TerminalWrapper {
    Crossterm(Terminal<CrosstermBackend<io::Stdout>>),
    Test(Terminal<TestBackend>),
}
