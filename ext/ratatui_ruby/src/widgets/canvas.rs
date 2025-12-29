// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_color};
use magnus::{prelude::*, Error, RArray, Symbol, Value};
use ratatui::{
    symbols::Marker,
    widgets::canvas::{Canvas, Circle, Line, Map, MapResolution, Rectangle},
    Frame,
};

pub fn render(frame: &mut Frame, area: ratatui::layout::Rect, node: Value) -> Result<(), Error> {
    let shapes_val: RArray = node.funcall("shapes", ())?;
    let x_bounds_val: RArray = node.funcall("x_bounds", ())?;
    let y_bounds_val: RArray = node.funcall("y_bounds", ())?;
    let marker_sym: Symbol = node.funcall("marker", ())?;
    let block_val: Value = node.funcall("block", ())?;

    let x_bounds: [f64; 2] = [x_bounds_val.entry::<f64>(0)?, x_bounds_val.entry::<f64>(1)?];
    let y_bounds: [f64; 2] = [y_bounds_val.entry::<f64>(0)?, y_bounds_val.entry::<f64>(1)?];

    let marker = match marker_sym.to_string().as_str() {
        "dot" => Marker::Dot,
        "block" => Marker::Block,
        "bar" => Marker::Bar,
        "braille" => Marker::Braille,
        "quadrant" => Marker::Quadrant,
        "sextant" => Marker::Sextant,
        "octant" => Marker::Octant,
        _ => Marker::Braille,
    };

    let mut canvas = Canvas::default()
        .x_bounds(x_bounds)
        .y_bounds(y_bounds)
        .marker(marker);

    if !block_val.is_nil() {
        canvas = canvas.block(parse_block(block_val)?);
    }

    let background_color_val: Value = node.funcall("background_color", ())?;
    if !background_color_val.is_nil() {
        let background_color =
            parse_color(&background_color_val.to_string()).unwrap_or(ratatui::style::Color::Reset);
        canvas = canvas.background_color(background_color);
    }

    let canvas = canvas.paint(|ctx| {
        for shape_val in shapes_val {
            let class = shape_val.class();
            let class_name = unsafe { class.name() };

            match class_name.as_ref() {
                "RatatuiRuby::Shape::Line" => {
                    let x1: f64 = shape_val.funcall("x1", ()).unwrap_or(0.0);
                    let y1: f64 = shape_val.funcall("y1", ()).unwrap_or(0.0);
                    let x2: f64 = shape_val.funcall("x2", ()).unwrap_or(0.0);
                    let y2: f64 = shape_val.funcall("y2", ()).unwrap_or(0.0);
                    let color_val: Value = shape_val.funcall("color", ()).unwrap();
                    let color =
                        parse_color(&color_val.to_string()).unwrap_or(ratatui::style::Color::Reset);
                    ctx.draw(&Line {
                        x1,
                        y1,
                        x2,
                        y2,
                        color,
                    });
                }
                "RatatuiRuby::Shape::Rectangle" => {
                    let x: f64 = shape_val.funcall("x", ()).unwrap_or(0.0);
                    let y: f64 = shape_val.funcall("y", ()).unwrap_or(0.0);
                    let width: f64 = shape_val.funcall("width", ()).unwrap_or(0.0);
                    let height: f64 = shape_val.funcall("height", ()).unwrap_or(0.0);
                    let color_val: Value = shape_val.funcall("color", ()).unwrap();
                    let color =
                        parse_color(&color_val.to_string()).unwrap_or(ratatui::style::Color::Reset);
                    ctx.draw(&Rectangle {
                        x,
                        y,
                        width,
                        height,
                        color,
                    });
                }
                "RatatuiRuby::Shape::Circle" => {
                    let x: f64 = shape_val.funcall("x", ()).unwrap_or(0.0);
                    let y: f64 = shape_val.funcall("y", ()).unwrap_or(0.0);
                    let radius: f64 = shape_val.funcall("radius", ()).unwrap_or(0.0);
                    let color_val: Value = shape_val.funcall("color", ()).unwrap();
                    let color =
                        parse_color(&color_val.to_string()).unwrap_or(ratatui::style::Color::Reset);
                    ctx.draw(&Circle {
                        x,
                        y,
                        radius,
                        color,
                    });
                }
                "RatatuiRuby::Shape::Map" => {
                    let color_val: Value = shape_val.funcall("color", ()).unwrap();
                    let color =
                        parse_color(&color_val.to_string()).unwrap_or(ratatui::style::Color::Reset);
                    let resolution_sym: Symbol = shape_val.funcall("resolution", ()).unwrap();
                    let resolution = match resolution_sym.to_string().as_str() {
                        "high" => MapResolution::High,
                        _ => MapResolution::Low,
                    };
                    ctx.draw(&Map { color, resolution });
                }
                _ => {}
            }
        }
    });

    frame.render_widget(canvas, area);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;
    use ratatui::layout::Rect;
    use ratatui::widgets::Widget;

    #[test]
    fn test_canvas_rendering() {
        let canvas = Canvas::default()
            .x_bounds([0.0, 10.0])
            .y_bounds([0.0, 10.0])
            .marker(Marker::Braille)
            .paint(|ctx| {
                ctx.draw(&Line {
                    x1: 0.0,
                    y1: 0.0,
                    x2: 10.0,
                    y2: 10.0,
                    color: ratatui::style::Color::Red,
                });
            });
        let mut buf = Buffer::empty(Rect::new(0, 0, 5, 5));
        canvas.render(Rect::new(0, 0, 5, 5), &mut buf);

        // Verify that some Braille characters are rendered
        let mut found_braille = false;
        for cell in buf.content() {
            if !cell.symbol().trim().is_empty() {
                found_braille = true;
                break;
            }
        }
        assert!(found_braille, "Canvas should render Braille characters");
    }
}
