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
  # {rdoc-image:/doc/images/widget_sparkline_demo.png}[link:/examples/widget_sparkline_demo/app_rb.html]
  #
  # === Example
  #
  # Run the interactive demo from the terminal:
  #
  #   ruby examples/widget_sparkline_demo/app.rb
  class Sparkline < Data.define(:data, :max, :style, :block, :direction, :absent_value_symbol, :absent_value_style, :bar_set)
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

    ##
    # :attr_reader: absent_value_symbol
    # Character to render for absent (nil) values (optional).
    #
    # If nil, absent values are rendered with a space.

    ##
    # :attr_reader: absent_value_style
    # Style for absent (nil) values (optional).

    ##
    # :attr_reader: bar_set
    # Custom characters for the bars (optional).
    #
    # A Hash with keys defining the characters for the bars.
    # Keys: <tt>:empty</tt>, <tt>:one_eighth</tt>, <tt>:one_quarter</tt>, <tt>:three_eighths</tt>, <tt>:half</tt>, <tt>:five_eighths</tt>, <tt>:three_quarters</tt>, <tt>:seven_eighths</tt>, <tt>:full</tt>.
    #
    # You can also use integers (0-8) as keys, where 0 is empty, 4 is half, and 8 is full.
    #
    # Alternatively, you can pass an Array of 9 strings, where index 0 is empty and index 8 is full.
    #
    # === Examples
    #
    #   bar_set: {
    #     empty: " ",
    #     one_eighth: " ",
    #     one_quarter: "▂",
    #     three_eighths: "▃",
    #     half: "▄",
    #     five_eighths: "▅",
    #     three_quarters: "▆",
    #     seven_eighths: "▇",
    #     full: "█"
    #   }
    #
    #   # Numeric keys (0-8)
    #   bar_set: {
    #     0 => " ", 1 => " ", 2 => "▂", 3 => "▃", 4 => "▄", 5 => "▅", 6 => "▆", 7 => "▇", 8 => "█"
    #   }
    #
    #   # Array (9 items)
    #   bar_set: [" ", " ", "▂", "▃", "▄", "▅", "▆", "▇", "█"]

    BAR_KEYS = %i[empty one_eighth one_quarter three_eighths half five_eighths three_quarters seven_eighths full].freeze

    # Creates a new Sparkline widget.
    #
    # [data] Array of Integers or nil. nil marks an absent value (distinct from 0).
    # [max] Max value (optional).
    # [style] Style (optional).
    # [block] Block (optional).
    # [direction] +:left_to_right+ or +:right_to_left+ (default: +:left_to_right+).
    # [absent_value_symbol] Character for absent (nil) values (optional).
    # [absent_value_style] Style for absent (nil) values (optional).
    # [bar_set] Hash or Array of custom characters (optional).
    def initialize(data:, max: nil, style: nil, block: nil, direction: :left_to_right, absent_value_symbol: nil, absent_value_style: nil, bar_set: nil)
      if bar_set
        if bar_set.is_a?(Array) && bar_set.size == 9
          # Convert Array to Hash using BAR_KEYS order
          bar_set = BAR_KEYS.zip(bar_set).to_h
        else
          bar_set = bar_set.dup
          # Normalize numeric keys (0-8) to symbolic keys
          BAR_KEYS.each_with_index do |key, i|
            if (val = bar_set.delete(i) || bar_set.delete(i.to_s))
              bar_set[key] = val
            end
          end
        end
      end
      coerced_data = data.map { |v| v.nil? ? nil : Integer(v) }
      super(
        data: coerced_data,
        max: max.nil? ? nil : Integer(max),
        style:,
        block:,
        direction:,
        absent_value_symbol:,
        absent_value_style:,
        bar_set:
      )
    end
  end
end
