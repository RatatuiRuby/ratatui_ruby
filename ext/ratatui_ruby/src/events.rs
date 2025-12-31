// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::{Error, IntoValue, TryConvert, Value};
use std::sync::Mutex;

static EVENT_QUEUE: Mutex<Vec<ratatui::crossterm::event::Event>> = Mutex::new(Vec::new());

#[allow(clippy::needless_pass_by_value)]
pub fn inject_test_event(event_type: String, data: magnus::RHash) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let event = match event_type.as_str() {
        "key" => parse_key_event(data, &ruby)?,
        "mouse" => parse_mouse_event(data, &ruby)?,
        "resize" => parse_resize_event(data, &ruby)?,
        "paste" => parse_paste_event(data, &ruby)?,
        "focus_gained" => ratatui::crossterm::event::Event::FocusGained,
        "focus_lost" => ratatui::crossterm::event::Event::FocusLost,
        _ => {
            return Err(Error::new(
                ruby.exception_arg_error(),
                format!("Unknown event type: {event_type}"),
            ))
        }
    };

    EVENT_QUEUE.lock().unwrap().push(event);
    Ok(())
}

fn parse_key_event(
    data: magnus::RHash,
    ruby: &magnus::Ruby,
) -> Result<ratatui::crossterm::event::Event, Error> {
    let code_val: Value = data
        .get(ruby.to_symbol("code"))
        .ok_or_else(|| Error::new(ruby.exception_arg_error(), "Missing 'code' in key event"))?;
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

    Ok(ratatui::crossterm::event::Event::Key(
        ratatui::crossterm::event::KeyEvent::new(code, modifiers),
    ))
}

fn parse_mouse_event(
    data: magnus::RHash,
    ruby: &magnus::Ruby,
) -> Result<ratatui::crossterm::event::Event, Error> {
    let kind_val: Value = data
        .get(ruby.to_symbol("kind"))
        .ok_or_else(|| Error::new(ruby.exception_arg_error(), "Missing 'kind' in mouse event"))?;
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

    let x_val: Value = data
        .get(ruby.to_symbol("x"))
        .ok_or_else(|| Error::new(ruby.exception_arg_error(), "Missing 'x' in mouse event"))?;
    let x: u16 = u16::try_convert(x_val)?;

    let y_val: Value = data
        .get(ruby.to_symbol("y"))
        .ok_or_else(|| Error::new(ruby.exception_arg_error(), "Missing 'y' in mouse event"))?;
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
                format!("Unknown mouse kind: {kind_str}"),
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

    Ok(ratatui::crossterm::event::Event::Mouse(
        ratatui::crossterm::event::MouseEvent {
            kind,
            column: x,
            row: y,
            modifiers,
        },
    ))
}

fn parse_resize_event(
    data: magnus::RHash,
    ruby: &magnus::Ruby,
) -> Result<ratatui::crossterm::event::Event, Error> {
    let width_val: Value = data.get(ruby.to_symbol("width")).ok_or_else(|| {
        Error::new(
            ruby.exception_arg_error(),
            "Missing 'width' in resize event",
        )
    })?;
    let width: u16 = u16::try_convert(width_val)?;

    let height_val: Value = data.get(ruby.to_symbol("height")).ok_or_else(|| {
        Error::new(
            ruby.exception_arg_error(),
            "Missing 'height' in resize event",
        )
    })?;
    let height: u16 = u16::try_convert(height_val)?;

    Ok(ratatui::crossterm::event::Event::Resize(width, height))
}

fn parse_paste_event(
    data: magnus::RHash,
    ruby: &magnus::Ruby,
) -> Result<ratatui::crossterm::event::Event, Error> {
    let content_val: Value = data.get(ruby.to_symbol("content")).ok_or_else(|| {
        Error::new(
            ruby.exception_arg_error(),
            "Missing 'content' in paste event",
        )
    })?;
    let content: String = String::try_convert(content_val)?;
    Ok(ratatui::crossterm::event::Event::Paste(content))
}

pub fn clear_events() {
    EVENT_QUEUE.lock().unwrap().clear();
}

pub fn poll_event(ruby: &magnus::Ruby) -> Result<Value, Error> {
    let event = {
        let mut queue = EVENT_QUEUE.lock().unwrap();
        if queue.is_empty() {
            None
        } else {
            Some(queue.remove(0))
        }
    };

    if let Some(e) = event {
        return handle_event(e);
    }

    let is_test_mode = {
        let term_lock = crate::terminal::TERMINAL.lock().unwrap();
        matches!(
            term_lock.as_ref(),
            Some(crate::terminal::TerminalWrapper::Test(_))
        )
    };

    if is_test_mode {
        return Ok(ruby.qnil().into_value_with(ruby));
    }

    if ratatui::crossterm::event::poll(std::time::Duration::from_millis(16))
        .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?
    {
        let event = ratatui::crossterm::event::read()
            .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;
        handle_event(event)
    } else {
        Ok(ruby.qnil().into_value_with(ruby))
    }
}

fn handle_event(event: ratatui::crossterm::event::Event) -> Result<Value, Error> {
    match event {
        ratatui::crossterm::event::Event::Key(key) => handle_key_event(key),
        ratatui::crossterm::event::Event::Mouse(event) => handle_mouse_event(event),
        ratatui::crossterm::event::Event::Resize(w, h) => handle_resize_event(w, h),
        ratatui::crossterm::event::Event::Paste(content) => handle_paste_event(content),
        ratatui::crossterm::event::Event::FocusGained => handle_focus_event("focus_gained"),
        ratatui::crossterm::event::Event::FocusLost => handle_focus_event("focus_lost"),
    }
}

fn handle_key_event(key: ratatui::crossterm::event::KeyEvent) -> Result<Value, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    if key.kind != ratatui::crossterm::event::KeyEventKind::Press {
        return Ok(ruby.qnil().into_value_with(&ruby));
    }
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
    if key
        .modifiers
        .contains(ratatui::crossterm::event::KeyModifiers::ALT)
    {
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
    Ok(hash.into_value_with(&ruby))
}

fn handle_mouse_event(event: ratatui::crossterm::event::MouseEvent) -> Result<Value, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let hash = ruby.hash_new();
    hash.aset(ruby.to_symbol("type"), ruby.to_symbol("mouse"))?;
    let (kind, button) = match event.kind {
        ratatui::crossterm::event::MouseEventKind::Down(btn) => ("down", btn),
        ratatui::crossterm::event::MouseEventKind::Up(btn) => ("up", btn),
        ratatui::crossterm::event::MouseEventKind::Drag(btn) => ("drag", btn),
        ratatui::crossterm::event::MouseEventKind::Moved => {
            ("moved", ratatui::crossterm::event::MouseButton::Left)
        }
        ratatui::crossterm::event::MouseEventKind::ScrollDown => {
            ("scroll_down", ratatui::crossterm::event::MouseButton::Left)
        }
        ratatui::crossterm::event::MouseEventKind::ScrollUp => {
            ("scroll_up", ratatui::crossterm::event::MouseButton::Left)
        }
        ratatui::crossterm::event::MouseEventKind::ScrollLeft => {
            ("scroll_left", ratatui::crossterm::event::MouseButton::Left)
        }
        ratatui::crossterm::event::MouseEventKind::ScrollRight => {
            ("scroll_right", ratatui::crossterm::event::MouseButton::Left)
        }
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
    Ok(hash.into_value_with(&ruby))
}

fn handle_resize_event(w: u16, h: u16) -> Result<Value, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let hash = ruby.hash_new();
    hash.aset(ruby.to_symbol("type"), ruby.to_symbol("resize"))?;
    hash.aset(ruby.to_symbol("width"), w)?;
    hash.aset(ruby.to_symbol("height"), h)?;
    Ok(hash.into_value_with(&ruby))
}

fn handle_paste_event(content: String) -> Result<Value, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let hash = ruby.hash_new();
    hash.aset(ruby.to_symbol("type"), ruby.to_symbol("paste"))?;
    hash.aset(ruby.to_symbol("content"), content)?;
    Ok(hash.into_value_with(&ruby))
}

fn handle_focus_event(event_type: &str) -> Result<Value, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let hash = ruby.hash_new();
    hash.aset(ruby.to_symbol("type"), ruby.to_symbol(event_type))?;
    Ok(hash.into_value_with(&ruby))
}
