# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Style
    # Defines colors and text modifiers.
    #
    # The terminal is traditionally monochrome, but efficient interfaces use color to convey meaning.
    # Red for errors. Green for success. Bold for headers.
    #
    # This value object encapsulates those choices. It applies foreground and background colors. It adds effects like italics or blinking.
    #
    # Use it to theme your application or highlight critical data.
    #
    # === Examples
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   # Standard colors
    #   Style::Style.new(fg: :red, bg: :white, modifiers: [:bold])
    #
    #   # Hex colors
    #   Style::Style.new(fg: "#ff00ff")
    #
    #--
    # SPDX-SnippetEnd
    #++
    # === Supported Colors
    #
    # ==== Integer
    # Represents an indexed color from the Xterm 256-color palette (0-255).
    # * <tt>0</tt>–<tt>15</tt>: Standard and bright ANSI colors.
    # * <tt>16</tt>–<tt>231</tt>: {6x6x6 Color Cube}[https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit].
    # * <tt>232</tt>–<tt>255</tt>: Grayscale ramp.
    #
    # ==== Symbol
    # Represents a named color from the standard ANSI palette. Supported values:
    # * <tt>:black</tt>, <tt>:red</tt>, <tt>:green</tt>, <tt>:yellow</tt>,
    #   <tt>:blue</tt>, <tt>:magenta</tt>, <tt>:cyan</tt>, <tt>:gray</tt>
    # * <tt>:dark_gray</tt>, <tt>:light_red</tt>, <tt>:light_green</tt>,
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   <tt>:light_yellow</tt>, <tt>:light_blue</tt>, <tt>:light_magenta</tt>,
    #   <tt>:light_cyan</tt>, <tt>:white</tt>
    #--
    # SPDX-SnippetEnd
    #++
    # * <tt>:reset</tt> — Restores the terminal's default color.
    #
    # ==== String
    # Represents a specific RGB color using a Hex code (<tt>"#RRGGBB"</tt>).
    # Requires a terminal emulator with "True Color" (24-bit color) support.
    class Style < Data.define(:fg, :bg, :modifiers)
      ##
      # :attr_reader: fg
      # Foreground color.
      #
      # Symbol (<tt>:red</tt>), Hex String (<tt>"#ffffff"</tt>), or Integer (0-255).

      ##
      # :attr_reader: bg
      # Background color.
      #
      # Symbol (<tt>:black</tt>), Hex String (<tt>"#000000"</tt>), or Integer (0-255).

      ##
      # :attr_reader: modifiers
      # Text effects.
      #
      # Array of symbols: <tt>:bold</tt>, <tt>:dim</tt>, <tt>:italic</tt>, <tt>:underlined</tt>,
      # <tt>:slow_blink</tt>, <tt>:rapid_blink</tt>, <tt>:reversed</tt>, <tt>:hidden</tt>, <tt>:crossed_out</tt>.

      # Creates a new Style.
      #
      # [fg] Color (Symbol/String/Integer).
      # [bg] Color (Symbol/String/Integer).
      # [modifiers] Array of Symbols.
      def initialize(fg: nil, bg: nil, modifiers: [])
        super
      end

      # Returns an empty style.
      #
      # Use this as a baseline to prevent style inheritance issues or when no styling is required.
      def self.default
        new
      end

      # Creates a new Style (convenience alias for {#initialize}).
      #
      # Constructor keyword arguments require typing out the full <tt>Style.new</tt> form.
      # This gets verbose in tight layout code or one-liners.
      #
      # <tt>Style.with</tt> reads more naturally and enables method chaining.
      # It shows intent: "use this style with these properties."
      #
      # Use it for inline styling where conciseness matters.
      #
      # === Examples
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Style.with(fg: :red, bg: :black, modifiers: [:bold])
      #   paragraph = Paragraph.new(text: "Alert!", style: Style.with(fg: :red))
      #--
      # SPDX-SnippetEnd
      #++
      #
      # @return [Style]
      def self.with(fg: nil, bg: nil, modifiers: [])
        new(fg:, bg:, modifiers:)
      end
    end
  end
end
