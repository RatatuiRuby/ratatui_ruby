// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use magnus::{prelude::*, Error, Value};
use ratatui::{layout::Rect, widgets::LineGauge, Frame};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let ratio: f64 = node.funcall("ratio", ())?;
    let label_val: Value = node.funcall("label", ())?;
    let filled_style_val: Value = node.funcall("filled_style", ())?;
    let unfilled_style_val: Value = node.funcall("unfilled_style", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let filled_symbol_val: String = node.funcall("filled_symbol", ())?;
    let unfilled_symbol_val: String = node.funcall("unfilled_symbol", ())?;

    let mut gauge = LineGauge::default()
        .ratio(ratio)
        .filled_symbol(&filled_symbol_val)
        .unfilled_symbol(&unfilled_symbol_val);

    if !label_val.is_nil() {
        let label_str: String = label_val.funcall("to_s", ())?;
        gauge = gauge.label(label_str);
    }

    if !filled_style_val.is_nil() {
        let parsed_style = parse_style(filled_style_val)?;
        gauge = gauge.filled_style(parsed_style);
    }

    if !unfilled_style_val.is_nil() {
        let parsed_style = parse_style(unfilled_style_val)?;
        gauge = gauge.unfilled_style(parsed_style);
    }

    if !block_val.is_nil() {
        gauge = gauge.block(parse_block(block_val)?);
    }

    frame.render_widget(gauge, area);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;
    use ratatui::widgets::{LineGauge, Widget};

    #[test]
    fn test_line_gauge_rendering() {
        let gauge = LineGauge::default().ratio(0.5).label("50%");
        let mut buf = Buffer::empty(Rect::new(0, 0, 20, 1));
        gauge.render(Rect::new(0, 0, 20, 1), &mut buf);
        // LineGauge renders filled and unfilled characters
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
        // Should contain label
        assert!(buf.content().iter().any(|c| c.symbol() == "5"));
        assert!(buf.content().iter().any(|c| c.symbol() == "%"));
    }

    #[test]
    fn test_line_gauge_zero_ratio() {
        let gauge = LineGauge::default().ratio(0.0);
        let mut buf = Buffer::empty(Rect::new(0, 0, 10, 1));
        gauge.render(Rect::new(0, 0, 10, 1), &mut buf);
        // At zero ratio, should mostly show unfilled character
        let unfilled_count = buf
            .content()
            .iter()
            .filter(|c| c.symbol() == "░" || c.symbol() == " ")
            .count();
        assert!(unfilled_count > 0);
    }

    #[test]
    fn test_line_gauge_full_ratio() {
        let gauge = LineGauge::default().ratio(1.0).label("100%");
        let mut buf = Buffer::empty(Rect::new(0, 0, 20, 1));
        gauge.render(Rect::new(0, 0, 20, 1), &mut buf);
        // At full ratio, should show some non-space characters (filled or partial)
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
    }
}
