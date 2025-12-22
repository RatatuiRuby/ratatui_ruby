// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

mod events;
mod rendering;
mod style;
mod terminal;
mod widgets;

use magnus::{define_module, function, Error, Value};
use terminal::{init_terminal, restore_terminal, TERMINAL};

fn draw(tree: Value) -> Result<(), Error> {
    let mut term_lock = TERMINAL.lock().unwrap();
    if let Some(terminal) = term_lock.as_mut() {
        terminal
            .draw(|f| {
                if let Err(e) = rendering::render_node(f, f.size(), tree) {
                    eprintln!("Render error: {:?}", e);
                }
            })
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
    } else {
        eprintln!("Terminal is None!");
    }
    Ok(())
}

#[magnus::init]
fn init() -> Result<(), Error> {
    let m = define_module("RatatuiRuby")?;
    m.define_module_function("init_terminal", function!(init_terminal, 0))?;
    m.define_module_function("restore_terminal", function!(restore_terminal, 0))?;
    m.define_module_function("draw", function!(draw, 1))?;
    m.define_module_function("poll_event", function!(events::poll_event, 0))?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use ratatui::style::Color;
    use ratatui::widgets::Widget;
    use ratatui::layout::Rect;
    use ratatui::widgets::{Chart, Dataset, Sparkline};

    #[test]
    fn test_parse_color() {
        // We can test this through the style module directly now
        use crate::style::parse_color;
        assert_eq!(parse_color("red"), Some(Color::Red));
        assert_eq!(parse_color("blue"), Some(Color::Blue));
        assert_eq!(parse_color("#ffffff"), Some(Color::Rgb(255, 255, 255)));
        assert_eq!(parse_color("#000000"), Some(Color::Rgb(0, 0, 0)));
        assert_eq!(parse_color("invalid"), None);
    }

    #[test]
    fn test_sparkline_render() {
        let mut buf = ratatui::buffer::Buffer::empty(Rect::new(0, 0, 10, 1));
        let data = vec![1, 2, 3];
        let sparkline = Sparkline::default().data(&data);
        sparkline.render(Rect::new(0, 0, 10, 1), &mut buf);
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
    }

    #[test]
    fn test_line_chart_render() {
        let mut buf = ratatui::buffer::Buffer::empty(Rect::new(0, 0, 20, 10));
        let data = vec![(0.0, 0.0), (1.0, 1.0)];
        let datasets = vec![Dataset::default().data(&data)];
        let chart = Chart::new(datasets)
            .x_axis(ratatui::widgets::Axis::default().bounds([0.0, 1.0]))
            .y_axis(ratatui::widgets::Axis::default().bounds([0.0, 1.0]));
        chart.render(Rect::new(0, 0, 20, 10), &mut buf);
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
    }
}
