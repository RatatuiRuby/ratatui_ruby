// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Frame wrapper for exposing Ratatui's Frame to Ruby.
//!
//! This module provides `RubyFrame`, a struct that wraps `ratatui::Frame` and exposes
//! it to Ruby via Magnus. It enables explicit widget placement through `render_widget`,
//! aligning `RatatuiRuby` with native Rust Ratatui patterns.
//!
//! # Safety
//!
//! `RubyFrame` uses raw pointer casting to store a `Frame` reference with an erased
//! lifetime. This is safe because:
//! 1. `RubyFrame` is only created within `Terminal::draw()` callbacks
//! 2. `RubyFrame` is never returned from or stored beyond the callback scope
//! 3. The Ruby block receiving `RubyFrame` completes before the callback returns
//!
//! The `'static` lifetime is a lie, but a safe one within these constraints.

use crate::rendering;
use crate::widgets;
use magnus::{prelude::*, Error, Value};
use ratatui::layout::Rect;
use ratatui::Frame;
use std::cell::UnsafeCell;
use std::ptr::NonNull;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;

/// A wrapper around Ratatui's `Frame` that can be exposed to Ruby.
///
/// This struct uses raw pointers to hold a mutable reference to the frame,
/// which is valid only for the duration of the draw callback.
///
/// # Safety
///
/// We implement `Send` manually because:
/// 1. `RubyFrame` is only created and used within a single `Terminal::draw()` callback
/// 2. The Ruby VM is single-threaded (GVL), so the frame pointer is never accessed
///    from multiple threads simultaneously
/// 3. `RubyFrame` never escapes the draw callback scope
///
/// The `active` flag provides runtime safety by preventing use after the draw
/// callback completes. Without this, a user could store the frame and cause
/// undefined behavior by accessing it after the underlying pointer is invalid.
#[magnus::wrap(class = "RatatuiRuby::Frame")]
pub struct RubyFrame {
    /// Pointer to the underlying frame. Valid only during the draw callback.
    inner: UnsafeCell<NonNull<Frame<'static>>>,
    /// Shared flag to invalidate the frame when the block finishes.
    /// Set to `true` during draw, `false` immediately after yield returns.
    active: Arc<AtomicBool>,
}

// SAFETY: RubyFrame is only used within Terminal::draw() callbacks, which are
// single-threaded. The Ruby VM's GVL ensures no concurrent access.
unsafe impl Send for RubyFrame {}

impl RubyFrame {
    /// Creates a new `RubyFrame` wrapping the given frame reference.
    ///
    /// # Arguments
    ///
    /// * `frame` - Mutable reference to the underlying Ratatui frame
    /// * `active` - Shared atomic flag that controls frame validity
    ///
    /// # Safety
    ///
    /// The caller must ensure that:
    /// 1. The `RubyFrame` does not outlive the frame reference
    /// 2. No other mutable references to the frame exist while `RubyFrame` is in use
    /// 3. The `active` flag is set to `false` after the draw callback completes
    pub fn new(frame: &mut Frame<'_>, active: Arc<AtomicBool>) -> Self {
        // SAFETY: We cast the frame pointer to 'static lifetime. This is safe because:
        // - RubyFrame is only used within Terminal::draw() callbacks
        // - The Ruby block completes before the callback returns
        // - No reference to RubyFrame escapes the callback scope
        let ptr = NonNull::from(frame);
        let static_ptr: NonNull<Frame<'static>> =
            // SAFETY: Lifetime erasure is safe within the draw callback scope.
            // The frame pointer remains valid for the entire callback duration.
            unsafe { std::mem::transmute(ptr) };

        Self {
            inner: UnsafeCell::new(static_ptr),
            active,
        }
    }

    /// Checks that the frame is still valid for use.
    ///
    /// Returns `Ok(())` if the frame can be used, or an error if the draw
    /// callback has already completed.
    fn ensure_active(&self) -> Result<(), Error> {
        if self.active.load(Ordering::Relaxed) {
            Ok(())
        } else {
            let ruby = magnus::Ruby::get().unwrap();
            let module = ruby.define_module("RatatuiRuby")?;
            let error_base = module.const_get::<_, magnus::RClass>("Error")?;
            let error_class = error_base.const_get("Safety")?;
            Err(Error::new(
                error_class,
                "Frame cannot be used outside of the draw block",
            ))
        }
    }

    /// Returns the terminal area as a Ruby `RatatuiRuby::Rect`.
    ///
    /// This mirrors `frame.area()` in Rust Ratatui.
    pub fn area(&self) -> Result<Value, Error> {
        self.ensure_active()?;
        let ruby = magnus::Ruby::get().unwrap();

        // SAFETY: The frame pointer is valid for the duration of the draw callback.
        // We only read from the frame, which is safe with an immutable reference.
        // The ensure_active() check above guarantees we're still in the callback.
        let area = unsafe { (*self.inner.get()).as_ref().area() };

        // Create a Ruby Rect object
        let module = ruby.define_module("RatatuiRuby")?;
        let class = module.const_get::<_, magnus::RClass>("Rect")?;
        class.funcall("new", (area.x, area.y, area.width, area.height))
    }

    /// Renders a widget at the specified area.
    ///
    /// This mirrors `frame.render_widget(widget, area)` in Rust Ratatui.
    ///
    /// # Arguments
    ///
    /// * `widget` - A Ruby widget object (e.g., `RatatuiRuby::Paragraph`)
    /// * `area` - A Ruby `Rect` or hash-like object with `x`, `y`, `width`, `height`
    pub fn render_widget(&self, widget: Value, area: Value) -> Result<(), Error> {
        self.ensure_active()?;

        // Parse the Ruby area into a Rust Rect
        let x: u16 = area.funcall("x", ())?;
        let y: u16 = area.funcall("y", ())?;
        let width: u16 = area.funcall("width", ())?;
        let height: u16 = area.funcall("height", ())?;
        let rect = Rect::new(x, y, width, height);

        // SAFETY: The frame pointer is valid for the duration of the draw callback.
        // We take a mutable reference which is safe because:
        // 1. RubyFrame is only used within Terminal::draw() callbacks
        // 2. Ruby's GVL ensures single-threaded access
        // 3. No other code holds a reference to the frame during this call
        // 4. ensure_active() above guarantees we're still in the callback
        let frame = unsafe { (*self.inner.get()).as_mut() };

        // Delegate to the existing render_node function
        rendering::render_node(frame, rect, widget)
    }

    /// Renders a stateful widget at the specified area.
    ///
    /// This mirrors `frame.render_stateful_widget(widget, area, &mut state)` in Rust Ratatui.
    /// The State object is the single source of truth for selection and offset.
    /// Widget properties (`selected_index`, `selected_row`, `offset`) are ignored.
    ///
    /// # Arguments
    ///
    /// * `widget` - A Ruby widget object (e.g., `RatatuiRuby::List`)
    /// * `area` - A Ruby `Rect`
    /// * `state` - A Ruby state object (e.g., `RatatuiRuby::ListState`)
    pub fn render_stateful_widget(
        &self,
        widget: Value,
        area: Value,
        state: Value,
    ) -> Result<(), Error> {
        self.ensure_active()?;
        let ruby = magnus::Ruby::get().unwrap();

        // Parse the Ruby area into a Rust Rect
        let x: u16 = area.funcall("x", ())?;
        let y: u16 = area.funcall("y", ())?;
        let width: u16 = area.funcall("width", ())?;
        let height: u16 = area.funcall("height", ())?;
        let rect = Rect::new(x, y, width, height);

        // SAFETY: The frame pointer is valid for the duration of the draw callback.
        let frame = unsafe { (*self.inner.get()).as_mut() };

        // SAFETY: Immediate conversion to owned string avoids GC-unsafe borrowed reference.
        let widget_class = unsafe { widget.class().name() }.into_owned();
        // SAFETY: Immediate conversion to owned string avoids GC-unsafe borrowed reference.
        let state_class = unsafe { state.class().name() }.into_owned();

        match (widget_class.as_str(), state_class.as_str()) {
            ("RatatuiRuby::List", "RatatuiRuby::ListState") => {
                widgets::list::render_stateful(frame, rect, widget, state)
            }
            ("RatatuiRuby::Table", "RatatuiRuby::TableState") => {
                widgets::table::render_stateful(frame, rect, widget, state)
            }
            ("RatatuiRuby::Scrollbar", "RatatuiRuby::ScrollbarState") => {
                widgets::scrollbar::render_stateful(frame, rect, widget, state)
            }
            _ => Err(Error::new(
                ruby.exception_arg_error(),
                format!("Unsupported widget/state combination: {widget_class} with {state_class}"),
            )),
        }
    }

    /// Sets the cursor position in the terminal.
    ///
    /// This mirrors `frame.set_cursor_position((x, y))` in Rust Ratatui.
    /// Use this for text input fields to show the cursor at the correct location.
    ///
    /// # Arguments
    ///
    /// * `x` - Column position (0-indexed from left)
    /// * `y` - Row position (0-indexed from top)
    pub fn set_cursor_position(&self, x: u16, y: u16) -> Result<(), Error> {
        self.ensure_active()?;

        // SAFETY: The frame pointer is valid for the duration of the draw callback.
        // ensure_active() above guarantees we're still in the callback.
        let frame = unsafe { (*self.inner.get()).as_mut() };
        frame.set_cursor_position((x, y));
        Ok(())
    }
}
