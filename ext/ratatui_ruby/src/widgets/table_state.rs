// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

//! `TableState` wrapper for exposing Ratatui's `TableState` to Ruby.
//!
//! This module provides `RubyTableState`, a Magnus-wrapped struct that holds
//! a `RefCell<TableState>` for interior mutability during stateful rendering.
//!
//! # Design
//!
//! When using `render_stateful_widget`, the State object is the single source
//! of truth for selection and offset. Widget properties (`selected_row`,
//! `selected_column`, `offset`) are ignored in stateful mode.

use magnus::{function, method, prelude::*, Error, Module, Ruby};
use ratatui::widgets::TableState;
use std::cell::RefCell;

/// A wrapper around Ratatui's `TableState` exposed to Ruby.
#[magnus::wrap(class = "RatatuiRuby::TableState")]
pub struct RubyTableState {
    inner: RefCell<TableState>,
}

impl RubyTableState {
    /// Creates a new `RubyTableState` with optional initial selection.
    pub fn new(selected: Option<usize>) -> Self {
        let mut state = TableState::default();
        if let Some(idx) = selected {
            state.select(Some(idx));
        }
        Self {
            inner: RefCell::new(state),
        }
    }

    /// Sets the selected row index.
    pub fn select(&self, index: Option<usize>) {
        self.inner.borrow_mut().select(index);
    }

    /// Returns the currently selected row index.
    pub fn selected(&self) -> Option<usize> {
        self.inner.borrow().selected()
    }

    /// Sets the selected column index.
    pub fn select_column(&self, index: Option<usize>) {
        self.inner.borrow_mut().select_column(index);
    }

    /// Returns the currently selected column index.
    pub fn selected_column(&self) -> Option<usize> {
        self.inner.borrow().selected_column()
    }

    /// Returns the current scroll offset.
    pub fn offset(&self) -> usize {
        self.inner.borrow().offset()
    }

    /// Scrolls down by the given number of rows.
    pub fn scroll_down_by(&self, amount: u16) {
        self.inner.borrow_mut().scroll_down_by(amount);
    }

    /// Scrolls up by the given number of rows.
    pub fn scroll_up_by(&self, amount: u16) {
        self.inner.borrow_mut().scroll_up_by(amount);
    }

    /// Borrows the inner `TableState` mutably for rendering.
    pub fn borrow_mut(&self) -> std::cell::RefMut<'_, TableState> {
        self.inner.borrow_mut()
    }
}

/// Registers the `TableState` class with Ruby.
pub fn register(ruby: &Ruby, module: magnus::RModule) -> Result<(), Error> {
    let class = module.define_class("TableState", ruby.class_object())?;
    class.define_singleton_method("new", function!(RubyTableState::new, 1))?;
    class.define_method("select", method!(RubyTableState::select, 1))?;
    class.define_method("selected", method!(RubyTableState::selected, 0))?;
    class.define_method("select_column", method!(RubyTableState::select_column, 1))?;
    class.define_method(
        "selected_column",
        method!(RubyTableState::selected_column, 0),
    )?;
    class.define_method("offset", method!(RubyTableState::offset, 0))?;
    class.define_method("scroll_down_by", method!(RubyTableState::scroll_down_by, 1))?;
    class.define_method("scroll_up_by", method!(RubyTableState::scroll_up_by, 1))?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_with_no_selection() {
        let state = RubyTableState::new(None);
        assert_eq!(state.selected(), None);
        assert_eq!(state.selected_column(), None);
        assert_eq!(state.offset(), 0);
    }

    #[test]
    fn test_new_with_selection() {
        let state = RubyTableState::new(Some(3));
        assert_eq!(state.selected(), Some(3));
    }

    #[test]
    fn test_column_selection() {
        let state = RubyTableState::new(None);
        state.select_column(Some(2));
        assert_eq!(state.selected_column(), Some(2));
        state.select_column(None);
        assert_eq!(state.selected_column(), None);
    }
}
