// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::rendering::render_node;
use magnus::{prelude::*, Error, Symbol, Value};
use ratatui::{
    layout::{Constraint, Direction, Layout, Rect},
    Frame,
};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let direction_sym: Symbol = node.funcall("direction", ())?;
    let children_val: Value = node.funcall("children", ())?;
    let children_array = magnus::RArray::from_value(children_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array"))?;

    let constraints_val: Value = node.funcall("constraints", ())?;
    let constraints_array = magnus::RArray::from_value(constraints_val);

    let direction = if direction_sym.to_string() == "vertical" {
        Direction::Vertical
    } else {
        Direction::Horizontal
    };

    let len = children_array.len();
    if len > 0 {
        let mut ratatui_constraints = Vec::new();

        if let Some(arr) = constraints_array {
            for i in 0..arr.len() {
                let constraint_obj: Value = arr.entry(i as isize)?;
                let type_sym: Symbol = constraint_obj.funcall("type", ())?;
                let value: u16 = constraint_obj.funcall("value", ())?;

                match type_sym.to_string().as_str() {
                    "length" => ratatui_constraints.push(Constraint::Length(value)),
                    "percentage" => ratatui_constraints.push(Constraint::Percentage(value)),
                    "min" => ratatui_constraints.push(Constraint::Min(value)),
                    _ => {}
                }
            }
        }

        // If constraints don't match children, adjust or default
        if ratatui_constraints.len() != len {
            ratatui_constraints = (0..len)
                .map(|_| Constraint::Percentage(100 / (len as u16).max(1)))
                .collect();
        }

        let chunks = Layout::default()
            .direction(direction)
            .constraints(ratatui_constraints)
            .split(area);

        for i in 0..len {
            let child: Value = children_array.entry(i as isize)?;
            if let Err(e) = render_node(frame, chunks[i], child) {
                eprintln!("Error rendering child {}: {:?}", i, e);
            }
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {

    use ratatui::layout::{Constraint, Direction, Layout, Rect};

    #[test]
    fn test_layout_logic() {
        let area = Rect::new(0, 0, 100, 100);
        let chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints([Constraint::Percentage(50), Constraint::Percentage(50)])
            .split(area);
        assert_eq!(chunks.len(), 2);
        assert_eq!(chunks[0].height, 50);
    }
}
