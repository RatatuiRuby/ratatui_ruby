// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use magnus::{prelude::*, Error, RString, Value};
use ratatui::{layout::Rect, widgets::Sparkline, widgets::RenderDirection, Frame};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let data_val: magnus::RArray = node.funcall("data", ())?;
    let max_val: Value = node.funcall("max", ())?;
    let style_val: Value = node.funcall("style", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let direction_val: Value = node.funcall("direction", ())?;
    let absent_value_symbol_val: Value = node.funcall("absent_value_symbol", ())?;
    let absent_value_style_val: Value = node.funcall("absent_value_style", ())?;

    let mut data_vec = Vec::new();
    for i in 0..data_val.len() {
        let val: Value = data_val.entry(i as isize)?;
        if val.is_nil() {
            data_vec.push(None);
        } else {
            let num: u64 = u64::try_convert(val)?;
            data_vec.push(Some(num));
        }
    }

    let mut sparkline = Sparkline::default().data(&data_vec);

    if !max_val.is_nil() {
        let max: u64 = u64::try_convert(max_val)?;
        sparkline = sparkline.max(max);
    }

    if !style_val.is_nil() {
        sparkline = sparkline.style(parse_style(style_val)?);
    }

    if !block_val.is_nil() {
        sparkline = sparkline.block(parse_block(block_val)?);
    }

    if !direction_val.is_nil() {
        let direction_sym: RString = direction_val.funcall("to_s", ())?;
        let direction_str = direction_sym.to_string()?;
        let direction = match direction_str.as_str() {
            "right_to_left" => RenderDirection::RightToLeft,
            _ => RenderDirection::LeftToRight,
        };
        sparkline = sparkline.direction(direction);
    }

    if !absent_value_symbol_val.is_nil() {
        let symbol_str: String = String::try_convert(absent_value_symbol_val)?;
        // Only use the first character if multiple are provided
        if let Some(first_char) = symbol_str.chars().next() {
            sparkline = sparkline.absent_value_symbol(first_char);
        }
    }

    if !absent_value_style_val.is_nil() {
        sparkline = sparkline.absent_value_style(parse_style(absent_value_style_val)?);
    }

    frame.render_widget(sparkline, area);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;
    use ratatui::widgets::{Sparkline, Widget};

    #[test]
    fn test_sparkline_rendering() {
        let data = vec![1, 2, 3, 4];
        let sparkline = Sparkline::default().data(&data);
        let mut buf = Buffer::empty(Rect::new(0, 0, 4, 1));
        sparkline.render(Rect::new(0, 0, 4, 1), &mut buf);
        // Should have sparkline rendered (non-space characters)
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
        // In sparkline, higher values generally result in different bar symbols
        // but verifying exact symbols might be fragile across ratatui versions.
        // At least we know it should have rendered 4 bars for 4 data points.
        let bars = buf.content().iter().filter(|c| c.symbol() != " ").count();
        assert_eq!(bars, 4);
    }

    #[test]
    fn test_sparkline_absent_value_symbol() {
        // Data with absent (None) and present values: [Some(5), None, Some(8), None]
        let data = vec![Some(5), None, Some(8), None];
        let sparkline = Sparkline::default()
            .data(&data)
            .absent_value_symbol("-");
        let mut buf = Buffer::empty(Rect::new(0, 0, 4, 1));
        sparkline.render(Rect::new(0, 0, 4, 1), &mut buf);
        
        // Collect all rendered symbols
        let symbols: Vec<&str> = buf.content().iter().map(|c| c.symbol()).collect();
        
        // Check that we have 4 cells rendered
        assert_eq!(symbols.len(), 4, "Should have 4 cells rendered for 4 data points");
        
        // Absent values (None) should render as "-"
        assert_eq!(symbols[1], "-", "Second value (None) should render as dash");
        assert_eq!(symbols[3], "-", "Fourth value (None) should render as dash");
        
        // Present values should not be dashes
        assert_ne!(symbols[0], "-", "First value (Some(5)) should not be dash");
        assert_ne!(symbols[2], "-", "Third value (Some(8)) should not be dash");
    }
}
