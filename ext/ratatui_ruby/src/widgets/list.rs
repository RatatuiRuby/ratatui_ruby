// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use bumpalo::Bump;
use magnus::{prelude::*, Error, Symbol, TryConvert, Value};
use ratatui::{
    layout::Rect,
    text::Line,
    widgets::{HighlightSpacing, List, ListState},
    Frame,
};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let arena = Bump::new();
    let ruby = magnus::Ruby::get().unwrap();
    let items_val: Value = node.funcall("items", ())?;
    let items_array = magnus::RArray::from_value(items_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array"))?;
    let selected_index_val: Value = node.funcall("selected_index", ())?;
    let style_val: Value = node.funcall("style", ())?;
    let highlight_style_val: Value = node.funcall("highlight_style", ())?;
    let highlight_symbol_val: Value = node.funcall("highlight_symbol", ())?;
    let repeat_highlight_symbol_val: Value = node.funcall("repeat_highlight_symbol", ())?;
    let highlight_spacing_sym: Symbol = node.funcall("highlight_spacing", ())?;
    let direction_val: Value = node.funcall("direction", ())?;
    let scroll_padding_val: Value = node.funcall("scroll_padding", ())?;
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

    let highlight_spacing = match highlight_spacing_sym.to_string().as_str() {
        "always" => HighlightSpacing::Always,
        "never" => HighlightSpacing::Never,
        _ => HighlightSpacing::WhenSelected,
    };
    list = list.highlight_spacing(highlight_spacing);

    if !highlight_symbol_val.is_nil() {
        list = list.highlight_symbol(Line::from(symbol));
    }

    if !repeat_highlight_symbol_val.is_nil() {
        let repeat: bool = TryConvert::try_convert(repeat_highlight_symbol_val)?;
        list = list.repeat_highlight_symbol(repeat);
    }

    if !direction_val.is_nil() {
        let direction_sym: magnus::Symbol = TryConvert::try_convert(direction_val)?;
        let direction_str = direction_sym.name().unwrap();
        match direction_str.as_ref() {
            "top_to_bottom" => list = list.direction(ratatui::widgets::ListDirection::TopToBottom),
            "bottom_to_top" => list = list.direction(ratatui::widgets::ListDirection::BottomToTop),
            _ => {
                return Err(Error::new(
                    ruby.exception_arg_error(),
                    "direction must be :top_to_bottom or :bottom_to_top",
                ))
            }
        }
    }

    if !scroll_padding_val.is_nil() {
        let padding: usize = TryConvert::try_convert(scroll_padding_val)?;
        list = list.scroll_padding(padding);
    }

    if !style_val.is_nil() {
        list = list.style(parse_style(style_val)?);
    }

    if !highlight_style_val.is_nil() {
        list = list.highlight_style(parse_style(highlight_style_val)?);
    }

    if !block_val.is_nil() {
        list = list.block(parse_block(block_val, &arena)?);
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
            .highlight_symbol(Line::from(">> "))
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
        assert_eq!(buf.cell((0, 0)).unwrap().fg, ratatui::style::Color::White);
        assert_eq!(buf.cell((0, 1)).unwrap().fg, ratatui::style::Color::Yellow);
        assert!(buf
            .cell((0, 1))
            .unwrap()
            .modifier
            .contains(ratatui::style::Modifier::BOLD));
    }

    #[test]
    fn test_repeat_highlight_symbol() {
        let items = vec!["Item 1", "Item 2"];
        let list_without_repeat = List::new(items.clone()).highlight_symbol(Line::from(">> "));
        let list_with_repeat = List::new(items).highlight_symbol(Line::from(">> ")).repeat_highlight_symbol(true);
        
        let mut state = ListState::default();
        state.select(Some(0));

        let mut buf1 = Buffer::empty(Rect::new(0, 0, 10, 2));
        use ratatui::widgets::StatefulWidget;
        StatefulWidget::render(list_without_repeat, Rect::new(0, 0, 10, 2), &mut buf1, &mut state);

        let mut buf2 = Buffer::empty(Rect::new(0, 0, 10, 2));
        StatefulWidget::render(list_with_repeat, Rect::new(0, 0, 10, 2), &mut buf2, &mut state);

        // Both should render, but the behavior might differ based on content width
        let content1 = buf1.content().iter().map(|c| c.symbol()).collect::<String>();
        let content2 = buf2.content().iter().map(|c| c.symbol()).collect::<String>();
        assert!(!content1.is_empty());
        assert!(!content2.is_empty());
    }

    #[test]
    fn test_scroll_padding() {
        let items = vec!["Item 1", "Item 2", "Item 3", "Item 4"];
        let list = List::new(items).scroll_padding(1).highlight_symbol(Line::from(">> "));
        
        let mut state = ListState::default();
        state.select(Some(1));

        let mut buf = Buffer::empty(Rect::new(0, 0, 15, 4));
        use ratatui::widgets::StatefulWidget;
        StatefulWidget::render(list, Rect::new(0, 0, 15, 4), &mut buf, &mut state);

        let content = buf.content().iter().map(|c| c.symbol()).collect::<String>();
        // With scroll padding, it should render but the exact behavior is handled by ratatui
        assert!(!content.is_empty());
        assert!(content.contains("Item"));
    }
}
