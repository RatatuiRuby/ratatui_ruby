// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::parse_block;
use bumpalo::Bump;
use magnus::{prelude::*, Error, Value};
use ratatui::{layout::Rect, widgets::RatatuiMascot, Frame};

pub fn render_ratatui_mascot(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let block_val: Value = node.funcall("block", ())?;

    let mut inner_area = area;

    if !block_val.is_nil() {
        let bump = Bump::new();
        let block = parse_block(block_val, &bump)?;
        inner_area = block.inner(area);
        frame.render_widget(block, area);
    }

    let widget = RatatuiMascot::new();
    frame.render_widget(widget, inner_area);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::{buffer::Buffer, layout::Rect, widgets::Widget};

    #[test]
    fn test_render() {
        let mut buffer = Buffer::empty(Rect::new(0, 0, 50, 20));
        let widget = RatatuiMascot::new();
        widget.render(Rect::new(0, 0, 50, 20), &mut buffer);

        let content = buffer
            .content()
            .iter()
            .map(|c| c.symbol())
            .collect::<String>();

        // The mascot uses block drawing characters
        assert!(
            content.contains("█"),
            "Mascot rendering should contain block characters"
        );
        assert!(!content.trim().is_empty());
    }
}
