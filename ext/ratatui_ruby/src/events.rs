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

/// Parses a `snake_case` string to `MediaKeyCode`.
fn parse_media_key(s: &str) -> Option<ratatui::crossterm::event::MediaKeyCode> {
    use ratatui::crossterm::event::MediaKeyCode;
    match s {
        "play" => Some(MediaKeyCode::Play),
        "media_pause" => Some(MediaKeyCode::Pause),
        "play_pause" => Some(MediaKeyCode::PlayPause),
        "reverse" => Some(MediaKeyCode::Reverse),
        "stop" => Some(MediaKeyCode::Stop),
        "fast_forward" => Some(MediaKeyCode::FastForward),
        "rewind" => Some(MediaKeyCode::Rewind),
        "track_next" => Some(MediaKeyCode::TrackNext),
        "track_previous" => Some(MediaKeyCode::TrackPrevious),
        "record" => Some(MediaKeyCode::Record),
        "lower_volume" => Some(MediaKeyCode::LowerVolume),
        "raise_volume" => Some(MediaKeyCode::RaiseVolume),
        "mute_volume" => Some(MediaKeyCode::MuteVolume),
        _ => None,
    }
}

/// Parses a `snake_case` string to `ModifierKeyCode`.
fn parse_modifier_key(s: &str) -> Option<ratatui::crossterm::event::ModifierKeyCode> {
    use ratatui::crossterm::event::ModifierKeyCode;
    match s {
        "left_shift" => Some(ModifierKeyCode::LeftShift),
        "left_control" => Some(ModifierKeyCode::LeftControl),
        "left_alt" => Some(ModifierKeyCode::LeftAlt),
        "left_super" => Some(ModifierKeyCode::LeftSuper),
        "left_hyper" => Some(ModifierKeyCode::LeftHyper),
        "left_meta" => Some(ModifierKeyCode::LeftMeta),
        "right_shift" => Some(ModifierKeyCode::RightShift),
        "right_control" => Some(ModifierKeyCode::RightControl),
        "right_alt" => Some(ModifierKeyCode::RightAlt),
        "right_super" => Some(ModifierKeyCode::RightSuper),
        "right_hyper" => Some(ModifierKeyCode::RightHyper),
        "right_meta" => Some(ModifierKeyCode::RightMeta),
        "iso_level3_shift" => Some(ModifierKeyCode::IsoLevel3Shift),
        "iso_level5_shift" => Some(ModifierKeyCode::IsoLevel5Shift),
        _ => None,
    }
}

fn parse_key_event(
    data: magnus::RHash,
    ruby: &magnus::Ruby,
) -> Result<ratatui::crossterm::event::Event, Error> {
    use ratatui::crossterm::event::KeyCode;

    let code_val: Value = data
        .get(ruby.to_symbol("code"))
        .ok_or_else(|| Error::new(ruby.exception_arg_error(), "Missing 'code' in key event"))?;
    let code_str: String = String::try_convert(code_val)?;
    let code = match code_str.as_str() {
        // Arrow keys
        "up" => KeyCode::Up,
        "down" => KeyCode::Down,
        "left" => KeyCode::Left,
        "right" => KeyCode::Right,
        // Common keys
        "enter" => KeyCode::Enter,
        "esc" => KeyCode::Esc,
        "backspace" => KeyCode::Backspace,
        "tab" => KeyCode::Tab,
        "back_tab" => KeyCode::BackTab,
        // Navigation keys
        "home" => KeyCode::Home,
        "end" => KeyCode::End,
        "page_up" => KeyCode::PageUp,
        "page_down" => KeyCode::PageDown,
        "insert" => KeyCode::Insert,
        "delete" => KeyCode::Delete,
        // Lock keys
        "caps_lock" => KeyCode::CapsLock,
        "scroll_lock" => KeyCode::ScrollLock,
        "num_lock" => KeyCode::NumLock,
        // System keys
        "print_screen" => KeyCode::PrintScreen,
        "pause" => KeyCode::Pause,
        "menu" => KeyCode::Menu,
        "keypad_begin" => KeyCode::KeypadBegin,
        "null" => KeyCode::Null,
        // Dynamic parsing for media, modifiers, function keys, and characters
        s => {
            // Media keys (check first - "fast_forward" starts with 'f' but isn't F-key)
            if let Some(m) = parse_media_key(s) {
                KeyCode::Media(m)
            }
            // Modifier keys
            else if let Some(m) = parse_modifier_key(s) {
                KeyCode::Modifier(m)
            }
            // Function keys: f1, f2, ..., f12, etc.
            else if let Some(num_str) = s.strip_prefix('f') {
                if let Ok(n) = num_str.parse::<u8>() {
                    KeyCode::F(n)
                } else {
                    // "f" alone or invalid suffix - treat as character
                    KeyCode::Char(s.chars().next().unwrap_or('\0'))
                }
            }
            // Single character
            else if s.len() == 1 {
                KeyCode::Char(s.chars().next().unwrap())
            }
            // Unknown - default to Null
            else {
                KeyCode::Null
            }
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

pub fn poll_event(ruby: &magnus::Ruby, timeout_val: Option<f64>) -> Result<Value, Error> {
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

    if let Some(secs) = timeout_val {
        // Timed poll: wait up to the specified duration
        let duration = std::time::Duration::from_secs_f64(secs);
        if ratatui::crossterm::event::poll(duration)
            .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?
        {
            let event = ratatui::crossterm::event::read()
                .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;
            handle_event(event)
        } else {
            Ok(ruby.qnil().into_value_with(ruby))
        }
    } else {
        // Blocking: wait indefinitely for an event
        let event = ratatui::crossterm::event::read()
            .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;
        handle_event(event)
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

/// Converts `MediaKeyCode` to `snake_case` string.
fn media_key_to_string(m: ratatui::crossterm::event::MediaKeyCode) -> &'static str {
    use ratatui::crossterm::event::MediaKeyCode;
    match m {
        MediaKeyCode::Play => "play",
        MediaKeyCode::Pause => "media_pause", // Disambiguate from KeyCode::Pause
        MediaKeyCode::PlayPause => "play_pause",
        MediaKeyCode::Reverse => "reverse",
        MediaKeyCode::Stop => "stop",
        MediaKeyCode::FastForward => "fast_forward",
        MediaKeyCode::Rewind => "rewind",
        MediaKeyCode::TrackNext => "track_next",
        MediaKeyCode::TrackPrevious => "track_previous",
        MediaKeyCode::Record => "record",
        MediaKeyCode::LowerVolume => "lower_volume",
        MediaKeyCode::RaiseVolume => "raise_volume",
        MediaKeyCode::MuteVolume => "mute_volume",
    }
}

/// Converts `ModifierKeyCode` to `snake_case` string.
fn modifier_key_to_string(m: ratatui::crossterm::event::ModifierKeyCode) -> &'static str {
    use ratatui::crossterm::event::ModifierKeyCode;
    match m {
        ModifierKeyCode::LeftShift => "left_shift",
        ModifierKeyCode::LeftControl => "left_control",
        ModifierKeyCode::LeftAlt => "left_alt",
        ModifierKeyCode::LeftSuper => "left_super",
        ModifierKeyCode::LeftHyper => "left_hyper",
        ModifierKeyCode::LeftMeta => "left_meta",
        ModifierKeyCode::RightShift => "right_shift",
        ModifierKeyCode::RightControl => "right_control",
        ModifierKeyCode::RightAlt => "right_alt",
        ModifierKeyCode::RightSuper => "right_super",
        ModifierKeyCode::RightHyper => "right_hyper",
        ModifierKeyCode::RightMeta => "right_meta",
        ModifierKeyCode::IsoLevel3Shift => "iso_level3_shift",
        ModifierKeyCode::IsoLevel5Shift => "iso_level5_shift",
    }
}

fn handle_key_event(key: ratatui::crossterm::event::KeyEvent) -> Result<Value, Error> {
    use ratatui::crossterm::event::KeyCode;

    let ruby = magnus::Ruby::get().unwrap();
    if key.kind != ratatui::crossterm::event::KeyEventKind::Press {
        return Ok(ruby.qnil().into_value_with(&ruby));
    }
    let hash = ruby.hash_new();
    hash.aset(ruby.to_symbol("type"), ruby.to_symbol("key"))?;
    let code = match key.code {
        // Characters
        KeyCode::Char(c) => c.to_string(),
        // Arrow keys
        KeyCode::Up => "up".to_string(),
        KeyCode::Down => "down".to_string(),
        KeyCode::Left => "left".to_string(),
        KeyCode::Right => "right".to_string(),
        // Common keys
        KeyCode::Enter => "enter".to_string(),
        KeyCode::Esc => "esc".to_string(),
        KeyCode::Backspace => "backspace".to_string(),
        KeyCode::Tab => "tab".to_string(),
        KeyCode::BackTab => "back_tab".to_string(),
        // Navigation keys
        KeyCode::Home => "home".to_string(),
        KeyCode::End => "end".to_string(),
        KeyCode::PageUp => "page_up".to_string(),
        KeyCode::PageDown => "page_down".to_string(),
        KeyCode::Insert => "insert".to_string(),
        KeyCode::Delete => "delete".to_string(),
        // Function keys
        KeyCode::F(n) => format!("f{n}"),
        // Lock keys
        KeyCode::CapsLock => "caps_lock".to_string(),
        KeyCode::ScrollLock => "scroll_lock".to_string(),
        KeyCode::NumLock => "num_lock".to_string(),
        // System keys
        KeyCode::PrintScreen => "print_screen".to_string(),
        KeyCode::Pause => "pause".to_string(),
        KeyCode::Menu => "menu".to_string(),
        KeyCode::KeypadBegin => "keypad_begin".to_string(),
        KeyCode::Null => "null".to_string(),
        // Compound variants
        KeyCode::Media(m) => media_key_to_string(m).to_string(),
        KeyCode::Modifier(m) => modifier_key_to_string(m).to_string(),
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
