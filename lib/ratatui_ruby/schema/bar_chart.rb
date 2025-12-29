# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
    # Displays categorical data as bars.
    #
    # Raw tables of numbers are hard to scan. Comparing magnitudes requires mental arithmetic, which slows down decision-making.
    #
    # This widget visualizes the data. It renders vertical bars proportional to their value.
    #
    # Use it to compare server loads, sales figures, or any discrete datasets.
    #
    # === Examples
    #
    #   BarChart.new(
    #     data: { "US" => 40, "EU" => 35, "AP" => 25 },
    #     bar_width: 5,
    #     style: Style.new(fg: :green)
    #   )
    class BarChart < Data.define(:data, :bar_width, :bar_gap, :max, :style, :block, :direction, :label_style, :value_style)
      ##
      # :attr_reader: data
      # The dataset relative to category labels.
      #
      #   { "CPU" => 90, "MEM" => 40 }

      ##
      # :attr_reader: bar_width
      # Width of each bar in characters.

      ##
      # :attr_reader: bar_gap
      # Spaces between bars.

      ##
      # :attr_reader: max
      # Maximum value for the Y-axis (optional).
      #
      # If nil, it is calculated from the data.

      ##
      # :attr_reader: style
      # Style for the bars.

      ##
      # :attr_reader: block
      # Optional wrapping block.

      ##
      # :attr_reader: label_style
      # Style for the bar labels (optional).

      ##
      # :attr_reader: value_style
      # Style for the bar values (optional).

      # Creates a new BarChart widget.
      #
      # [data]
      #   Hash of { "Label" => Integer }.
      # [bar_width]
      #   Width in cells (Integer, default: 3).
      # [bar_gap]
      #   Gap in cells (Integer, default: 1).
      # [max]
      #   Max Y value (Integer, optional).
      # [style]
      #   Style object for the bars (optional).
      # [block]
      #   Block wrapper (optional).
      # [direction]
      #   Direction of the bars (:vertical or :horizontal, default: :vertical).
      # [label_style]
      #   Style object for labels (optional).
      # [value_style]
      #   Style object for values (optional).
      def initialize(data:, bar_width: 3, bar_gap: 1, max: nil, style: nil, block: nil, direction: :vertical, label_style: nil, value_style: nil)
        super
      end
    end
end
