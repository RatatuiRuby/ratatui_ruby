// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::{prelude::*, Error, Symbol, Value};
use ratatui::{
    style::{Color, Modifier, Style},
    widgets::{Block, Borders},
};

pub fn parse_color(color_str: &str) -> Option<Color> {
    color_str.parse::<Color>().ok()
}

pub fn parse_style(style_val: Value) -> Result<Style, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    if style_val.is_nil() {
        return Ok(Style::default());
    }

    let mut style = Style::default();

    let fg: Value = style_val.funcall("fg", ())?;
    if !fg.is_nil() {
        let fg_str: String = fg.funcall("to_s", ())?;
        if let Some(color) = parse_color(&fg_str) {
            style = style.fg(color);
        }
    }

    let bg: Value = style_val.funcall("bg", ())?;
    if !bg.is_nil() {
        let bg_str: String = bg.funcall("to_s", ())?;
        if let Some(color) = parse_color(&bg_str) {
            style = style.bg(color);
        }
    }

    let modifiers_val: Value = style_val.funcall("modifiers", ())?;
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

pub fn parse_block(block_val: Value) -> Result<Block<'static>, Error> {
    if block_val.is_nil() {
        return Ok(Block::default());
    }

    let title: Value = block_val.funcall("title", ())?;
    let borders_val: Value = block_val.funcall("borders", ())?;
    let border_color: Value = block_val.funcall("border_color", ())?;

    let mut block = Block::default();

    if !title.is_nil() {
        let title_str: String = title.funcall("to_s", ())?;
        block = block.title(title_str);
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

    if !border_color.is_nil() {
        let color_str: String = border_color.funcall("to_s", ())?;
        if let Some(color) = parse_color(&color_str) {
            block = block.border_style(Style::default().fg(color));
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
