// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_color};
use magnus::{prelude::*, Error, Value};
use ratatui::{
    layout::Rect,
    style::{Color, Style},
    symbols,
    widgets::{Chart, Dataset},
    Frame,
};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let datasets_val: magnus::RArray = node.funcall("datasets", ())?;
    let x_labels_val: magnus::RArray = node.funcall("x_labels", ())?;
    let y_labels_val: magnus::RArray = node.funcall("y_labels", ())?;
    let y_bounds_val: magnus::RArray = node.funcall("y_bounds", ())?;
    let block_val: Value = node.funcall("block", ())?;

    let mut datasets = Vec::new();
    // We need to keep the data alive until the chart is rendered
    let mut data_storage: Vec<Vec<(f64, f64)>> = Vec::new();
    let mut name_storage: Vec<String> = Vec::new();

    for i in 0..datasets_val.len() {
        let ds_val: Value = datasets_val.entry(i as isize)?;
        let name: String = ds_val.funcall("name", ())?;
        let data_array: magnus::RArray = ds_val.funcall("data", ())?;

        let mut points = Vec::new();
        for j in 0..data_array.len() {
            let point_array_val: Value = data_array.entry(j as isize)?;
            let point_array = magnus::RArray::from_value(point_array_val).ok_or_else(|| {
                Error::new(magnus::exception::type_error(), "expected array for point")
            })?;
            let x_val: Value = point_array.entry(0)?;
            let y_val: Value = point_array.entry(1)?;

            let x: f64 = x_val.funcall("to_f", ())?;
            let y: f64 = y_val.funcall("to_f", ())?;
            points.push((x, y));
        }

        data_storage.push(points);
        name_storage.push(name);
    }

    for i in 0..data_storage.len() {
        let ds_val: Value = datasets_val.entry(i as isize)?;
        let color_val: Value = ds_val.funcall("color", ())?;
        let color_str: String = color_val.funcall("to_s", ())?;
        let color = parse_color(&color_str).unwrap_or(Color::White);

        let ds = Dataset::default()
            .name(name_storage[i].clone())
            .marker(symbols::Marker::Braille)
            .style(Style::default().fg(color))
            .data(&data_storage[i]);
        datasets.push(ds);
    }

    let mut x_labels = Vec::new();
    for i in 0..x_labels_val.len() {
        let label: String = x_labels_val.entry(i as isize)?;
        x_labels.push(ratatui::text::Span::from(label));
    }

    let mut y_labels = Vec::new();
    for i in 0..y_labels_val.len() {
        let label: String = y_labels_val.entry(i as isize)?;
        y_labels.push(ratatui::text::Span::from(label));
    }

    let y_bounds: [f64; 2] = [y_bounds_val.entry(0)?, y_bounds_val.entry(1)?];

    // Calculate x_bounds based on datasets if possible
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

    // Ensure there's some range
    if min_x == max_x {
        max_x = min_x + 1.0;
    }

    let x_axis = ratatui::widgets::Axis::default()
        .labels(x_labels)
        .bounds([min_x, max_x]);

    let y_axis = ratatui::widgets::Axis::default()
        .labels(y_labels)
        .bounds(y_bounds);

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
    use ratatui::widgets::{Axis, Chart, Dataset, Widget};

    #[test]
    fn test_linechart_rendering() {
        let data = vec![(0.0, 0.0), (1.0, 1.0)];
        let datasets = vec![Dataset::default().name("TestDS").data(&data)];
        let chart = Chart::new(datasets)
            .x_axis(
                Axis::default()
                    .bounds([0.0, 1.0])
                    .labels(vec!["XMIN".into(), "XMAX".into()]),
            )
            .y_axis(
                Axis::default()
                    .bounds([0.0, 1.0])
                    .labels(vec!["YMIN".into(), "YMAX".into()]),
            );
        let mut buf = Buffer::empty(Rect::new(0, 0, 40, 20)); // Larger buffer
        chart.render(Rect::new(0, 0, 40, 20), &mut buf);
        // Should have chart rendered (braille characters)
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
        // Should have labels
        let content = buf.content().iter().map(|c| c.symbol()).collect::<String>();
        assert!(content.contains("XMIN"));
        assert!(content.contains("XMAX"));
        assert!(content.contains("YMIN"));
        assert!(content.contains("YMAX"));
        assert!(content.contains("TestDS"));
    }
}
