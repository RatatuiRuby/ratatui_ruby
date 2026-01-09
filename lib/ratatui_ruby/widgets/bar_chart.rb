# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Widgets
    # Displays categorical data as bars.
    #
    # Raw tables of numbers are hard to scan. Comparing magnitudes requires mental arithmetic, which slows down decision-making.
    #
    # This widget visualizes the data. It renders vertical bars proportional to their value.
    #
    # Use it to compare server loads, sales figures, or any discrete datasets.
    #
    # {rdoc-image:/doc/images/widget_barchart.png}[link:/examples/widget_barchart/app_rb.html]
    #
    # === Example
    #
    # Run the interactive demo from the terminal:
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   ruby examples/widget_barchart/app.rb
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
    #--
    # SPDX-SnippetEnd
    #++
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
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   List of <tt>BarChart::BarGroup</tt> objects for grouped charts.
      #
      #--
      # SPDX-SnippetEnd
      #++
      # === Examples
      #
      # Hash (Simple):
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   { "Apples" => 10, :Oranges => 15 }
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Array of Tuples (Ordered):
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   [["Mon", 20], ["Tue", 30], ["Wed", 25]]
      #
      #--
      # SPDX-SnippetEnd
      #++
      # BarGroup (Grouped):
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   [
      #     RatatuiRuby::BarChart::BarGroup.new(label: "Q1", bars: [
      #       RatatuiRuby::BarChart::Bar.new(value: 50, label: "Rev"),
      #       RatatuiRuby::BarChart::Bar.new(value: 30, label: "Cost")
      #     ])
      #   ]
      #--
      # SPDX-SnippetEnd
      #++

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
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
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
      #--
      # SPDX-SnippetEnd
      #++

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
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Symbol, Hash, or Array: Custom characters for bars.
      #   Symbols: <tt>:nine_levels</tt> (default gradient), <tt>:three_levels</tt> (simplified).
      #--
      # SPDX-SnippetEnd
      #++
      def initialize(data:, bar_width: 3, bar_gap: 1, group_gap: 0, max: nil, style: nil, block: nil, direction: :vertical, label_style: nil, value_style: nil, bar_set: nil)
        # Normalize bar_set to Hash[Symbol, String] if provided as Array or Hash
        bar_set = case bar_set
                  when Symbol, nil
                    bar_set
                  when Array
                    # Convert Array to Hash using BAR_KEYS order
                    BAR_KEYS.zip(bar_set).to_h
                  when Hash
                    # @type var raw_hash: Hash[untyped, untyped]
                    raw_hash = bar_set.dup
                    normalized = {} #: Hash[Symbol, String]
                    # Normalize numeric keys (0-8) to symbolic keys
                    BAR_KEYS.each_with_index do |key, i|
                      val = raw_hash.delete(i) || raw_hash.delete(i.to_s) || raw_hash.delete(key)
                      normalized[key] = val.to_s if val
                    end
                    normalized
                  else
                    bar_set
        end

        # Normalize data to Array of BarGroup
        data = if data.is_a?(Hash)
          if direction == :horizontal
            bars = data.map do |label, value|
              Bar.new(value:, label: label.to_s)
            end
            [BarGroup.new(label: "", bars:)]
          else
            data.map do |label, value|
              BarGroup.new(label: label.to_s, bars: [Bar.new(value:)])
            end
          end
        elsif data.is_a?(Array)
          if data.empty?
            []
          elsif data.first.is_a?(BarGroup)
            data
          elsif data.first.is_a?(Array)
            # Tuples - use type assertion for Steep
            if direction == :horizontal
              bars = data.map do |item|
                tuple = item #: Array[untyped]
                label = tuple[0].to_s
                value = tuple[1]
                style = tuple[2]

                bar = Bar.new(value:, label:)
                bar = bar.with(style:) if style
                bar
              end
              [BarGroup.new(label: "", bars:)]
            else
              data.map do |item|
                tuple = item #: Array[untyped]
                label = tuple[0].to_s
                value = tuple[1]
                style = tuple[2]

                bar = Bar.new(value:)
                bar = bar.with(style:) if style
                BarGroup.new(label:, bars: [bar])
              end
            end
          else
            # Fallback
            data
          end
        else
          data
        end

        super(
          data:,
          bar_width: Integer(bar_width),
          bar_gap: Integer(bar_gap),
          group_gap: Integer(group_gap),
          max: max.nil? ? nil : Integer(max),
          style:,
          block:,
          direction:,
          label_style:,
          value_style:,
          bar_set:
        )
      end
    end
  end
end
