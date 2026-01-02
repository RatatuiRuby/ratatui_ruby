// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

//! `ScrollbarState` wrapper for exposing Ratatui's `ScrollbarState` to Ruby.
//!
//! This module provides `RubyScrollbarState`, a Magnus-wrapped struct that holds
//! a `RefCell<ScrollbarState>` for interior mutability during stateful rendering.

use magnus::{function, method, prelude::*, Error, Module, Ruby};
use ratatui::widgets::ScrollbarState;
use std::cell::RefCell;

/// A wrapper around Ratatui's `ScrollbarState` exposed to Ruby.
///
/// Ratatui's `ScrollbarState` doesn't expose getters for `position`, `content_length`,
/// or `viewport_content_length`. We track these values internally.
#[magnus::wrap(class = "RatatuiRuby::ScrollbarState")]
pub struct RubyScrollbarState {
    inner: RefCell<ScrollbarState>,
    /// We store these values ourselves since Ratatui's `ScrollbarState`
    /// doesn't expose getters for them.
    position_val: RefCell<usize>,
    content_len: RefCell<usize>,
    viewport_len: RefCell<usize>,
}

impl RubyScrollbarState {
    /// Creates a new `RubyScrollbarState` with the given content length.
    pub fn new(content_length: usize) -> Self {
        Self {
            inner: RefCell::new(ScrollbarState::new(content_length)),
            position_val: RefCell::new(0),
            content_len: RefCell::new(content_length),
            viewport_len: RefCell::new(0),
        }
    }

    /// Returns the current scroll position.
    pub fn position(&self) -> usize {
        *self.position_val.borrow()
    }

    /// Sets the current scroll position.
    pub fn set_position(&self, position: usize) {
        *self.position_val.borrow_mut() = position;
        let mut state = self.inner.borrow_mut();
        *state = state.position(position);
    }

    /// Returns the total content length.
    pub fn content_length(&self) -> usize {
        *self.content_len.borrow()
    }

    /// Sets the total content length.
    pub fn set_content_length(&self, length: usize) {
        *self.content_len.borrow_mut() = length;
        let mut state = self.inner.borrow_mut();
        *state = state.content_length(length);
    }

    /// Returns the viewport content length.
    pub fn viewport_content_length(&self) -> usize {
        *self.viewport_len.borrow()
    }

    /// Sets the viewport content length.
    pub fn set_viewport_content_length(&self, length: usize) {
        *self.viewport_len.borrow_mut() = length;
        let mut state = self.inner.borrow_mut();
        *state = state.viewport_content_length(length);
    }

    /// Scrolls to the first position.
    pub fn first(&self) {
        *self.position_val.borrow_mut() = 0;
        self.inner.borrow_mut().first();
    }

    /// Scrolls to the last position.
    pub fn last(&self) {
        let content_len = *self.content_len.borrow();
        let new_pos = content_len.saturating_sub(1);
        *self.position_val.borrow_mut() = new_pos;
        self.inner.borrow_mut().last();
    }

    /// Scrolls to the next position.
    pub fn next(&self) {
        let content_len = *self.content_len.borrow();
        let current = *self.position_val.borrow();
        let new_pos = (current + 1).min(content_len.saturating_sub(1));
        *self.position_val.borrow_mut() = new_pos;
        self.inner.borrow_mut().next();
    }

    /// Scrolls to the previous position.
    pub fn prev(&self) {
        let current = *self.position_val.borrow();
        let new_pos = current.saturating_sub(1);
        *self.position_val.borrow_mut() = new_pos;
        self.inner.borrow_mut().prev();
    }

    /// Borrows the inner `ScrollbarState` mutably for rendering.
    pub fn borrow_mut(&self) -> std::cell::RefMut<'_, ScrollbarState> {
        self.inner.borrow_mut()
    }
}

/// Registers the `ScrollbarState` class with Ruby.
pub fn register(ruby: &Ruby, module: magnus::RModule) -> Result<(), Error> {
    let class = module.define_class("ScrollbarState", ruby.class_object())?;
    class.define_singleton_method("new", function!(RubyScrollbarState::new, 1))?;
    class.define_method("position", method!(RubyScrollbarState::position, 0))?;
    class.define_method("position=", method!(RubyScrollbarState::set_position, 1))?;
    class.define_method(
        "content_length",
        method!(RubyScrollbarState::content_length, 0),
    )?;
    class.define_method(
        "content_length=",
        method!(RubyScrollbarState::set_content_length, 1),
    )?;
    class.define_method(
        "viewport_content_length",
        method!(RubyScrollbarState::viewport_content_length, 0),
    )?;
    class.define_method(
        "viewport_content_length=",
        method!(RubyScrollbarState::set_viewport_content_length, 1),
    )?;
    class.define_method("first", method!(RubyScrollbarState::first, 0))?;
    class.define_method("last", method!(RubyScrollbarState::last, 0))?;
    class.define_method("next", method!(RubyScrollbarState::next, 0))?;
    class.define_method("prev", method!(RubyScrollbarState::prev, 0))?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_with_content_length() {
        let state = RubyScrollbarState::new(100);
        assert_eq!(state.content_length(), 100);
        assert_eq!(state.position(), 0);
    }

    #[test]
    fn test_position_navigation() {
        let state = RubyScrollbarState::new(10);
        state.next();
        assert_eq!(state.position(), 1);
        state.prev();
        assert_eq!(state.position(), 0);
    }

    #[test]
    fn test_first_and_last() {
        let state = RubyScrollbarState::new(10);
        state.set_position(5);
        state.first();
        assert_eq!(state.position(), 0);
        state.last();
        assert_eq!(state.position(), 9);
    }
}
