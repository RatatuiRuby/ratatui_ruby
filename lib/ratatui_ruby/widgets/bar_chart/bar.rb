# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  module Widgets
    class BarChart
      # A bar in a grouped bar chart.
      #
      # === Examples
      #
      #   BarChart::Bar.new(value: 10, style: Style.new(fg: :red), label: "A")
      class Bar < Data.define(:value, :label, :style, :value_style, :text_value)
        ##
        # :attr_reader: value
        # The value of the bar (Integer).

        ##
        # :attr_reader: label
        # The label of the bar (optional String, Text::Span, or Text::Line for rich styling).

        ##
        # :attr_reader: style
        # The style of the bar (optional Style).

        ##
        # :attr_reader: value_style
        # The style of the value (optional Style).

        ##
        # :attr_reader: text_value
        # The text to display as the value (optional String, Text::Span, or Text::Line for rich styling).

        def initialize(value:, label: nil, style: nil, value_style: nil, text_value: nil)
          super(
            value: Integer(value),
            label:,
            style:,
            value_style:,
            text_value:
          )
        end
      end
    end
  end
end
