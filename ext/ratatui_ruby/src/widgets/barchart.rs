// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use magnus::{prelude::*, Error, Value};
use ratatui::{layout::Rect, widgets::BarChart, Frame};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let data_val: magnus::RHash = node.funcall("data", ())?;
    let bar_width: u16 = node.funcall("bar_width", ())?;
    let bar_gap: u16 = node.funcall("bar_gap", ())?;
    let max_val: Value = node.funcall("max", ())?;
    let style_val: Value = node.funcall("style", ())?;
    let block_val: Value = node.funcall("block", ())?;

    let keys: magnus::RArray = data_val.funcall("keys", ())?;
    let mut labels = Vec::new();
    let mut data_vec = Vec::new();

    for i in 0..keys.len() {
        let key: Value = keys.entry(i as isize)?;
        let val: u64 = data_val.funcall("[]", (key,))?;
        let label: String = key.funcall("to_s", ())?;
        labels.push(label);
        data_vec.push(val);
    }

    let chart_data: Vec<(&str, u64)> = labels
        .iter()
        .zip(data_vec.iter())
        .map(|(l, v)| (l.as_str(), *v))
        .collect();

    let mut bar_chart = BarChart::default()
        .data(&chart_data)
        .bar_width(bar_width)
        .bar_gap(bar_gap);

    if !max_val.is_nil() {
        let max: u64 = u64::try_convert(max_val)?;
        bar_chart = bar_chart.max(max);
    }

    if !style_val.is_nil() {
        bar_chart = bar_chart.style(parse_style(style_val)?);
    }

    if !block_val.is_nil() {
        bar_chart = bar_chart.block(parse_block(block_val)?);
    }

    frame.render_widget(bar_chart, area);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;
    use ratatui::widgets::{BarChart, Widget};

    #[test]
    fn test_barchart_rendering() {
        let data = [("B1", 10), ("B2", 20)];
        let chart = BarChart::default().data(&data).bar_width(3);
        let mut buf = Buffer::empty(Rect::new(0, 0, 10, 5));
        chart.render(Rect::new(0, 0, 10, 5), &mut buf);
        // Should have bars rendered (non-space characters)
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
        // Should have labels
        assert!(buf.content().iter().any(|c| c.symbol().contains('B')));
    }
}
