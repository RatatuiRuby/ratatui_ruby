// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

//! `ListState` wrapper for exposing Ratatui's `ListState` to Ruby.
//!
//! This module provides `RubyListState`, a Magnus-wrapped struct that holds
//! a `RefCell<ListState>` for interior mutability during stateful rendering.
//!
//! # Design
//!
//! When using `render_stateful_widget`, the State object is the single source
//! of truth for selection and offset. Widget properties (`selected_index`, `offset`)
//! are ignored in stateful mode.
//!
//! # Safety
//!
//! The `RefCell` is borrowed only during the `render_stateful_widget` call.
//! The borrow is released immediately after to avoid double-borrow panics
//! if a user inspects state inside a custom widget's render method.

use magnus::{function, method, prelude::*, Error, Module, Ruby};
use ratatui::widgets::ListState;
use std::cell::RefCell;

/// A wrapper around Ratatui's `ListState` exposed to Ruby.
///
/// This struct uses `RefCell` for interior mutability, allowing the state
/// to be updated during rendering while remaining accessible from Ruby.
#[magnus::wrap(class = "RatatuiRuby::ListState")]
pub struct RubyListState {
    inner: RefCell<ListState>,
}

impl RubyListState {
    /// Creates a new `RubyListState` with optional initial selection.
    ///
    /// # Arguments
    ///
    /// * `selected` - Optional initial selection index
    pub fn new(selected: Option<usize>) -> Self {
        let mut state = ListState::default();
        if let Some(idx) = selected {
            state.select(Some(idx));
        }
        Self {
            inner: RefCell::new(state),
        }
    }

    /// Sets the selected index.
    ///
    /// Pass `nil` to deselect.
    pub fn select(&self, index: Option<usize>) {
        self.inner.borrow_mut().select(index);
    }

    /// Returns the currently selected index, or `nil` if nothing is selected.
    pub fn selected(&self) -> Option<usize> {
        self.inner.borrow().selected()
    }

    /// Returns the current scroll offset.
    ///
    /// This is the critical read-back method. After `render_stateful_widget`,
    /// this returns the scroll position calculated by Ratatui to keep the
    /// selection visible.
    pub fn offset(&self) -> usize {
        self.inner.borrow().offset()
    }

    /// Scrolls down by the given number of items.
    pub fn scroll_down_by(&self, amount: u16) {
        self.inner.borrow_mut().scroll_down_by(amount);
    }

    /// Scrolls up by the given number of items.
    pub fn scroll_up_by(&self, amount: u16) {
        self.inner.borrow_mut().scroll_up_by(amount);
    }

    /// Borrows the inner `ListState` mutably for rendering.
    ///
    /// # Safety
    ///
    /// The caller must ensure the borrow is released before returning
    /// control to Ruby to avoid double-borrow panics.
    pub fn borrow_mut(&self) -> std::cell::RefMut<'_, ListState> {
        self.inner.borrow_mut()
    }
}

/// Registers the `ListState` class with Ruby.
pub fn register(ruby: &Ruby, module: magnus::RModule) -> Result<(), Error> {
    let class = module.define_class("ListState", ruby.class_object())?;
    class.define_singleton_method("new", function!(RubyListState::new, 1))?;
    class.define_method("select", method!(RubyListState::select, 1))?;
    class.define_method("selected", method!(RubyListState::selected, 0))?;
    class.define_method("offset", method!(RubyListState::offset, 0))?;
    class.define_method("scroll_down_by", method!(RubyListState::scroll_down_by, 1))?;
    class.define_method("scroll_up_by", method!(RubyListState::scroll_up_by, 1))?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_with_no_selection() {
        let state = RubyListState::new(None);
        assert_eq!(state.selected(), None);
        assert_eq!(state.offset(), 0);
    }

    #[test]
    fn test_new_with_selection() {
        let state = RubyListState::new(Some(5));
        assert_eq!(state.selected(), Some(5));
    }

    #[test]
    fn test_select_and_deselect() {
        let state = RubyListState::new(None);
        state.select(Some(3));
        assert_eq!(state.selected(), Some(3));
        state.select(None);
        assert_eq!(state.selected(), None);
    }

    #[test]
    fn test_scroll_operations() {
        let state = RubyListState::new(None);
        state.scroll_down_by(5);
        // Note: scroll operations affect offset, but the exact behavior
        // depends on the list size which is determined during rendering
    }
}
