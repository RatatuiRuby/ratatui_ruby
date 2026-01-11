# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Style
    # Color constructors for creating RGB color values.
    #
    # Styles accept colors in multiple formats: symbols (<tt>:red</tt>),
    # indexed integers (0-255), or hex strings (<tt>"#FF0000"</tt>).
    # Converting from other color representations manually is tedious.
    #
    # This module provides factory methods matching Ratatui's Color API.
    # Convert from hex integers, HSL, or other formats in a single call.
    #
    # Use these constructors when you have color data in non-standard formats.
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   # From a hex integer (common in design tools)
    #   red = Style::Color.from_u32(0xFF0000)
    #   style = Style::Style.new(fg: red)
    #
    #   # From HSL (common in color pickers)
    #   blue = Style::Color.from_hsl(240, 100, 50)
    #   style = Style::Style.new(bg: blue)
    #--
    # SPDX-SnippetEnd
    #++
    module Color
      class << self
        # Creates a color from a 32-bit unsigned integer.
        #
        # Design tools and APIs often represent colors as hex integers.
        # Manually extracting RGB components and formatting is error-prone.
        #
        # This method parses the integer and returns a hex string
        # ready for use with Style.
        #
        # === Example
        #
        #--
        # SPDX-SnippetBegin
        # SPDX-FileCopyrightText: 2026 Kerrick Long
        # SPDX-License-Identifier: MIT-0
        #++
        #   Color.from_u32(0xFF0000) # => "#ff0000" (red)
        #   Color.from_u32(0x00FF00) # => "#00ff00" (green)
        #   Color.from_u32(0x0000FF) # => "#0000ff" (blue)
        #--
        # SPDX-SnippetEnd
        #++
        #
        # [value] Integer in <tt>0xRRGGBB</tt> format.
        #
        # Returns a hex string like <tt>"#rrggbb"</tt>.
        def from_u32(value)
          RatatuiRuby._color_from_u32(value)
        end

        # Creates a color from HSL (Hue, Saturation, Lightness) values.
        #
        # Color pickers often use HSL because it matches human perception
        # better than RGB. Converting HSL to RGB manually requires math.
        #
        # This method handles the conversion by delegating to Ratatui's
        # palette integration.
        #
        # Note: This implementation uses degrees (0-360) for hue and
        # percentages (0-100) for saturation and lightness, matching
        # common UI conventions.
        #
        # === Example
        #
        #--
        # SPDX-SnippetBegin
        # SPDX-FileCopyrightText: 2026 Kerrick Long
        # SPDX-License-Identifier: MIT-0
        #++
        #   Color.from_hsl(0, 100, 50)   # => "#ff0000" (red)
        #   Color.from_hsl(120, 100, 50) # => "#00ff00" (green)
        #   Color.from_hsl(240, 100, 50) # => "#0000ff" (blue)
        #   Color.from_hsl(0, 0, 50)     # => "#808080" (gray)
        #--
        # SPDX-SnippetEnd
        #++
        #
        # [h] Hue in degrees (0-360). Values wrap automatically.
        # [s] Saturation as percentage (0-100).
        # [l] Lightness as percentage (0-100).
        #
        # Returns a hex string like <tt>"#rrggbb"</tt>.
        def from_hsl(h, s, l)
          RatatuiRuby._color_from_hsl(h.to_f, s.to_f, l.to_f)
        end

        # Ruby-idiomatic aliases (TIMTOWTDI)
        alias hex from_u32
        alias hsl from_hsl

        # Creates a color from HSLuv (Human-friendly Hue, Saturation, Lightness) values.
        #
        # HSLuv is a perceptually uniform color space. Unlike standard HSL,
        # colors at the same lightness appear equally bright regardless of hue.
        # This makes it ideal for generating color palettes with consistent
        # perceived brightness.
        #
        # This method delegates to Ratatui's palette integration for the
        # complex HSLuv to RGB conversion.
        #
        # Note: Ratatui uses the range [-180, 180] for hue and [0, 100] for
        # saturation and lightness. This implementation matches those conventions.
        #
        # === Example
        #
        #--
        # SPDX-SnippetBegin
        # SPDX-FileCopyrightText: 2026 Kerrick Long
        # SPDX-License-Identifier: MIT-0
        #++
        #   Color.from_hsluv(12.18, 100, 53.2)   # => "#ff0000" (bright red)
        #   Color.from_hsluv(-94.13, 100, 32.3) # => "#0000ff" (bright blue)
        #   Color.from_hsluv(0, 0, 50)          # => gray
        #--
        # SPDX-SnippetEnd
        #++
        #
        # [h] Hue in degrees (-180 to 360). Values wrap automatically.
        # [s] Saturation as percentage (0-100). Values are clamped.
        # [l] Lightness as percentage (0-100). Values are clamped.
        #
        # Returns a hex string like <tt>"#rrggbb"</tt>.
        def from_hsluv(h, s, l)
          RatatuiRuby._color_from_hsluv(h.to_f, s.to_f, l.to_f)
        end

        alias hsluv from_hsluv
      end
    end
  end
end
