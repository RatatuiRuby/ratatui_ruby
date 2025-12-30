// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use bumpalo::Bump;
use magnus::{prelude::*, Error, Symbol, Value};
use ratatui::{
    layout::{HorizontalAlignment, Rect},
    widgets::{Paragraph, Wrap},
    Frame,
};

use crate::text::parse_text;

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let arena = Bump::new();
    let text_val: Value = node.funcall("text", ())?;
    let style_val: Value = node.funcall("style", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let wrap: bool = node.funcall("wrap", ())?;
    let align_sym: Symbol = node.funcall("align", ())?;
    let scroll_val: Value = node.funcall("scroll", ())?;

    let lines = parse_text(text_val)?;
    let style = parse_style(style_val)?;
    let mut paragraph = Paragraph::new(lines).style(style);

    if !block_val.is_nil() {
        paragraph = paragraph.block(parse_block(block_val, &arena)?);
    }

    if wrap {
        paragraph = paragraph.wrap(Wrap { trim: true });
    }

    match align_sym.to_string().as_str() {
        "center" => paragraph = paragraph.alignment(HorizontalAlignment::Center),
        "right" => paragraph = paragraph.alignment(HorizontalAlignment::Right),
        _ => {}
    }

    // Apply scroll offset if provided
    // Ruby passes (y, x) array matching ratatui's convention
    if !scroll_val.is_nil() {
        let scroll_array: Vec<u16> = Vec::<u16>::try_convert(scroll_val)?;
        if scroll_array.len() >= 2 {
            paragraph = paragraph.scroll((scroll_array[0], scroll_array[1]));
        }
    }

    frame.render_widget(paragraph, area);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;

    #[test]
    fn test_paragraph_rendering() {
        let p = Paragraph::new("test content").alignment(HorizontalAlignment::Center);
        let mut buf = Buffer::empty(Rect::new(0, 0, 20, 1));
        use ratatui::widgets::Widget;
        p.render(Rect::new(0, 0, 20, 1), &mut buf);
        let content = buf.content().iter().map(|c| c.symbol()).collect::<String>();
        assert!(content.contains("test content"));
        // Check for centered alignment (should have leading spaces)
        assert!(content.starts_with(' '));
    }
}
