// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::parse_block;
use bumpalo::Bump;
use magnus::{prelude::*, Error, Value};
use ratatui::{layout::Rect, text::Line, widgets::Tabs, Frame};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let bump = Bump::new();
    let tabs = create_tabs(node, &bump)?;
    frame.render_widget(tabs, area);
    Ok(())
}

use crate::text::parse_line;

fn create_tabs<'a>(node: Value, bump: &'a Bump) -> Result<Tabs<'a>, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let titles_val: Value = node.funcall("titles", ())?;
    let selected_index: usize = node.funcall("selected_index", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let divider_val: Value = node.funcall("divider", ())?;
    let highlight_style_val: Value = node.funcall("highlight_style", ())?;
    let padding_left: usize = node.funcall("padding_left", ())?;
    let padding_right: usize = node.funcall("padding_right", ())?;

    let titles_array = magnus::RArray::from_value(titles_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for titles"))?;

    let mut titles = Vec::new();
    for i in 0..titles_array.len() {
        let index = isize::try_from(i).map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let val: Value = titles_array.entry(index)?;
        if let Ok(line) = parse_line(val) {
            titles.push(line);
        } else {
            let s: String = String::try_convert(val)?;
            titles.push(Line::from(s));
        }
    }

    let mut tabs = Tabs::new(titles).select(selected_index);

    if !divider_val.is_nil() {
        let divider: String = divider_val.funcall("to_s", ())?;
        tabs = tabs.divider(divider);
    }

    if !highlight_style_val.is_nil() {
        let style = crate::style::parse_style(highlight_style_val)?;
        tabs = tabs.highlight_style(style);
    }

    let style_val: Value = node.funcall("style", ())?;
    if !style_val.is_nil() {
        tabs = tabs.style(crate::style::parse_style(style_val)?);
    }

    if !block_val.is_nil() {
        tabs = tabs.block(parse_block(block_val, bump)?);
    }

    if padding_left > 0 || padding_right > 0 {
        let left_str = " ".repeat(padding_left);
        let right_str = " ".repeat(padding_right);
        tabs = tabs.padding(left_str, right_str);
    }

    Ok(tabs)
}

pub fn width(node: Value) -> Result<usize, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let titles_val: Value = node.funcall("titles", ())?;
    let divider_val: Value = node.funcall("divider", ())?;
    let padding_left: usize = node.funcall("padding_left", ())?;
    let padding_right: usize = node.funcall("padding_right", ())?;

    let titles_array = magnus::RArray::from_value(titles_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for titles"))?;

    let mut total_width = padding_left + padding_right;
    
    let mut titles_count = 0;
    for i in 0..titles_array.len() {
        let index = isize::try_from(i).map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let val: Value = titles_array.entry(index)?;
        let line_width = if let Ok(line) = parse_line(val) {
            line.width()
        } else {
            let s: String = String::try_convert(val)?;
            ratatui::text::Span::raw(s).width()
        };
        total_width += line_width;
        titles_count += 1;
    }

    if titles_count > 1 {
        let divider_width = if !divider_val.is_nil() {
            let d: String = divider_val.funcall("to_s", ())?;
            ratatui::text::Span::raw(d).width()
        } else {
            1 // Default divider is "|"
        };
        total_width += (titles_count - 1) * divider_width;
    }

    Ok(total_width)
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::buffer::Buffer;
    use ratatui::style::{Color, Modifier, Style};
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

    #[test]
    fn test_tabs_highlight_style() {
        let titles = vec![Line::from("Tab1"), Line::from("Tab2")];
        let highlight_style = Style::default().fg(Color::Red).add_modifier(Modifier::BOLD);
        let tabs = Tabs::new(titles)
            .select(0)
            .highlight_style(highlight_style);
        
        let mut buf = Buffer::empty(Rect::new(0, 0, 15, 1));
        tabs.render(Rect::new(0, 0, 15, 1), &mut buf);

        // Check the first cell of the first tab (which is selected)
        // " Tab1 "
        // Index 1 should be 'T' with Red+Bold
        let cell = &buf.content()[1];
        assert_eq!(cell.symbol(), "T");
        assert_eq!(cell.fg, Color::Red);
        assert!(cell.modifier.contains(Modifier::BOLD));
    }
}
