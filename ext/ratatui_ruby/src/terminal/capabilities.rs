// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Terminal capability detection functions.

use magnus::{Error, Ruby};

/// Returns color support level (8, 256, or `u16::MAX` for truecolor)
///
/// Wraps `crossterm::style::available_color_count()` which checks COLORTERM and TERM env vars.
pub fn available_color_count() -> u16 {
    ratatui::crossterm::style::available_color_count()
}

/// Query if terminal supports Kitty keyboard protocol
///
/// Note: This requires raw mode and may return errors in some environments.
pub fn supports_keyboard_enhancement() -> Result<bool, Error> {
    ratatui::crossterm::terminal::supports_keyboard_enhancement().map_err(|e| {
        Error::new(
            Ruby::get().unwrap().exception_runtime_error(),
            e.to_string(),
        )
    })
}

/// Query terminal window size in characters and pixels
///
/// Wraps `crossterm::terminal::window_size()`. Returns
/// Some((columns, rows, `pixel_width`, `pixel_height`)) or None if query fails.
/// Note: Pixel dimensions may be 0 on some systems (marked as "unused" by Unix drivers,
/// not implemented on Windows).
pub fn terminal_window_size() -> Option<(u16, u16, u16, u16)> {
    match ratatui::crossterm::terminal::window_size() {
        Ok(size) => Some((size.columns, size.rows, size.width, size.height)),
        Err(_) => None,
    }
}

/// Globally override `NO_COLOR` detection
///
/// Wraps `crossterm::style::force_color_output()`. When enabled, color output will
/// be forced even if `NO_COLOR` is set. Useful for `--color=always` flags.
pub fn force_color_output(enable: bool) {
    ratatui::crossterm::style::force_color_output(enable);
}
