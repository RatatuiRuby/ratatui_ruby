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
          r = (value >> 16) & 0xFF
          g = (value >> 8) & 0xFF
          b = value & 0xFF
          format("#%02x%02x%02x", r, g, b)
        end

        # Creates a color from HSL (Hue, Saturation, Lightness) values.
        #
        # Color pickers often use HSL because it matches human perception
        # better than RGB. Converting HSL to RGB manually requires math.
        #
        # This method handles the conversion.
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
          # Normalize to 0-1 range
          h = h.to_f % 360
          s = s.to_f / 100.0
          l = l.to_f / 100.0

          # HSL to RGB conversion
          c = (1 - ((2 * l) - 1).abs) * s
          x = c * (1 - (((h / 60.0) % 2) - 1).abs)
          m = l - (c / 2.0)

          r1, g1, b1 = case h
                       when 0...60 then [c, x, 0]
                       when 60...120 then [x, c, 0]
                       when 120...180 then [0, c, x]
                       when 180...240 then [0, x, c]
                       when 240...300 then [x, 0, c]
                       else [c, 0, x]
          end

          r = ((r1 + m) * 255).round
          g = ((g1 + m) * 255).round
          b = ((b1 + m) * 255).round

          format("#%02x%02x%02x", r, g, b)
        end

        # Ruby-idiomatic aliases (TIMTOWTDI)
        alias hex from_u32
        alias hsl from_hsl
      end
    end
  end
end
