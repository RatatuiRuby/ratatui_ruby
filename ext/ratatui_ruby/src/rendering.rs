// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::buffer::BufferWrapper;
use crate::widgets;
use magnus::{prelude::*, Error, Value};
use ratatui::{layout::Rect, Frame};

pub fn render_node(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    if node.respond_to("render", true)? {
        let wrapper = BufferWrapper::new(frame.buffer_mut());
        let ruby = magnus::Ruby::get().unwrap();
        let ruby_area = {
            let module = ruby.define_module("RatatuiRuby")?;
            let class = module.const_get::<_, magnus::RClass>("Rect")?;
            class.funcall::<_, _, Value>("new", (area.x, area.y, area.width, area.height))?
        };
        let wrapper_obj = ruby.obj_wrap(wrapper);
        node.funcall::<_, _, Value>("render", (ruby_area, wrapper_obj))?;
        return Ok(());
    }

    let class = node.class();
    let class_name = unsafe { class.name() };

    match class_name.as_ref() {
        "RatatuiRuby::Paragraph" => widgets::paragraph::render(frame, area, node)?,
        "RatatuiRuby::Clear" => widgets::clear::render(frame, area, node)?,
        "RatatuiRuby::Cursor" => widgets::cursor::render(frame, area, node)?,
        "RatatuiRuby::Overlay" => widgets::overlay::render(frame, area, node)?,
        "RatatuiRuby::Center" => widgets::center::render(frame, area, node)?,
        "RatatuiRuby::Layout" => widgets::layout::render(frame, area, node)?,
        "RatatuiRuby::List" => widgets::list::render(frame, area, node)?,
        "RatatuiRuby::Gauge" => widgets::gauge::render(frame, area, node)?,
        "RatatuiRuby::Table" => widgets::table::render(frame, area, node)?,
        "RatatuiRuby::Block" => widgets::block::render(frame, area, node)?,
        "RatatuiRuby::Tabs" => widgets::tabs::render(frame, area, node)?,
        "RatatuiRuby::Scrollbar" => widgets::scrollbar::render(frame, area, node)?,
        "RatatuiRuby::BarChart" => widgets::barchart::render(frame, area, node)?,
        "RatatuiRuby::Canvas" => widgets::canvas::render(frame, area, node)?,
        "RatatuiRuby::Calendar" => widgets::calendar::render(frame, area, node)?,
        "RatatuiRuby::Sparkline" => widgets::sparkline::render(frame, area, node)?,
        "RatatuiRuby::Chart" | "RatatuiRuby::LineChart" => {
            widgets::chart::render(frame, area, node)?
        }
        _ => {}
    }
    Ok(())
}
