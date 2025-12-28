// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::rendering::render_node;
use magnus::{prelude::*, Error, Value};
use ratatui::{layout::Rect, Frame};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let layers_val: Value = node.funcall("layers", ())?;
    let layers_array = magnus::RArray::from_value(layers_val)
        .ok_or_else(|| Error::new(ruby.exception_type_error(), "expected array for layers"))?;

    for i in 0..layers_array.len() {
        let layer: Value = layers_array.entry(i as isize)?;
        if let Err(e) = render_node(frame, area, layer) {
            eprintln!("Error rendering overlay layer {}: {:?}", i, e);
        }
    }
    Ok(())
}
