// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::parse_block;
use magnus::{prelude::*, Error, Value};
use ratatui::{layout::Rect, text::Line, widgets::Tabs, Frame};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let titles_val: Value = node.funcall("titles", ())?;
    let selected_index: usize = node.funcall("selected_index", ())?;
    let block_val: Value = node.funcall("block", ())?;

    let titles_array = magnus::RArray::from_value(titles_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for titles"))?;

    let mut titles = Vec::new();
    for i in 0..titles_array.len() {
        let title: String = titles_array.entry(i as isize)?;
        titles.push(Line::from(title));
    }

    let mut tabs = Tabs::new(titles).select(selected_index);

    if !block_val.is_nil() {
        tabs = tabs.block(parse_block(block_val)?);
    }

    frame.render_widget(tabs, area);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;
    use ratatui::text::Line;
    use ratatui::widgets::{Tabs, Widget};

    #[test]
    fn test_tabs_rendering() {
        let titles = vec![Line::from("Tab1"), Line::from("Tab2")];
        let tabs = Tabs::new(titles).select(1).divider("|");
        let mut buf = Buffer::empty(Rect::new(0, 0, 15, 1));
        tabs.render(Rect::new(0, 0, 15, 1), &mut buf);
        // Should contain tab titles
        let content = buf.content().iter().map(|c| c.symbol()).collect::<String>();
        assert!(content.contains("Tab1"));
        assert!(content.contains("Tab2"));
        assert!(content.contains('|'));
    }
}
