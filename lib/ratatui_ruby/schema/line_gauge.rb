# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
    # Displays a compact, single-line progress bar.
    #
    # Screen space is precious. Standard block gauges are bulky and consume multiple rows.
    #
    # This widget compresses the feedback. It draws a progress bar using line characters, fitting perfectly into tight layouts or lists.
    #
    # Use it when you need to show status without stealing focus or space.
    #
    # === Examples
    #
    #   LineGauge.new(
    #     ratio: 0.4,
    #     filled_style: Style.new(fg: :blue),
    #     unfilled_symbol: "-"
    #   )
    class LineGauge < Data.define(:ratio, :label, :filled_style, :unfilled_style, :block, :filled_symbol, :unfilled_symbol)
      ##
      # :attr_reader: ratio
      # Progress ratio from 0.0 to 1.0.

      ##
      # :attr_reader: label
      # Optional label.

      ##
      # :attr_reader: filled_style
      # Style for the completed portion.

      ##
      # :attr_reader: unfilled_style
      # Style for the remainder.

      ##
      # :attr_reader: block
      # Optional wrapping block.

      ##
      # :attr_reader: filled_symbol
      # Character for filled segments.

      ##
      # :attr_reader: unfilled_symbol
      # Character for empty segments.

      # Creates a new LineGauge.
      #
      # [ratio] Float (0.0 - 1.0).
      # [label] String (optional).
      # [filled_style] Style.
      # [unfilled_style] Style.
      # [block] Block.
      # [filled_symbol] String (default: <tt>"█"</tt>).
      # [unfilled_symbol] String (default: <tt>"░"</tt>).
      def initialize(ratio: 0.0, label: nil, filled_style: nil, unfilled_style: nil, block: nil, filled_symbol: "█", unfilled_symbol: "░")
        super
      end
    end
end
