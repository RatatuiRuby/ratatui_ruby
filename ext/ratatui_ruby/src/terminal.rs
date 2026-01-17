// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::value::ReprValue;
use magnus::{Error, Module, Ruby};
use ratatui::{
    backend::{CrosstermBackend, TestBackend},
    Terminal, TerminalOptions, Viewport,
};
use std::collections::HashMap;
use std::io;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Mutex;

use lazy_static::lazy_static;

pub enum TerminalWrapper {
    Crossterm(Terminal<CrosstermBackend<io::Stdout>>),
    Test(Terminal<TestBackend>),
}

// Legacy global singleton (for backward compat with module-level methods)
pub static TERMINAL: Mutex<Option<TerminalWrapper>> = Mutex::new(None);
// Track whether we're using fullscreen viewport (for restore_terminal)
static IS_FULLSCREEN: Mutex<bool> = Mutex::new(false);

// Instance-based terminal tracking (Proposal 1 from terminal.md)
lazy_static! {
    static ref TERMINAL_INSTANCES: Mutex<HashMap<u64, TerminalWrapper>> =
        Mutex::new(HashMap::new());
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
    let mut term_lock = TERMINAL.lock().unwrap();
    if term_lock.is_none() {
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
            ratatui::crossterm::execute!(
                stdout,
                ratatui::crossterm::terminal::EnterAlternateScreen
            )
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
        *IS_FULLSCREEN.lock().unwrap() = is_fullscreen;

        let options = TerminalOptions { viewport };
        let terminal = Terminal::with_options(backend, options)
            .map_err(|e| Error::new(error_class, e.to_string()))?;

        *term_lock = Some(TerminalWrapper::Crossterm(terminal));
    }
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
    let mut term_lock = TERMINAL.lock().unwrap();
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

    *term_lock = Some(TerminalWrapper::Test(terminal));
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
    let mut instances = TERMINAL_INSTANCES.lock().unwrap();
    instances.insert(id, TerminalWrapper::Test(terminal));

    Ok(id)
}

pub fn restore_terminal() {
    let mut term_lock = TERMINAL.lock().unwrap();
    if let Some(wrapper) = term_lock.take() {
        match wrapper {
            TerminalWrapper::Crossterm(mut t) => {
                let _ = ratatui::crossterm::terminal::disable_raw_mode();

                // Only leave alternate screen if we were in fullscreen mode
                let is_fullscreen = *IS_FULLSCREEN.lock().unwrap();
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

pub fn get_buffer_content() -> Result<String, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let term_lock = TERMINAL.lock().unwrap();
    if let Some(TerminalWrapper::Test(terminal)) = term_lock.as_ref() {
        let buffer = terminal.backend().buffer();
        let area = buffer.area;
        let mut result = String::new();
        for y in 0..area.height {
            for x in 0..area.width {
                let cell = buffer.cell((x, y)).unwrap();
                result.push_str(cell.symbol());
            }
            result.push('\n');
        }
        Ok(result)
    } else {
        let module = ruby.define_module("RatatuiRuby")?;
        let error_base = module.const_get::<_, magnus::RClass>("Error")?;
        let error_class = error_base.const_get("Terminal")?;
        Err(Error::new(
            error_class,
            "Terminal is not initialized as TestBackend",
        ))
    }
}

pub fn insert_before(height: u16, widget: magnus::Value) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let mut term_lock = TERMINAL.lock().unwrap();

    if let Some(wrapper) = term_lock.as_mut() {
        let module = ruby.define_module("RatatuiRuby")?;
        let error_base = module.const_get::<_, magnus::RClass>("Error")?;
        let error_class = error_base.const_get("Terminal")?;

        match wrapper {
            TerminalWrapper::Crossterm(term) => {
                // Capture rendering error since closure can't return Result
                let mut render_error: Option<String> = None;

                let result = term.insert_before(height, |buf| {
                    let area = buf.area();
                    let area_copy = *area; // Copy rect before closure capture

                    // Render widget to buffer using centralized dispatch
                    let render_result =
                        crate::rendering::render_widget_to_buffer(buf, area_copy, widget);

                    if let Err(e) = render_result {
                        render_error = Some(e.to_string());
                    }
                });

                // Handle insert_before error
                result.map_err(|e| Error::new(error_class, e.to_string()))?;

                // Handle rendering error
                if let Some(err_msg) = render_error {
                    return Err(Error::new(error_class, err_msg));
                }
            }
            TerminalWrapper::Test(term) => {
                // Capture rendering error since closure can't return Result
                let mut render_error: Option<String> = None;

                let result = term.insert_before(height, |buf| {
                    let area = buf.area();
                    let area_copy = *area; // Copy rect before closure capture

                    // Render widget to buffer using centralized dispatch
                    let render_result =
                        crate::rendering::render_widget_to_buffer(buf, area_copy, widget);

                    if let Err(e) = render_result {
                        render_error = Some(e.to_string());
                    }
                });

                // Handle insert_before error
                result.map_err(|e| Error::new(error_class, e.to_string()))?;

                // Handle rendering error
                if let Some(err_msg) = render_error {
                    return Err(Error::new(error_class, err_msg));
                }
            }
        }
        Ok(())
    } else {
        let module = ruby.define_module("RatatuiRuby")?;
        let error_base = module.const_get::<_, magnus::RClass>("Error")?;
        let error_class = error_base.const_get("Terminal")?;
        Err(Error::new(error_class, "Terminal not initialized"))
    }
}

pub fn get_terminal_area() -> Result<magnus::RHash, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let mut term_lock = TERMINAL.lock().unwrap();

    if let Some(wrapper) = term_lock.as_mut() {
        // Get viewport area directly from the terminal
        let area = match wrapper {
            TerminalWrapper::Crossterm(term) => term.get_frame().area(),
            TerminalWrapper::Test(term) => term.get_frame().area(),
        };

        let hash = ruby.hash_new();
        hash.aset("x", area.x)?;
        hash.aset("y", area.y)?;
        hash.aset("width", area.width)?;
        hash.aset("height", area.height)?;
        Ok(hash)
    } else {
        let module = ruby.define_module("RatatuiRuby")?;
        let error_base = module.const_get::<_, magnus::RClass>("Error")?;
        let error_class = error_base.const_get("Terminal")?;
        Err(Error::new(error_class, "Terminal is not initialized"))
    }
}

/// Returns the full terminal backend size (not the viewport)
pub fn get_terminal_size() -> Result<magnus::RHash, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let term_lock = TERMINAL.lock().unwrap();

    if let Some(wrapper) = term_lock.as_ref() {
        let size = match wrapper {
            TerminalWrapper::Crossterm(term) => term.size().map_err(|e| {
                let module = ruby.define_module("RatatuiRuby").unwrap();
                let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
                let error_class = error_base.const_get("Terminal").unwrap();
                Error::new(error_class, e.to_string())
            })?,
            TerminalWrapper::Test(term) => term.size().unwrap_or_default(),
        };

        let hash = ruby.hash_new();
        hash.aset("x", 0)?;
        hash.aset("y", 0)?;
        hash.aset("width", size.width)?;
        hash.aset("height", size.height)?;
        Ok(hash)
    } else {
        let module = ruby.define_module("RatatuiRuby")?;
        let error_base = module.const_get::<_, magnus::RClass>("Error")?;
        let error_class = error_base.const_get("Terminal")?;
        Err(Error::new(error_class, "Terminal is not initialized"))
    }
}

// Instance-based terminal size query (Returns Layout::Rect object, not hash!)
pub fn get_terminal_size_instance(terminal_id: u64) -> Result<magnus::Value, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let instances = TERMINAL_INSTANCES.lock().unwrap();

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
}

pub fn get_viewport_type() -> Result<String, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let mut term_lock = TERMINAL.lock().unwrap();

    if let Some(wrapper) = term_lock.as_mut() {
        // Get viewport area directly from the terminal
        let vp_area = match wrapper {
            TerminalWrapper::Crossterm(term) => term.get_frame().area(),
            TerminalWrapper::Test(term) => term.get_frame().area(),
        };
        let backend_size = match wrapper {
            TerminalWrapper::Crossterm(term) => term.size().unwrap_or_default(),
            TerminalWrapper::Test(term) => term.size().unwrap_or_default(),
        };

        if vp_area.height < backend_size.height {
            Ok("inline".to_string())
        } else {
            Ok("fullscreen".to_string())
        }
    } else {
        let module = ruby.define_module("RatatuiRuby")?;
        let error_base = module.const_get::<_, magnus::RClass>("Error")?;
        let error_class = error_base.const_get("Terminal")?;
        Err(Error::new(error_class, "Terminal not initialized"))
    }
}

pub fn get_cursor_position() -> Result<Option<(u16, u16)>, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let mut term_lock = TERMINAL.lock().unwrap();
    if let Some(TerminalWrapper::Test(terminal)) = term_lock.as_mut() {
        let module = ruby.define_module("RatatuiRuby")?;
        let error_base = module.const_get::<_, magnus::RClass>("Error")?;
        let error_class = error_base.const_get("Terminal")?;
        let pos = terminal
            .get_cursor_position()
            .map_err(|e| Error::new(error_class, e.to_string()))?;
        Ok(Some(pos.into()))
    } else {
        let module = ruby.define_module("RatatuiRuby")?;
        let error_base = module.const_get::<_, magnus::RClass>("Error")?;
        let error_class = error_base.const_get("Terminal")?;
        Err(Error::new(
            error_class,
            "Terminal is not initialized as TestBackend",
        ))
    }
}

pub fn set_cursor_position(x: u16, y: u16) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let mut term_lock = TERMINAL.lock().unwrap();

    if let Some(wrapper) = term_lock.as_mut() {
        let module = ruby.define_module("RatatuiRuby")?;
        let error_base = module.const_get::<_, magnus::RClass>("Error")?;
        let error_class = error_base.const_get("Terminal")?;

        match wrapper {
            TerminalWrapper::Crossterm(term) => {
                term.set_cursor_position((x, y))
                    .map_err(|e| Error::new(error_class, e.to_string()))?;
            }
            TerminalWrapper::Test(term) => {
                term.set_cursor_position((x, y))
                    .map_err(|e| Error::new(error_class, e.to_string()))?;
            }
        }
        Ok(())
    } else {
        let module = ruby.define_module("RatatuiRuby")?;
        let error_base = module.const_get::<_, magnus::RClass>("Error")?;
        let error_class = error_base.const_get("Terminal")?;
        Err(Error::new(error_class, "Terminal is not initialized"))
    }
}

pub fn resize_terminal(width: u16, height: u16) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let mut term_lock = TERMINAL.lock().unwrap();
    if let Some(wrapper) = term_lock.as_mut() {
        match wrapper {
            TerminalWrapper::Crossterm(_) => {}
            TerminalWrapper::Test(terminal) => {
                terminal.backend_mut().resize(width, height);
                if let Err(e) = terminal.resize(ratatui::layout::Rect::new(0, 0, width, height)) {
                    let module = ruby.define_module("RatatuiRuby")?;
                    let error_base = module.const_get::<_, magnus::RClass>("Error")?;
                    let error_class = error_base.const_get("Terminal")?;
                    return Err(Error::new(error_class, e.to_string()));
                }
            }
        }
    }
    Ok(())
}

use magnus::Value;

pub fn get_cell_at(x: u16, y: u16) -> Result<magnus::RHash, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let term_lock = TERMINAL.lock().unwrap();
    if let Some(TerminalWrapper::Test(terminal)) = term_lock.as_ref() {
        let buffer = terminal.backend().buffer();
        if let Some(cell) = buffer.cell((x, y)) {
            let hash = ruby.hash_new();
            hash.aset("char", cell.symbol())?;
            hash.aset("fg", color_to_value(cell.fg))?;
            hash.aset("bg", color_to_value(cell.bg))?;
            hash.aset("underline_color", color_to_value(cell.underline_color))?;
            hash.aset("modifiers", modifiers_to_value(cell.modifier))?;
            Ok(hash)
        } else {
            let module = ruby.define_module("RatatuiRuby")?;
            let error_base = module.const_get::<_, magnus::RClass>("Error")?;
            let error_class = error_base.const_get("Terminal")?;
            Err(Error::new(
                error_class,
                format!("Coordinates ({x}, {y}) out of bounds"),
            ))
        }
    } else {
        let module = ruby.define_module("RatatuiRuby")?;
        let error_base = module.const_get::<_, magnus::RClass>("Error")?;
        let error_class = error_base.const_get("Terminal")?;
        Err(Error::new(
            error_class,
            "Terminal is not initialized as TestBackend",
        ))
    }
}

fn color_to_value(color: ratatui::style::Color) -> Value {
    let ruby = magnus::Ruby::get().unwrap();
    match color {
        ratatui::style::Color::Reset => ruby.qnil().as_value(),
        ratatui::style::Color::Black => ruby.to_symbol("black").as_value(),
        ratatui::style::Color::Red => ruby.to_symbol("red").as_value(),
        ratatui::style::Color::Green => ruby.to_symbol("green").as_value(),
        ratatui::style::Color::Yellow => ruby.to_symbol("yellow").as_value(),
        ratatui::style::Color::Blue => ruby.to_symbol("blue").as_value(),
        ratatui::style::Color::Magenta => ruby.to_symbol("magenta").as_value(),
        ratatui::style::Color::Cyan => ruby.to_symbol("cyan").as_value(),
        ratatui::style::Color::Gray => ruby.to_symbol("gray").as_value(),
        ratatui::style::Color::DarkGray => ruby.to_symbol("dark_gray").as_value(),
        ratatui::style::Color::LightRed => ruby.to_symbol("light_red").as_value(),
        ratatui::style::Color::LightGreen => ruby.to_symbol("light_green").as_value(),
        ratatui::style::Color::LightYellow => ruby.to_symbol("light_yellow").as_value(),
        ratatui::style::Color::LightBlue => ruby.to_symbol("light_blue").as_value(),
        ratatui::style::Color::LightMagenta => ruby.to_symbol("light_magenta").as_value(),
        ratatui::style::Color::LightCyan => ruby.to_symbol("light_cyan").as_value(),
        ratatui::style::Color::White => ruby.to_symbol("white").as_value(),
        ratatui::style::Color::Rgb(r, g, b) => ruby
            .str_new(&(format!("#{r:02x}{g:02x}{b:02x}")))
            .as_value(),
        ratatui::style::Color::Indexed(i) => ruby.to_symbol(format!("indexed_{i}")).as_value(),
    }
}

fn modifiers_to_value(modifier: ratatui::style::Modifier) -> Value {
    let ruby = magnus::Ruby::get().unwrap();
    let ary = ruby.ary_new();

    if modifier.contains(ratatui::style::Modifier::BOLD) {
        let _ = ary.push(ruby.to_symbol("bold"));
    }
    if modifier.contains(ratatui::style::Modifier::ITALIC) {
        let _ = ary.push(ruby.to_symbol("italic"));
    }
    if modifier.contains(ratatui::style::Modifier::DIM) {
        let _ = ary.push(ruby.to_symbol("dim"));
    }
    if modifier.contains(ratatui::style::Modifier::UNDERLINED) {
        let _ = ary.push(ruby.to_symbol("underlined"));
    }
    if modifier.contains(ratatui::style::Modifier::REVERSED) {
        let _ = ary.push(ruby.to_symbol("reversed"));
    }
    if modifier.contains(ratatui::style::Modifier::HIDDEN) {
        let _ = ary.push(ruby.to_symbol("hidden"));
    }
    if modifier.contains(ratatui::style::Modifier::CROSSED_OUT) {
        let _ = ary.push(ruby.to_symbol("crossed_out"));
    }
    if modifier.contains(ratatui::style::Modifier::SLOW_BLINK) {
        let _ = ary.push(ruby.to_symbol("slow_blink"));
    }
    if modifier.contains(ratatui::style::Modifier::RAPID_BLINK) {
        let _ = ary.push(ruby.to_symbol("rapid_blink"));
    }

    ary.as_value()
}

// --- Terminal Capability Detection (Phase 2) ---
//
// Direct crossterm calls. For testing, control env vars:
// - COLORTERM: "truecolor" -> 65535, "24bit" -> 65535
// - TERM: "xterm-256color" -> 256, "xterm-truecolor" -> 65535
// - Neither set: 8 (default)
// See crossterm::style::available_color_count() source for details.

/// Returns color support level (8, 256, or `u16::MAX` for truecolor)
///
/// Wraps `crossterm::style::available_color_count()` which checks COLORTERM and TERM env vars.
pub fn available_color_count() -> u16 {
    ratatui::crossterm::style::available_color_count()
}

/// Query if terminal supports Kitty keyboard protocol
///
/// Note: This requires raw mode and may return errors in some environments.
pub fn supports_keyboard_enhancement() -> Result<bool, Error> {
    ratatui::crossterm::terminal::supports_keyboard_enhancement().map_err(|e| {
        Error::new(
            Ruby::get().unwrap().exception_runtime_error(),
            e.to_string(),
        )
    })
}
