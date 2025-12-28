# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that displays data in a grid with rows and columns.
  #
  # [header] An array of strings or Paragraphs representing the header row.
  # [rows] An array of arrays of strings or Paragraphs representing the data rows.
  # [widths] An array of Constraint objects defining column widths.
  # [highlight_style] The style for the selected row.
  # [highlight_symbol] The symbol to display in front of the selected row.
  # [selected_row] The index of the currently selected row, or nil if none.
  # [block] An optional Block widget to wrap the table.
  # [footer] An optional array of strings or Paragraphs representing the footer row.
  # [flex] The flex mode for column widths: [:legacy, :start, :center, :end, :space_between, :space_around, :space_evenly]
  class Table < Data.define(:header, :rows, :widths, :highlight_style, :highlight_symbol, :selected_row, :block, :footer, :flex)
    # Creates a new Table.
    #
    # [header] An array of strings or Paragraphs representing the header row.
    # [rows] An array of arrays of strings or Paragraphs representing the data rows.
    # [widths] An array of Constraint objects defining column widths.
    # [highlight_style] The style for the selected row.
    # [highlight_symbol] The symbol to display in front of the selected row.
    # [selected_row] The index of the currently selected row, or nil if none.
    # [block] An optional Block widget to wrap the table.
    # [footer] An optional array of strings or Paragraphs representing the footer row.
    # [flex] The flex mode for column widths.
    def initialize(header: nil, rows: [], widths: [], highlight_style: nil, highlight_symbol: "> ", selected_row: nil, block: nil, footer: nil, flex: :legacy)
      super
    end
  end
end
