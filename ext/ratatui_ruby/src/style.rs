// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::{prelude::*, Error, Symbol, Value};
use ratatui::{
    style::{Color, Modifier, Style},
    text::Line,
    widgets::{Block, BorderType, Borders, Padding},
    layout::Alignment,
    symbols,
};
use std::collections::HashSet;
use std::sync::RwLock;

lazy_static::lazy_static! {
    static ref BORDER_STRING_INTERNER: RwLock<HashSet<&'static str>> = RwLock::new(HashSet::new());
}

fn intern_string(s: &str) -> &'static str {
    // fast path: check if string is already interned
    {
        let reader = BORDER_STRING_INTERNER.read().unwrap();
        if let Some(&interned) = reader.get(s) {
            return interned;
        }
    }

    // slow path: intern string
    let mut writer = BORDER_STRING_INTERNER.write().unwrap();
    if let Some(&interned) = writer.get(s) {
        // another thread might have interned it in the meantime
        return interned;
    }

    let leaked = Box::leak(s.to_string().into_boxed_str());
    writer.insert(leaked);
    leaked
}

pub fn parse_color(color_str: &str) -> Option<Color> {
    color_str.parse::<Color>().ok()
}

pub fn parse_color_value(val: Value) -> Result<Option<Color>, Error> {
    if val.is_nil() {
        return Ok(None);
    }
    let s: String = val.funcall("to_s", ())?;
    Ok(parse_color(&s))
}

pub fn parse_modifier_str(s: &str) -> Option<Modifier> {
    match s {
        "bold" => Some(Modifier::BOLD),
        "italic" => Some(Modifier::ITALIC),
        "dim" => Some(Modifier::DIM),
        "reversed" => Some(Modifier::REVERSED),
        "underlined" => Some(Modifier::UNDERLINED),
        "slow_blink" => Some(Modifier::SLOW_BLINK),
        "rapid_blink" => Some(Modifier::RAPID_BLINK),
        "crossed_out" => Some(Modifier::CROSSED_OUT),
        "hidden" => Some(Modifier::HIDDEN),
        _ => None,
    }
}

pub fn parse_style(style_val: Value) -> Result<Style, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    if style_val.is_nil() {
        return Ok(Style::default());
    }

    let mut style = Style::default();

    let fg: Value;
    let bg: Value;
    let modifiers_val: Value;

    if let Some(hash) = magnus::RHash::from_value(style_val) {
        let fg_sym = ruby.to_symbol("fg");
        let bg_sym = ruby.to_symbol("bg");
        let mod_sym = ruby.to_symbol("modifiers");

        fg = hash.lookup(fg_sym).unwrap_or(ruby.qnil().as_value());
        bg = hash.lookup(bg_sym).unwrap_or(ruby.qnil().as_value());
        modifiers_val = hash.lookup(mod_sym).unwrap_or(ruby.qnil().as_value());
    } else {
        fg = style_val.funcall("fg", ())?;
        bg = style_val.funcall("bg", ())?;
        modifiers_val = style_val.funcall("modifiers", ())?;
    }

    if !fg.is_nil() {
        let fg_str: String = fg.funcall("to_s", ())?;
        if let Some(color) = parse_color(&fg_str) {
            style = style.fg(color);
        }
    }

    if !bg.is_nil() {
        let bg_str: String = bg.funcall("to_s", ())?;
        if let Some(color) = parse_color(&bg_str) {
            style = style.bg(color);
        }
    }

    if !modifiers_val.is_nil() {
        let modifiers_array = magnus::RArray::from_value(modifiers_val).ok_or_else(|| {
            Error::new(
                ruby.exception_type_error(),
                "expected array for modifiers",
            )
        })?;

        for i in 0..modifiers_array.len() {
            let sym: Symbol = modifiers_array.entry(i as isize)?;
            match sym.to_string().as_str() {
                "bold" => style = style.add_modifier(Modifier::BOLD),
                "italic" => style = style.add_modifier(Modifier::ITALIC),
                "dim" => style = style.add_modifier(Modifier::DIM),
                "reversed" => style = style.add_modifier(Modifier::REVERSED),
                "underlined" => style = style.add_modifier(Modifier::UNDERLINED),
                "slow_blink" => style = style.add_modifier(Modifier::SLOW_BLINK),
                "rapid_blink" => style = style.add_modifier(Modifier::RAPID_BLINK),
                "crossed_out" => style = style.add_modifier(Modifier::CROSSED_OUT),
                "hidden" => style = style.add_modifier(Modifier::HIDDEN),
                _ => {}
            }
        }
    }

    Ok(style)
}

pub fn parse_border_set(set_val: Value) -> Result<symbols::border::Set<'static>, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let hash = magnus::RHash::from_value(set_val).ok_or_else(|| {
        Error::new(ruby.exception_type_error(), "expected hash for border_set")
    })?;

    let get_char = |key: &str| -> Result<Option<&str>, Error> {
        let sym = ruby.to_symbol(key);
        let mut val: Value = hash.lookup(sym).unwrap_or(ruby.qnil().as_value());

        if val.is_nil() {
            let str_key = ruby.str_new(key);
            val = hash.lookup(str_key).unwrap_or(ruby.qnil().as_value());
        }

        if val.is_nil() {
            Ok(None)
        } else {
            let s: String = val.funcall("to_s", ())?;
            Ok(Some(intern_string(&s)))
        }
    };

    let mut set = symbols::border::Set::default();
    
    if let Some(s) = get_char("top_left")? { set.top_left = s; }
    if let Some(s) = get_char("top_right")? { set.top_right = s; }
    if let Some(s) = get_char("bottom_left")? { set.bottom_left = s; }
    if let Some(s) = get_char("bottom_right")? { set.bottom_right = s; }
    if let Some(s) = get_char("vertical_left")? { set.vertical_left = s; }
    if let Some(s) = get_char("vertical_right")? { set.vertical_right = s; }
    if let Some(s) = get_char("horizontal_top")? { set.horizontal_top = s; }
    if let Some(s) = get_char("horizontal_bottom")? { set.horizontal_bottom = s; }

    Ok(set)
}

pub fn parse_block(block_val: Value) -> Result<Block<'static>, Error> {
    if block_val.is_nil() {
        return Ok(Block::default());
    }

    let title: Value = block_val.funcall("title", ())?;
    let title_alignment: Value = block_val.funcall("title_alignment", ())?;
    let title_style_val: Value = block_val.funcall("title_style", ())?;
    let borders_val: Value = block_val.funcall("borders", ())?;
    let border_color: Value = block_val.funcall("border_color", ())?;
    let border_style_val: Value = block_val.funcall("border_style", ())?;
    let border_type_val: Value = block_val.funcall("border_type", ())?;
    let border_set_val: Value = block_val.funcall("border_set", ())?;
    let style_val: Value = block_val.funcall("style", ())?;
    let padding_val: Value = block_val.funcall("padding", ())?;

    let mut block = Block::default();

    if !style_val.is_nil() {
        block = block.style(crate::style::parse_style(style_val)?);
    }

    if !title_style_val.is_nil() {
        block = block.title_style(crate::style::parse_style(title_style_val)?);
    }

    if !title.is_nil() {
        let title_str: String = title.funcall("to_s", ())?;
        block = block.title(Line::from(title_str));
    }

    if !title_alignment.is_nil() {
        if let Some(align_sym) = Symbol::from_value(title_alignment) {
            match align_sym.to_string().as_str() {
                "left" => block = block.title_alignment(Alignment::Left),
                "center" => block = block.title_alignment(Alignment::Center),
                "right" => block = block.title_alignment(Alignment::Right),
                _ => {}
            }
        }
    }

    let titles_val: Value = block_val.funcall("titles", ())?;
    if !titles_val.is_nil() {
        if let Some(titles_array) = magnus::RArray::from_value(titles_val) {
            for i in 0..titles_array.len() {
                let title_item: Value = titles_array.entry(i as isize)?;
                
                // Defaults
                let mut content = String::new();
                let mut alignment = Alignment::Left;
                let mut position = "top"; // "top" or "bottom"
                let mut title_style = Style::default();

                if let Some(hash) = magnus::RHash::from_value(title_item) {
                     let ruby = magnus::Ruby::get().unwrap();
                     let content_sym = ruby.to_symbol("content");
                     let align_sym_key = ruby.to_symbol("alignment");
                     let pos_sym_key = ruby.to_symbol("position");
                     let style_sym_key = ruby.to_symbol("style");

                     let content_val: Value = hash.lookup(content_sym).unwrap_or(ruby.qnil().as_value());
                     if !content_val.is_nil() {
                        content = content_val.funcall("to_s", ())?;
                     }

                     let align_val: Value = hash.lookup(align_sym_key).unwrap_or(ruby.qnil().as_value());
                     if let Some(align_sym) = Symbol::from_value(align_val) {
                        match align_sym.to_string().as_str() {
                            "left" => alignment = Alignment::Left,
                            "center" => alignment = Alignment::Center,
                            "right" => alignment = Alignment::Right,
                            _ => {}
                        }
                     }

                     let pos_val: Value = hash.lookup(pos_sym_key).unwrap_or(ruby.qnil().as_value());
                     if let Some(pos_sym) = Symbol::from_value(pos_val) {
                         if pos_sym.to_string().as_str() == "bottom" {
                             position = "bottom";
                         }
                     }

                     let style_val: Value = hash.lookup(style_sym_key).unwrap_or(ruby.qnil().as_value());
                     if !style_val.is_nil() {
                         title_style = crate::style::parse_style(style_val)?;
                     }
                } else {
                    // Assume it's a string
                    content = title_item.funcall("to_s", ())?;
                }

                let line = Line::from(content).alignment(alignment).style(title_style);
                
                if position == "bottom" {
                    block = block.title_bottom(line);
                } else {
                    block = block.title_top(line);
                }
            }
        }
    }

    if !borders_val.is_nil() {
        let mut ratatui_borders = Borders::NONE;
        if let Some(sym) = Symbol::from_value(borders_val) {
            match sym.to_string().as_str() {
                "all" => ratatui_borders = Borders::ALL,
                "top" => ratatui_borders = Borders::TOP,
                "bottom" => ratatui_borders = Borders::BOTTOM,
                "left" => ratatui_borders = Borders::LEFT,
                "right" => ratatui_borders = Borders::RIGHT,
                _ => {}
            }
        } else if let Some(borders_array) = magnus::RArray::from_value(borders_val) {
            for i in 0..borders_array.len() {
                let sym: Symbol = borders_array.entry(i as isize)?;
                match sym.to_string().as_str() {
                    "all" => ratatui_borders |= Borders::ALL,
                    "top" => ratatui_borders |= Borders::TOP,
                    "bottom" => ratatui_borders |= Borders::BOTTOM,
                    "left" => ratatui_borders |= Borders::LEFT,
                    "right" => ratatui_borders |= Borders::RIGHT,
                    _ => {}
                }
            }
        }
        block = block.borders(ratatui_borders);
    }

    // Apply border style. If both border_style and border_color are provided, border_style takes precedence.
    if !border_style_val.is_nil() {
        let border_style = crate::style::parse_style(border_style_val)?;
        block = block.border_style(border_style);
    } else if !border_color.is_nil() {
        // Fallback to border_color for backward compatibility
        let color_str: String = border_color.funcall("to_s", ())?;
        if let Some(color) = parse_color(&color_str) {
            block = block.border_style(Style::default().fg(color));
        }
    }

    if !border_set_val.is_nil() {
        block = block.border_set(parse_border_set(border_set_val)?);
    } else     if !border_type_val.is_nil() {
        if let Some(sym) = Symbol::from_value(border_type_val) {
            match sym.to_string().as_str() {
                "plain" => block = block.border_type(BorderType::Plain),
                "rounded" => block = block.border_type(BorderType::Rounded),
                "double" => block = block.border_type(BorderType::Double),
                "thick" => block = block.border_type(BorderType::Thick),
                "quadrant_inside" => block = block.border_type(BorderType::QuadrantInside),
                "quadrant_outside" => block = block.border_type(BorderType::QuadrantOutside),
                _ => {}
            }
        }
    }

    if !padding_val.is_nil() {
        if let Ok(padding) = u16::try_convert(padding_val) {
            block = block.padding(Padding::uniform(padding));
        } else if let Some(padding_array) = magnus::RArray::from_value(padding_val) {
            if padding_array.len() == 4 {
                let left: u16 = padding_array.entry(0).unwrap_or(0);
                let right: u16 = padding_array.entry(1).unwrap_or(0);
                let top: u16 = padding_array.entry(2).unwrap_or(0);
                let bottom: u16 = padding_array.entry(3).unwrap_or(0);
                block = block.padding(Padding::new(left, right, top, bottom));
            }
        }
    }

    Ok(block)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_color() {
        assert_eq!(parse_color("red"), Some(Color::Red));
        assert_eq!(parse_color("blue"), Some(Color::Blue));
        assert_eq!(parse_color("black"), Some(Color::Black));
        assert_eq!(parse_color("white"), Some(Color::White));
        assert_eq!(parse_color("green"), Some(Color::Green));
        assert_eq!(parse_color("yellow"), Some(Color::Yellow));
        assert_eq!(parse_color("magenta"), Some(Color::Magenta));
        assert_eq!(parse_color("cyan"), Some(Color::Cyan));
        assert_eq!(parse_color("gray"), Some(Color::Gray));
        assert_eq!(parse_color("dark_gray"), Some(Color::DarkGray));
        assert_eq!(parse_color("light_red"), Some(Color::LightRed));
        assert_eq!(parse_color("light_green"), Some(Color::LightGreen));
        assert_eq!(parse_color("light_yellow"), Some(Color::LightYellow));
        assert_eq!(parse_color("light_blue"), Some(Color::LightBlue));
        assert_eq!(parse_color("light_magenta"), Some(Color::LightMagenta));
        assert_eq!(parse_color("light_cyan"), Some(Color::LightCyan));

        assert_eq!(parse_color("#ffffff"), Some(Color::Rgb(255, 255, 255)));
        assert_eq!(parse_color("#000000"), Some(Color::Rgb(0, 0, 0)));
        assert_eq!(parse_color("#FF0000"), Some(Color::Rgb(255, 0, 0)));

        assert_eq!(parse_color("invalid"), None);
        assert_eq!(parse_color(""), None);
    }
}
