// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::parse_block;
use magnus::{prelude::*, Error, Symbol, Value};
use ratatui::{
    layout::Rect,
    widgets::{Scrollbar, ScrollbarOrientation, ScrollbarState},
    Frame,
};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let content_length: usize = node.funcall("content_length", ())?;
    let position: usize = node.funcall("position", ())?;
    let orientation_sym: Symbol = node.funcall("orientation", ())?;
    let thumb_symbol: String = node.funcall("thumb_symbol", ())?;
    let block_val: Value = node.funcall("block", ())?;

    let mut state = ScrollbarState::new(content_length).position(position);
    let mut scrollbar = Scrollbar::default().thumb_symbol(&thumb_symbol);

    scrollbar = match orientation_sym.to_string().as_str() {
        "horizontal" => scrollbar.orientation(ScrollbarOrientation::HorizontalBottom),
        _ => scrollbar.orientation(ScrollbarOrientation::VerticalRight),
    };

    if !block_val.is_nil() {
        let block = parse_block(block_val)?;
        let inner_area = block.inner(area);
        frame.render_widget(block, area);
        frame.render_stateful_widget(scrollbar, inner_area, &mut state);
    } else {
        frame.render_stateful_widget(scrollbar, area, &mut state);
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;
    use ratatui::widgets::StatefulWidget;

    #[test]
    fn test_scrollbar_vertical_render() {
        let mut buf = Buffer::empty(Rect::new(0, 0, 1, 5));
        let mut state = ScrollbarState::new(10).position(2);
        let scrollbar = Scrollbar::default().orientation(ScrollbarOrientation::VerticalRight);

        // Note: Scrollbar is stateful
        scrollbar.render(Rect::new(0, 0, 1, 5), &mut buf, &mut state);

        // Vertical scrollbar should render something in the first column
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
    }

    #[test]
    fn test_scrollbar_horizontal_render() {
        let mut buf = Buffer::empty(Rect::new(0, 0, 5, 1));
        let mut state = ScrollbarState::new(10).position(2);
        let scrollbar = Scrollbar::default().orientation(ScrollbarOrientation::HorizontalBottom);

        scrollbar.render(Rect::new(0, 0, 5, 1), &mut buf, &mut state);

        // Horizontal scrollbar should render something in the first row
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
    }
}
