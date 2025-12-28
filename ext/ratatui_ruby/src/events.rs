// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::{Error, IntoValue, TryConvert, Value};
use std::sync::Mutex;

lazy_static::lazy_static! {
    static ref EVENT_QUEUE: Mutex<Vec<ratatui::crossterm::event::Event>> = Mutex::new(Vec::new());
}

pub fn inject_test_event(event_type: String, data: magnus::RHash) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let event = match event_type.as_str() {
        "key" => {
            let code_val: Value = data.get(ruby.to_symbol("code")).ok_or_else(|| {
                Error::new(
                    ruby.exception_arg_error(),
                    "Missing 'code' in key event",
                )
            })?;
            let code_str: String = String::try_convert(code_val)?;
            let code = match code_str.as_str() {
                "up" => ratatui::crossterm::event::KeyCode::Up,
                "down" => ratatui::crossterm::event::KeyCode::Down,
                "left" => ratatui::crossterm::event::KeyCode::Left,
                "right" => ratatui::crossterm::event::KeyCode::Right,
                "enter" => ratatui::crossterm::event::KeyCode::Enter,
                "esc" => ratatui::crossterm::event::KeyCode::Esc,
                "backspace" => ratatui::crossterm::event::KeyCode::Backspace,
                "tab" => ratatui::crossterm::event::KeyCode::Tab,
                c if c.len() == 1 => ratatui::crossterm::event::KeyCode::Char(c.chars().next().unwrap()),
                _ => ratatui::crossterm::event::KeyCode::Null,
            };

            let mut modifiers = ratatui::crossterm::event::KeyModifiers::empty();
            if let Some(mods_val) = data.get(ruby.to_symbol("modifiers")) {
                let mods: Vec<String> = Vec::try_convert(mods_val)?;
                for m in mods {
                    match m.as_str() {
                        "ctrl" => modifiers |= ratatui::crossterm::event::KeyModifiers::CONTROL,
                        "alt" => modifiers |= ratatui::crossterm::event::KeyModifiers::ALT,
                        "shift" => modifiers |= ratatui::crossterm::event::KeyModifiers::SHIFT,
                        _ => {}
                    }
                }
            }

            ratatui::crossterm::event::Event::Key(ratatui::crossterm::event::KeyEvent::new(code, modifiers))
        }
        "mouse" => {
            let kind_val: Value = data.get(ruby.to_symbol("kind")).ok_or_else(|| {
                Error::new(
                    ruby.exception_arg_error(),
                    "Missing 'kind' in mouse event",
                )
            })?;
            let kind_str: String = String::try_convert(kind_val)?;

            let button = if let Some(btn_val) = data.get(ruby.to_symbol("button")) {
                let button_str: String = String::try_convert(btn_val)?;
                match button_str.as_str() {
                    "right" => ratatui::crossterm::event::MouseButton::Right,
                    "middle" => ratatui::crossterm::event::MouseButton::Middle,
                    _ => ratatui::crossterm::event::MouseButton::Left,
                }
            } else {
                ratatui::crossterm::event::MouseButton::Left
            };

            let x_val: Value = data.get(ruby.to_symbol("x")).ok_or_else(|| {
                Error::new(ruby.exception_arg_error(), "Missing 'x' in mouse event")
            })?;
            let x: u16 = u16::try_convert(x_val)?;

            let y_val: Value = data.get(ruby.to_symbol("y")).ok_or_else(|| {
                Error::new(ruby.exception_arg_error(), "Missing 'y' in mouse event")
            })?;
            let y: u16 = u16::try_convert(y_val)?;

            let kind = match kind_str.as_str() {
                "down" => ratatui::crossterm::event::MouseEventKind::Down(button),
                "up" => ratatui::crossterm::event::MouseEventKind::Up(button),
                "drag" => ratatui::crossterm::event::MouseEventKind::Drag(button),
                "moved" => ratatui::crossterm::event::MouseEventKind::Moved,
                "scroll_down" => ratatui::crossterm::event::MouseEventKind::ScrollDown,
                "scroll_up" => ratatui::crossterm::event::MouseEventKind::ScrollUp,
                "scroll_left" => ratatui::crossterm::event::MouseEventKind::ScrollLeft,
                "scroll_right" => ratatui::crossterm::event::MouseEventKind::ScrollRight,
                _ => {
                    return Err(Error::new(
                        ruby.exception_arg_error(),
                        format!("Unknown mouse kind: {}", kind_str),
                    ))
                }
            };

            let mut modifiers = ratatui::crossterm::event::KeyModifiers::empty();
            if let Some(mods_val) = data.get(ruby.to_symbol("modifiers")) {
                let mods: Vec<String> = Vec::try_convert(mods_val)?;
                for m in mods {
                    match m.as_str() {
                        "ctrl" => modifiers |= ratatui::crossterm::event::KeyModifiers::CONTROL,
                        "alt" => modifiers |= ratatui::crossterm::event::KeyModifiers::ALT,
                        "shift" => modifiers |= ratatui::crossterm::event::KeyModifiers::SHIFT,
                        _ => {}
                    }
                }
            }

            ratatui::crossterm::event::Event::Mouse(ratatui::crossterm::event::MouseEvent {
                kind,
                column: x,
                row: y,
                modifiers,
            })
        }
        _ => {
            return Err(Error::new(
                ruby.exception_arg_error(),
                format!("Unknown event type: {}", event_type),
            ))
        }
    };

    EVENT_QUEUE.lock().unwrap().push(event);
    Ok(())
}

pub fn poll_event() -> Result<Value, Error> {
    let ruby = magnus::Ruby::get().unwrap();
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
        return Ok(ruby.qnil().into_value_with(&magnus::Ruby::get().unwrap()));
    }

    if ratatui::crossterm::event::poll(std::time::Duration::from_millis(16))
        .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?
    {
        let event = ratatui::crossterm::event::read()
            .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;
        handle_event(event)
    } else {
        Ok(ruby.qnil().into_value_with(&magnus::Ruby::get().unwrap()))
    }
}

fn handle_event(event: ratatui::crossterm::event::Event) -> Result<Value, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    match event {
        ratatui::crossterm::event::Event::Key(key) => {
            if key.kind == ratatui::crossterm::event::KeyEventKind::Press {
                let ruby = magnus::Ruby::get().unwrap();
                let hash = ruby.hash_new();
                hash.aset(ruby.to_symbol("type"), ruby.to_symbol("key"))?;

                let code = match key.code {
                    ratatui::crossterm::event::KeyCode::Char(c) => c.to_string(),
                    ratatui::crossterm::event::KeyCode::Up => "up".to_string(),
                    ratatui::crossterm::event::KeyCode::Down => "down".to_string(),
                    ratatui::crossterm::event::KeyCode::Left => "left".to_string(),
                    ratatui::crossterm::event::KeyCode::Right => "right".to_string(),
                    ratatui::crossterm::event::KeyCode::Enter => "enter".to_string(),
                    ratatui::crossterm::event::KeyCode::Esc => "esc".to_string(),
                    ratatui::crossterm::event::KeyCode::Backspace => "backspace".to_string(),
                    ratatui::crossterm::event::KeyCode::Tab => "tab".to_string(),
                    _ => "unknown".to_string(),
                };
                hash.aset(ruby.to_symbol("code"), code)?;

                let mut modifiers = Vec::new();
                if key
                    .modifiers
                    .contains(ratatui::crossterm::event::KeyModifiers::CONTROL)
                {
                    modifiers.push("ctrl");
                }
                if key.modifiers.contains(ratatui::crossterm::event::KeyModifiers::ALT) {
                    modifiers.push("alt");
                }
                if key
                    .modifiers
                    .contains(ratatui::crossterm::event::KeyModifiers::SHIFT)
                {
                    modifiers.push("shift");
                }
                if !modifiers.is_empty() {
                    hash.aset(ruby.to_symbol("modifiers"), modifiers)?;
                }

            return Ok(hash.into_value_with(&ruby));
            }
        }
        ratatui::crossterm::event::Event::Mouse(event) => {
            let ruby = magnus::Ruby::get().unwrap();
            let hash = ruby.hash_new();
            hash.aset(ruby.to_symbol("type"), ruby.to_symbol("mouse"))?;

            let (kind, button) = match event.kind {
                ratatui::crossterm::event::MouseEventKind::Down(btn) => ("down", btn),
                ratatui::crossterm::event::MouseEventKind::Up(btn) => ("up", btn),
                ratatui::crossterm::event::MouseEventKind::Drag(btn) => ("drag", btn),
                ratatui::crossterm::event::MouseEventKind::Moved => {
                    ("moved", ratatui::crossterm::event::MouseButton::Left)
                } // button is ignored for moved
                ratatui::crossterm::event::MouseEventKind::ScrollDown => {
                    ("scroll_down", ratatui::crossterm::event::MouseButton::Left)
                } // button is ignored for scroll
                ratatui::crossterm::event::MouseEventKind::ScrollUp => {
                    ("scroll_up", ratatui::crossterm::event::MouseButton::Left)
                } // button is ignored for scroll
                ratatui::crossterm::event::MouseEventKind::ScrollLeft => {
                    ("scroll_left", ratatui::crossterm::event::MouseButton::Left)
                } // button is ignored for scroll
                ratatui::crossterm::event::MouseEventKind::ScrollRight => {
                    ("scroll_right", ratatui::crossterm::event::MouseButton::Left)
                } // button is ignored for scroll
            };

            hash.aset(ruby.to_symbol("kind"), ruby.to_symbol(kind))?;

            if matches!(
                event.kind,
                ratatui::crossterm::event::MouseEventKind::Down(_)
                    | ratatui::crossterm::event::MouseEventKind::Up(_)
                    | ratatui::crossterm::event::MouseEventKind::Drag(_)
            ) {
                let btn_sym = match button {
                    ratatui::crossterm::event::MouseButton::Left => "left",
                    ratatui::crossterm::event::MouseButton::Right => "right",
                    ratatui::crossterm::event::MouseButton::Middle => "middle",
                };
                hash.aset(ruby.to_symbol("button"), ruby.to_symbol(btn_sym))?;
            } else {
                hash.aset(ruby.to_symbol("button"), ruby.to_symbol("none"))?;
            }

            hash.aset(ruby.to_symbol("x"), event.column)?;
            hash.aset(ruby.to_symbol("y"), event.row)?;

            let mut modifiers = Vec::new();
            if event
                .modifiers
                .contains(ratatui::crossterm::event::KeyModifiers::CONTROL)
            {
                modifiers.push("ctrl");
            }
            if event
                .modifiers
                .contains(ratatui::crossterm::event::KeyModifiers::ALT)
            {
                modifiers.push("alt");
            }
            if event
                .modifiers
                .contains(ratatui::crossterm::event::KeyModifiers::SHIFT)
            {
                modifiers.push("shift");
            }
            hash.aset(ruby.to_symbol("modifiers"), modifiers)?;

            return Ok(hash.into_value_with(&ruby));
        }
        _ => {}
    }
    Ok(ruby.qnil().into_value_with(&magnus::Ruby::get().unwrap()))
}
