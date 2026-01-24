// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Private terminal storage with safe accessor functions.
//!
//! This module provides thread-local storage for the terminal and draw snapshot,
//! with functions that route queries correctly:
//! - During draw: queries go to snapshot (no lock needed)
//! - Outside draw: queries go to live terminal

use super::query::{DrawSnapshot, LiveTerminal, TerminalQuery};
use super::wrapper::TerminalWrapper;
use std::cell::RefCell;

thread_local! {
    static TERMINAL: RefCell<Option<TerminalWrapper>> = const { RefCell::new(None) };
    static DRAW_SNAPSHOT: RefCell<Option<DrawSnapshot>> = const { RefCell::new(None) };
}

/// Check if we're currently inside a draw operation.
pub fn is_in_draw_mode() -> bool {
    DRAW_SNAPSHOT.with(|cell| cell.borrow().is_some())
}

/// Execute a query. Routes to snapshot during draw, live terminal outside.
pub fn with_query<R, F>(f: F) -> Option<R>
where
    F: Fn(&dyn TerminalQuery) -> R,
{
    // During draw: use snapshot
    DRAW_SNAPSHOT
        .with(|cell| cell.borrow().as_ref().map(|snapshot| f(snapshot)))
        .or_else(|| {
            // Outside draw: use live terminal from thread-local storage
            TERMINAL.with(|cell| {
                cell.borrow_mut().as_mut().map(|t| {
                    let live = LiveTerminal::new(t);
                    f(&live)
                })
            })
        })
}

/// Mutable access to terminal. Only works OUTSIDE draw.
pub fn with_terminal_mut<R, F>(f: F) -> Option<R>
where
    F: FnOnce(&mut TerminalWrapper) -> R,
{
    // During draw: reject
    if is_in_draw_mode() {
        return None;
    }
    TERMINAL.with(|cell| cell.borrow_mut().as_mut().map(f))
}

/// Execute draw with snapshot for queries.
pub fn lend_for_draw<R, F>(f: F) -> Option<R>
where
    F: FnOnce(&mut TerminalWrapper) -> R,
{
    // Take terminal out of storage
    let mut terminal = TERMINAL.with(|cell| cell.borrow_mut().take())?;

    // Capture snapshot BEFORE draw (while we have &mut)
    let snapshot = DrawSnapshot::capture(&mut terminal);
    DRAW_SNAPSHOT.with(|cell| *cell.borrow_mut() = Some(snapshot));

    let result = f(&mut terminal);

    // Clear snapshot, restore terminal
    DRAW_SNAPSHOT.with(|cell| *cell.borrow_mut() = None);
    TERMINAL.with(|cell| *cell.borrow_mut() = Some(terminal));

    Some(result)
}

/// Set the terminal (used during initialization).
pub fn set_terminal(wrapper: TerminalWrapper) {
    TERMINAL.with(|cell| {
        *cell.borrow_mut() = Some(wrapper);
    });
}

/// Take the terminal out of storage (used during cleanup).
pub fn take_terminal() -> Option<TerminalWrapper> {
    TERMINAL.with(|cell| cell.borrow_mut().take())
}

/// Check if terminal is initialized.
pub fn is_initialized() -> bool {
    TERMINAL.with(|cell| cell.borrow().is_some())
}

#[cfg(test)]
mod tests {
    use crate::terminal::query::DrawSnapshot;
    use ratatui::layout::Rect;

    #[test]
    fn test_is_in_draw_mode_false_by_default() {
        assert!(!super::is_in_draw_mode());
    }

    #[test]
    fn test_with_query_returns_none_when_not_initialized() {
        let result = super::with_query(|q| q.size());
        assert!(result.is_none());
    }
}
