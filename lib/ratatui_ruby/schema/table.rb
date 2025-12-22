# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Data Grid
  # [header] Array of Strings (or Cells)
  # [rows] Array of Arrays of Strings (or Cells)
  # [widths] Array of Constraints (e.g. [Constraint.length(10), Constraint.min(0)])
  # [block] optional block widget
  Table = Data.define(:header, :rows, :widths, :block) do
    # Creates a new Table.
    # [header] the header row.
    # [rows] the data rows.
    # [widths] the column widths.
    # [block] the block to wrap the table.
    def initialize(header: nil, rows: [], widths: [], block: nil)
      super
    end
  end
end
