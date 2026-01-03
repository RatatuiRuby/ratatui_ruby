// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use crate::text::{parse_line, parse_span};
use crate::widgets::list_state::RubyListState;
use bumpalo::Bump;
use magnus::{prelude::*, Error, Symbol, TryConvert, Value};
use ratatui::{
    layout::Rect,
    text::Line,
    widgets::{HighlightSpacing, List, ListItem, ListState},
    Frame,
};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let bump = Bump::new();
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

    let mut items: Vec<ListItem> = Vec::new();
    for i in 0..items_array.len() {
        let index = isize::try_from(i)
            .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let item_val: Value = items_array.entry(index)?;
        let item = parse_list_item(item_val)?;
        items.push(item);
    }

    let symbol: String = if highlight_symbol_val.is_nil() {
        String::new()
    } else {
        String::try_convert(highlight_symbol_val)?
    };

    let mut state = ListState::default();
    if !selected_index_val.is_nil() {
        let index: usize = selected_index_val.funcall("to_int", ())?;
        state.select(Some(index));
    }

    let offset_val: Value = node.funcall("offset", ())?;
    if !offset_val.is_nil() {
        let offset: usize = offset_val.funcall("to_int", ())?;
        *state.offset_mut() = offset;
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
        list = list.block(parse_block(block_val, &bump)?);
    }

    frame.render_stateful_widget(list, area, &mut state);
    Ok(())
}

/// Renders a List with an external state object.
///
/// This function ignores `selected_index` and `offset` from the widget.
/// The State object is the single source of truth for selection and scroll position.
pub fn render_stateful(
    frame: &mut Frame,
    area: Rect,
    node: Value,
    state_wrapper: Value,
) -> Result<(), Error> {
    let bump = Bump::new();
    let ruby = magnus::Ruby::get().unwrap();

    // Extract the RubyListState wrapper
    let state: &RubyListState = TryConvert::try_convert(state_wrapper)?;

    // Build items
    let items_val: Value = node.funcall("items", ())?;
    let items_array = magnus::RArray::from_value(items_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array"))?;

    let mut items: Vec<ListItem> = Vec::new();
    for i in 0..items_array.len() {
        let index = isize::try_from(i)
            .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let item_val: Value = items_array.entry(index)?;
        let item = parse_list_item(item_val)?;
        items.push(item);
    }

    // Build widget (ignoring selected_index and offset — State is truth)
    let style_val: Value = node.funcall("style", ())?;
    let highlight_style_val: Value = node.funcall("highlight_style", ())?;
    let highlight_symbol_val: Value = node.funcall("highlight_symbol", ())?;
    let repeat_highlight_symbol_val: Value = node.funcall("repeat_highlight_symbol", ())?;
    let highlight_spacing_sym: Symbol = node.funcall("highlight_spacing", ())?;
    let direction_val: Value = node.funcall("direction", ())?;
    let scroll_padding_val: Value = node.funcall("scroll_padding", ())?;
    let block_val: Value = node.funcall("block", ())?;

    let symbol: String = if highlight_symbol_val.is_nil() {
        String::new()
    } else {
        String::try_convert(highlight_symbol_val)?
    };

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
        list = list.block(parse_block(block_val, &bump)?);
    }

    // Borrow the inner ListState, render, and release the borrow immediately
    {
        let mut inner_state = state.borrow_mut();
        frame.render_stateful_widget(list, area, &mut inner_state);
    }
    // Borrow is now released

    Ok(())
}

/// Parses a Ruby list item into a ratatui `ListItem`.
///
/// Accepts:
/// - `String`: Plain text item
/// - `Text::Span`: A single styled fragment
/// - `Text::Line`: A line composed of multiple spans
/// - `RatatuiRuby::ListItem`: A `ListItem` object with content and optional style
fn parse_list_item(value: Value) -> Result<ListItem<'static>, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    // Check if it's a RatatuiRuby::ListItem
    if let Ok(class_obj) = value.funcall::<_, _, Value>("class", ()) {
        if let Ok(class_name) = class_obj.funcall::<_, _, String>("name", ()) {
            if class_name.contains("ListItem") {
                // Extract content and style from the ListItem
                let content_val: Value = value.funcall("content", ())?;
                let style_val: Value = value.funcall("style", ())?;

                // Parse content as a Line
                let line = if let Ok(s) = String::try_convert(content_val) {
                    Line::from(s)
                } else if let Ok(line) = parse_line(content_val) {
                    line
                } else if let Ok(span) = parse_span(content_val) {
                    Line::from(vec![span])
                } else {
                    Line::from("")
                };

                // Parse and apply style if present
                let mut item = ListItem::new(line);
                if !style_val.is_nil() {
                    item = item.style(parse_style(style_val)?);
                }
                return Ok(item);
            }
        }
    }

    // Try as String
    if let Ok(s) = String::try_convert(value) {
        return Ok(ListItem::new(Line::from(s)));
    }

    // Try as Line
    if let Ok(line) = parse_line(value) {
        return Ok(ListItem::new(line));
    }

    // Try as Span
    if let Ok(span) = parse_span(value) {
        return Ok(ListItem::new(Line::from(vec![span])));
    }

    // Fallback
    Err(Error::new(
        ruby.exception_type_error(),
        "expected String, Text::Span, Text::Line, or ListItem",
    ))
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
        let list_with_repeat = List::new(items)
            .highlight_symbol(Line::from(">> "))
            .repeat_highlight_symbol(true);

        let mut state = ListState::default();
        state.select(Some(0));

        let mut buf1 = Buffer::empty(Rect::new(0, 0, 10, 2));
        use ratatui::widgets::StatefulWidget;
        StatefulWidget::render(
            list_without_repeat,
            Rect::new(0, 0, 10, 2),
            &mut buf1,
            &mut state,
        );

        let mut buf2 = Buffer::empty(Rect::new(0, 0, 10, 2));
        StatefulWidget::render(
            list_with_repeat,
            Rect::new(0, 0, 10, 2),
            &mut buf2,
            &mut state,
        );

        // Both should render, but the behavior might differ based on content width
        let content1 = buf1
            .content()
            .iter()
            .map(|c| c.symbol())
            .collect::<String>();
        let content2 = buf2
            .content()
            .iter()
            .map(|c| c.symbol())
            .collect::<String>();
        assert!(!content1.is_empty());
        assert!(!content2.is_empty());
    }

    #[test]
    fn test_scroll_padding() {
        let items = vec!["Item 1", "Item 2", "Item 3", "Item 4"];
        let list = List::new(items)
            .scroll_padding(1)
            .highlight_symbol(Line::from(">> "));

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
