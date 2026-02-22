// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: LGPL-3.0-or-later

use magnus::{prelude::*, Error, Value};
use ratatui::text::Text;

/// Calculate the display width of a string in terminal cells.
///
/// Delegates to Ratatui's own `Text::width()`, which uses `unicode-width`
/// internally. This guarantees the width we report to Ruby matches the
/// width Ratatui uses when laying out widgets like Table highlight symbols.
///
/// Returns the total display width in cells (not bytes or characters).
pub fn text_width(string: Value) -> Result<usize, Error> {
    let ruby = magnus::Ruby::get().unwrap();

    let s: String = String::try_convert(string).map_err(|_| {
        Error::new(
            ruby.exception_type_error(),
            "expected a String or object that converts to String",
        )
    })?;

    let text = Text::raw(&s);
    Ok(text.width())
}
