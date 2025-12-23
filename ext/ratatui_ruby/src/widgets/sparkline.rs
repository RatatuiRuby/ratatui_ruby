// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use magnus::{prelude::*, Error, Value};
use ratatui::{layout::Rect, widgets::Sparkline, Frame};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let data_val: magnus::RArray = node.funcall("data", ())?;
    let max_val: Value = node.funcall("max", ())?;
    let style_val: Value = node.funcall("style", ())?;
    let block_val: Value = node.funcall("block", ())?;

    let mut data_vec = Vec::new();
    for i in 0..data_val.len() {
        let val: u64 = data_val.entry(i as isize)?;
        data_vec.push(val);
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

    frame.render_widget(sparkline, area);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;
    use ratatui::widgets::{Sparkline, Widget};

    #[test]
    fn test_sparkline_compile() {
        let data = vec![1, 2, 3, 4];
        let sparkline = Sparkline::default().data(&data);
        let mut buf = Buffer::empty(Rect::new(0, 0, 4, 1));
        sparkline.render(Rect::new(0, 0, 4, 1), &mut buf);
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
    }
}
