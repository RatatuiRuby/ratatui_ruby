// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::parse_style;
use magnus::{prelude::*, Error, Value};
use ratatui::text::{Line, Span};

/// Parses a Ruby value into a ratatui Text structure.
///
/// Supports:
/// - String: Plain text without styling
/// - `Text::Span`: A single styled fragment
/// - `Text::Line`: A line composed of multiple spans
/// - Array: Array of `Text::Lines` or Strings
pub fn parse_text(value: Value) -> Result<Vec<Line<'static>>, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    if value.is_nil() {
        return Ok(vec![Line::from("")]);
    }

    // Check if it's a String
    if let Ok(s) = String::try_convert(value) {
        // Split on newlines and create a Line for each.
        // We need to own the strings, so we convert each line string to a String
        let lines: Vec<Line> = s.split('\n').map(|line| Line::from(line.to_string())).collect();
        return if lines.is_empty() {
            Ok(vec![Line::from("")])
        } else {
            Ok(lines)
        };
    }

    // Check if it's an Array
    if let Some(arr) = magnus::RArray::from_value(value) {
        let mut lines = Vec::new();
        for i in 0..arr.len() {
            let ruby = magnus::Ruby::get().unwrap();
            let index = isize::try_from(i).map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
            let elem: Value = arr.entry(index)?;

            // Try to convert to String
            if let Ok(s) = String::try_convert(elem) {
                lines.push(Line::from(s));
            } else if let Ok(line) = parse_line(elem) {
                lines.push(line);
            } else if let Ok(span) = parse_span(elem) {
                lines.push(Line::from(vec![span]));
            }
        }
        return if lines.is_empty() {
            Ok(vec![Line::from("")])
        } else {
            Ok(lines)
        };
    }

    // Try to parse as Line
    if let Ok(line) = parse_line(value) {
        return Ok(vec![line]);
    }

    // Try to parse as Span
    if let Ok(span) = parse_span(value) {
        return Ok(vec![Line::from(vec![span])]);
    }

    // Fallback: try to convert to string
    match String::try_convert(value) {
        Ok(s) => {
            let lines: Vec<Line> = s.split('\n').map(|line| Line::from(line.to_string())).collect();
            if lines.is_empty() {
                Ok(vec![Line::from("")])
            } else {
                Ok(lines)
            }
        }
        Err(_) => Err(Error::new(
            ruby.exception_type_error(),
            "expected String, Text::Span, Text::Line, or Array of Text::Lines/Spans",
        )),
    }
}

/// Parses a Ruby Span object into a ratatui Span.
fn parse_span(value: Value) -> Result<Span<'static>, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    // Get class name
    let class_obj: Value = value.funcall("class", ())?;
    let class_name: String = class_obj.funcall("name", ())?;

    if !class_name.contains("Span") {
        return Err(Error::new(
            ruby.exception_type_error(),
            "expected a Text::Span object",
        ));
    }

    // Extract content and style from the Ruby Span
    let content: Value = value.funcall("content", ())?;
    let style_val: Value = value.funcall("style", ())?;

    let content_str: String = content.funcall("to_s", ())?;
    let style = parse_style(style_val)?;

    Ok(Span::styled(content_str, style))
}

/// Parses a Ruby `Text::Line` object into a ratatui Line.
fn parse_line(value: Value) -> Result<Line<'static>, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    // Get class name
    let class_obj: Value = value.funcall("class", ())?;
    let class_name: String = class_obj.funcall("name", ())?;

    if !class_name.contains("Line") {
        return Err(Error::new(
            ruby.exception_type_error(),
            "expected a Text::Line object",
        ));
    }

    // Extract spans from the Ruby Line
    let spans_val: Value = value.funcall("spans", ())?;

    if spans_val.is_nil() {
        return Ok(Line::from(""));
    }

    let spans_array = magnus::RArray::from_value(spans_val).ok_or_else(|| {
        Error::new(
            ruby.exception_type_error(),
            "expected array of Spans in Text::Line.spans",
        )
    })?;

    let mut spans = Vec::new();
    for i in 0..spans_array.len() {
        let ruby = magnus::Ruby::get().unwrap();
        let index = isize::try_from(i).map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let span_elem: Value = spans_array.entry(index)?;

        // If it's a string, convert to span without style
        if let Ok(s) = String::try_convert(span_elem) {
            spans.push(Span::raw(s));
        } else {
            // Try to parse as Span object
            if let Ok(span) = parse_span(span_elem) {
                spans.push(span);
            } else if let Ok(s) = String::try_convert(span_elem) {
                // If it fails, try converting to string
                spans.push(Span::raw(s));
            }
        }
    }

    if spans.is_empty() {
        Ok(Line::from(""))
    } else {
        Ok(Line::from(spans))
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_parse_plain_string() {
    }
}
