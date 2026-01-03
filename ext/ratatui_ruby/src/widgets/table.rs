// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use crate::text::{parse_line, parse_span};
use crate::widgets::table_state::RubyTableState;
use bumpalo::Bump;
use magnus::{prelude::*, Error, Symbol, TryConvert, Value};
use ratatui::{
    layout::{Constraint, Flex, Rect},
    widgets::{Cell, HighlightSpacing, Row, Table, TableState},
    Frame,
};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let bump = Bump::new();
    let ruby = magnus::Ruby::get().unwrap();
    let header_val: Value = node.funcall("header", ())?;
    let footer_val: Value = node.funcall("footer", ())?;
    let rows_value: Value = node.funcall("rows", ())?;
    let rows_array = magnus::RArray::from_value(rows_value)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for rows"))?;
    let widths_val: Value = node.funcall("widths", ())?;
    let widths_array = magnus::RArray::from_value(widths_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for widths"))?;
    let highlight_style_val: Value = node.funcall("highlight_style", ())?;
    let column_highlight_style_val: Value = node.funcall("column_highlight_style", ())?;
    let cell_highlight_style_val: Value = node.funcall("cell_highlight_style", ())?;
    let highlight_symbol_val: Value = node.funcall("highlight_symbol", ())?;
    let selected_row_val: Value = node.funcall("selected_row", ())?;
    let selected_column_val: Value = node.funcall("selected_column", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let flex_sym: Symbol = node.funcall("flex", ())?;
    let highlight_spacing_sym: Symbol = node.funcall("highlight_spacing", ())?;

    let mut rows = Vec::new();
    for i in 0..rows_array.len() {
        let index = isize::try_from(i)
            .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let row_val: Value = rows_array.entry(index)?;
        rows.push(parse_row(row_val)?);
    }

    let constraints = parse_constraints(widths_array)?;

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

    let highlight_spacing = match highlight_spacing_sym.to_string().as_str() {
        "always" => HighlightSpacing::Always,
        "never" => HighlightSpacing::Never,
        _ => HighlightSpacing::WhenSelected,
    };
    table = table.highlight_spacing(highlight_spacing);

    if !header_val.is_nil() {
        table = table.header(parse_row(header_val)?);
    }

    if !footer_val.is_nil() {
        table = table.footer(parse_row(footer_val)?);
    }

    if !block_val.is_nil() {
        table = table.block(parse_block(block_val, &bump)?);
    }

    if !highlight_style_val.is_nil() {
        table = table.row_highlight_style(parse_style(highlight_style_val)?);
    }

    if !column_highlight_style_val.is_nil() {
        table = table.column_highlight_style(parse_style(column_highlight_style_val)?);
    }

    if !cell_highlight_style_val.is_nil() {
        table = table.cell_highlight_style(parse_style(cell_highlight_style_val)?);
    }

    if !highlight_symbol_val.is_nil() {
        let symbol: String = highlight_symbol_val.funcall("to_s", ())?;
        table = table.highlight_symbol(symbol);
    }

    let style_val: Value = node.funcall("style", ())?;
    if !style_val.is_nil() {
        table = table.style(parse_style(style_val)?);
    }

    let column_spacing_val: Value = node.funcall("column_spacing", ())?;
    if !column_spacing_val.is_nil() {
        let spacing: u16 = column_spacing_val.funcall("to_int", ())?;
        table = table.column_spacing(spacing);
    }

    let mut state = TableState::default();
    if !selected_row_val.is_nil() {
        let index: usize = selected_row_val.funcall("to_int", ())?;
        state.select(Some(index));
    }
    if !selected_column_val.is_nil() {
        let index: usize = selected_column_val.funcall("to_int", ())?;
        state.select_column(Some(index));
    }

    let offset_val: Value = node.funcall("offset", ())?;
    if !offset_val.is_nil() {
        let offset: usize = offset_val.funcall("to_int", ())?;
        *state.offset_mut() = offset;
    }

    frame.render_stateful_widget(table, area, &mut state);
    Ok(())
}

/// Renders a Table with an external state object.
///
/// This function ignores `selected_row`, `selected_column`, and `offset` from the widget.
/// The State object is the single source of truth for selection and scroll position.
pub fn render_stateful(
    frame: &mut Frame,
    area: Rect,
    node: Value,
    state_wrapper: Value,
) -> Result<(), Error> {
    let bump = Bump::new();
    let ruby = magnus::Ruby::get().unwrap();

    // Extract the RubyTableState wrapper
    let state: &RubyTableState = TryConvert::try_convert(state_wrapper)?;

    // Parse rows
    let rows_value: Value = node.funcall("rows", ())?;
    let rows_array = magnus::RArray::from_value(rows_value)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for rows"))?;
    let widths_val: Value = node.funcall("widths", ())?;
    let widths_array = magnus::RArray::from_value(widths_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for widths"))?;

    let mut rows = Vec::new();
    for i in 0..rows_array.len() {
        let index = isize::try_from(i)
            .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let row_val: Value = rows_array.entry(index)?;
        rows.push(parse_row(row_val)?);
    }

    let constraints = parse_constraints(widths_array)?;

    // Build table (ignoring selected_row, selected_column, offset — State is truth)
    let header_val: Value = node.funcall("header", ())?;
    let footer_val: Value = node.funcall("footer", ())?;
    let highlight_style_val: Value = node.funcall("highlight_style", ())?;
    let column_highlight_style_val: Value = node.funcall("column_highlight_style", ())?;
    let cell_highlight_style_val: Value = node.funcall("cell_highlight_style", ())?;
    let highlight_symbol_val: Value = node.funcall("highlight_symbol", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let flex_sym: Symbol = node.funcall("flex", ())?;
    let highlight_spacing_sym: Symbol = node.funcall("highlight_spacing", ())?;
    let style_val: Value = node.funcall("style", ())?;
    let column_spacing_val: Value = node.funcall("column_spacing", ())?;

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

    let highlight_spacing = match highlight_spacing_sym.to_string().as_str() {
        "always" => HighlightSpacing::Always,
        "never" => HighlightSpacing::Never,
        _ => HighlightSpacing::WhenSelected,
    };
    table = table.highlight_spacing(highlight_spacing);

    if !header_val.is_nil() {
        table = table.header(parse_row(header_val)?);
    }
    if !footer_val.is_nil() {
        table = table.footer(parse_row(footer_val)?);
    }
    if !block_val.is_nil() {
        table = table.block(parse_block(block_val, &bump)?);
    }
    if !highlight_style_val.is_nil() {
        table = table.row_highlight_style(parse_style(highlight_style_val)?);
    }
    if !column_highlight_style_val.is_nil() {
        table = table.column_highlight_style(parse_style(column_highlight_style_val)?);
    }
    if !cell_highlight_style_val.is_nil() {
        table = table.cell_highlight_style(parse_style(cell_highlight_style_val)?);
    }
    if !highlight_symbol_val.is_nil() {
        let symbol: String = highlight_symbol_val.funcall("to_s", ())?;
        table = table.highlight_symbol(symbol);
    }
    if !style_val.is_nil() {
        table = table.style(parse_style(style_val)?);
    }
    if !column_spacing_val.is_nil() {
        let spacing: u16 = column_spacing_val.funcall("to_int", ())?;
        table = table.column_spacing(spacing);
    }

    // Borrow the inner TableState, render, and release the borrow immediately
    {
        let mut inner_state = state.borrow_mut();
        frame.render_stateful_widget(table, area, &mut inner_state);
    }

    Ok(())
}

fn parse_row(row_val: Value) -> Result<Row<'static>, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    // Check if this is a RatatuiRuby::Row object with cells + style + height + margins
    let class = row_val.class();
    let class_name = unsafe { class.name() }.into_owned();

    if class_name == "RatatuiRuby::Row" {
        let cells_val: Value = row_val.funcall("cells", ())?;
        let style_val: Value = row_val.funcall("style", ())?;
        let height_val: Value = row_val.funcall("height", ())?;
        let top_margin_val: Value = row_val.funcall("top_margin", ())?;
        let bottom_margin_val: Value = row_val.funcall("bottom_margin", ())?;

        let cells_array = magnus::RArray::from_value(cells_val)
            .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for Row.cells"))?;

        let mut cells = Vec::new();
        for i in 0..cells_array.len() {
            let index = isize::try_from(i)
                .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
            let cell_val: Value = cells_array.entry(index)?;
            cells.push(parse_cell(cell_val)?);
        }

        let mut row = Row::new(cells);

        if !style_val.is_nil() {
            row = row.style(parse_style(style_val)?);
        }
        if !height_val.is_nil() {
            let h: u16 = height_val.funcall("to_int", ())?;
            row = row.height(h);
        }
        if !top_margin_val.is_nil() {
            let m: u16 = top_margin_val.funcall("to_int", ())?;
            row = row.top_margin(m);
        }
        if !bottom_margin_val.is_nil() {
            let m: u16 = bottom_margin_val.funcall("to_int", ())?;
            row = row.bottom_margin(m);
        }

        return Ok(row);
    }

    // Fallback: plain array of cells
    let row_array = magnus::RArray::from_value(row_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for row"))?;

    let mut cells = Vec::new();
    for i in 0..row_array.len() {
        let index = isize::try_from(i)
            .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let cell_val: Value = row_array.entry(index)?;
        cells.push(parse_cell(cell_val)?);
    }
    Ok(Row::new(cells))
}

fn parse_cell(cell_val: Value) -> Result<Cell<'static>, Error> {
    let class = cell_val.class();
    // SAFETY: Immediate conversion to owned string avoids GC-unsafe borrowed reference.
    let class_name = unsafe { class.name() }.into_owned();

    // Try Text::Line first (contains multiple spans)
    if class_name.contains("Line") {
        if let Ok(line) = parse_line(cell_val) {
            return Ok(Cell::from(line));
        }
    }

    // Try Text::Span
    if class_name.contains("Span") {
        if let Ok(span) = parse_span(cell_val) {
            return Ok(Cell::from(ratatui::text::Line::from(vec![span])));
        }
    }

    if class_name == "RatatuiRuby::Paragraph" {
        let text: String = cell_val.funcall("text", ())?;
        let style_val: Value = cell_val.funcall("style", ())?;
        let cell_style = parse_style(style_val)?;
        Ok(Cell::from(text).style(cell_style))
    } else if class_name == "RatatuiRuby::Style" {
        Ok(Cell::from("").style(parse_style(cell_val)?))
    } else if class_name == "RatatuiRuby::Cell" {
        let symbol: String = cell_val.funcall("char", ())?;
        let fg_val: Value = cell_val.funcall("fg", ())?;
        let bg_val: Value = cell_val.funcall("bg", ())?;
        let modifiers_val: Value = cell_val.funcall("modifiers", ())?;

        let mut style = ratatui::style::Style::default();
        if !fg_val.is_nil() {
            if let Some(color) = crate::style::parse_color_value(fg_val)? {
                style = style.fg(color);
            }
        }
        if !bg_val.is_nil() {
            if let Some(color) = crate::style::parse_color_value(bg_val)? {
                style = style.bg(color);
            }
        }
        if let Some(mods_array) = magnus::RArray::from_value(modifiers_val) {
            let ruby = magnus::Ruby::get().unwrap();
            for i in 0..mods_array.len() {
                let index = isize::try_from(i)
                    .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
                let mod_str: String = mods_array.entry::<String>(index)?;
                if let Some(modifier) = crate::style::parse_modifier_str(&mod_str) {
                    style = style.add_modifier(modifier);
                }
            }
        }
        Ok(Cell::from(symbol).style(style))
    } else {
        let cell_str: String = cell_val.funcall("to_s", ())?;
        Ok(Cell::from(cell_str))
    }
}

fn parse_constraints(widths_array: magnus::RArray) -> Result<Vec<Constraint>, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let mut constraints = Vec::new();
    for i in 0..widths_array.len() {
        let index = isize::try_from(i)
            .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let constraint_obj: Value = widths_array.entry(index)?;
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
    Ok(constraints)
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
