// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::Error;
use ratatui::{backend::CrosstermBackend, Terminal};
use std::io;
use std::sync::Mutex;

lazy_static::lazy_static! {
    pub static ref TERMINAL: Mutex<Option<Terminal<CrosstermBackend<io::Stdout>>>> = Mutex::new(None);
}

pub fn init_terminal() -> Result<(), Error> {
    let mut term_lock = TERMINAL.lock().unwrap();
    if term_lock.is_none() {
        crossterm::terminal::enable_raw_mode()
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
        let mut stdout = io::stdout();
        crossterm::execute!(stdout, crossterm::terminal::EnterAlternateScreen)
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
        let backend = CrosstermBackend::new(stdout);
        let terminal = Terminal::new(backend)
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
        *term_lock = Some(terminal);
    }
    Ok(())
}

pub fn restore_terminal() -> Result<(), Error> {
    let mut term_lock = TERMINAL.lock().unwrap();
    if let Some(mut terminal) = term_lock.take() {
        let _ = crossterm::terminal::disable_raw_mode();
        let _ = crossterm::execute!(
            terminal.backend_mut(),
            crossterm::terminal::LeaveAlternateScreen
        );
    }
    Ok(())
}
