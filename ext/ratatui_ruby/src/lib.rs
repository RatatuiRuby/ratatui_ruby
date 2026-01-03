// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

// Require SAFETY comments on all unsafe blocks
#![warn(clippy::undocumented_unsafe_blocks)]
// Enable pedantic lints for stricter code quality
#![warn(clippy::pedantic)]
// Allow certain pedantic lints that are too noisy for FFI code
#![allow(clippy::missing_errors_doc)]
#![allow(clippy::missing_panics_doc)]
#![allow(clippy::module_name_repetitions)]

mod events;
mod frame;
mod rendering;
mod string_width;
mod style;
mod terminal;
mod text;
mod widgets;

use frame::RubyFrame;
use magnus::{function, method, Error, Module, Object, Ruby, Value};
use terminal::{init_terminal, restore_terminal, TERMINAL};

/// Draw to the terminal.
///
/// Supports two calling conventions:
/// - Legacy: `RatatuiRuby.draw(tree)` - Renders a widget tree to the full terminal area
/// - New: `RatatuiRuby.draw { |frame| ... }` - Yields a Frame for explicit widget placement
fn draw(args: &[Value]) -> Result<(), Error> {
    let ruby = Ruby::get().unwrap();

    // Parse arguments: check for optional tree argument
    let tree: Option<Value> = if args.is_empty() {
        None
    } else if args.len() == 1 {
        Some(args[0])
    } else {
        return Err(Error::new(
            ruby.exception_arg_error(),
            format!(
                "wrong number of arguments (given {}, expected 0..1)",
                args.len()
            ),
        ));
    };
    let block_given = ruby.block_given();

    // Validate: must have either tree or block, but not both
    if tree.is_some() && block_given {
        return Err(Error::new(
            ruby.exception_arg_error(),
            "Cannot provide both a tree and a block to draw",
        ));
    }
    if tree.is_none() && !block_given {
        return Err(Error::new(
            ruby.exception_arg_error(),
            "Must provide either a tree or a block to draw",
        ));
    }

    let mut term_lock = TERMINAL.lock().unwrap();
    let mut render_error: Option<Error> = None;

    // Helper closure to execute the draw callback logic for either terminal type
    let mut draw_callback = |f: &mut ratatui::Frame<'_>| {
        if block_given {
            // New API: yield RubyFrame to block
            // Create validity flag — set to true while the block is executing
            let active = std::sync::Arc::new(std::sync::atomic::AtomicBool::new(true));

            let ruby_frame = RubyFrame::new(f, active.clone());
            if let Err(e) = ruby.yield_value::<_, Value>(ruby_frame) {
                render_error = Some(e);
            }

            // Invalidate frame immediately after block returns
            // This prevents use-after-free if user stored the frame object
            active.store(false, std::sync::atomic::Ordering::Relaxed);
        } else if let Some(tree_value) = tree {
            // Legacy API: render tree to full area
            if let Err(e) = rendering::render_node(f, f.area(), tree_value) {
                render_error = Some(e);
            }
        }
    };

    if let Some(wrapper) = term_lock.as_mut() {
        match wrapper {
            terminal::TerminalWrapper::Crossterm(term) => {
                let module = ruby.define_module("RatatuiRuby")?;
                let error_base = module.const_get::<_, magnus::RClass>("Error")?;
                let error_class = error_base.const_get("Terminal")?;
                term.draw(&mut draw_callback)
                    .map_err(|e| Error::new(error_class, e.to_string()))?;
            }
            terminal::TerminalWrapper::Test(term) => {
                let module = ruby.define_module("RatatuiRuby")?;
                let error_base = module.const_get::<_, magnus::RClass>("Error")?;
                let error_class = error_base.const_get("Terminal")?;
                term.draw(&mut draw_callback)
                    .map_err(|e| Error::new(error_class, e.to_string()))?;
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

    m.define_module_function("_init_terminal", function!(init_terminal, 2))?;
    m.define_module_function("restore_terminal", function!(restore_terminal, 0))?;
    m.define_module_function("_draw", function!(draw, -1))?;

    // Register Frame class
    let frame_class = m.define_class("Frame", ruby.class_object())?;
    frame_class.define_method("area", method!(RubyFrame::area, 0))?;
    frame_class.define_method("render_widget", method!(RubyFrame::render_widget, 2))?;
    frame_class.define_method(
        "render_stateful_widget",
        method!(RubyFrame::render_stateful_widget, 3),
    )?;
    frame_class.define_method(
        "set_cursor_position",
        method!(RubyFrame::set_cursor_position, 2),
    )?;
    m.define_module_function("_poll_event", function!(events::poll_event, 1))?;
    m.define_module_function("inject_test_event", function!(events::inject_test_event, 2))?;
    m.define_module_function("clear_events", function!(events::clear_events, 0))?;

    // Register State classes
    widgets::list_state::register(&ruby, m)?;
    widgets::table_state::register(&ruby, m)?;
    widgets::scrollbar_state::register(&ruby, m)?;

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
    m.define_module_function("_get_cell_at", function!(terminal::get_cell_at, 2))?;
    m.define_module_function("resize_terminal", function!(terminal::resize_terminal, 2))?;

    // Register Layout.split on the Layout::Layout class (inside the Layout module)
    let layout_mod = m.const_get::<_, magnus::RModule>("Layout")?;
    let layout_class = layout_mod.const_get::<_, magnus::RClass>("Layout")?;
    layout_class.define_singleton_method("_split", function!(widgets::layout::split_layout, 4))?;

    // Paragraph metrics
    m.define_module_function(
        "_paragraph_line_count",
        function!(widgets::paragraph::line_count, 2),
    )?;
    m.define_module_function(
        "_paragraph_line_width",
        function!(widgets::paragraph::line_width, 1),
    )?;

    // Tabs metrics
    m.define_module_function("_tabs_width", function!(widgets::tabs::width, 1))?;

    // Text measurement
    m.define_module_function("_text_width", function!(string_width::text_width, 1))?;

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
