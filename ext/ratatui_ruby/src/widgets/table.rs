// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use magnus::{prelude::*, Error, Symbol, Value};
use ratatui::{
    layout::{Constraint, Rect},
    widgets::{Cell, Row, Table},
    Frame,
};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let header_val: Value = node.funcall("header", ())?;
    let rows_val: Value = node.funcall("rows", ())?;
    let rows_array = magnus::RArray::from_value(rows_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for rows"))?;
    let widths_val: Value = node.funcall("widths", ())?;
    let widths_array = magnus::RArray::from_value(widths_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for widths"))?;
    let block_val: Value = node.funcall("block", ())?;

    let mut rows = Vec::new();
    for i in 0..rows_array.len() {
        let row_val: Value = rows_array.entry(i as isize)?;
        let row_array = magnus::RArray::from_value(row_val)
            .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for row"))?;

        let mut cells = Vec::new();
        for j in 0..row_array.len() {
            let cell_val: Value = row_array.entry(j as isize)?;
            let class = cell_val.class();
            let class_name = unsafe { class.name() };

            if class_name.as_ref() == "RatatuiRuby::Paragraph" {
                let text: String = cell_val.funcall("text", ())?;
                let style_val: Value = cell_val.funcall("style", ())?;
                let cell_style = parse_style(style_val)?;
                cells.push(Cell::from(text).style(cell_style));
            } else if class_name.as_ref() == "RatatuiRuby::Style" {
                cells.push(Cell::from("").style(parse_style(cell_val)?));
            } else {
                let cell_str: String = cell_val.funcall("to_s", ())?;
                cells.push(Cell::from(cell_str));
            }
        }
        rows.push(Row::new(cells));
    }

    let mut constraints = Vec::new();
    for i in 0..widths_array.len() {
        let constraint_obj: Value = widths_array.entry(i as isize)?;
        let type_sym: Symbol = constraint_obj.funcall("type", ())?;
        let value: u16 = constraint_obj.funcall("value", ())?;

        match type_sym.to_string().as_str() {
            "length" => constraints.push(Constraint::Length(value)),
            "percentage" => constraints.push(Constraint::Percentage(value)),
            "min" => constraints.push(Constraint::Min(value)),
            _ => {}
        }
    }

    let mut table = Table::new(rows, constraints);

    if !header_val.is_nil() {
        let header_array = magnus::RArray::from_value(header_val).ok_or_else(|| {
            Error::new(ruby.exception_type_error(), "expected array for header")
        })?;
        let mut header_cells = Vec::new();
        for i in 0..header_array.len() {
            let cell_val: Value = header_array.entry(i as isize)?;
            let class = cell_val.class();
            let class_name = unsafe { class.name() };

            if class_name.as_ref() == "RatatuiRuby::Paragraph" {
                let text: String = cell_val.funcall("text", ())?;
                let style_val: Value = cell_val.funcall("style", ())?;
                let cell_style = parse_style(style_val)?;
                header_cells.push(Cell::from(text).style(cell_style));
            } else {
                let cell_str: String = cell_val.funcall("to_s", ())?;
                header_cells.push(Cell::from(cell_str));
            }
        }
        table = table.header(Row::new(header_cells));
    }

    if !block_val.is_nil() {
        table = table.block(parse_block(block_val)?);
    }

    frame.render_widget(table, area);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;
    use ratatui::widgets::{Row, Table, Widget};

    #[test]
    fn test_table_rendering() {
        let rows = vec![Row::new(vec!["C1", "C2"])];
        let table = Table::new(rows, [Constraint::Length(3), Constraint::Length(3)])
            .header(Row::new(vec!["H1", "H2"]));
        let mut buf = Buffer::empty(Rect::new(0, 0, 10, 2));
        Widget::render(table, Rect::new(0, 0, 10, 2), &mut buf);

        let content = buf.content().iter().map(|c| c.symbol()).collect::<String>();
        // Check for presence of header and row content
        assert!(content.contains("H1"));
        assert!(content.contains("H2"));
        assert!(content.contains("C1"));
        assert!(content.contains("C2"));
    }
}
