// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::parse_block;
use magnus::{Error, Value};
use ratatui::{layout::Rect, widgets::Widget, Frame};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let block = parse_block(node)?;
    block.render(area, frame.buffer_mut());
    Ok(())
}
