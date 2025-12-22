# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that displays numeric data as a bar chart.
  #
  # [data] A hash of { "Label" => value (Integer) }.
  # [bar_width] The width of each bar in the chart.
  # [bar_gap] The gap between bars.
  # [max] Optional maximum value for the Y-axis.
  # [style] Optional style for the bars.
  # [block] Optional block widget to wrap the chart.
  class BarChart < Data.define(:data, :bar_width, :bar_gap, :max, :style, :block)
    # Creates a new BarChart widget.
    #
    # [data] A hash of { "Label" => value (Integer) }.
    # [bar_width] The width of each bar in the chart.
    # [bar_gap] The gap between bars.
    # [max] Optional maximum value for the Y-axis.
    # [style] Optional style for the bars.
    # [block] Optional block widget to wrap the chart.
    def initialize(data:, bar_width: 3, bar_gap: 1, max: nil, style: nil, block: nil)
      super
    end
  end
end
