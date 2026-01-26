// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::{Error, IntoValue, TryConvert, Value};
use std::cell::RefCell;

/// Wrapper enum for test events - includes crossterm events and our Sync event.
#[derive(Debug, Clone)]
enum TestEvent {
    Crossterm(ratatui::crossterm::event::Event),
    Sync,
}

thread_local! {
    static EVENT_QUEUE: RefCell<Vec<TestEvent>> = const { RefCell::new(Vec::new()) };
}

use ratatui::crossterm::event::{KeyCode, KeyModifiers, MediaKeyCode, ModifierKeyCode};

/// Single source of truth for base key code mappings.
const BASE_KEY_MAPPINGS: &[(&str, KeyCode)] = &[
    // Arrow keys
    ("up", KeyCode::Up),
    ("down", KeyCode::Down),
    ("left", KeyCode::Left),
    ("right", KeyCode::Right),
    // Common keys
    ("enter", KeyCode::Enter),
    ("esc", KeyCode::Esc),
    ("backspace", KeyCode::Backspace),
    ("tab", KeyCode::Tab),
    ("back_tab", KeyCode::BackTab),
    ("null", KeyCode::Null),
    // Navigation keys
    ("home", KeyCode::Home),
    ("end", KeyCode::End),
    ("page_up", KeyCode::PageUp),
    ("page_down", KeyCode::PageDown),
    ("insert", KeyCode::Insert),
    ("delete", KeyCode::Delete),
    // Lock keys
    ("caps_lock", KeyCode::CapsLock),
    ("scroll_lock", KeyCode::ScrollLock),
    ("num_lock", KeyCode::NumLock),
    // System keys
    ("print_screen", KeyCode::PrintScreen),
    ("pause", KeyCode::Pause),
    ("menu", KeyCode::Menu),
    ("keypad_begin", KeyCode::KeypadBegin),
];

/// Single source of truth for media key mappings.
const MEDIA_KEY_MAPPINGS: &[(&str, MediaKeyCode)] = &[
    ("media_play", MediaKeyCode::Play),
    ("media_pause", MediaKeyCode::Pause),
    ("media_play_pause", MediaKeyCode::PlayPause),
    ("media_reverse", MediaKeyCode::Reverse),
    ("media_stop", MediaKeyCode::Stop),
    ("media_fast_forward", MediaKeyCode::FastForward),
    ("media_rewind", MediaKeyCode::Rewind),
    ("media_track_next", MediaKeyCode::TrackNext),
    ("media_track_previous", MediaKeyCode::TrackPrevious),
    ("media_record", MediaKeyCode::Record),
    ("media_lower_volume", MediaKeyCode::LowerVolume),
    ("media_raise_volume", MediaKeyCode::RaiseVolume),
    ("media_mute_volume", MediaKeyCode::MuteVolume),
];

/// Single source of truth for modifier key mappings.
const MODIFIER_KEY_MAPPINGS: &[(&str, ModifierKeyCode)] = &[
    ("left_shift", ModifierKeyCode::LeftShift),
    ("left_control", ModifierKeyCode::LeftControl),
    ("left_alt", ModifierKeyCode::LeftAlt),
    ("left_super", ModifierKeyCode::LeftSuper),
    ("left_hyper", ModifierKeyCode::LeftHyper),
    ("left_meta", ModifierKeyCode::LeftMeta),
    ("right_shift", ModifierKeyCode::RightShift),
    ("right_control", ModifierKeyCode::RightControl),
    ("right_alt", ModifierKeyCode::RightAlt),
    ("right_super", ModifierKeyCode::RightSuper),
    ("right_hyper", ModifierKeyCode::RightHyper),
    ("right_meta", ModifierKeyCode::RightMeta),
    ("iso_level3_shift", ModifierKeyCode::IsoLevel3Shift),
    ("iso_level5_shift", ModifierKeyCode::IsoLevel5Shift),
];

/// Single source of truth for keyboard modifier flag mappings.
const KEYBOARD_MODIFIER_MAPPINGS: &[(&str, KeyModifiers)] = &[
    ("ctrl", KeyModifiers::CONTROL),
    ("alt", KeyModifiers::ALT),
    ("shift", KeyModifiers::SHIFT),
];

/// Returns all supported key codes for RBS generation.
pub fn all_key_codes() -> magnus::RHash {
    let ruby = magnus::Ruby::get().unwrap();
    let hash = ruby.hash_new();

    let base: Vec<&str> = BASE_KEY_MAPPINGS.iter().map(|(s, _)| *s).collect();
    let media: Vec<&str> = MEDIA_KEY_MAPPINGS.iter().map(|(s, _)| *s).collect();
    let modifier_keys: Vec<&str> = MODIFIER_KEY_MAPPINGS.iter().map(|(s, _)| *s).collect();
    let keyboard_modifiers: Vec<&str> =
        KEYBOARD_MODIFIER_MAPPINGS.iter().map(|(s, _)| *s).collect();

    let _ = hash.aset(ruby.to_symbol("base_keys"), base);
    let _ = hash.aset(ruby.to_symbol("media_keys"), media);
    let _ = hash.aset(ruby.to_symbol("modifier_keys"), modifier_keys);
    let _ = hash.aset(ruby.to_symbol("keyboard_modifiers"), keyboard_modifiers);

    hash
}

#[allow(clippy::needless_pass_by_value)]
pub fn inject_test_event(event_type: String, data: magnus::RHash) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let event = match event_type.as_str() {
        "key" => TestEvent::Crossterm(parse_key_event(data, &ruby)?),
        "mouse" => TestEvent::Crossterm(parse_mouse_event(data, &ruby)?),
        "resize" => TestEvent::Crossterm(parse_resize_event(data, &ruby)?),
        "paste" => TestEvent::Crossterm(parse_paste_event(data, &ruby)?),
        "focus_gained" => TestEvent::Crossterm(ratatui::crossterm::event::Event::FocusGained),
        "focus_lost" => TestEvent::Crossterm(ratatui::crossterm::event::Event::FocusLost),
        "sync" => TestEvent::Sync,
        _ => {
            return Err(Error::new(
                ruby.exception_arg_error(),
                format!("Unknown event type: {event_type}"),
            ))
        }
    };

    EVENT_QUEUE.with(|q| q.borrow_mut().push(event));
    Ok(())
}

fn parse_base_key(s: &str) -> Option<KeyCode> {
    BASE_KEY_MAPPINGS
        .iter()
        .find(|(key, _)| *key == s)
        .map(|(_, code)| *code)
}

fn parse_media_key(s: &str) -> Option<MediaKeyCode> {
    MEDIA_KEY_MAPPINGS
        .iter()
        .find(|(key, _)| *key == s)
        .map(|(_, code)| *code)
}

fn parse_modifier_key(s: &str) -> Option<ModifierKeyCode> {
    MODIFIER_KEY_MAPPINGS
        .iter()
        .find(|(key, _)| *key == s)
        .map(|(_, code)| *code)
}

fn parse_keyboard_modifier(s: &str) -> Option<KeyModifiers> {
    KEYBOARD_MODIFIER_MAPPINGS
        .iter()
        .find(|(key, _)| *key == s)
        .map(|(_, mods)| *mods)
}

fn parse_key_event(
    data: magnus::RHash,
    ruby: &magnus::Ruby,
) -> Result<ratatui::crossterm::event::Event, Error> {
    let code_val: Value = data
        .get(ruby.to_symbol("code"))
        .ok_or_else(|| Error::new(ruby.exception_arg_error(), "Missing 'code' in key event"))?;
    let code_str: String = String::try_convert(code_val)?;

    let code = if let Some(kc) = parse_base_key(&code_str) {
        kc
    } else if let Some(m) = parse_media_key(&code_str) {
        KeyCode::Media(m)
    } else if let Some(m) = parse_modifier_key(&code_str) {
        KeyCode::Modifier(m)
    } else if let Some(num_str) = code_str.strip_prefix('f') {
        if let Ok(n) = num_str.parse::<u8>() {
            KeyCode::F(n)
        } else {
            KeyCode::Char(code_str.chars().next().unwrap_or('\0'))
        }
    } else if code_str.len() == 1 {
        KeyCode::Char(code_str.chars().next().unwrap())
    } else {
        KeyCode::Null
    };

    let mut modifiers = KeyModifiers::empty();
    if let Some(mods_val) = data.get(ruby.to_symbol("modifiers")) {
        let mods: Vec<String> = Vec::try_convert(mods_val)?;
        for m in mods {
            if let Some(mod_flag) = parse_keyboard_modifier(&m) {
                modifiers |= mod_flag;
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
    EVENT_QUEUE.with(|q| q.borrow_mut().clear());
}

pub fn poll_event(ruby: &magnus::Ruby, timeout_val: Option<f64>) -> Result<Value, Error> {
    let event = EVENT_QUEUE.with(|q| {
        let mut queue = q.borrow_mut();
        if queue.is_empty() {
            None
        } else {
            Some(queue.remove(0))
        }
    });

    if let Some(e) = event {
        return handle_test_event(e);
    }

    let is_test_mode = crate::terminal::with_query(|q| q.is_test_mode()).unwrap_or(false);

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
            handle_crossterm_event(event)
        } else {
            Ok(ruby.qnil().into_value_with(ruby))
        }
    } else {
        // Blocking: wait indefinitely for an event
        let event = ratatui::crossterm::event::read()
            .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;
        handle_crossterm_event(event)
    }
}

fn handle_test_event(event: TestEvent) -> Result<Value, Error> {
    match event {
        TestEvent::Crossterm(e) => handle_crossterm_event(e),
        TestEvent::Sync => handle_sync_event(),
    }
}

fn handle_crossterm_event(event: ratatui::crossterm::event::Event) -> Result<Value, Error> {
    match event {
        ratatui::crossterm::event::Event::Key(key) => handle_key_event(key),
        ratatui::crossterm::event::Event::Mouse(event) => handle_mouse_event(event),
        ratatui::crossterm::event::Event::Resize(w, h) => handle_resize_event(w, h),
        ratatui::crossterm::event::Event::Paste(content) => handle_paste_event(content),
        ratatui::crossterm::event::Event::FocusGained => handle_focus_event("focus_gained"),
        ratatui::crossterm::event::Event::FocusLost => handle_focus_event("focus_lost"),
    }
}

fn handle_sync_event() -> Result<Value, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let hash = ruby.hash_new();
    hash.aset(ruby.to_symbol("type"), ruby.to_symbol("sync"))?;
    Ok(hash.into_value_with(&ruby))
}

fn media_key_to_string(m: MediaKeyCode) -> &'static str {
    MEDIA_KEY_MAPPINGS
        .iter()
        .find(|(_, code)| *code == m)
        .map_or("unknown", |(s, _)| *s)
}

fn modifier_key_to_string(m: ModifierKeyCode) -> &'static str {
    MODIFIER_KEY_MAPPINGS
        .iter()
        .find(|(_, code)| *code == m)
        .map_or("unknown", |(s, _)| *s)
}

fn base_key_to_string(kc: KeyCode) -> Option<&'static str> {
    BASE_KEY_MAPPINGS
        .iter()
        .find(|(_, code)| *code == kc)
        .map(|(s, _)| *s)
}

fn handle_key_event(key: ratatui::crossterm::event::KeyEvent) -> Result<Value, Error> {
    use ratatui::crossterm::event::KeyCode;

    let ruby = magnus::Ruby::get().unwrap();
    if key.kind != ratatui::crossterm::event::KeyEventKind::Press {
        return Ok(ruby.qnil().into_value_with(&ruby));
    }

    let hash = ruby.hash_new();
    hash.aset(ruby.to_symbol("type"), ruby.to_symbol("key"))?;

    // Determine the kind (category) of the key
    let kind = match key.code {
        KeyCode::Char(_)
        | KeyCode::Enter
        | KeyCode::Tab
        | KeyCode::Backspace
        | KeyCode::BackTab
        | KeyCode::Up
        | KeyCode::Down
        | KeyCode::Left
        | KeyCode::Right
        | KeyCode::Home
        | KeyCode::End
        | KeyCode::PageUp
        | KeyCode::PageDown
        | KeyCode::Insert
        | KeyCode::Delete
        | KeyCode::Null => "standard",
        KeyCode::F(_) => "function",
        KeyCode::Media(_) => "media",
        KeyCode::Modifier(_) => "modifier",
        KeyCode::Esc
        | KeyCode::CapsLock
        | KeyCode::ScrollLock
        | KeyCode::NumLock
        | KeyCode::PrintScreen
        | KeyCode::Pause
        | KeyCode::Menu
        | KeyCode::KeypadBegin => "system",
    };

    let code = if let KeyCode::Char(c) = key.code {
        c.to_string()
    } else if let KeyCode::F(n) = key.code {
        format!("f{n}")
    } else if let KeyCode::Media(m) = key.code {
        media_key_to_string(m).to_string()
    } else if let KeyCode::Modifier(m) = key.code {
        modifier_key_to_string(m).to_string()
    } else if let Some(s) = base_key_to_string(key.code) {
        s.to_string()
    } else {
        "unknown".to_string()
    };

    hash.aset(ruby.to_symbol("code"), code)?;
    hash.aset(ruby.to_symbol("kind"), ruby.to_symbol(kind))?;

    let mut modifiers = Vec::new();
    for (name, flag) in KEYBOARD_MODIFIER_MAPPINGS {
        if key.modifiers.contains(*flag) {
            modifiers.push(*name);
        }
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
