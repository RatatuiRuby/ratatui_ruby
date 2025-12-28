// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::{prelude::*, Error, Value};
use ratatui::{layout::Rect, widgets::Widget, Frame};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    frame.render_widget(ratatui::widgets::Clear, area);

    // If a block is provided, render it on top of the cleared area
    if let Ok(block_val) = node.funcall::<_, _, Value>("block", ()) {
        if !block_val.is_nil() {
            let block = crate::style::parse_block(block_val)?;
            block.render(area, frame.buffer_mut());
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use ratatui::{backend::TestBackend, layout::Rect, Terminal};

    #[test]
    fn test_clear_renders_without_error() {
        let backend = TestBackend::new(10, 5);
        let mut terminal = Terminal::new(backend).unwrap();

        terminal
            .draw(|frame| {
                let area = Rect::new(0, 0, 10, 5);
                frame.render_widget(ratatui::widgets::Clear, area);
            })
            .unwrap();
    }
}
