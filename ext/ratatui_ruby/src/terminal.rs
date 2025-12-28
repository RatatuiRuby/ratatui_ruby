// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::Error;
use ratatui::{
    backend::{CrosstermBackend, TestBackend},
    Terminal,
};
use std::io;
use std::sync::Mutex;

pub enum TerminalWrapper {
    Crossterm(Terminal<CrosstermBackend<io::Stdout>>),
    Test(Terminal<TestBackend>), // We don't need Mutex inside the enum variant because the global is a Mutex
}

lazy_static::lazy_static! {
    pub static ref TERMINAL: Mutex<Option<TerminalWrapper>> = Mutex::new(None);
}

pub fn init_terminal() -> Result<(), Error> {
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

pub fn restore_terminal() -> Result<(), Error> {
    let mut term_lock = TERMINAL.lock().unwrap();
    if let Some(TerminalWrapper::Crossterm(mut terminal)) = term_lock.take() {
        let _ = ratatui::crossterm::terminal::disable_raw_mode();
        let _ = ratatui::crossterm::execute!(
            terminal.backend_mut(),
            ratatui::crossterm::terminal::LeaveAlternateScreen,
            ratatui::crossterm::event::DisableMouseCapture
        );
    }
    Ok(())
}

pub fn get_buffer_content() -> Result<String, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let term_lock = TERMINAL.lock().unwrap();
    if let Some(TerminalWrapper::Test(terminal)) = term_lock.as_ref() {
        // We need to access the buffer.
        // Since we are mocking, we can just print the buffer to a string.
        let buffer = terminal.backend().buffer();
        // Simple representation: each cell's symbol.
        // For a more complex representation we could return an array of strings.
        // Let's just return the full string representation for now which is useful for debugging/asserting.
        // Actually, let's reconstruct it line by line.
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
                // Resize happens automatically for Crossterm via signals usually,
                // but we can't easily force it here without OS interaction.
                // Ignoring for now as it's less critical for unit testing the logic.
            }
            TerminalWrapper::Test(terminal) => {
                terminal.backend_mut().resize(width, height);
                // Also resize the terminal wrapper itself if needed, but TestBackend resize handles the buffer.
                // We might need to call terminal.resize() too if Ratatui caches the size.
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
