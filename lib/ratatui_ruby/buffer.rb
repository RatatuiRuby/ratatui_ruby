# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  # Buffer primitives for terminal cell inspection.
  #
  # Widgets render to an intermediate buffer, not directly to the terminal.
  # Testing and debugging require access to buffer state.
  #
  # This module mirrors +ratatui::buffer+ and provides query methods
  # for inspecting buffer contents, converting between coordinates and indices,
  # and retrieving individual cells.
  #
  # Use it in tests to verify rendered output or in debugging to inspect state.
  module Buffer
    class << self
      # Converts a position to a linear buffer index.
      #
      # Buffers store cells in a flat array, row by row. Widget code
      # works with (x, y) coordinates. Bridging these representations
      # requires index translation.
      #
      # The index is calculated as <tt>y * width + x</tt>.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   # In a 10-wide buffer, position (3, 2) maps to index 23
      #   Buffer.index_of(3, 2) # => 23
      #--
      # SPDX-SnippetEnd
      #++
      #
      # [x] Column (0-indexed from left).
      # [y] Row (0-indexed from top).
      #
      # Returns the linear index (Integer).
      def index_of(x, y)
        area = RatatuiRuby._get_terminal_area
        (y * area["width"]) + x
      end

      # Converts a linear buffer index to position coordinates.
      #
      # Inverse of +index_of+. When iterating over buffer content
      # by index, use this to recover the original coordinates.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   # In a 10-wide buffer, index 23 maps to position (3, 2)
      #   Buffer.pos_of(23) # => [3, 2]
      #--
      # SPDX-SnippetEnd
      #++
      #
      # [index] Linear buffer index (Integer).
      #
      # Returns <tt>[x, y]</tt> coordinates.
      def pos_of(index)
        area = RatatuiRuby._get_terminal_area
        width = area["width"]
        x = index % width
        y = index / width
        [x, y]
      end

      # Returns the Cell at the specified position.
      #
      # Tests assert on cell contents. This method provides direct
      # access without iterating the entire buffer.
      #
      # Delegates to +RatatuiRuby.get_cell_at+.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   cell = Buffer.get(0, 0)
      #   assert_equal "H", cell.char
      #--
      # SPDX-SnippetEnd
      #++
      #
      # [x] Column (0-indexed from left).
      # [y] Row (0-indexed from top).
      #
      # Returns a Buffer::Cell containing the character and style at that position.
      def get(x, y)
        RatatuiRuby.get_cell_at(x, y)
      end

      # Returns all cells in the buffer as a flat array.
      #
      # Snapshot testing compares entire buffer states. Manually
      # iterating coordinates is verbose and error-prone.
      #
      # This method returns every cell, ordered row by row
      # (top to bottom, left to right).
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   cells = Buffer.content
      #   cells.each { |cell| puts cell.char }
      #--
      # SPDX-SnippetEnd
      #++
      #
      # Returns an Array of Buffer::Cell objects.
      def content
        area = RatatuiRuby._get_terminal_area
        width = area["width"]
        height = area["height"]
        cells = [] #: Array[Buffer::Cell]
        (0...height).each do |y|
          (0...width).each do |x|
            cells << RatatuiRuby.get_cell_at(x, y)
          end
        end
        cells
      end

      # Ruby-idiomatic alias (TIMTOWTDI)
      alias [] get
    end
  end
end

require_relative "buffer/cell"
