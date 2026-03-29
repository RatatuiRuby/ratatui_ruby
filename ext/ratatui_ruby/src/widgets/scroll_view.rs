// SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: LGPL-3.0-or-later

use crate::rendering::render_node;
use magnus::{prelude::*, Error, Value};
use ratatui::{buffer::Buffer, layout::Rect};

pub fn render(buffer: &mut Buffer, area: Rect, node: Value) -> Result<(), Error> {
    let child: Value = node.funcall("child", ())?;
    let content_height: u16 = node.funcall("content_height", ())?;
    let scroll_val: Value = node.funcall("scroll", ())?;

    let scroll_y: u16 = if scroll_val.is_nil() {
        0
    } else {
        let arr = magnus::RArray::from_value(scroll_val).ok_or_else(|| {
            let ruby = magnus::Ruby::get().unwrap();
            Error::new(
                ruby.exception_type_error(),
                "scroll must be [y, x] array or nil",
            )
        })?;
        if arr.len() > 0 {
            arr.entry::<u16>(0)?
        } else {
            0
        }
    };

    // If no scrolling needed, render directly
    if scroll_y == 0 && content_height <= area.height {
        return render_node(buffer, area, child);
    }

    // Create virtual buffer tall enough for all content
    let virtual_height = content_height.max(area.height);
    let virtual_area = Rect::new(0, 0, area.width, virtual_height);
    let mut virtual_buf = Buffer::empty(virtual_area);

    // Render child widget tree into virtual buffer
    render_node(&mut virtual_buf, virtual_area, child)?;

    // Copy visible viewport from virtual buffer to real buffer
    let clamped_scroll = scroll_y.min(virtual_height.saturating_sub(area.height));
    for y in 0..area.height {
        let src_y = y + clamped_scroll;
        if src_y >= virtual_height {
            break;
        }
        for x in 0..area.width {
            if let Some(src_cell) = virtual_buf.cell((x, src_y)) {
                if let Some(dst_cell) = buffer.cell_mut((area.x + x, area.y + y)) {
                    dst_cell
                        .set_symbol(src_cell.symbol())
                        .set_style(src_cell.style());
                }
            }
        }
    }

    Ok(())
}
