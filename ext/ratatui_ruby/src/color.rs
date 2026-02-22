// SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: LGPL-3.0-or-later

//! Color conversion functions exposed to Ruby.
//!
//! These functions wrap Ratatui's color conversion methods that require the `palette` feature.

use magnus::{Error, Ruby};
use ratatui::palette::{Hsl, Hsluv};
use ratatui::style::Color;

/// Formats an RGB color as a hex string.
fn rgb_to_hex(red: u8, green: u8, blue: u8) -> String {
    format!("#{red:02x}{green:02x}{blue:02x}")
}

/// Convert HSL values to a hex color string.
///
/// # Arguments
/// * `hue` - Hue in degrees (0-360, wraps)
/// * `saturation` - Saturation as percentage (0-100)
/// * `lightness` - Lightness as percentage (0-100)
///
/// # Returns
/// A hex color string like "#rrggbb"
pub fn from_hsl(_ruby: &Ruby, hue: f32, saturation: f32, lightness: f32) -> String {
    // Normalize: h wraps, s and l are percentages (0-100) that need to be 0-1
    let hsl = Hsl::new(hue, saturation / 100.0, lightness / 100.0);
    let color = Color::from_hsl(hsl);

    match color {
        Color::Rgb(red, green, blue) => rgb_to_hex(red, green, blue),
        _ => "#000000".to_string(),
    }
}

/// Convert `HSLuv` values to a hex color string.
///
/// `HSLuv` is a perceptually uniform color space where colors at the same
/// lightness appear equally bright regardless of hue.
///
/// # Arguments
/// * `hue` - Hue in degrees (-180 to 360, wraps)
/// * `saturation` - Saturation as percentage (0-100)
/// * `lightness` - Lightness as percentage (0-100)
///
/// # Returns
/// A hex color string like "#rrggbb"
pub fn from_hsluv(_ruby: &Ruby, hue: f32, saturation: f32, lightness: f32) -> String {
    // Hsluv expects h in degrees, s and l as percentages (0-100)
    let hsluv = Hsluv::new(hue, saturation, lightness);
    let color = Color::from_hsluv(hsluv);

    match color {
        Color::Rgb(red, green, blue) => rgb_to_hex(red, green, blue),
        _ => "#000000".to_string(),
    }
}

/// Convert a u32 to a hex color string.
///
/// # Arguments
/// * `val` - A u32 in the format 0x00RRGGBB
///
/// # Returns
/// A hex color string like "#rrggbb"
pub fn from_u32(_ruby: &Ruby, val: u32) -> String {
    let color = Color::from_u32(val);

    match color {
        Color::Rgb(red, green, blue) => rgb_to_hex(red, green, blue),
        _ => "#000000".to_string(),
    }
}

/// Register color module functions in the `RatatuiRuby` module.
pub fn register(_ruby: &Ruby, module: magnus::RModule) -> Result<(), Error> {
    module.define_module_function("_color_from_hsl", magnus::function!(from_hsl, 3))?;
    module.define_module_function("_color_from_hsluv", magnus::function!(from_hsluv, 3))?;
    module.define_module_function("_color_from_u32", magnus::function!(from_u32, 1))?;
    Ok(())
}
