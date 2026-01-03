# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  module Widgets
    # A styled table row combining cells with optional row-level styling.
    #
    # By default, Table rows are arrays of cell content. For more control over styling
    # individual rows, wrap the cells in a Row object to apply row-level style.
    #
    # The cells can be Strings, Text::Spans, Text::Lines, Paragraphs, or Cells.
    # The style applies to the entire row background.
    #
    # === Examples
    #
    #   # Row with red background
    #   Row.new(cells: ["Error", "Something went wrong"], style: Style.new(bg: :red))
    #
    #   # Row with styled cells and custom height
    #   Row.new(
    #     cells: [
    #       Text::Span.new(content: "Status", style: Style.new(modifiers: [:bold])),
    #       Text::Span.new(content: "OK", style: Style.new(fg: :green))
    #     ],
    #     height: 2
    #   )
    class Row < Data.define(:cells, :style, :height, :top_margin, :bottom_margin)
      ##
      # :attr_reader: cells
      # The cells to display (Array of Strings, Text::Spans, Text::Lines, Paragraphs, or Cells).

      ##
      # :attr_reader: style
      # The style to apply to the row (optional Style).

      ##
      # :attr_reader: height
      # Fixed row height in lines (optional Integer).

      ##
      # :attr_reader: top_margin
      # Margin above the row in lines (optional Integer).

      ##
      # :attr_reader: bottom_margin
      # Margin below the row in lines (optional Integer).

      # Creates a new Row.
      #
      # [cells] Array of Strings, Text::Spans, Text::Lines, Paragraphs, or Cells.
      # [style] Style object (optional).
      # [height] Integer for fixed height (optional).
      # [top_margin] Integer for top margin (optional).
      # [bottom_margin] Integer for bottom margin (optional).
      def initialize(cells:, style: nil, height: nil, top_margin: nil, bottom_margin: nil)
        super(
          cells:,
          style:,
          height: height.nil? ? nil : Integer(height),
          top_margin: top_margin.nil? ? nil : Integer(top_margin),
          bottom_margin: bottom_margin.nil? ? nil : Integer(bottom_margin)
        )
      end
    end
  end
end
