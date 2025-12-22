// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::rendering::render_node;
use magnus::{Error, Value, prelude::*};
use ratatui::{
    layout::{Constraint, Direction, Layout, Rect},
    widgets::Clear,
    Frame,
};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let child: Value = node.funcall("child", ())?;
    let width_percent: u16 = node.funcall("width_percent", ())?;
    let height_percent: u16 = node.funcall("height_percent", ())?;

    let popup_layout = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Percentage((100 - height_percent) / 2),
            Constraint::Percentage(height_percent),
            Constraint::Percentage((100 - height_percent) / 2),
        ])
        .split(area);

    let vertical_center_area = popup_layout[1];

    let popup_layout_horizontal = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([
            Constraint::Percentage((100 - width_percent) / 2),
            Constraint::Percentage(width_percent),
            Constraint::Percentage((100 - width_percent) / 2),
        ])
        .split(vertical_center_area);

    let center_area = popup_layout_horizontal[1];

    frame.render_widget(Clear, center_area);
    render_node(frame, center_area, child)?;
    Ok(())
}

#[cfg(test)]
mod tests {

    use ratatui::layout::{Constraint, Direction, Layout, Rect};

    #[test]
    fn test_center_logic() {
        let area = Rect::new(0, 0, 100, 100);
        let width_percent = 50;
        let height_percent = 50;

        let popup_layout = Layout::default()
            .direction(Direction::Vertical)
            .constraints([
                Constraint::Percentage((100 - height_percent) / 2),
                Constraint::Percentage(height_percent),
                Constraint::Percentage((100 - height_percent) / 2),
            ])
            .split(area);
        let vertical_center = popup_layout[1];
        
        // Vertical check
        assert_eq!(vertical_center.height, 50);

        let popup_layout_horizontal = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([
                Constraint::Percentage((100 - width_percent) / 2),
                Constraint::Percentage(width_percent),
                Constraint::Percentage((100 - width_percent) / 2),
            ])
            .split(vertical_center);
        let center = popup_layout_horizontal[1];

        // Horizontal check
        assert_eq!(center.width, 50);
    }
}
