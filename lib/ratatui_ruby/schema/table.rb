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
    # === Examples
    #
    #   Table.new(
    #     header: ["ID", "Name", "Status"],
    #     rows: [
    #       ["1", "Hideo", "Active"],
    #       ["2", "Kojima", "Idle"]
    #     ],
    #     widths: [
    #       Constraint.length(5),
    #       Constraint.fill(1),
    #       Constraint.length(10)
    #     ]
    #   )
    class Table < Data.define(:header, :rows, :widths, :highlight_style, :highlight_symbol, :highlight_spacing, :selected_row, :block, :footer, :flex, :style, :column_spacing)
      ##
      # :attr_reader: header
      # Header row content (Array of Strings).

      ##
      # :attr_reader: rows
      # Data rows (Array of Arrays of Strings).

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
      # When to show the highlight symbol column (:always, :when_selected, :never).

      ##
      # :attr_reader: selected_row
      # Index of the selected row (Integer or nil).

      ##
      # :attr_reader: block
      # Optional wrapping block.

      ##
      # :attr_reader: footer
      # Footer row content (Array of Strings).

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
      # [header] Array of strings/paragraphs.
      # [rows] 2D Array of strings/paragraphs.
      # [widths] Array of Constraints.
      # [highlight_style] Style object.
      # [highlight_symbol] String.
      # [selected_row] Integer (nullable).
      # [block] Block (optional).
      # [footer] Array of strings/paragraphs (optional).
    # [flex] Symbol (optional, default: <tt>:legacy</tt>).
      # [style] Style object or Hash (optional).
      # [column_spacing] Integer (optional, default: 1).
      def initialize(header: nil, rows: [], widths: [], highlight_style: nil, highlight_symbol: "> ", highlight_spacing: :when_selected, selected_row: nil, block: nil, footer: nil, flex: :legacy, style: nil, column_spacing: 1)
        super
      end
    end
end
