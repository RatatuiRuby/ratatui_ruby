// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_color_value, parse_modifier_str, parse_style};
use crate::widgets;
use magnus::{prelude::*, Error, RArray, Value};
use ratatui::{buffer::Buffer, layout::Rect, style::Style, Frame};

pub fn render_node(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    if node.respond_to("render", true)? {
        let ruby = magnus::Ruby::get().unwrap();
        let ruby_area = {
            let module = ruby.define_module("RatatuiRuby")?;
            let class = module.const_get::<_, magnus::RClass>("Rect")?;
            class.funcall::<_, _, Value>("new", (area.x, area.y, area.width, area.height))?
        };

        // Call render with just the area (no buffer!)
        let commands: Value = node.funcall("render", (ruby_area,))?;

        // Process returned draw commands
        if let Some(arr) = RArray::from_value(commands) {
            for i in 0..arr.len() {
                let ruby = magnus::Ruby::get().unwrap();
                let index = isize::try_from(i).map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
                let cmd: Value = arr.entry(index)?;
                process_draw_command(frame.buffer_mut(), cmd)?;
            }
        }
        return Ok(());
    }

    // SAFETY: Immediate conversion to owned string avoids GC-unsafe borrowed reference.
    let class_name = unsafe { node.class().name() }.into_owned();

    match class_name.as_str() {
        "RatatuiRuby::Paragraph" => widgets::paragraph::render(frame, area, node)?,
        "RatatuiRuby::Clear" => widgets::clear::render(frame, area, node)?,
        "RatatuiRuby::Cursor" => widgets::cursor::render(frame, area, node)?,
        "RatatuiRuby::Overlay" => widgets::overlay::render(frame, area, node)?,
        "RatatuiRuby::Center" => widgets::center::render(frame, area, node)?,
        "RatatuiRuby::Layout" => widgets::layout::render(frame, area, node)?,
        "RatatuiRuby::List" => widgets::list::render(frame, area, node)?,
        "RatatuiRuby::Gauge" => widgets::gauge::render(frame, area, node)?,
        "RatatuiRuby::LineGauge" => widgets::line_gauge::render(frame, area, node)?,
        "RatatuiRuby::Table" => widgets::table::render(frame, area, node)?,
        "RatatuiRuby::Block" => widgets::block::render(frame, area, node)?,
        "RatatuiRuby::Tabs" => widgets::tabs::render(frame, area, node)?,
        "RatatuiRuby::Scrollbar" => widgets::scrollbar::render(frame, area, node)?,
        "RatatuiRuby::BarChart" => widgets::barchart::render(frame, area, node)?,
        "RatatuiRuby::Canvas" => widgets::canvas::render(frame, area, node)?,
        "RatatuiRuby::Calendar" => widgets::calendar::render(frame, area, node)?,
        "RatatuiRuby::Sparkline" => widgets::sparkline::render(frame, area, node)?,
        "RatatuiRuby::Chart" | "RatatuiRuby::LineChart" => {
            widgets::chart::render(frame, area, node)?;
        }
        "RatatuiRuby::RatatuiLogo" => widgets::ratatui_logo::render(frame, area, node)?,
        "RatatuiRuby::RatatuiMascot" => widgets::ratatui_mascot::render_ratatui_mascot(frame, area, node)?,
        _ => {}
    }
    Ok(())
}

fn process_draw_command(buffer: &mut Buffer, cmd: Value) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    // SAFETY: Immediate conversion to owned string avoids GC-unsafe borrowed reference.
    let class_name = unsafe { cmd.class().name() }.into_owned();

    match class_name.as_str() {
        "RatatuiRuby::Draw::StringCmd" => {
            let x: u16 = cmd.funcall("x", ())?;
            let y: u16 = cmd.funcall("y", ())?;
            let string: String = cmd.funcall("string", ())?;
            let style_val: Value = cmd.funcall("style", ())?;
            let style = parse_style(style_val)?;
            buffer.set_string(x, y, string, style);
        }
        "RatatuiRuby::Draw::CellCmd" => {
            let x: u16 = cmd.funcall("x", ())?;
            let y: u16 = cmd.funcall("y", ())?;
            let cell_val: Value = cmd.funcall("cell", ())?;

            let area = buffer.area;
            if x >= area.x + area.width || y >= area.y + area.height {
                return Ok(());
            }

            let symbol: String = cell_val.funcall("char", ())?;
            let fg_val: Value = cell_val.funcall("fg", ())?;
            let bg_val: Value = cell_val.funcall("bg", ())?;
            let modifiers_val: Value = cell_val.funcall("modifiers", ())?;

            let mut style = Style::default();

            if !fg_val.is_nil() {
                if let Some(color) = parse_color_value(fg_val)? {
                    style = style.fg(color);
                }
            }
            if !bg_val.is_nil() {
                if let Some(color) = parse_color_value(bg_val)? {
                    style = style.bg(color);
                }
            }

            if let Some(mods_array) = RArray::from_value(modifiers_val) {
                for i in 0..mods_array.len() {
                    let index = isize::try_from(i).map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
                    let mod_str: String = mods_array.entry::<String>(index)?;
                    if let Some(modifier) = parse_modifier_str(&mod_str) {
                        style = style.add_modifier(modifier);
                    }
                }
            }

            if let Some(cell) = buffer.cell_mut((x, y)) {
                cell.set_symbol(&symbol).set_style(style);
            }
        }
        _ => {
            return Err(Error::new(
                ruby.exception_type_error(),
                format!("Unknown draw command: {class_name}"),
            ));
        }
    }

    Ok(())
}
