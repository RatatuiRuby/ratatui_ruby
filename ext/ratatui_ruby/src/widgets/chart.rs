// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: LGPL-3.0-or-later

use crate::errors::type_error_with_context;
use crate::style::{parse_block, parse_style};
use crate::text::parse_line;
use bumpalo::Bump;
use magnus::{prelude::*, Error, Symbol, Value};
use ratatui::buffer::Buffer;
use ratatui::{
    layout::Rect,
    symbols,
    widgets::{Axis, Chart, Dataset, GraphType, LegendPosition, Widget},
};

#[allow(clippy::too_many_lines)]
pub fn render(buffer: &mut Buffer, area: Rect, node: Value) -> Result<(), Error> {
    let bump = Bump::new();
    let ruby = magnus::Ruby::get().unwrap();

    let datasets_val: magnus::RArray = node.funcall("datasets", ())?;
    let x_axis_val: Value = node.funcall("x_axis", ())?;
    let y_axis_val: Value = node.funcall("y_axis", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let style_val: Value = node.funcall("style", ())?;
    let legend_position_val: Value = node.funcall("legend_position", ())?;
    let hidden_legend_constraints_val: Value = node.funcall("hidden_legend_constraints", ())?;

    let mut datasets = Vec::new();
    // We need to keep the data alive until the chart is rendered
    let mut data_storage: Vec<Vec<(f64, f64)>> = Vec::new();

    for i in 0..datasets_val.len() {
        let index = isize::try_from(i)
            .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let ds_val: Value = datasets_val.entry(index)?;
        let data_array: magnus::RArray = ds_val.funcall("data", ())?;

        let mut points = Vec::new();
        for j in 0..data_array.len() {
            let index = isize::try_from(j)
                .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
            let point_array_val: Value = data_array.entry(index)?;
            let point_array = magnus::RArray::from_value(point_array_val).ok_or_else(|| {
                type_error_with_context(&ruby, "expected array for point", point_array_val)
            })?;
            let x: f64 = point_array.entry(0)?;
            let y: f64 = point_array.entry(1)?;
            points.push((x, y));
        }
        data_storage.push(points);
    }

    for (i, points) in data_storage.iter().enumerate() {
        let index = isize::try_from(i)
            .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let ds_val: Value = datasets_val.entry(index)?;
        let name_val: Value = ds_val.funcall("name", ())?;
        let name = if let Ok(line) = parse_line(name_val) {
            line
        } else {
            let name_str: String = name_val.funcall("to_s", ())?;
            ratatui::text::Line::from(name_str)
        };
        let marker_sym: Symbol = ds_val.funcall("marker", ())?;
        let graph_type_sym: Symbol = ds_val.funcall("graph_type", ())?;

        let marker = match marker_sym.to_string().as_str() {
            "braille" => symbols::Marker::Braille,
            "block" => symbols::Marker::Block,
            "bar" => symbols::Marker::Bar,
            "half_block" => symbols::Marker::HalfBlock,
            _ => symbols::Marker::Dot,
        };

        let graph_type = match graph_type_sym.to_string().as_str() {
            "scatter" => GraphType::Scatter,
            _ => GraphType::Line,
        };

        let mut ds_style = ratatui::style::Style::default();
        let style_val: Value = ds_val.funcall("style", ())?;
        if !style_val.is_nil() {
            ds_style = parse_style(style_val)?;
        }

        let ds = Dataset::default()
            .name(name)
            .marker(marker)
            .graph_type(graph_type)
            .style(ds_style)
            .data(points);
        datasets.push(ds);
    }

    let x_axis = parse_axis(x_axis_val)?;
    let y_axis = parse_axis(y_axis_val)?;

    let mut chart = Chart::new(datasets).x_axis(x_axis).y_axis(y_axis);

    if !block_val.is_nil() {
        chart = chart.block(parse_block(block_val, &bump)?);
    }

    if !style_val.is_nil() {
        chart = chart.style(parse_style(style_val)?);
    }

    if !legend_position_val.is_nil() {
        let pos_sym: Symbol = legend_position_val.funcall("to_sym", ())?;
        let pos = match pos_sym.to_string().as_str() {
            "top_left" => LegendPosition::TopLeft,
            "top" => LegendPosition::Top,
            "bottom_left" => LegendPosition::BottomLeft,
            "bottom" => LegendPosition::Bottom,
            "bottom_right" => LegendPosition::BottomRight,
            "left" => LegendPosition::Left,
            "right" => LegendPosition::Right,
            _ => LegendPosition::TopRight,
        };
        chart = chart.legend_position(Some(pos));
    }

    if !hidden_legend_constraints_val.is_nil() {
        let constraints_array: magnus::RArray =
            hidden_legend_constraints_val.funcall("to_a", ())?;
        if constraints_array.len() == 2 {
            let width_val: Value = constraints_array.entry(0)?;
            let height_val: Value = constraints_array.entry(1)?;
            let width_constraint = super::layout::parse_constraint(width_val)?;
            let height_constraint = super::layout::parse_constraint(height_val)?;
            chart = chart.hidden_legend_constraints((width_constraint, height_constraint));
        }
    }

    Widget::render(chart, area, buffer);
    Ok(())
}

fn parse_axis(axis_val: Value) -> Result<Axis<'static>, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let title_val: Value = axis_val.funcall("title", ())?;
    let title = if title_val.is_nil() {
        ratatui::text::Line::from("")
    } else if let Ok(line) = parse_line(title_val) {
        line
    } else {
        let title_str: String = title_val.funcall("to_s", ())?;
        ratatui::text::Line::from(title_str)
    };
    let bounds_val: magnus::RArray = axis_val.funcall("bounds", ())?;
    let labels_val: magnus::RArray = axis_val.funcall("labels", ())?;
    let style_val: Value = axis_val.funcall("style", ())?;
    let labels_alignment_val: Value = axis_val.funcall("labels_alignment", ())?;

    let bounds: [f64; 2] = [bounds_val.entry(0)?, bounds_val.entry(1)?];

    let mut labels = Vec::new();
    for i in 0..labels_val.len() {
        let index = isize::try_from(i)
            .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let entry_val: Value = labels_val.entry(index)?;
        let label = if let Ok(line) = parse_line(entry_val) {
            line
        } else {
            let label_str: String = entry_val.funcall("to_s", ())?;
            ratatui::text::Line::from(label_str)
        };
        labels.push(label);
    }

    let mut axis = Axis::default().title(title).bounds(bounds).labels(labels);

    if !style_val.is_nil() {
        axis = axis.style(parse_style(style_val)?);
    }

    if !labels_alignment_val.is_nil() {
        let alignment_sym: Symbol = labels_alignment_val.funcall("to_sym", ())?;
        let alignment = match alignment_sym.to_string().as_str() {
            "left" => ratatui::layout::HorizontalAlignment::Left,
            "right" => ratatui::layout::HorizontalAlignment::Right,
            _ => ratatui::layout::HorizontalAlignment::Center,
        };
        axis = axis.labels_alignment(alignment);
    }

    Ok(axis)
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;
    use ratatui::widgets::Widget;

    #[test]
    fn test_chart_rendering() {
        let data = vec![(0.0, 0.0), (1.0, 1.0)];
        let datasets = vec![Dataset::default().name("TestDS").data(&data)];
        let chart = Chart::new(datasets)
            .x_axis(
                Axis::default()
                    .bounds([0.0, 1.0])
                    .labels(vec!["XMIN".into(), "XMAX".into()] as Vec<ratatui::text::Line>),
            )
            .y_axis(
                Axis::default()
                    .bounds([0.0, 1.0])
                    .labels(vec!["YMIN".into(), "YMAX".into()] as Vec<ratatui::text::Line>),
            );
        let mut buf = Buffer::empty(Rect::new(0, 0, 40, 20));
        chart.render(Rect::new(0, 0, 40, 20), &mut buf);
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
        let content = buf.content().iter().map(|c| c.symbol()).collect::<String>();
        assert!(content.contains("XMIN"));
        assert!(content.contains("XMAX"));
        assert!(content.contains("YMIN"));
        assert!(content.contains("YMAX"));
        assert!(content.contains("TestDS"));
    }
}
