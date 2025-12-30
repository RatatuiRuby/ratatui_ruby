// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::Error;
use magnus::value::ReprValue;
use ratatui::{
    backend::{CrosstermBackend, TestBackend},
    Terminal,
};
use std::io;
use std::sync::Mutex;

pub enum TerminalWrapper {
    Crossterm(Terminal<CrosstermBackend<io::Stdout>>),
    Test(Terminal<TestBackend>),
}

pub static TERMINAL: Mutex<Option<TerminalWrapper>> = Mutex::new(None);

pub fn init_terminal(focus_events: bool, bracketed_paste: bool) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let mut term_lock = TERMINAL.lock().unwrap();
    if term_lock.is_none() {
        ratatui::crossterm::terminal::enable_raw_mode()
            .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;
        let mut stdout = io::stdout();
        ratatui::crossterm::execute!(
            stdout,
            ratatui::crossterm::terminal::EnterAlternateScreen,
            ratatui::crossterm::event::EnableMouseCapture
        )
        .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;

        if focus_events {
            ratatui::crossterm::execute!(stdout, ratatui::crossterm::event::EnableFocusChange)
                .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;
        }
        if bracketed_paste {
            ratatui::crossterm::execute!(stdout, ratatui::crossterm::event::EnableBracketedPaste)
                .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;
        }

        let backend = CrosstermBackend::new(stdout);
        let terminal = Terminal::new(backend)
            .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;
        *term_lock = Some(TerminalWrapper::Crossterm(terminal));
    }
    Ok(())
}

pub fn init_test_terminal(width: u16, height: u16) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let mut term_lock = TERMINAL.lock().unwrap();
    let backend = TestBackend::new(width, height);
    let terminal = Terminal::new(backend)
        .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;
    *term_lock = Some(TerminalWrapper::Test(terminal));
    Ok(())
}

pub fn restore_terminal() {
    let mut term_lock = TERMINAL.lock().unwrap();
    if let Some(wrapper) = term_lock.take() {
        match wrapper {
            TerminalWrapper::Crossterm(mut t) => {
                let _ = ratatui::crossterm::terminal::disable_raw_mode();
                let _ = ratatui::crossterm::execute!(
                    t.backend_mut(),
                    ratatui::crossterm::terminal::LeaveAlternateScreen,
                    ratatui::crossterm::event::DisableMouseCapture,
                    ratatui::crossterm::event::DisableFocusChange,
                    ratatui::crossterm::event::DisableBracketedPaste
                );
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
        Err(Error::new(
            ruby.exception_runtime_error(),
            "Terminal is not initialized as TestBackend",
        ))
    }
}

pub fn get_cursor_position() -> Result<Option<(u16, u16)>, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let mut term_lock = TERMINAL.lock().unwrap();
    if let Some(TerminalWrapper::Test(terminal)) = term_lock.as_mut() {
        let pos = terminal
            .get_cursor_position()
            .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;
        Ok(Some(pos.into()))
    } else {
        Err(Error::new(
            ruby.exception_runtime_error(),
            "Terminal is not initialized as TestBackend",
        ))
    }
}

pub fn resize_terminal(width: u16, height: u16) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let mut term_lock = TERMINAL.lock().unwrap();
    if let Some(wrapper) = term_lock.as_mut() {
        match wrapper {
            TerminalWrapper::Crossterm(_) => {
            }
            TerminalWrapper::Test(terminal) => {
                terminal.backend_mut().resize(width, height);
                if let Err(e) = terminal.resize(ratatui::layout::Rect::new(0, 0, width, height)) {
                    return Err(Error::new(
                        ruby.exception_runtime_error(),
                        e.to_string(),
                    ));
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
            hash.aset("modifiers", modifiers_to_value(cell.modifier))?;
            Ok(hash)
        } else {
            Err(Error::new(
                ruby.exception_runtime_error(),
                format!("Coordinates ({x}, {y}) out of bounds"),
            ))
        }
    } else {
        Err(Error::new(
            ruby.exception_runtime_error(),
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
        let _ = ary.push(ruby.str_new("bold"));
    }
    if modifier.contains(ratatui::style::Modifier::ITALIC) {
        let _ = ary.push(ruby.str_new("italic"));
    }
    if modifier.contains(ratatui::style::Modifier::DIM) {
        let _ = ary.push(ruby.str_new("dim"));
    }
    if modifier.contains(ratatui::style::Modifier::UNDERLINED) {
        let _ = ary.push(ruby.str_new("underlined"));
    }
    if modifier.contains(ratatui::style::Modifier::REVERSED) {
        let _ = ary.push(ruby.str_new("reversed"));
    }
    if modifier.contains(ratatui::style::Modifier::HIDDEN) {
        let _ = ary.push(ruby.str_new("hidden"));
    }
    if modifier.contains(ratatui::style::Modifier::CROSSED_OUT) {
        let _ = ary.push(ruby.str_new("crossed_out"));
    }
    if modifier.contains(ratatui::style::Modifier::SLOW_BLINK) {
        let _ = ary.push(ruby.str_new("slow_blink"));
    }
    if modifier.contains(ratatui::style::Modifier::RAPID_BLINK) {
        let _ = ary.push(ruby.str_new("rapid_blink"));
    }
    
    ary.as_value()
}
