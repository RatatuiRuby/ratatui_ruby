# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
    # Displays high-density data in a compact row.
    #
    # Users need context. A single value ("90% CPU") tells you current status, but not the trend.
    # Full charts take up too much room.
    #
    # This widget solves the density problem. It condenses history into a single line of variable-height blocks.
    #
    # Use it in dashboards, headers, or list items to providing trending data at a glance.
    #
    # === Examples
    #
    #   Sparkline.new(
    #     data: [1, 4, 3, 8, 2, 9, 3, 2],
    #     style: Style.new(fg: :yellow)
    #   )
    class Sparkline < Data.define(:data, :max, :style, :block, :direction)
      ##
      # :attr_reader: data
      # Array of integer values to plot.

      ##
      # :attr_reader: max
      # Maximum value for scaling (optional).
      #
      # If nil, derived from data max.

      ##
      # :attr_reader: style
      # Style for the bars.

      ##
      # :attr_reader: block
      # Optional wrapping block.

      ##
      # :attr_reader: direction
      # Direction to render data.
      #
      # Accepts +:left_to_right+ (default) or +:right_to_left+.
      # Use +:right_to_left+ when new data should appear on the left.

      # Creates a new Sparkline widget.
      #
      # [data] Array of Integers.
      # [max] Max value (optional).
      # [style] Style (optional).
      # [block] Block (optional).
      # [direction] +:left_to_right+ or +:right_to_left+ (default: +:left_to_right+).
      def initialize(data:, max: nil, style: nil, block: nil, direction: :left_to_right)
        super
      end
    end
end
