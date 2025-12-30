// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::{parse_block, parse_style};
use bumpalo::Bump;
use magnus::{prelude::*, Error, Value};
use ratatui::{
    layout::Rect,
    widgets::calendar::{CalendarEventStore, Monthly},
    Frame,
};
use std::convert::TryFrom;
use time::{Date, Month};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let bump = Bump::new();
    let ruby = magnus::Ruby::get().unwrap();
    let year: i32 = node.funcall("year", ())?;
    let month_u8: u8 = node.funcall("month", ())?;
    let events_val: Value = node.funcall("events", ())?;
    let default_style_val: Value = node.funcall("default_style", ())?;
    let header_style_val: Value = node.funcall("header_style", ())?;
    let block_val: Value = node.funcall("block", ())?;
    let show_weekdays_header: bool = node.funcall("show_weekdays_header", ())?;
    let show_surrounding_val: Value = node.funcall("show_surrounding", ())?;

    let month = Month::try_from(month_u8)
        .map_err(|e| Error::new(ruby.exception_arg_error(), e.to_string()))?;

    let date = Date::from_calendar_date(year, month, 1)
        .map_err(|e| Error::new(ruby.exception_arg_error(), e.to_string()))?;

    let mut event_store = CalendarEventStore::default();
    if !events_val.is_nil() {
        let events_hash = magnus::RHash::try_convert(events_val)?;
        events_hash.foreach(|date_val: Value, style_val: Value| {
            let year = date_val.funcall("year", ())?;
            let month_u8: u8 = date_val.funcall("month", ())?;
            let day: u8 = date_val.funcall("day", ())?;

            let month = Month::try_from(month_u8)
                .map_err(|e| Error::new(ruby.exception_arg_error(), e.to_string()))?;
            let date = Date::from_calendar_date(year, month, day)
                .map_err(|e| Error::new(ruby.exception_arg_error(), e.to_string()))?;
            let style = parse_style(style_val)?;

            event_store.add(date, style);
            Ok(magnus::r_hash::ForEach::Continue)
        })?;
    }

    let mut calendar = Monthly::new(date, event_store);

    let header_style = if header_style_val.is_nil() {
        ratatui::style::Style::default()
    } else {
        parse_style(header_style_val)?
    };

    let show_month_header: bool = node.funcall("show_month_header", ())?;
    if show_month_header {
        calendar = calendar.show_month_header(header_style);
    }

    if show_weekdays_header {
        calendar = calendar.show_weekdays_header(header_style);
    }

    if !show_surrounding_val.is_nil() {
        calendar = calendar.show_surrounding(parse_style(show_surrounding_val)?);
    }

    if !default_style_val.is_nil() {
        calendar = calendar.default_style(parse_style(default_style_val)?);
    }

    if !block_val.is_nil() {
        calendar = calendar.block(parse_block(block_val, &bump)?);
    }

    frame.render_widget(calendar, area);
    Ok(())
}
