// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::{Error, Value};
use ratatui::{buffer::Buffer, layout::Rect};

/// Cursor widget requires Frame for `set_cursor_position` - cannot be rendered to buffer alone
/// This is a no-op when rendering to buffer directly (e.g., in `insert_before`)
/// For Frame-based rendering, use `frame.set_cursor_position()` directly
#[allow(dead_code, clippy::unnecessary_wraps)]
pub fn render(_buffer: &mut Buffer, _area: Rect, _node: Value) -> Result<(), Error> {
    // Cursor positioning requires Frame.set_cursor_position(), not Buffer
    // This is intentionally a no-op for buffer-only rendering
    // The Frame wrapper in frame.rs should handle Cursor widgets specially
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
