// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::{Error, IntoValue, Symbol, TryConvert, Value};
use std::sync::Mutex;

lazy_static::lazy_static! {
    static ref EVENT_QUEUE: Mutex<Vec<crossterm::event::Event>> = Mutex::new(Vec::new());
}

pub fn inject_test_event(event_type: String, data: magnus::RHash) -> Result<(), Error> {
    let event = match event_type.as_str() {
        "key" => {
            let code_val: Value = data.get(Symbol::new("code")).ok_or_else(|| {
                Error::new(
                    magnus::exception::arg_error(),
                    "Missing 'code' in key event",
                )
            })?;
            let code_str: String = String::try_convert(code_val)?;
            let code = match code_str.as_str() {
                "up" => crossterm::event::KeyCode::Up,
                "down" => crossterm::event::KeyCode::Down,
                "left" => crossterm::event::KeyCode::Left,
                "right" => crossterm::event::KeyCode::Right,
                "enter" => crossterm::event::KeyCode::Enter,
                "esc" => crossterm::event::KeyCode::Esc,
                "backspace" => crossterm::event::KeyCode::Backspace,
                "tab" => crossterm::event::KeyCode::Tab,
                c if c.len() == 1 => crossterm::event::KeyCode::Char(c.chars().next().unwrap()),
                _ => crossterm::event::KeyCode::Null,
            };

            let mut modifiers = crossterm::event::KeyModifiers::empty();
            if let Some(mods_val) = data.get(Symbol::new("modifiers")) {
                let mods: Vec<String> = Vec::try_convert(mods_val)?;
                for m in mods {
                    match m.as_str() {
                        "ctrl" => modifiers |= crossterm::event::KeyModifiers::CONTROL,
                        "alt" => modifiers |= crossterm::event::KeyModifiers::ALT,
                        "shift" => modifiers |= crossterm::event::KeyModifiers::SHIFT,
                        _ => {}
                    }
                }
            }

            crossterm::event::Event::Key(crossterm::event::KeyEvent::new(code, modifiers))
        }
        "mouse" => {
            let kind_val: Value = data.get(Symbol::new("kind")).ok_or_else(|| {
                Error::new(
                    magnus::exception::arg_error(),
                    "Missing 'kind' in mouse event",
                )
            })?;
            let kind_str: String = String::try_convert(kind_val)?;

            let button = if let Some(btn_val) = data.get(Symbol::new("button")) {
                let button_str: String = String::try_convert(btn_val)?;
                match button_str.as_str() {
                    "right" => crossterm::event::MouseButton::Right,
                    "middle" => crossterm::event::MouseButton::Middle,
                    _ => crossterm::event::MouseButton::Left,
                }
            } else {
                crossterm::event::MouseButton::Left
            };

            let x_val: Value = data.get(Symbol::new("x")).ok_or_else(|| {
                Error::new(magnus::exception::arg_error(), "Missing 'x' in mouse event")
            })?;
            let x: u16 = u16::try_convert(x_val)?;

            let y_val: Value = data.get(Symbol::new("y")).ok_or_else(|| {
                Error::new(magnus::exception::arg_error(), "Missing 'y' in mouse event")
            })?;
            let y: u16 = u16::try_convert(y_val)?;

            let kind = match kind_str.as_str() {
                "down" => crossterm::event::MouseEventKind::Down(button),
                "up" => crossterm::event::MouseEventKind::Up(button),
                "drag" => crossterm::event::MouseEventKind::Drag(button),
                "moved" => crossterm::event::MouseEventKind::Moved,
                "scroll_down" => crossterm::event::MouseEventKind::ScrollDown,
                "scroll_up" => crossterm::event::MouseEventKind::ScrollUp,
                "scroll_left" => crossterm::event::MouseEventKind::ScrollLeft,
                "scroll_right" => crossterm::event::MouseEventKind::ScrollRight,
                _ => {
                    return Err(Error::new(
                        magnus::exception::arg_error(),
                        format!("Unknown mouse kind: {}", kind_str),
                    ))
                }
            };

            let mut modifiers = crossterm::event::KeyModifiers::empty();
            if let Some(mods_val) = data.get(Symbol::new("modifiers")) {
                let mods: Vec<String> = Vec::try_convert(mods_val)?;
                for m in mods {
                    match m.as_str() {
                        "ctrl" => modifiers |= crossterm::event::KeyModifiers::CONTROL,
                        "alt" => modifiers |= crossterm::event::KeyModifiers::ALT,
                        "shift" => modifiers |= crossterm::event::KeyModifiers::SHIFT,
                        _ => {}
                    }
                }
            }

            crossterm::event::Event::Mouse(crossterm::event::MouseEvent {
                kind,
                column: x,
                row: y,
                modifiers,
            })
        }
        _ => {
            return Err(Error::new(
                magnus::exception::arg_error(),
                format!("Unknown event type: {}", event_type),
            ))
        }
    };

    EVENT_QUEUE.lock().unwrap().push(event);
    Ok(())
}

pub fn poll_event() -> Result<Value, Error> {
    let event = {
        let mut queue = EVENT_QUEUE.lock().unwrap();
        if !queue.is_empty() {
            Some(queue.remove(0))
        } else {
            None
        }
    };

    if let Some(e) = event {
        return handle_event(e);
    }

    // Check if we are in test mode. If so, don't poll crossterm.
    let is_test_mode = {
        let term_lock = crate::terminal::TERMINAL.lock().unwrap();
        matches!(
            term_lock.as_ref(),
            Some(crate::terminal::TerminalWrapper::Test(_))
        )
    };

    if is_test_mode {
        return Ok(magnus::value::qnil().into_value());
    }

    if crossterm::event::poll(std::time::Duration::from_millis(16))
        .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?
    {
        let event = crossterm::event::read()
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
        handle_event(event)
    } else {
        Ok(magnus::value::qnil().into_value())
    }
}

fn handle_event(event: crossterm::event::Event) -> Result<Value, Error> {
    match event {
        crossterm::event::Event::Key(key) => {
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
        crossterm::event::Event::Mouse(event) => {
            let hash = magnus::RHash::new();
            hash.aset(Symbol::new("type"), Symbol::new("mouse"))?;

            let (kind, button) = match event.kind {
                crossterm::event::MouseEventKind::Down(btn) => ("down", btn),
                crossterm::event::MouseEventKind::Up(btn) => ("up", btn),
                crossterm::event::MouseEventKind::Drag(btn) => ("drag", btn),
                crossterm::event::MouseEventKind::Moved => {
                    ("moved", crossterm::event::MouseButton::Left)
                } // button is ignored for moved
                crossterm::event::MouseEventKind::ScrollDown => {
                    ("scroll_down", crossterm::event::MouseButton::Left)
                } // button is ignored for scroll
                crossterm::event::MouseEventKind::ScrollUp => {
                    ("scroll_up", crossterm::event::MouseButton::Left)
                } // button is ignored for scroll
                crossterm::event::MouseEventKind::ScrollLeft => {
                    ("scroll_left", crossterm::event::MouseButton::Left)
                } // button is ignored for scroll
                crossterm::event::MouseEventKind::ScrollRight => {
                    ("scroll_right", crossterm::event::MouseButton::Left)
                } // button is ignored for scroll
            };

            hash.aset(Symbol::new("kind"), Symbol::new(kind))?;

            if matches!(
                event.kind,
                crossterm::event::MouseEventKind::Down(_)
                    | crossterm::event::MouseEventKind::Up(_)
                    | crossterm::event::MouseEventKind::Drag(_)
            ) {
                let btn_sym = match button {
                    crossterm::event::MouseButton::Left => "left",
                    crossterm::event::MouseButton::Right => "right",
                    crossterm::event::MouseButton::Middle => "middle",
                };
                hash.aset(Symbol::new("button"), Symbol::new(btn_sym))?;
            } else {
                hash.aset(Symbol::new("button"), Symbol::new("none"))?;
            }

            hash.aset(Symbol::new("x"), event.column)?;
            hash.aset(Symbol::new("y"), event.row)?;

            let mut modifiers = Vec::new();
            if event
                .modifiers
                .contains(crossterm::event::KeyModifiers::CONTROL)
            {
                modifiers.push("ctrl");
            }
            if event
                .modifiers
                .contains(crossterm::event::KeyModifiers::ALT)
            {
                modifiers.push("alt");
            }
            if event
                .modifiers
                .contains(crossterm::event::KeyModifiers::SHIFT)
            {
                modifiers.push("shift");
            }
            hash.aset(Symbol::new("modifiers"), modifiers)?;

            return Ok(hash.into_value());
        }
        _ => {}
    }
    Ok(magnus::value::qnil().into_value())
}
