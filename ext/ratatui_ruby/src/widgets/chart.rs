// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use magnus::{prelude::*, Error, Symbol, Value};
use ratatui::{
    layout::Rect,
    symbols,
    text::Span,
    widgets::{Axis, Chart, Dataset, GraphType},
    Frame,
};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let class = node.class();
    let class_name = unsafe { class.name() };

    if class_name == "RatatuiRuby::LineChart" {
        return render_line_chart(frame, area, node);
    }

    let datasets_val: magnus::RArray = node.funcall("datasets", ())?;
    let x_axis_val: Value = node.funcall("x_axis", ())?;
    let y_axis_val: Value = node.funcall("y_axis", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let style_val: Value = node.funcall("style", ())?;

    let mut datasets = Vec::new();
    // We need to keep the data alive until the chart is rendered
    let mut data_storage: Vec<Vec<(f64, f64)>> = Vec::new();

    for i in 0..datasets_val.len() {
        let ds_val: Value = datasets_val.entry(i as isize)?;
        let data_array: magnus::RArray = ds_val.funcall("data", ())?;

        let mut points = Vec::new();
        for j in 0..data_array.len() {
            let point_array_val: Value = data_array.entry(j as isize)?;
            let point_array = magnus::RArray::from_value(point_array_val).ok_or_else(|| {
                Error::new(ruby.exception_type_error(), "expected array for point")
            })?;
            let x: f64 = point_array.entry(0)?;
            let y: f64 = point_array.entry(1)?;
            points.push((x, y));
        }
        data_storage.push(points);
    }

    for (i, points) in data_storage.iter().enumerate() {
        let ds_val: Value = datasets_val.entry(i as isize)?;
        let name: String = ds_val.funcall("name", ())?;
        let marker_sym: Symbol = ds_val.funcall("marker", ())?;
        let graph_type_sym: Symbol = ds_val.funcall("graph_type", ())?;

        let marker = match marker_sym.to_string().as_str() {
            "dot" => symbols::Marker::Dot,
            "braille" => symbols::Marker::Braille,
            "block" => symbols::Marker::Block,
            "bar" => symbols::Marker::Bar,
            _ => symbols::Marker::Dot,
        };

        let graph_type = match graph_type_sym.to_string().as_str() {
            "line" => GraphType::Line,
            "scatter" => GraphType::Scatter,
            _ => GraphType::Line,
        };

        let mut ds_style = ratatui::style::Style::default();
        let color_val: Value = ds_val.funcall("color", ())?;
        if !color_val.is_nil() {
            let color_str: String = color_val.funcall("to_s", ())?;
            if let Some(color) = crate::style::parse_color(&color_str) {
                ds_style = ds_style.fg(color);
            }
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
        chart = chart.block(parse_block(block_val)?);
    }

    if !style_val.is_nil() {
        chart = chart.style(parse_style(style_val)?);
    }

    frame.render_widget(chart, area);
    Ok(())
}

fn parse_axis(axis_val: Value) -> Result<Axis<'static>, Error> {
    let title: String = axis_val.funcall("title", ())?;
    let bounds_val: magnus::RArray = axis_val.funcall("bounds", ())?;
    let labels_val: magnus::RArray = axis_val.funcall("labels", ())?;
    let style_val: Value = axis_val.funcall("style", ())?;
    let labels_alignment_val: Value = axis_val.funcall("labels_alignment", ())?;

    let bounds: [f64; 2] = [bounds_val.entry(0)?, bounds_val.entry(1)?];

    let mut labels = Vec::new();
    for i in 0..labels_val.len() {
        let label: String = labels_val.entry(i as isize)?;
        labels.push(Span::from(label));
    }

    let mut axis = Axis::default().title(title).bounds(bounds).labels(labels);

    if !style_val.is_nil() {
        axis = axis.style(parse_style(style_val)?);
    }

    if !labels_alignment_val.is_nil() {
        let alignment_sym: Symbol = labels_alignment_val.funcall("to_sym", ())?;
        let alignment = match alignment_sym.to_string().as_str() {
            "left" => ratatui::layout::HorizontalAlignment::Left,
            "center" => ratatui::layout::HorizontalAlignment::Center,
            "right" => ratatui::layout::HorizontalAlignment::Right,
            _ => ratatui::layout::HorizontalAlignment::Center,
        };
        axis = axis.labels_alignment(alignment);
    }

    Ok(axis)
}

fn render_line_chart(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let datasets_val: magnus::RArray = node.funcall("datasets", ())?;
    let x_labels_val: magnus::RArray = node.funcall("x_labels", ())?;
    let y_labels_val: magnus::RArray = node.funcall("y_labels", ())?;
    let y_bounds_val: magnus::RArray = node.funcall("y_bounds", ())?;
    let block_val: Value = node.funcall("block", ())?;

    let mut datasets = Vec::new();
    let mut data_storage: Vec<Vec<(f64, f64)>> = Vec::new();

    for i in 0..datasets_val.len() {
        let ds_val: Value = datasets_val.entry(i as isize)?;
        let data_array: magnus::RArray = ds_val.funcall("data", ())?;

        let mut points = Vec::new();
        for j in 0..data_array.len() {
            let point_array_val: Value = data_array.entry(j as isize)?;
            let point_array = magnus::RArray::from_value(point_array_val).ok_or_else(|| {
                Error::new(ruby.exception_type_error(), "expected array for point")
            })?;
            let x: f64 = point_array.entry(0)?;
            let y: f64 = point_array.entry(1)?;
            points.push((x, y));
        }
        data_storage.push(points);
    }

    for (i, points) in data_storage.iter().enumerate() {
        let ds_val: Value = datasets_val.entry(i as isize)?;
        let name: String = ds_val.funcall("name", ())?;

        let mut ds_style = ratatui::style::Style::default();
        let color_val: Value = ds_val.funcall("color", ())?;
        let color_str: String = color_val.funcall("to_s", ())?;
        if let Some(color) = crate::style::parse_color(&color_str) {
            ds_style = ds_style.fg(color);
        }

        let ds = Dataset::default()
            .name(name)
            .marker(symbols::Marker::Braille)
            .style(ds_style)
            .data(points);
        datasets.push(ds);
    }

    let mut x_labels = Vec::new();
    for i in 0..x_labels_val.len() {
        let label: String = x_labels_val.entry(i as isize)?;
        x_labels.push(Span::from(label));
    }

    let mut y_labels = Vec::new();
    for i in 0..y_labels_val.len() {
        let label: String = y_labels_val.entry(i as isize)?;
        y_labels.push(Span::from(label));
    }
    // Ratatui 0.29+ requires labels to be present for the axis line to render
    if y_labels.is_empty() {
        y_labels.push(Span::from(""));
        y_labels.push(Span::from(""));
    }

    let y_bounds: [f64; 2] = [y_bounds_val.entry(0)?, y_bounds_val.entry(1)?];

    let mut min_x = 0.0;
    let mut max_x = 0.0;
    let mut first = true;
    for ds_data in &data_storage {
        for (x, _) in ds_data {
            if first {
                min_x = *x;
                max_x = *x;
                first = false;
            } else {
                if *x < min_x {
                    min_x = *x;
                }
                if *x > max_x {
                    max_x = *x;
                }
            }
        }
    }
    if min_x == max_x {
        max_x = min_x + 1.0;
    }

    let x_axis = Axis::default().labels(x_labels).bounds([min_x, max_x]);
    let y_axis = Axis::default().labels(y_labels).bounds(y_bounds);

    let mut chart = Chart::new(datasets).x_axis(x_axis).y_axis(y_axis);
    if !block_val.is_nil() {
        chart = chart.block(parse_block(block_val)?);
    }

    frame.render_widget(chart, area);
    Ok(())
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
