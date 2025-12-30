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
    #
    #   # Grouped Bar Chart
    #   BarChart.new(
    #     data: [
    #       BarGroup.new(label: "Q1", bars: [Bar.new(value: 40), Bar.new(value: 45)]),
    #       BarGroup.new(label: "Q2", bars: [Bar.new(value: 50), Bar.new(value: 55)])
    #     ],
    #     bar_width: 5,
    #     group_gap: 3
    #   )
    class BarChart < Data.define(:data, :bar_width, :bar_gap, :group_gap, :max, :style, :block, :direction, :label_style, :value_style, :bar_set)
      ##
      ##
      ##
      ##
      # :attr_reader: data
      # The data to display.
      #
      # Supports multiple formats:
      # [<tt>Hash</tt>]
      #   Mapping labels (<tt>String</tt> or <tt>Symbol</tt>) to values (<tt>Integer</tt>).
      # [<tt>Array</tt> of tuples]
      #   Ordered list of <tt>["Label", Value]</tt> or <tt>["Label", Value, Style]</tt> pairs.
      # [<tt>Array</tt> of <tt>BarChart::BarGroup</tt>]
      #   List of <tt>BarChart::BarGroup</tt> objects for grouped charts.
      #
      # === Examples
      #
      # Hash (Simple):
      #   { "Apples" => 10, :Oranges => 15 }
      #
      # Array of Tuples (Ordered):
      #   [["Mon", 20], ["Tue", 30], ["Wed", 25]]
      #
      # BarGroup (Grouped):
      #   [
      #     RatatuiRuby::BarChart::BarGroup.new(label: "Q1", bars: [
      #       RatatuiRuby::BarChart::Bar.new(value: 50, label: "Rev"),
      #       RatatuiRuby::BarChart::Bar.new(value: 30, label: "Cost")
      #     ])
      #   ]

      ##
      # :attr_reader: bar_width
      # Width of each bar in characters.

      ##
      # :attr_reader: bar_gap
      # Spaces between bars.

      ##
      # :attr_reader: group_gap
      # Spaces between groups (for grouped bar charts).

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

      # Creates a new BarChart widget.
      #
      # [data]
      #   Data to display. Hash, Array of arrays, or Array of BarGroup.
      # [bar_width]
      #   Width of each bar (Integer).
      # [bar_gap]
      #   Gap between bars (Integer).
      # [group_gap]
      #   Gap between groups (Integer).
      # [max]
      #   Maximum value of the bar chart (Integer).
      # [style]
      #   Base style for the widget (Style).
      # [block]
      #   Block to render around the chart (Block).
      # [direction]
      #   Direction of the bars (:vertical or :horizontal).
      # [label_style]
      #   Style object for labels (optional).
      # [value_style]
      #   Style object for values (optional).
      # [bar_set]
      #   Hash or Array: Custom characters for the bars.
      def initialize(data:, bar_width: 3, bar_gap: 1, group_gap: 0, max: nil, style: nil, block: nil, direction: :vertical, label_style: nil, value_style: nil, bar_set: nil)
        if bar_set
          if bar_set.is_a?(Array) && bar_set.size == 9
            # Convert Array to Hash using BAR_KEYS order
            bar_set = BAR_KEYS.zip(bar_set).to_h
          else
            bar_set = bar_set.dup
            # Normalize numeric keys (0-8) to symbolic keys
            BAR_KEYS.each_with_index do |key, i|
              if val = bar_set.delete(i) || bar_set.delete(i.to_s)
                bar_set[key] = val
              end
            end
          end
        end

        # Normalize data to Array of BarGroup
        data = if data.is_a?(Hash)
                 if direction == :horizontal
                   bars = data.map do |label, value|
                     Bar.new(value: value, label: label.to_s)
                   end
                   [BarGroup.new(label: "", bars: bars)]
                 else
                   data.map do |label, value|
                     BarGroup.new(label: label.to_s, bars: [Bar.new(value: value)])
                   end
                 end
               elsif data.is_a?(Array)
                 if data.empty?
                   []
                 elsif data.first.is_a?(BarGroup)
                   data
                 elsif data.first.is_a?(Array)
                   # Tuples
                   if direction == :horizontal
                     bars = data.map do |item|
                       label = item[0].to_s
                       value = item[1]
                       style = item[2]
                       
                       bar = Bar.new(value: value, label: label)
                       bar = bar.with(style: style) if style
                       bar
                     end
                     [BarGroup.new(label: "", bars: bars)]
                   else
                     data.map do |item|
                       label = item[0].to_s
                       value = item[1]
                       style = item[2]
                       
                       bar = Bar.new(value: value)
                       bar = bar.with(style: style) if style
                       BarGroup.new(label: label, bars: [bar])
                     end
                   end
                 else
                   # Fallback
                   data
                 end
               else
                 data
               end

        super(data: data, bar_width: bar_width, bar_gap: bar_gap, group_gap: group_gap, max: max, style: style, block: block, direction: direction, label_style: label_style, value_style: value_style, bar_set: bar_set)
      end
    end
end
