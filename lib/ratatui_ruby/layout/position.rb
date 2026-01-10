# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Layout
    # A position in terminal coordinates.
    #
    # Layout code passes x/y pairs between functions. Bundling them
    # into separate variables is verbose and prone to ordering mistakes.
    #
    # This class wraps column and row into a single immutable object.
    # Pass it around, destructure it, or convert from a Rect.
    #
    # Use it for cursor positioning, mouse coordinates, or anywhere
    # you need to represent a single point on the terminal grid.
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   pos = Layout::Position.new(x: 10, y: 5)
    #   puts "Cursor at column #{pos.x}, row #{pos.y}"
    #
    #   # Extract from a Rect
    #   rect = Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
    #   pos = rect.as_position # => Position(x: 10, y: 5)
    #--
    # SPDX-SnippetEnd
    #++
    class Position < Data.define(:x, :y)
      ##
      # :attr_reader: x
      # Column index (0-indexed from left edge).

      ##
      # :attr_reader: y
      # Row index (0-indexed from top edge).

      # Creates a new Position.
      #
      # [x] Column index (Integer, coerced via +Integer()+).
      # [y] Row index (Integer, coerced via +Integer()+).
      def initialize(x: 0, y: 0)
        super(x: Integer(x), y: Integer(y))
      end
    end
  end
end
