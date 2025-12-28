// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::rendering::render_node;
use magnus::{prelude::*, Error, Symbol, Value};
use ratatui::{
    layout::{Constraint, Direction, Flex, Layout, Rect},
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

    let flex_sym: Symbol = node.funcall("flex", ())?;

    let direction = if direction_sym.to_string() == "vertical" {
        Direction::Vertical
    } else {
        Direction::Horizontal
    };

    let flex = match flex_sym.to_string().as_str() {
        "start" => Flex::Start,
        "center" => Flex::Center,
        "end" => Flex::End,
        "space_between" => Flex::SpaceBetween,
        "space_around" => Flex::SpaceAround,
        "space_evenly" => Flex::SpaceEvenly,
        _ => Flex::Legacy,
    };

    let len = children_array.len();
    if len > 0 {
        let mut ratatui_constraints = Vec::new();

        if let Some(arr) = constraints_array {
            for i in 0..arr.len() {
                let constraint_obj: Value = arr.entry(i as isize)?;
                let type_sym: Symbol = constraint_obj.funcall("type", ())?;
                let value_obj: Value = constraint_obj.funcall("value", ())?;

                match type_sym.to_string().as_str() {
                    "length" => {
                        let val = u16::try_convert(value_obj)?;
                        ratatui_constraints.push(Constraint::Length(val));
                    }
                    "percentage" => {
                        let val = u16::try_convert(value_obj)?;
                        ratatui_constraints.push(Constraint::Percentage(val));
                    }
                    "min" => {
                        let val = u16::try_convert(value_obj)?;
                        ratatui_constraints.push(Constraint::Min(val));
                    }
                    "max" => {
                        let val = u16::try_convert(value_obj)?;
                        ratatui_constraints.push(Constraint::Max(val));
                    }
                    "fill" => {
                        let val = u16::try_convert(value_obj)?;
                        ratatui_constraints.push(Constraint::Fill(val));
                    }
                    "ratio" => {
                        if let Some(arr) = magnus::RArray::from_value(value_obj) {
                            if arr.len() == 2 {
                                let n = u32::try_convert(arr.entry(0)?)?;
                                let d = u32::try_convert(arr.entry(1)?)?;
                                ratatui_constraints.push(Constraint::Ratio(n, d));
                            }
                        }
                    }
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
            .flex(flex)
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
    use ratatui::layout::{Constraint, Direction, Flex, Layout, Rect};

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

    #[test]
    fn test_fill_constraint() {
        let area = Rect::new(0, 0, 100, 10);
        let chunks = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([Constraint::Fill(1), Constraint::Fill(3)])
            .split(area);
        assert_eq!(chunks.len(), 2);
        assert_eq!(chunks[0].width, 25);
        assert_eq!(chunks[1].width, 75);
    }

    #[test]
    fn test_flex_space_between() {
        let area = Rect::new(0, 0, 100, 10);
        let chunks = Layout::default()
            .direction(Direction::Horizontal)
            .flex(Flex::SpaceBetween)
            .constraints([
                Constraint::Length(10),
                Constraint::Length(10),
                Constraint::Length(10),
            ])
            .split(area);
        assert_eq!(chunks.len(), 3);
        assert_eq!(chunks[0].x, 0);
        assert_eq!(chunks[1].x, 45);
        assert_eq!(chunks[2].x, 90);
    }

    #[test]
    fn test_flex_space_evenly() {
        let area = Rect::new(0, 0, 100, 10);
        let chunks = Layout::default()
            .direction(Direction::Horizontal)
            .flex(Flex::SpaceEvenly)
            .constraints([
                Constraint::Length(10),
                Constraint::Length(10),
                Constraint::Length(10),
            ])
            .split(area);
        assert_eq!(chunks.len(), 3);
        assert_eq!(chunks[0].x, 18);
        assert_eq!(chunks[1].x, 45);
        assert_eq!(chunks[2].x, 73);
    }

    #[test]
    fn test_flex_center() {
        let area = Rect::new(0, 0, 100, 10);
        let chunks = Layout::default()
            .direction(Direction::Horizontal)
            .flex(Flex::Center)
            .constraints([Constraint::Length(20)])
            .split(area);
        assert_eq!(chunks.len(), 1);
        assert_eq!(chunks[0].x, 40);
        assert_eq!(chunks[0].width, 20);
    }

    #[test]
    fn test_max_constraint() {
        let area = Rect::new(0, 0, 100, 10);
        let chunks = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([Constraint::Max(30), Constraint::Fill(1)])
            .split(area);
        assert_eq!(chunks.len(), 2);
        assert_eq!(chunks[0].width, 30);
        assert_eq!(chunks[1].width, 70);
    }
}
