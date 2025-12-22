// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::{Error, IntoValue, Symbol, Value};

pub fn poll_event() -> Result<Value, Error> {
    if crossterm::event::poll(std::time::Duration::from_millis(16))
        .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?
    {
        let event = crossterm::event::read()
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;

        if let crossterm::event::Event::Key(key) = event {
            if key.kind == crossterm::event::KeyEventKind::Press {
                let hash = magnus::RHash::new();
                hash.aset(Symbol::new("type"), Symbol::new("key"))?;

                let code = match key.code {
                    crossterm::event::KeyCode::Char(c) => c.to_string(),
                    crossterm::event::KeyCode::Up => "up".to_string(),
                    crossterm::event::KeyCode::Down => "down".to_string(),
                    crossterm::event::KeyCode::Left => "left".to_string(),
                    crossterm::event::KeyCode::Right => "right".to_string(),
                    crossterm::event::KeyCode::Enter => "enter".to_string(),
                    crossterm::event::KeyCode::Esc => "esc".to_string(),
                    crossterm::event::KeyCode::Backspace => "backspace".to_string(),
                    crossterm::event::KeyCode::Tab => "tab".to_string(),
                    _ => "unknown".to_string(),
                };
                hash.aset(Symbol::new("code"), code)?;

                let mut modifiers = Vec::new();
                if key
                    .modifiers
                    .contains(crossterm::event::KeyModifiers::CONTROL)
                {
                    modifiers.push("ctrl");
                }
                if key.modifiers.contains(crossterm::event::KeyModifiers::ALT) {
                    modifiers.push("alt");
                }
                if key
                    .modifiers
                    .contains(crossterm::event::KeyModifiers::SHIFT)
                {
                    modifiers.push("shift");
                }
                if !modifiers.is_empty() {
                    hash.aset(Symbol::new("modifiers"), modifiers)?;
                }

                return Ok(hash.into_value());
            }
        }
    }
    Ok(magnus::value::qnil().into_value())
}
