// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::{prelude::*, Error, Value};

/// Calculate the display width of a string in terminal cells.
///
/// Handles unicode correctly, including:
/// - Regular ASCII characters: 1 cell each
/// - CJK characters: 2 cells each (full-width)
/// - Emoji: typically 2 cells each (varies by terminal)
/// - Combining marks and zero-width characters: 0 cells
///
/// This uses the same `unicode-width` crate that Ratatui uses internally.
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

    // Use unicode_width's width calculation.
    // This is the same mechanism Ratatui uses internally for Paragraph.line_width().
    let width = s
        .chars()
        .map(|c| unicode_width::UnicodeWidthChar::width(c).unwrap_or(0))
        .sum();

    Ok(width)
}

#[cfg(test)]
mod tests {
    use unicode_width::UnicodeWidthChar;

    fn measure_width(s: &str) -> usize {
        s.chars()
            .map(|c| UnicodeWidthChar::width(c).unwrap_or(0))
            .sum()
    }

    #[test]
    fn test_ascii_width() {
        // ASCII is 1 cell per character
        assert_eq!(measure_width("hello"), 5);
        assert_eq!(measure_width("Hello, World!"), 13);
    }

    #[test]
    fn test_emoji_width() {
        // Emoji typically take 2 cells
        // 👍 is U+1F44D THUMBS UP SIGN, width 2
        assert_eq!(measure_width("👍"), 2);
        // 🌍 is U+1F30D EARTH GLOBE EUROPE-AFRICA, width 2
        assert_eq!(measure_width("🌍"), 2);
        // "Hello 👍" = 5 + 1 + 2 = 8
        assert_eq!(measure_width("Hello 👍"), 8);
    }

    #[test]
    fn test_cjk_width() {
        // CJK characters are full-width, 2 cells each
        // 你 (U+4F60) is width 2
        assert_eq!(measure_width("你"), 2);
        // 好 (U+597D) is width 2
        assert_eq!(measure_width("好"), 2);
        // "你好" should be 4
        assert_eq!(measure_width("你好"), 4);
    }

    #[test]
    fn test_mixed_width() {
        // "a你b好" = 1 + 2 + 1 + 2 = 6
        assert_eq!(measure_width("a你b好"), 6);
    }

    #[test]
    fn test_empty_string() {
        assert_eq!(measure_width(""), 0);
    }

    #[test]
    fn test_spaces_and_punctuation() {
        // Regular ASCII space and punctuation are 1 cell each
        assert_eq!(measure_width("a b c"), 5);
        assert_eq!(measure_width("!!!"), 3);
    }

    #[test]
    fn test_combining_marks() {
        // Zero-width marks don't add to width
        // "a" + combining acute accent (U+0301)
        let combining = "a\u{0301}";
        assert_eq!(measure_width(combining), 1);
    }
}
