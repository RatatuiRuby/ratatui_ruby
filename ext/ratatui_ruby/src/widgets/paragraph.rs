// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use magnus::{Error, Symbol, Value, prelude::*};
use ratatui::{
    layout::{Alignment, Rect},
    widgets::{Paragraph, Wrap},
    Frame,
};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let text: String = node.funcall("text", ())?;
    let style_val: Value = node.funcall("style", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let wrap: bool = node.funcall("wrap", ())?;
    let align_sym: Symbol = node.funcall("align", ())?;

    let style = parse_style(style_val)?;
    let mut paragraph = Paragraph::new(text).style(style);

    if !block_val.is_nil() {
        paragraph = paragraph.block(parse_block(block_val)?);
    }

    if wrap {
        paragraph = paragraph.wrap(Wrap { trim: true });
    }

    match align_sym.to_string().as_str() {
        "center" => paragraph = paragraph.alignment(Alignment::Center),
        "right" => paragraph = paragraph.alignment(Alignment::Right),
        _ => {}
    }

    frame.render_widget(paragraph, area);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;

    #[test]
    fn test_paragraph_compile() {
        // Simple compilation check that Paragraph is used correctly
        let p = Paragraph::new("test");
        let mut buf = Buffer::empty(Rect::new(0, 0, 10, 1));
        use ratatui::widgets::Widget;
        p.render(Rect::new(0, 0, 10, 1), &mut buf);
        assert_eq!(buf.content()[0].symbol(), "t");
    }
}
