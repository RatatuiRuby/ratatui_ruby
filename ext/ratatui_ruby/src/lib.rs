// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

mod buffer;
mod events;
mod rendering;
mod style;
mod terminal;
mod text;
mod widgets;

use magnus::{function, Class, Error, Module, Value};
use terminal::{init_terminal, restore_terminal, TERMINAL};

fn draw(tree: Value) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let mut term_lock = TERMINAL.lock().unwrap();
    let mut render_error = None;
    if let Some(wrapper) = term_lock.as_mut() {
        match wrapper {
            terminal::TerminalWrapper::Crossterm(term) => {
                term.draw(|f| {
                    if let Err(e) = rendering::render_node(f, f.area(), tree) {
                        render_error = Some(e);
                    }
                })
                .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;
            }
            terminal::TerminalWrapper::Test(term) => {
                term.draw(|f| {
                    if let Err(e) = rendering::render_node(f, f.area(), tree) {
                        render_error = Some(e);
                    }
                })
                .map_err(|e| Error::new(ruby.exception_runtime_error(), e.to_string()))?;
            }
        }
    } else {
        eprintln!("Terminal is None!");
    }

    if let Some(e) = render_error {
        return Err(e);
    }

    Ok(())
}

#[magnus::init]
fn init() -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let m = ruby.define_module("RatatuiRuby")?;

    let buffer_class = m.define_class("Buffer", ruby.class_object())?;
    buffer_class.undef_default_alloc_func();
    buffer_class.define_method("set_string", magnus::method!(buffer::BufferWrapper::set_string, 4))?;
    buffer_class.define_method("area", magnus::method!(buffer::BufferWrapper::area, 0))?;

    m.define_module_function("_init_terminal", function!(init_terminal, 2))?;
    m.define_module_function("restore_terminal", function!(restore_terminal, 0))?;
    m.define_module_function("draw", function!(draw, 1))?;
    m.define_module_function("_poll_event", function!(events::poll_event, 0))?;
    m.define_module_function("inject_test_event", function!(events::inject_test_event, 2))?;
    m.define_module_function("clear_events", function!(events::clear_events, 0))?;

    // Test backend helpers
    m.define_module_function(
        "init_test_terminal",
        function!(terminal::init_test_terminal, 2),
    )?;
    m.define_module_function(
        "get_buffer_content",
        function!(terminal::get_buffer_content, 0),
    )?;
    m.define_module_function(
        "get_cursor_position",
        function!(terminal::get_cursor_position, 0),
    )?;
    m.define_module_function(
        "_get_cell_at",
        function!(terminal::get_cell_at, 2),
    )?;
    m.define_module_function("resize_terminal", function!(terminal::resize_terminal, 2))?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use ratatui::layout::Rect;
    use ratatui::style::Color;
    use ratatui::widgets::Widget;
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
