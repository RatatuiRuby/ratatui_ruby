# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Displays structured data in rows and columns.
  #
  # Data is often multidimensional. You need to show relationships between fields (Name, Age, ID).
  # Aligning columns manually in a monospaced environment is painful and error-prone.
  #
  # This widget creates a grid. It enforces column widths using constraints. It renders headers, rows, and footers aligned perfectly.
  #
  # Use it to display database records, logs, or file lists.
  #
  # {rdoc-image:/doc/images/widget_table_flex.png}[link:/examples/widget_table_flex/app_rb.html]
  #
  # === Example
  #
  # Run the interactive demo from the terminal:
  #
  #   ruby examples/widget_table_flex/app.rb
  class Table < Data.define(:header, :rows, :widths, :highlight_style, :highlight_symbol, :highlight_spacing, :column_highlight_style, :cell_highlight_style, :selected_row, :selected_column, :offset, :block, :footer, :flex, :style, :column_spacing)
    ##
    # :attr_reader: header
    # Header row content (Array of Strings, Text::Spans, Text::Lines, or Paragraphs).

    ##
    # :attr_reader: rows
    # Data rows (Array of Arrays). Each cell can be String, Text::Span, Text::Line, Paragraph, or Cell.

    ##
    # :attr_reader: widths
    # Column width constraints (Array of Constraint).

    ##
    # :attr_reader: highlight_style
    # Style for the selected row.

    ##
    # :attr_reader: highlight_symbol
    # Symbol for the selected row.

    ##
    # :attr_reader: highlight_spacing
    # When to show the highlight symbol column (<tt>:always</tt>, <tt>:when_selected</tt>, <tt>:never</tt>).

    ##
    # :attr_reader: column_highlight_style
    # Style for the selected column.

    ##
    # :attr_reader: cell_highlight_style
    # Style for the selected cell (intersection of row and column).

    ##
    # :attr_reader: selected_row
    # Index of the selected row (Integer or nil).

    ##
    # :attr_reader: selected_column
    # Index of the selected column (Integer or nil).

    ##
    # :attr_reader: offset
    # Scroll offset (Integer or nil).
    #
    # Controls the viewport's starting row position in the table.
    #
    # When +nil+ (default), Ratatui auto-scrolls to keep the selection visible ("natural scrolling").
    #
    # When set, forces the viewport to start at this row index. Use this for:
    # - **Passive scrolling**: Scroll through a log table without selecting rows.
    # - **Click-to-select math**: Calculate which row index corresponds to a click coordinate.
    #
    # *Important*: When both +offset+ and +selected_row+ are set, Ratatui may still adjust
    # the viewport during rendering to ensure the selection stays visible. Set +selected_row+
    # to +nil+ for fully manual scroll control.

    ##
    # :attr_reader: block
    # Optional wrapping block.

    ##
    # :attr_reader: footer
    # Footer row content (Array of Strings, Text::Spans, Text::Lines, or Paragraphs).

    ##
    # :attr_reader: flex
    # Flex mode for column distribution.

    ##
    # :attr_reader: style
    # Base style for the entire table.

    ##
    # :attr_reader: column_spacing
    # Spacing between columns (Integer, default 1).

    # Creates a new Table.
    #
    # [header] Array of strings, Text::Spans, Text::Lines, or paragraphs.
    # [rows] 2D Array where each cell is String, Text::Span, Text::Line, Paragraph, or Cell.
    # [widths] Array of Constraints.
    # [highlight_style] Style object.
    # [highlight_symbol] String.
    # [highlight_spacing] Symbol (optional, default: <tt>:when_selected</tt>).
    # [column_highlight_style] Style object.
    # [cell_highlight_style] Style object.
    # [selected_row] Integer (nullable).
    # [selected_column] Integer (nullable).
    # [offset] Numeric (nullable, coerced to Integer). Forces scroll position when set.
    # [block] Block (optional).
    # [footer] Array of strings/paragraphs (optional).
    # [flex] Symbol (optional, default: <tt>:legacy</tt>).
    # [style] Style object or Hash (optional).
    # [column_spacing] Integer (optional, default: 1).
    def initialize(header: nil, rows: [], widths: [], highlight_style: nil, highlight_symbol: "> ", highlight_spacing: :when_selected, column_highlight_style: nil, cell_highlight_style: nil, selected_row: nil, selected_column: nil, offset: nil, block: nil, footer: nil, flex: :legacy, style: nil, column_spacing: 1)
      super(
        header:,
        rows:,
        widths:,
        highlight_style:,
        highlight_symbol:,
        highlight_spacing:,
        column_highlight_style:,
        cell_highlight_style:,
        selected_row: selected_row.nil? ? nil : Integer(selected_row),
        selected_column: selected_column.nil? ? nil : Integer(selected_column),
        offset: offset.nil? ? nil : Integer(offset),
        block:,
        footer:,
        flex:,
        style:,
        column_spacing: Integer(column_spacing)
      )
    end
  end
end
