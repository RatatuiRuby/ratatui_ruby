// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::errors::type_error_with_context;
use crate::style::parse_block;
use crate::text::{parse_line, parse_span};
use bumpalo::Bump;
use magnus::{prelude::*, Error, Value};
use ratatui::buffer::Buffer;
use ratatui::{layout::Rect, text::Line, widgets::Tabs, widgets::Widget};

pub fn render(buffer: &mut Buffer, area: Rect, node: Value) -> Result<(), Error> {
    let bump = Bump::new();
    let tabs = create_tabs(node, &bump)?;
    tabs.render(area, buffer);
    Ok(())
}

/// Parses padding value with duck-typing support:
/// - Integer: generates that many spaces
/// - Line: uses styled Line directly
/// - Span: wraps in Line
/// - String or `to_s` responder: converts to Line
fn parse_padding(val: Value) -> Result<Line<'static>, Error> {
    // Handle nil or zero
    if val.is_nil() {
        return Ok(Line::from(""));
    }

    // Try as Integer first (most common case)
    if let Ok(n) = usize::try_convert(val) {
        if n == 0 {
            return Ok(Line::from(""));
        }
        return Ok(Line::from(" ".repeat(n)));
    }

    // Try to parse as Line
    if let Ok(line) = parse_line(val) {
        return Ok(line);
    }

    // Try to parse as Span (wrap in Line)
    if let Ok(span) = parse_span(val) {
        return Ok(Line::from(vec![span]));
    }

    // Fallback: call to_s and convert to Line
    let s: String = val.funcall("to_s", ())?;
    Ok(Line::from(s))
}

fn create_tabs(node: Value, bump: &Bump) -> Result<Tabs<'_>, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let titles_val: Value = node.funcall("titles", ())?;
    let selected_index: usize = node.funcall("selected_index", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let divider_val: Value = node.funcall("divider", ())?;
    let highlight_style_val: Value = node.funcall("highlight_style", ())?;
    let padding_left_val: Value = node.funcall("padding_left", ())?;
    let padding_right_val: Value = node.funcall("padding_right", ())?;

    let titles_array = magnus::RArray::from_value(titles_val)
        .ok_or_else(|| type_error_with_context(&ruby, "expected array for titles", titles_val))?;

    let mut titles = Vec::new();
    for i in 0..titles_array.len() {
        let index = isize::try_from(i)
            .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
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
        if let Ok(span) = parse_span(divider_val) {
            tabs = tabs.divider(span);
        } else {
            let divider: String = divider_val.funcall("to_s", ())?;
            tabs = tabs.divider(divider);
        }
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

    // Handle duck-typed padding: Integer (spaces), String, Line, or anything with to_s
    let left_padding = parse_padding(padding_left_val)?;
    let right_padding = parse_padding(padding_right_val)?;
    if !left_padding.spans.is_empty() || !right_padding.spans.is_empty() {
        tabs = tabs.padding(left_padding, right_padding);
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
        .ok_or_else(|| type_error_with_context(&ruby, "expected array for titles", titles_val))?;

    let mut total_width = padding_left + padding_right;

    let mut titles_count = 0;
    for i in 0..titles_array.len() {
        let index = isize::try_from(i)
            .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
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
        let divider_width = if divider_val.is_nil() {
            1 // Default divider is "|"
        } else if let Ok(span) = parse_span(divider_val) {
            span.width()
        } else {
            let d: String = divider_val.funcall("to_s", ())?;
            ratatui::text::Span::raw(d).width()
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
        let tabs = Tabs::new(titles).select(0).highlight_style(highlight_style);

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
