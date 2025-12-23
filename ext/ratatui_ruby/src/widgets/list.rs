// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use magnus::{prelude::*, Error, TryConvert, Value};
use ratatui::{
    layout::Rect,
    widgets::{List, ListState},
    Frame,
};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let items_val: Value = node.funcall("items", ())?;
    let items_array = magnus::RArray::from_value(items_val)
        .ok_or_else(|| Error::new(magnus::exception::type_error(), "expected array"))?;
    let selected_index_val: Value = node.funcall("selected_index", ())?;
    let style_val: Value = node.funcall("style", ())?;
    let highlight_style_val: Value = node.funcall("highlight_style", ())?;
    let highlight_symbol_val: Value = node.funcall("highlight_symbol", ())?;
    let block_val: Value = node.funcall("block", ())?;

    let mut items = Vec::new();
    for i in 0..items_array.len() {
        let item: String = items_array.entry(i as isize)?;
        items.push(item);
    }

    let symbol: String = if !highlight_symbol_val.is_nil() {
        let s: String = String::try_convert(highlight_symbol_val)?;
        s
    } else {
        String::new()
    };

    let mut state = ListState::default();
    if !selected_index_val.is_nil() {
        let index: usize = selected_index_val.funcall("to_int", ())?;
        state.select(Some(index));
    }

    let mut list = List::new(items);

    if !highlight_symbol_val.is_nil() {
        list = list.highlight_symbol(&symbol);
    }

    if !style_val.is_nil() {
        list = list.style(parse_style(style_val)?);
    }

    if !highlight_style_val.is_nil() {
        list = list.highlight_style(parse_style(highlight_style_val)?);
    }

    if !block_val.is_nil() {
        list = list.block(parse_block(block_val)?);
    }

    frame.render_stateful_widget(list, area, &mut state);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;
    use ratatui::widgets::List;

    #[test]
    fn test_list_rendering() {
        let items = vec!["Item 1", "Item 2"];
        let list = List::new(items)
            .highlight_symbol(">> ")
            .style(ratatui::style::Style::default().fg(ratatui::style::Color::White))
            .highlight_style(
                ratatui::style::Style::default()
                    .fg(ratatui::style::Color::Yellow)
                    .add_modifier(ratatui::style::Modifier::BOLD),
            );
        let mut state = ListState::default();
        state.select(Some(1));

        let mut buf = Buffer::empty(Rect::new(0, 0, 10, 2));
        use ratatui::widgets::StatefulWidget;
        StatefulWidget::render(list, Rect::new(0, 0, 10, 2), &mut buf, &mut state);

        let content = buf.content().iter().map(|c| c.symbol()).collect::<String>();
        assert!(content.contains("Item 1"));
        assert!(content.contains(">> Item 2"));

        // Check colors
        assert_eq!(buf.get(0, 0).fg, ratatui::style::Color::White);
        assert_eq!(buf.get(0, 1).fg, ratatui::style::Color::Yellow);
        assert!(buf
            .get(0, 1)
            .modifier
            .contains(ratatui::style::Modifier::BOLD));
    }
}
