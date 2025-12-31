// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_bar_set, parse_block, parse_style};
use bumpalo::Bump;
use magnus::{prelude::*, Error, RArray, Symbol, Value};
use ratatui::{
    layout::{Direction, Rect},
    text::Line,
    widgets::{Bar, BarChart, BarGroup},
    Frame,
};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let bump = Bump::new();
    let data_val: Value = node.funcall("data", ())?;
    let bar_width: u16 = node.funcall("bar_width", ())?;
    let bar_gap: u16 = node.funcall("bar_gap", ())?;
    let group_gap: u16 = node.funcall("group_gap", ())?;
    let max_val: Value = node.funcall("max", ())?;
    let style_val: Value = node.funcall("style", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let direction_sym: Symbol = node.funcall("direction", ())?;
    let label_style_val: Value = node.funcall("label_style", ())?;
    let value_style_val: Value = node.funcall("value_style", ())?;
    let bar_set_val: Value = node.funcall("bar_set", ())?;

    let direction = if direction_sym.to_string() == "horizontal" {
        Direction::Horizontal
    } else {
        Direction::Vertical
    };

    let mut bar_chart = BarChart::default()
        .bar_width(bar_width)
        .bar_gap(bar_gap)
        .group_gap(group_gap)
        .direction(direction);

    // Data parsing
    let ruby = magnus::Ruby::get().unwrap();
    if let Some(array) = RArray::from_value(data_val) {
        for i in 0..array.len() {
            let index = isize::try_from(i)
                .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
            let group_obj: Value = array.entry(index)?;

            let label_val: Value = group_obj.funcall("label", ())?;
            let label_str: String = if label_val.is_nil() {
                String::new()
            } else {
                label_val.funcall("to_s", ())?
            };
            let label_ref = bump.alloc_str(&label_str) as &str;

            let bars_array: RArray = group_obj.funcall("bars", ())?;
            let mut bars: Vec<Bar> = Vec::new();

            for j in 0..bars_array.len() {
                let bar_idx = isize::try_from(j)
                    .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
                let bar_obj: Value = bars_array.entry(bar_idx)?;

                let value: u64 = bar_obj.funcall("value", ())?;
                let mut bar = Bar::default().value(value);

                let label_val: Value = bar_obj.funcall("label", ())?;
                if !label_val.is_nil() {
                    let s: String = label_val.funcall("to_s", ())?;
                    let s_ref = bump.alloc_str(&s) as &str;
                    bar = bar.label(Line::from(s_ref));
                }

                let text_val: Value = bar_obj.funcall("text_value", ())?;
                if !text_val.is_nil() {
                    let s: String = text_val.funcall("to_s", ())?;
                    let s_ref = bump.alloc_str(&s) as &str;
                    bar = bar.text_value(s_ref);
                }

                let style_val: Value = bar_obj.funcall("style", ())?;
                if !style_val.is_nil() {
                    bar = bar.style(parse_style(style_val)?);
                }

                let val_style_val: Value = bar_obj.funcall("value_style", ())?;
                if !val_style_val.is_nil() {
                    bar = bar.value_style(parse_style(val_style_val)?);
                }

                bars.push(bar);
            }

            let mut group = BarGroup::new(bars);
            if !label_ref.is_empty() {
                group = group.label(Line::from(label_ref));
            }
            bar_chart = bar_chart.data(group);
        }
    }

    if !max_val.is_nil() {
        let max: u64 = u64::try_convert(max_val)?;
        bar_chart = bar_chart.max(max);
    }

    if !style_val.is_nil() {
        bar_chart = bar_chart.style(parse_style(style_val)?);
    }

    if !block_val.is_nil() {
        bar_chart = bar_chart.block(parse_block(block_val, &bump)?);
    }

    if !label_style_val.is_nil() {
        bar_chart = bar_chart.label_style(parse_style(label_style_val)?);
    }

    if !value_style_val.is_nil() {
        bar_chart = bar_chart.value_style(parse_style(value_style_val)?);
    }

    if !bar_set_val.is_nil() {
        bar_chart = bar_chart.bar_set(parse_bar_set(bar_set_val, &bump)?);
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
