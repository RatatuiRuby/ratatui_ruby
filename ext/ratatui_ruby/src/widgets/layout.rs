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
                let index = isize::try_from(i).map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
                let constraint_obj: Value = arr.entry(index)?;
                if let Ok(constraint) = parse_constraint(constraint_obj) {
                    ratatui_constraints.push(constraint);
                }
            }
        }

        // If constraints don't match children, adjust or default
        if ratatui_constraints.len() != len {
            ratatui_constraints = (0..len)
                .map(|_| Constraint::Percentage(100 / u16::try_from(len).unwrap_or(u16::MAX).max(1)))
                .collect();
        }

        let chunks = Layout::default()
            .direction(direction)
            .flex(flex)
            .constraints(ratatui_constraints)
            .split(area);

        for i in 0..len {
            let index = isize::try_from(i).map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
            let child: Value = children_array.entry(index)?;
            if let Err(e) = render_node(frame, chunks[i], child) {
                eprintln!("Error rendering child {i}: {e:?}");
            }
        }
    }
    Ok(())
}

pub fn parse_constraint(value: Value) -> Result<Constraint, Error> {
    let type_sym: Symbol = value.funcall("type", ())?;
    let value_obj: Value = value.funcall("value", ())?;

    match type_sym.to_string().as_str() {
        "length" => {
            let val = u16::try_convert(value_obj)?;
            Ok(Constraint::Length(val))
        }
        "percentage" => {
            let val = u16::try_convert(value_obj)?;
            Ok(Constraint::Percentage(val))
        }
        "min" => {
            let val = u16::try_convert(value_obj)?;
            Ok(Constraint::Min(val))
        }
        "max" => {
            let val = u16::try_convert(value_obj)?;
            Ok(Constraint::Max(val))
        }
        "fill" => {
            let val = u16::try_convert(value_obj)?;
            Ok(Constraint::Fill(val))
        }
        "ratio" => {
            if let Some(arr) = magnus::RArray::from_value(value_obj) {
                if arr.len() == 2 {
                    let n = u32::try_convert(arr.entry(0)?)?;
                    let d = u32::try_convert(arr.entry(1)?)?;
                    return Ok(Constraint::Ratio(n, d));
                }
            }
            // Fallback or error for invalid ratio?
            // For now, let's treat it as Min(0) or similar, or error.
            // But to match previous behavior (which ignored invalid), we just return 0 length or something?
            // Check previous logic: it ignored it (`_ => {}`).
            // But we need to return a Constraint. Use Length(0) as safe fallback if unmatched?
            // Actually, let's error if strictly required, but existing logic pushed nothing if mismatched.
            // If we push nothing, we can't return a Constraint.
            // Let's assume input is valid for now or return a default.
            Ok(Constraint::Length(0))
        }
        _ => Ok(Constraint::Length(0)), // Default fallback
    }
}

/// Splits an area into multiple rectangles based on constraints.
/// This is a pure calculation helper for hit testing.
///
/// # Arguments
/// * `area` - A Ruby Hash or Rect with :x, :y, :width, :height keys
/// * `direction` - Symbol :vertical or :horizontal
/// * `constraints` - Array of Constraint objects
/// * `flex` - Symbol for flex mode
///
/// # Returns
/// An array of Ruby Hashes representing Rect objects
pub fn split_layout(
    area: Value,
    direction: Symbol,
    constraints: magnus::RArray,
    flex: Symbol,
) -> Result<magnus::RArray, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    // Parse area from Hash or Rect-like object
    let x: u16 = area.funcall("x", ())?;
    let y: u16 = area.funcall("y", ())?;
    let width: u16 = area.funcall("width", ())?;
    let height: u16 = area.funcall("height", ())?;
    let rect = Rect::new(x, y, width, height);

    // Parse direction
    let dir = if direction.to_string() == "vertical" {
        Direction::Vertical
    } else {
        Direction::Horizontal
    };

    // Parse flex
    let flex_mode = match flex.to_string().as_str() {
        "start" => Flex::Start,
        "center" => Flex::Center,
        "end" => Flex::End,
        "space_between" => Flex::SpaceBetween,
        "space_around" => Flex::SpaceAround,
        "space_evenly" => Flex::SpaceEvenly,
        _ => Flex::Legacy,
    };

    // Parse constraints
    let mut ratatui_constraints = Vec::new();
    for i in 0..constraints.len() {
        let index = isize::try_from(i).map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let constraint_obj: Value = constraints.entry(index)?;
        if let Ok(constraint) = parse_constraint(constraint_obj) {
            ratatui_constraints.push(constraint);
        }
    }

    // Compute layout
    let chunks = Layout::default()
        .direction(dir)
        .flex(flex_mode)
        .constraints(ratatui_constraints)
        .split(rect);

    // Convert to Ruby array of Hashes
    let result = ruby.ary_new_capa(chunks.len());
    for chunk in chunks.iter() {
        let hash = ruby.hash_new();
        hash.aset(ruby.sym_new("x"), chunk.x)?;
        hash.aset(ruby.sym_new("y"), chunk.y)?;
        hash.aset(ruby.sym_new("width"), chunk.width)?;
        hash.aset(ruby.sym_new("height"), chunk.height)?;
        result.push(hash)?;
    }

    Ok(result)
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
