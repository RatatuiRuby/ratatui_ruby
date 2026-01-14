// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::errors::type_error_with_context;
use crate::rendering::render_node;
use magnus::{prelude::*, Error, Value};
use ratatui::{buffer::Buffer, layout::Rect};

pub fn render(buffer: &mut Buffer, area: Rect, node: Value) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let layers_val: Value = node.funcall("layers", ())?;
    let layers_array = magnus::RArray::from_value(layers_val)
        .ok_or_else(|| type_error_with_context(&ruby, "expected array for layers", layers_val))?;

    for i in 0..layers_array.len() {
        let index = isize::try_from(i)
            .map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
        let layer: Value = layers_array.entry(index)?;
        if let Err(e) = render_node(buffer, area, layer) {
            eprintln!("Error rendering overlay layer {i}: {e:?}");
        }
    }
    Ok(())
}
