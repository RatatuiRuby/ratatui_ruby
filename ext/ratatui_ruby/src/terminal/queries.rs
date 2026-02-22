// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Terminal query functions (read-only access to terminal state).

use magnus::value::ReprValue;
use magnus::{Error, Module, Value};

use super::TerminalWrapper;

pub fn get_buffer_content() -> Result<String, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    // This function builds a string from all cells - we need direct terminal access
    crate::terminal::with_terminal_mut(|wrapper| {
        if let TerminalWrapper::Test(terminal) = wrapper {
            let buffer = terminal.backend().buffer();
            let area = buffer.area;
            let mut result = String::new();
            for y in 0..area.height {
                // SPDX-SnippetBegin
                // SPDX-License-Identifier: MIT
                // SPDX-SnippetCopyrightText: The Ratatui Developers
                // Derived from ratatui-core/src/buffer/buffer.rs (Buffer Debug impl)
                let mut skip: usize = 0;
                for x in 0..area.width {
                    if skip > 0 {
                        skip -= 1;
                        continue;
                    }
                    let cell = buffer.cell((x, y)).unwrap();
                    let symbol = cell.symbol();
                    result.push_str(symbol);
                    // Skip continuation cells after wide characters (e.g. emoji, CJK).
                    // Ratatui's set_stringn resets these to " ", but they don't represent
                    // an additional display column — the preceding wide symbol covers them.
                    let width = ratatui::text::Text::raw(symbol).width();
                    if width > 1 {
                        skip = width - 1;
                    }
                }
                // SPDX-SnippetEnd
                result.push('\n');
            }
            Ok(result)
        } else {
            let module = ruby.define_module("RatatuiRuby").unwrap();
            let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
            let error_class = error_base.const_get("Terminal").unwrap();
            Err(Error::new(
                error_class,
                "Terminal is not initialized as TestBackend",
            ))
        }
    })
    .unwrap_or_else(|| {
        let module = ruby.define_module("RatatuiRuby").unwrap();
        let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
        let error_class = error_base.const_get("Terminal").unwrap();
        Err(Error::new(error_class, "Terminal is not initialized"))
    })
}

pub fn get_terminal_area() -> Result<magnus::RHash, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    crate::terminal::with_query(|q| {
        let area = q.viewport_area();
        let hash = ruby.hash_new();
        hash.aset("x", area.x).unwrap();
        hash.aset("y", area.y).unwrap();
        hash.aset("width", area.width).unwrap();
        hash.aset("height", area.height).unwrap();
        Ok(hash)
    })
    .unwrap_or_else(|| {
        let module = ruby.define_module("RatatuiRuby").unwrap();
        let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
        let error_class = error_base.const_get("Terminal").unwrap();
        Err(Error::new(error_class, "Terminal is not initialized"))
    })
}

/// Returns the full terminal backend size (not the viewport)
pub fn get_terminal_size() -> Result<magnus::RHash, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    crate::terminal::with_query(|q| {
        let size = q.size();
        let hash = ruby.hash_new();
        hash.aset("x", 0).unwrap();
        hash.aset("y", 0).unwrap();
        hash.aset("width", size.width).unwrap();
        hash.aset("height", size.height).unwrap();
        Ok(hash)
    })
    .unwrap_or_else(|| {
        let module = ruby.define_module("RatatuiRuby").unwrap();
        let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
        let error_class = error_base.const_get("Terminal").unwrap();
        Err(Error::new(error_class, "Terminal is not initialized"))
    })
}

pub fn get_viewport_type() -> Result<String, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    crate::terminal::with_query(|q| {
        let viewport = q.viewport_area();
        let size = q.size();
        if viewport.height < size.height {
            Ok("inline".to_string())
        } else {
            Ok("fullscreen".to_string())
        }
    })
    .unwrap_or_else(|| {
        let module = ruby.define_module("RatatuiRuby").unwrap();
        let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
        let error_class = error_base.const_get("Terminal").unwrap();
        Err(Error::new(error_class, "Terminal not initialized"))
    })
}

pub fn get_cursor_position() -> Result<Option<(u16, u16)>, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    crate::terminal::with_query(|q| Ok(q.cursor_position())).unwrap_or_else(|| {
        let module = ruby.define_module("RatatuiRuby").unwrap();
        let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
        let error_class = error_base.const_get("Terminal").unwrap();
        Err(Error::new(
            error_class,
            "Terminal is not initialized as TestBackend",
        ))
    })
}

pub fn get_cell_at(x: u16, y: u16) -> Result<magnus::RHash, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    crate::terminal::with_query(|q| {
        if let Some(cell) = q.cell_at(x, y) {
            let hash = ruby.hash_new();
            hash.aset("char", cell.symbol()).unwrap();
            hash.aset("fg", color_to_value(cell.fg)).unwrap();
            hash.aset("bg", color_to_value(cell.bg)).unwrap();
            hash.aset("underline_color", color_to_value(cell.underline_color))
                .unwrap();
            hash.aset("modifiers", modifiers_to_value(cell.modifier))
                .unwrap();
            Ok(hash)
        } else {
            let module = ruby.define_module("RatatuiRuby").unwrap();
            let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
            let error_class = error_base.const_get("Terminal").unwrap();
            Err(Error::new(
                error_class,
                format!("Coordinates ({x}, {y}) out of bounds"),
            ))
        }
    })
    .unwrap_or_else(|| {
        let module = ruby.define_module("RatatuiRuby").unwrap();
        let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
        let error_class = error_base.const_get("Terminal").unwrap();
        Err(Error::new(
            error_class,
            "Terminal is not initialized as TestBackend",
        ))
    })
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

/// Returns the number of frames that have been drawn
pub fn frame_count() -> Result<usize, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    crate::terminal::with_query(|q| Ok(q.frame_count())).unwrap_or_else(|| {
        let module = ruby.define_module("RatatuiRuby").unwrap();
        let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
        let error_class = error_base.const_get("Invariant").unwrap();
        Err(Error::new(
            error_class,
            "Cannot query frame_count: terminal not initialized. Use RatatuiRuby.run or call init_terminal first.",
        ))
    })
}
