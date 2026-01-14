// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use bumpalo::Bump;
use magnus::{prelude::*, Error, Value};
use ratatui::{buffer::Buffer, layout::Rect, widgets::Widget};

pub fn render(buffer: &mut Buffer, area: Rect, node: Value) -> Result<(), Error> {
    ratatui::widgets::Clear.render(area, buffer);

    // If a block is provided, render it on top of the cleared area
    if let Ok(block_val) = node.funcall::<_, _, Value>("block", ()) {
        if !block_val.is_nil() {
            let bump = Bump::new();
            let block = crate::style::parse_block(block_val, &bump)?;
            block.render(area, buffer);
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use ratatui::{backend::TestBackend, layout::Rect, widgets::Widget, Terminal};

    #[test]
    fn test_clear_renders_without_error() {
        let backend = TestBackend::new(10, 5);
        let mut terminal = Terminal::new(backend).unwrap();

        terminal
            .draw(|frame| {
                let area = Rect::new(0, 0, 10, 5);
                ratatui::widgets::Clear.render(area, frame.buffer_mut());
            })
            .unwrap();
    }
}
