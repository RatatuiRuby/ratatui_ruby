// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Terminal initialization and restoration functions.

use magnus::value::ReprValue;
use magnus::{Error, Module};
use ratatui::{
    backend::{CrosstermBackend, TestBackend},
    Terminal, TerminalOptions, Viewport,
};
use std::collections::HashMap;
use std::io;
use std::sync::atomic::{AtomicU64, Ordering};

use super::TerminalWrapper;

// Track whether we're using fullscreen viewport (for restore_terminal)
thread_local! {
    static IS_FULLSCREEN: std::cell::Cell<bool> = const { std::cell::Cell::new(false) };
}

// Instance-based terminal tracking (Proposal 1 from terminal.md)
thread_local! {
    static TERMINAL_INSTANCES: std::cell::RefCell<HashMap<u64, TerminalWrapper>> =
        std::cell::RefCell::new(HashMap::new());
}
static NEXT_TERMINAL_ID: AtomicU64 = AtomicU64::new(1);

#[allow(clippy::needless_pass_by_value)] // Magnus FFI requires owned String, not &str
pub fn init_terminal(
    focus_events: bool,
    bracketed_paste: bool,
    viewport_type: String,
    viewport_height: Option<u16>,
) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();

    // Check if already initialized
    if super::is_initialized() {
        return Ok(());
    }

    let module = ruby.define_module("RatatuiRuby")?;
    let error_base = module.const_get::<_, magnus::RClass>("Error")?;
    let error_class = error_base.const_get("Terminal")?;

    // Parse viewport type
    let viewport = match viewport_type.as_ref() {
        "inline" => {
            let height = viewport_height.unwrap_or(8);
            Viewport::Inline(height)
        }
        _ => Viewport::Fullscreen,
    };

    ratatui::crossterm::terminal::enable_raw_mode()
        .map_err(|e| Error::new(error_class, e.to_string()))?;
    let mut stdout = io::stdout();

    // Only enter alternate screen for fullscreen viewports
    if matches!(viewport, Viewport::Fullscreen) {
        ratatui::crossterm::execute!(stdout, ratatui::crossterm::terminal::EnterAlternateScreen)
            .map_err(|e| Error::new(error_class, e.to_string()))?;
    }

    ratatui::crossterm::execute!(stdout, ratatui::crossterm::event::EnableMouseCapture)
        .map_err(|e| Error::new(error_class, e.to_string()))?;

    if focus_events {
        ratatui::crossterm::execute!(stdout, ratatui::crossterm::event::EnableFocusChange)
            .map_err(|e| Error::new(error_class, e.to_string()))?;
    }
    if bracketed_paste {
        ratatui::crossterm::execute!(stdout, ratatui::crossterm::event::EnableBracketedPaste)
            .map_err(|e| Error::new(error_class, e.to_string()))?;
    }

    let backend = CrosstermBackend::new(stdout);

    // Store whether we're using fullscreen for restore_terminal (before moving viewport)
    let is_fullscreen = matches!(viewport, Viewport::Fullscreen);
    IS_FULLSCREEN.with(|f| f.set(is_fullscreen));

    let options = TerminalOptions { viewport };
    let terminal = Terminal::with_options(backend, options)
        .map_err(|e| Error::new(error_class, e.to_string()))?;

    super::set_terminal(TerminalWrapper::Crossterm(terminal));
    Ok(())
}

#[allow(clippy::needless_pass_by_value)] // Magnus FFI requires owned String, not &str
pub fn init_test_terminal(
    width: u16,
    height: u16,
    viewport_type: String,
    viewport_height: Option<u16>,
) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let backend = TestBackend::new(width, height);
    let module = ruby.define_module("RatatuiRuby")?;
    let error_base = module.const_get::<_, magnus::RClass>("Error")?;
    let error_class = error_base.const_get("Terminal")?;

    // Parse viewport type (same as init_terminal)
    let viewport = match viewport_type.as_ref() {
        "inline" => {
            let vp_height = viewport_height.unwrap_or(height);
            Viewport::Inline(vp_height)
        }
        _ => Viewport::Fullscreen,
    };

    let options = TerminalOptions { viewport };
    let terminal = Terminal::with_options(backend, options)
        .map_err(|e| Error::new(error_class, e.to_string()))?;

    super::set_terminal(TerminalWrapper::Test(terminal));
    Ok(())
}

// Instance-based terminal initialization (Proposal 1 from terminal.md)
// Returns terminal ID for Ruby to store
#[allow(clippy::needless_pass_by_value)]
pub fn init_test_terminal_instance(
    width: u16,
    height: u16,
    viewport_type: String,
    viewport_height: Option<u16>,
) -> Result<u64, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let backend = TestBackend::new(width, height);
    let module = ruby.define_module("RatatuiRuby")?;
    let error_base = module.const_get::<_, magnus::RClass>("Error")?;
    let error_class = error_base.const_get("Terminal")?;

    // Parse viewport type
    let viewport = match viewport_type.as_ref() {
        "inline" => {
            let vp_height = viewport_height.unwrap_or(height);
            Viewport::Inline(vp_height)
        }
        _ => Viewport::Fullscreen,
    };

    let options = TerminalOptions { viewport };
    let terminal = Terminal::with_options(backend, options)
        .map_err(|e| Error::new(error_class, e.to_string()))?;

    // Generate unique ID and store instance
    let id = NEXT_TERMINAL_ID.fetch_add(1, Ordering::SeqCst);
    TERMINAL_INSTANCES.with(|instances| {
        instances
            .borrow_mut()
            .insert(id, TerminalWrapper::Test(terminal));
    });

    Ok(id)
}

pub fn restore_terminal() {
    if let Some(wrapper) = super::take_terminal() {
        match wrapper {
            TerminalWrapper::Crossterm(mut t) => {
                let _ = ratatui::crossterm::terminal::disable_raw_mode();

                // Only leave alternate screen if we were in fullscreen mode
                let is_fullscreen = IS_FULLSCREEN.with(std::cell::Cell::get);
                if is_fullscreen {
                    let _ = ratatui::crossterm::execute!(
                        t.backend_mut(),
                        ratatui::crossterm::terminal::LeaveAlternateScreen,
                        ratatui::crossterm::event::DisableMouseCapture,
                        ratatui::crossterm::event::DisableFocusChange,
                        ratatui::crossterm::event::DisableBracketedPaste
                    );
                } else {
                    let _ = ratatui::crossterm::execute!(
                        t.backend_mut(),
                        ratatui::crossterm::event::DisableMouseCapture,
                        ratatui::crossterm::event::DisableFocusChange,
                        ratatui::crossterm::event::DisableBracketedPaste
                    );
                }
            }
            TerminalWrapper::Test(_) => {}
        }
    }
}

/// Get terminal size for a specific instance.
/// Returns `Layout::Rect` object (not hash!)
pub fn get_terminal_size_instance(terminal_id: u64) -> Result<magnus::Value, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    TERMINAL_INSTANCES.with(|instances| {
        let instances = instances.borrow();
        if let Some(wrapper) = instances.get(&terminal_id) {
            let size = match wrapper {
                TerminalWrapper::Crossterm(term) => term.size().map_err(|e| {
                    let module = ruby.define_module("RatatuiRuby").unwrap();
                    let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
                    let error_class = error_base.const_get("Terminal").unwrap();
                    Error::new(error_class, e.to_string())
                })?,
                TerminalWrapper::Test(term) => term.size().unwrap_or_default(),
            };

            // Construct Layout::Rect object in Rust (NOT a hash!)
            let module = ruby.define_module("RatatuiRuby")?;
            let layout_mod = module.const_get::<_, magnus::RModule>("Layout")?;
            let rect_class = layout_mod.const_get::<_, magnus::RClass>("Rect")?;

            // Create hash with keyword args for Rect.new
            let args = ruby.hash_new();
            args.aset(ruby.to_symbol("x"), 0)?;
            args.aset(ruby.to_symbol("y"), 0)?;
            args.aset(ruby.to_symbol("width"), size.width)?;
            args.aset(ruby.to_symbol("height"), size.height)?;

            rect_class.funcall_public("new", (0, 0, size.width, size.height))
        } else {
            let module = ruby.define_module("RatatuiRuby")?;
            let error_base = module.const_get::<_, magnus::RClass>("Error")?;
            let error_class = error_base.const_get("Terminal")?;
            Err(Error::new(
                error_class,
                format!("Terminal instance {terminal_id} not found"),
            ))
        }
    })
}
