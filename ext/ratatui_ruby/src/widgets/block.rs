// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::rendering::render_node;
use crate::style::parse_block;
use bumpalo::Bump;
use magnus::{prelude::*, Error, Value};
use ratatui::{layout::Rect, widgets::Widget, Frame};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let arena = Bump::new();
    let block = parse_block(node, &arena)?;
    let block_clone = block.clone();
    
    // Render the block itself (borders, styling)
    block_clone.render(area, frame.buffer_mut());
    
    // Get children and render them within the block's inner area
    let children_val: Value = node.funcall("children", ())?;
    let children_array = magnus::RArray::from_value(children_val);
    
    if let Some(arr) = children_array {
        if arr.len() > 0 {
            // Calculate the inner area of the block (excluding borders and padding)
            let inner = block.inner(area);
            
            // Render each child in the block's inner area
            for i in 0..arr.len() {
                let child: Value = arr.entry(i as isize)?;
                if let Err(e) = render_node(frame, inner, child) {
                    eprintln!("Error rendering block child {}: {:?}", i, e);
                }
            }
        }
    }
    
    Ok(())
}
