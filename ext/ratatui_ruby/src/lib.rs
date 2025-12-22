// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::{define_module, function, prelude::*, Error, IntoValue, Symbol, Value};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Constraint, Direction, Layout, Rect},
    style::{Color, Style},
    widgets::{Paragraph, Widget},
    Terminal,
};
use std::io;
use std::sync::Mutex;

lazy_static::lazy_static! {
    static ref TERMINAL: Mutex<Option<Terminal<CrosstermBackend<io::Stdout>>>> = Mutex::new(None);
}

fn init_terminal() -> Result<(), Error> {
    let mut term_lock = TERMINAL.lock().unwrap();
    if term_lock.is_none() {
        crossterm::terminal::enable_raw_mode()
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
        let mut stdout = io::stdout();
        crossterm::execute!(stdout, crossterm::terminal::EnterAlternateScreen)
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
        let backend = CrosstermBackend::new(stdout);
        let terminal = Terminal::new(backend)
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
        *term_lock = Some(terminal);
    }
    Ok(())
}

fn restore_terminal() -> Result<(), Error> {
    let mut term_lock = TERMINAL.lock().unwrap();
    if let Some(mut terminal) = term_lock.take() {
        let _ = crossterm::terminal::disable_raw_mode();
        let _ = crossterm::execute!(
            terminal.backend_mut(),
            crossterm::terminal::LeaveAlternateScreen
        );
    }
    Ok(())
}

fn draw(tree: Value) -> Result<(), Error> {
    let mut term_lock = TERMINAL.lock().unwrap();
    if let Some(terminal) = term_lock.as_mut() {
        terminal
            .draw(|f| {
                let _ = render_node(f.size(), tree, f.buffer_mut());
            })
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
    }
    Ok(())
}

fn render_node(area: Rect, node: Value, buf: &mut ratatui::buffer::Buffer) -> Result<(), Error> {
    let class = node.class();
    let class_name = unsafe { class.name() };

    match class_name.as_ref() {
        "RatatuiRuby::Paragraph" => {
            let text: String = node.funcall("text", ())?;
            let fg: Value = node.funcall("fg", ())?;
            let bg: Value = node.funcall("bg", ())?;

            let mut style = Style::default();
            if !fg.is_nil() {
                let fg_str: String = fg.funcall("to_s", ())?;
                if let Some(color) = parse_color(&fg_str) {
                    style = style.fg(color);
                }
            }
            if !bg.is_nil() {
                let bg_str: String = bg.funcall("to_s", ())?;
                if let Some(color) = parse_color(&bg_str) {
                    style = style.bg(color);
                }
            }

            Paragraph::new(text).style(style).render(area, buf);
        }
        "RatatuiRuby::Layout" => {
            let direction_sym: Symbol = node.funcall("direction", ())?;
            let children_val: Value = node.funcall("children", ())?;
            let children_array = magnus::RArray::from_value(children_val)
                .ok_or_else(|| Error::new(magnus::exception::type_error(), "expected array"))?;

            let direction = if direction_sym.to_string() == "vertical" {
                Direction::Vertical
            } else {
                Direction::Horizontal
            };

            let len = children_array.len();
            if len > 0 {
                let constraints: Vec<Constraint> = (0..len)
                    .map(|_| Constraint::Percentage(100 / len as u16))
                    .collect();
                let chunks = Layout::default()
                    .direction(direction)
                    .constraints(constraints)
                    .split(area);

                for i in 0..len {
                    let child: Value = children_array.entry(i as isize)?;
                    let _ = render_node(chunks[i], child, buf);
                }
            }
        }
        _ => {}
    }
    Ok(())
}

fn poll_event() -> Result<Value, Error> {
    if crossterm::event::poll(std::time::Duration::from_millis(16))
        .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?
    {
        if let crossterm::event::Event::Key(key) = crossterm::event::read()
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?
        {
            if key.kind == crossterm::event::KeyEventKind::Press {
                if let crossterm::event::KeyCode::Char(c) = key.code {
                    return Ok(magnus::r_string::RString::new(&c.to_string()).into_value());
                }
            }
        }
    }
    Ok(magnus::value::qnil().into_value())
}

fn parse_color(color_str: &str) -> Option<Color> {
    color_str.parse::<Color>().ok()
}

#[magnus::init]
fn init() -> Result<(), Error> {
    let m = define_module("RatatuiRuby")?;
    m.define_module_function("init_terminal", function!(init_terminal, 0))?;
    m.define_module_function("restore_terminal", function!(restore_terminal, 0))?;
    m.define_module_function("draw", function!(draw, 1))?;
    m.define_module_function("poll_event", function!(poll_event, 0))?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::style::Color;

    #[test]
    fn test_parse_color() {
        assert_eq!(parse_color("red"), Some(Color::Red));
        assert_eq!(parse_color("blue"), Some(Color::Blue));
        assert_eq!(parse_color("#ffffff"), Some(Color::Rgb(255, 255, 255)));
        assert_eq!(parse_color("#000000"), Some(Color::Rgb(0, 0, 0)));
        assert_eq!(parse_color("invalid"), None);
    }
}
