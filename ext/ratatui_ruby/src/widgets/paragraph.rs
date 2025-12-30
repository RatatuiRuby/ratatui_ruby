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

fn create_paragraph<'a>(node: Value, bump: &'a Bump) -> Result<Paragraph<'a>, Error> {
    let text_val: Value = node.funcall("text", ())?;
    let style_val: Value = node.funcall("style", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let wrap: bool = node.funcall("wrap", ())?;
    let alignment_opt: Option<Symbol> = node.funcall("alignment", ())?;
    let scroll_val: Value = node.funcall("scroll", ())?;

    let lines = parse_text(text_val)?;
    let style = parse_style(style_val)?;
    let mut paragraph = Paragraph::new(lines).style(style);

    if !block_val.is_nil() {
        paragraph = paragraph.block(parse_block(block_val, bump)?);
    }

    if wrap {
        paragraph = paragraph.wrap(Wrap { trim: true });
    }

    if let Some(alignment) = alignment_opt {
        match alignment.to_string().as_str() {
            "center" => paragraph = paragraph.alignment(HorizontalAlignment::Center),
            "right" => paragraph = paragraph.alignment(HorizontalAlignment::Right),
            _ => {}
        }
    }

    if !scroll_val.is_nil() {
        let scroll_array: Vec<u16> = Vec::<u16>::try_convert(scroll_val)?;
        if scroll_array.len() >= 2 {
            paragraph = paragraph.scroll((scroll_array[0], scroll_array[1]));
        }
    }

    Ok(paragraph)
}

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let bump = Bump::new();
    let paragraph = create_paragraph(node, &bump)?;
    frame.render_widget(paragraph, area);
    Ok(())
}

pub fn line_count(node: Value, width: u16) -> Result<usize, Error> {
    let bump = Bump::new();
    let paragraph = create_paragraph(node, &bump)?;
    Ok(paragraph.line_count(width))
}

pub fn line_width(node: Value) -> Result<usize, Error> {
    let bump = Bump::new();
    let paragraph = create_paragraph(node, &bump)?;
    Ok(paragraph.line_width())
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
