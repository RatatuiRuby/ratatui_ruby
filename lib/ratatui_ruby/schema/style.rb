# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
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
    #   # Standard colors
    #   Style.new(fg: :red, bg: :white, modifiers: [:bold])
    #
    #   # Hex colors
    #   Style.new(fg: "#ff00ff")
    class Style < Data.define(:fg, :bg, :modifiers)
      ##
      # :attr_reader: fg
      # Foreground color.
      #
      # Symbol (<tt>:red</tt>) or Hex String (<tt>"#ffffff"</tt>).

      ##
      # :attr_reader: bg
      # Background color.
      #
      # Symbol (<tt>:black</tt>) or Hex String (<tt>"#000000"</tt>).

      ##
      # :attr_reader: modifiers
      # Text effects.
      #
      # Array of symbols: <tt>:bold</tt>, <tt>:dim</tt>, <tt>:italic</tt>, <tt>:underlined</tt>,
      # <tt>:slow_blink</tt>, <tt>:rapid_blink</tt>, <tt>:reversed</tt>, <tt>:hidden</tt>, <tt>:crossed_out</tt>.

      # Creates a new Style.
      #
      # [fg] Color (Symbol/String).
      # [bg] Color (Symbol/String).
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
    end
end
