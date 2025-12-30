// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::parse_block;
use bumpalo::Bump;
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
    
    let thumb_symbol_val: Value = node.funcall("thumb_symbol", ())?;
    let thumb_style_val: Value = node.funcall("thumb_style", ())?;
    let track_symbol_val: Value = node.funcall("track_symbol", ())?;
    let track_style_val: Value = node.funcall("track_style", ())?;
    let begin_symbol_val: Value = node.funcall("begin_symbol", ())?;
    let begin_style_val: Value = node.funcall("begin_style", ())?;
    let end_symbol_val: Value = node.funcall("end_symbol", ())?;
    let end_style_val: Value = node.funcall("end_style", ())?;
    let style_val: Value = node.funcall("style", ())?;

    let block_val: Value = node.funcall("block", ())?;

    let mut state = ScrollbarState::new(content_length).position(position);
    let mut scrollbar = Scrollbar::default();

    scrollbar = match orientation_sym.to_string().as_str() {
        "vertical_left" => scrollbar.orientation(ScrollbarOrientation::VerticalLeft),
        "horizontal_bottom" | "horizontal" => scrollbar.orientation(ScrollbarOrientation::HorizontalBottom),
        "horizontal_top" => scrollbar.orientation(ScrollbarOrientation::HorizontalTop),
        _ => scrollbar.orientation(ScrollbarOrientation::VerticalRight),
    };

    // Hoisted strings to extend lifetime
    let thumb_str: String;
    let track_str: String;
    let begin_str: String;
    let end_str: String;

    if !thumb_symbol_val.is_nil() {
        thumb_str = thumb_symbol_val.funcall("to_s", ())?;
        scrollbar = scrollbar.thumb_symbol(&thumb_str);
    }
    if !thumb_style_val.is_nil() {
        scrollbar = scrollbar.thumb_style(crate::style::parse_style(thumb_style_val)?);
    }
    if !track_symbol_val.is_nil() {
        track_str = track_symbol_val.funcall("to_s", ())?;
        scrollbar = scrollbar.track_symbol(Some(&track_str));
    }
    if !track_style_val.is_nil() {
        scrollbar = scrollbar.track_style(crate::style::parse_style(track_style_val)?);
    }
    if !begin_symbol_val.is_nil() {
        begin_str = begin_symbol_val.funcall("to_s", ())?;
        scrollbar = scrollbar.begin_symbol(Some(&begin_str));
    }
    if !begin_style_val.is_nil() {
        scrollbar = scrollbar.begin_style(crate::style::parse_style(begin_style_val)?);
    }
    if !end_symbol_val.is_nil() {
        end_str = end_symbol_val.funcall("to_s", ())?;
        scrollbar = scrollbar.end_symbol(Some(&end_str));
    }
    if !end_style_val.is_nil() {
        scrollbar = scrollbar.end_style(crate::style::parse_style(end_style_val)?);
    }
    if !style_val.is_nil() {
        scrollbar = scrollbar.style(crate::style::parse_style(style_val)?);
    }

    if block_val.is_nil() {
        frame.render_stateful_widget(scrollbar, area, &mut state);
    } else {
        let bump = Bump::new();
        let block = parse_block(block_val, &bump)?;
        let inner_area = block.inner(area);
        frame.render_widget(block, area);
        frame.render_stateful_widget(scrollbar, inner_area, &mut state);
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
