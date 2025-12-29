// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use magnus::{prelude::*, Error, Symbol, Value};
use ratatui::{
    layout::{Constraint, Flex, Rect},
    widgets::{Cell, Row, Table, TableState},
    Frame,
};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let header_val: Value = node.funcall("header", ())?;
    let footer_val: Value = node.funcall("footer", ())?;
    let rows_val: Value = node.funcall("rows", ())?;
    let rows_array = magnus::RArray::from_value(rows_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for rows"))?;
    let widths_val: Value = node.funcall("widths", ())?;
    let widths_array = magnus::RArray::from_value(widths_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for widths"))?;
    let highlight_style_val: Value = node.funcall("highlight_style", ())?;
    let highlight_symbol_val: Value = node.funcall("highlight_symbol", ())?;
    let selected_row_val: Value = node.funcall("selected_row", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let flex_sym: Symbol = node.funcall("flex", ())?;

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
        let value_obj: Value = constraint_obj.funcall("value", ())?;

        match type_sym.to_string().as_str() {
            "length" => {
                let val = u16::try_convert(value_obj)?;
                constraints.push(Constraint::Length(val));
            }
            "percentage" => {
                let val = u16::try_convert(value_obj)?;
                constraints.push(Constraint::Percentage(val));
            }
            "min" => {
                let val = u16::try_convert(value_obj)?;
                constraints.push(Constraint::Min(val));
            }
            "max" => {
                let val = u16::try_convert(value_obj)?;
                constraints.push(Constraint::Max(val));
            }
            "fill" => {
                let val = u16::try_convert(value_obj)?;
                constraints.push(Constraint::Fill(val));
            }
            "ratio" => {
                if let Some(arr) = magnus::RArray::from_value(value_obj) {
                    if arr.len() == 2 {
                        let n = u32::try_convert(arr.entry(0)?)?;
                        let d = u32::try_convert(arr.entry(1)?)?;
                        constraints.push(Constraint::Ratio(n, d));
                    }
                }
            }
            _ => {}
        }
    }

    let flex = match flex_sym.to_string().as_str() {
        "start" => Flex::Start,
        "center" => Flex::Center,
        "end" => Flex::End,
        "space_between" => Flex::SpaceBetween,
        "space_around" => Flex::SpaceAround,
        "space_evenly" => Flex::SpaceEvenly,
        _ => Flex::Legacy,
    };

    let mut table = Table::new(rows, constraints).flex(flex);

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

    if !footer_val.is_nil() {
        let footer_array = magnus::RArray::from_value(footer_val).ok_or_else(|| {
            Error::new(ruby.exception_type_error(), "expected array for footer")
        })?;
        let mut footer_cells = Vec::new();
        for i in 0..footer_array.len() {
            let cell_val: Value = footer_array.entry(i as isize)?;
            let class = cell_val.class();
            let class_name = unsafe { class.name() };

            if class_name.as_ref() == "RatatuiRuby::Paragraph" {
                let text: String = cell_val.funcall("text", ())?;
                let style_val: Value = cell_val.funcall("style", ())?;
                let cell_style = parse_style(style_val)?;
                footer_cells.push(Cell::from(text).style(cell_style));
            } else {
                let cell_str: String = cell_val.funcall("to_s", ())?;
                footer_cells.push(Cell::from(cell_str));
            }
        }
        table = table.footer(Row::new(footer_cells));
    }

    if !block_val.is_nil() {
        table = table.block(parse_block(block_val)?);
    }

    if !highlight_style_val.is_nil() {
        table = table.row_highlight_style(parse_style(highlight_style_val)?);
    }

    if !highlight_symbol_val.is_nil() {
        let symbol: String = highlight_symbol_val.funcall("to_s", ())?;
        table = table.highlight_symbol(symbol);
    }

    let style_val: Value = node.funcall("style", ())?;
    if !style_val.is_nil() {
        table = table.style(parse_style(style_val)?);
    }

    let mut state = TableState::default();
    if !selected_row_val.is_nil() {
        let index: usize = selected_row_val.funcall("to_int", ())?;
        state.select(Some(index));
    }

    frame.render_stateful_widget(table, area, &mut state);
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
            .header(Row::new(vec!["H1", "H2"]))
            .footer(Row::new(vec!["F1", "F2"]));
        let mut buf = Buffer::empty(Rect::new(0, 0, 10, 3));
        Widget::render(table, Rect::new(0, 0, 10, 3), &mut buf);

        let content = buf.content().iter().map(|c| c.symbol()).collect::<String>();
        // Check for presence of header and row content
        assert!(content.contains("H1"));
        assert!(content.contains("H2"));
        assert!(content.contains("F1"));
        assert!(content.contains("F2"));
        assert!(content.contains("C1"));
        assert!(content.contains("C2"));
    }
}
