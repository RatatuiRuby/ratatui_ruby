// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::widgets;
use magnus::{prelude::*, Error, Value};
use ratatui::{layout::Rect, Frame};

pub fn render_node(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let class = node.class();
    let class_name = unsafe { class.name() };

    match class_name.as_ref() {
        "RatatuiRuby::Paragraph" => widgets::paragraph::render(frame, area, node)?,
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
        "RatatuiRuby::Sparkline" => widgets::sparkline::render(frame, area, node)?,
        "RatatuiRuby::LineChart" => widgets::linechart::render(frame, area, node)?,
        _ => {}
    }
    Ok(())
}
