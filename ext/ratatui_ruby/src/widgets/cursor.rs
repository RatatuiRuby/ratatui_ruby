// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::{Error, Value, prelude::*};
use ratatui::{layout::Rect, Frame};

pub fn render(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let x: u16 = node.funcall("x", ())?;
    let y: u16 = node.funcall("y", ())?;
    frame.set_cursor(area.x + x, area.y + y);
    Ok(())
}

#[cfg(test)]
mod tests {

    use ratatui::layout::Rect;
    
    #[test]
    fn test_cursor_math() {
        let area = Rect::new(10, 10, 50, 50);
        let x = 5;
        let y = 5;
        let abs_x = area.x + x;
        let abs_y = area.y + y;
        assert_eq!(abs_x, 15);
        assert_eq!(abs_y, 15);
    }
}
