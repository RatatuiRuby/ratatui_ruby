# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "chroma"
require "wcag_color_contrast"
require_relative "harmony"

# Represents a single color with format conversion and harmony generation.
#
# Colors are central to visual design. Users need to work with colors in multiple
# formats: hex, RGB, HSL. They also need to generate color schemes: shades, tints,
# and complementary colors. Managing these conversions and relationships manually
# is tedious and error-prone.
#
# This object wraps a Chroma color. It exposes format conversions. It generates
# color harmonies. It calculates contrast ratios to choose readable text colors.
#
# Use it to parse user input, transform colors, and build color palettes.
#
# === Example
#
#   color = Color.parse("#FF0000")
#   puts color.hex     # => "#FF0000"
#   puts color.rgb     # => "rgb(255, 0, 0)"
#   puts color.hsl_string  # => "hsl(0, 100%, 50%)"
#
#   # Generate harmonies
#   harmonies = color.harmonies  # => [main, shade, tint, complement, ...]
#
#   # Transform colors
#   lighter = color.tint(5)
#   darker = color.shade(3)
#   rotated = color.spin(180)
class Color
  def initialize(chroma_color)
    @chroma = chroma_color
  end

  # Parses a color string and returns a Color, or nil if the string is invalid.
  #
  # Accepts hex, RGB, HSL, and named colors. Trims whitespace and handles
  # empty strings gracefully.
  #
  # [input_str] String in any format Chroma supports (e.g., <tt>"#FF0000"</tt>, <tt>"red"</tt>, <tt>"rgb(255,0,0)"</tt>)
  #
  # === Example
  #
  #   Color.parse("#FF0000")       # => Color
  #   Color.parse("red")            # => Color
  #   Color.parse("invalid")        # => nil
  #   Color.parse("")               # => nil
  def self.parse(input_str)
    input_str = input_str.to_s.strip
    return nil if input_str.empty?

    new(Chroma.paint(input_str.dup))
  rescue
    nil
  end

  # Hex color code (uppercase).
  #
  # === Example
  #
  #   color = Color.parse("red")
  #   color.hex  # => "#FF0000"
  def hex
    @chroma.to_hex.upcase
  end

  # RGB color code.
  #
  # === Example
  #
  #   color = Color.parse("red")
  #   color.rgb  # => "rgb(255, 0, 0)"
  def rgb
    @chroma.to_rgb
  end

  # HSL color string with percentage formatting.
  #
  # === Example
  #
  #   color = Color.parse("red")
  #   color.hsl_string  # => "hsl(0, 100%, 50%)"
  def hsl_string
    hsl_obj = @chroma.hsl
    h = hsl_obj.h
    s = hsl_obj.s
    l = hsl_obj.l
    format("hsl(%.0f, %.1f%%, %.1f%%)", h, s * 100, l * 100)
  end

  # Darkens the color. Returns a new Color.
  #
  # [amount] Integer amount to darken (default: 3)
  #
  # === Example
  #
  #   color = Color.parse("red")
  #   color.shade(5).hex  # => darker red
  def shade(amount = 3)
    Color.new(@chroma.darken(amount))
  end

  # Lightens the color. Returns a new Color.
  #
  # [amount] Integer amount to lighten (default: 3)
  #
  # === Example
  #
  #   color = Color.parse("red")
  #   color.tint(5).hex  # => lighter red
  def tint(amount = 3)
    Color.new(@chroma.lighten(amount))
  end

  # Rotates the hue. Returns a new Color.
  #
  # [degrees] Integer degrees to rotate (0-360)
  #
  # === Example
  #
  #   color = Color.parse("red")
  #   color.spin(180).hex  # => cyan
  def spin(degrees)
    Color.new(@chroma.spin(degrees))
  end

  # Determines optimal text color (:white or :black) for maximum contrast.
  #
  # Uses WCAG contrast ratio calculation. Returns <tt>:white</tt> if white has
  # higher contrast; <tt>:black</tt> otherwise.
  #
  # === Example
  #
  #   Color.parse("yellow").contrasting_text_color  # => :black
  #   Color.parse("navy").contrasting_text_color    # => :white
  def contrasting_text_color
    white_contrast = WCAGColorContrast.ratio(hex.sub(/^#/, ""), "ffffff")
    black_contrast = WCAGColorContrast.ratio(hex.sub(/^#/, ""), "000000")
    (white_contrast > black_contrast) ? :white : :black
  end

  # Background color for rendering this color as a swatch.
  #
  # Returns <tt>"#000000"</tt> if text should be white; <tt>"#ffffff"</tt> if black.
  # Used to frame color swatches with contrasting borders.
  #
  # === Example
  #
  #   Color.parse("yellow").frame_color  # => "#000000"
  def frame_color
    (contrasting_text_color == :white) ? "#000000" : "#ffffff"
  end

  # Seven-color harmony: main, shade, tint, complement, split 1, split 2, split-complement.
  #
  # Generates a complete color scheme for UI design. Each harmony is a Harmony
  # value object with label, hex, and styling information.
  #
  # === Example
  #
  #   color = Color.parse("red")
  #   harmonies = color.harmonies
  #   harmonies.first.label  # => "Main"
  #   harmonies.size         # => 7
  def harmonies
    [
      harmony_with_label("Main"),
      shade.harmony_with_label("Shade"),
      tint.harmony_with_label("Tint"),
      spin(180).harmony_with_label("Comp"),
      spin(150).harmony_with_label("Split 1"),
      spin(210).harmony_with_label("Split 2"),
      spin(30).harmony_with_label("S.Comp"),
    ]
  end

  def harmony_with_label(label)
    Harmony.new(
      label:,
      hex:,
      text_color: contrasting_text_color,
      frame_color:,
    )
  end
end
