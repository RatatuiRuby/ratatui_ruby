// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use bumpalo::Bump;
use magnus::{prelude::*, Error, Value};
use ratatui::{layout::Rect, widgets::Gauge, Frame};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let arena = Bump::new();
    let ratio: f64 = node.funcall("ratio", ())?;
    let label_val: Value = node.funcall("label", ())?;
    let style_val: Value = node.funcall("style", ())?;
    let gauge_style_val: Value = node.funcall("gauge_style", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let use_unicode: bool = node.funcall("use_unicode", ())?;
    let mut gauge = Gauge::default().ratio(ratio).use_unicode(use_unicode);

    if !label_val.is_nil() {
        let label_str: String = label_val.funcall("to_s", ())?;
        gauge = gauge.label(label_str);
    }

    if !style_val.is_nil() {
        gauge = gauge.style(parse_style(style_val)?);
    }

    if !gauge_style_val.is_nil() {
        gauge = gauge.gauge_style(parse_style(gauge_style_val)?);
    }

    if !block_val.is_nil() {
        gauge = gauge.block(parse_block(block_val, &arena)?);
    }

    frame.render_widget(gauge, area);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;
    use ratatui::widgets::{Gauge, Widget};

    #[test]
    fn test_gauge_rendering() {
        let gauge = Gauge::default().ratio(0.5).label("50%");
        let mut buf = Buffer::empty(Rect::new(0, 0, 10, 1));
        gauge.render(Rect::new(0, 0, 10, 1), &mut buf);
        // Gauge renders block characters
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
        // Should contain label
        assert!(buf.content().iter().any(|c| c.symbol() == "5"));
        assert!(buf.content().iter().any(|c| c.symbol() == "%"));
    }
}
