# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Draw commands for custom widgets.
  #
  # Custom widgets return an array of Draw commands instead of writing directly to a buffer.
  # This keeps all pointers safely inside Rust while Ruby works with pure data.
  #
  # === Example
  #
  #   class MyWidget
  #     def render(area)
  #       [
  #         RatatuiRuby::Draw.string(area.x, area.y, "Hello", {fg: :red}),
  #         RatatuiRuby::Draw.cell(area.x + 6, area.y, RatatuiRuby::Cell.char("!"))
  #       ]
  #     end
  #   end
  module Draw
    # Command to draw a string at the given coordinates.
    #
    # [x] X coordinate (absolute).
    # [y] Y coordinate (absolute).
    # [string] The text to draw.
    # [style] Style hash or Style object.
    StringCmd = Data.define(:x, :y, :string, :style)

    # Command to draw a cell at the given coordinates.
    #
    # [x] X coordinate (absolute).
    # [y] Y coordinate (absolute).
    # [cell] The Cell to draw.
    CellCmd = Data.define(:x, :y, :cell)

    # Creates a string draw command.
    #
    # [x] X coordinate.
    # [y] Y coordinate.
    # [string] Text to draw.
    # [style] Optional style (Hash or Style).
    def self.string(x, y, string, style = {}) = StringCmd.new(x:, y:, string:, style:)

    # Creates a cell draw command.
    #
    # [x] X coordinate.
    # [y] Y coordinate.
    # [cell] Cell to draw.
    def self.cell(x, y, cell) = CellCmd.new(x:, y:, cell:)
  end
end
