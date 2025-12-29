# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
    # Defines a rectangular area in the terminal grid.
    #
    # Geometry management involves passing groups of four integers (`x, y, width, height`) repeatedly.
    # This is verbose and prone to parameter mismatch errors.
    #
    # This class encapsulates the geometry. It provides a standard primitive for passing area definitions
    # between layout engines and rendering functions.
    #
    # Use it when manual positioning is required or when querying layout results.
    #
    # === Examples
    #
    #   area = Rect.new(x: 0, y: 0, width: 80, height: 24)
    #   puts area.width # => 80
    class Rect < Data.define(:x, :y, :width, :height)
      ##
      # :attr_reader: x
      # X coordinate (column) of the top-left corner.

      ##
      # :attr_reader: y
      # Y coordinate (row) of the top-left corner.

      ##
      # :attr_reader: width
      # Width in characters.

      ##
      # :attr_reader: height
      # Height in characters.

      # Creates a new Rect.
      #
      # [x] Column index (Integer).
      # [y] Row index (Integer).
      # [width] Width in columns (Integer).
      # [height] Height in rows (Integer).
      def initialize(x: 0, y: 0, width: 0, height: 0)
        super
      end

      # Tests whether a point is inside this rectangle.
      #
      # Essential for hit testing mouse clicks against layout regions.
      #
      #   area = Rect.new(x: 10, y: 5, width: 20, height: 10)
      #   area.contains?(15, 8) # => true
      #   area.contains?(5, 8)  # => false
      #
      # [px]
      #   X coordinate to test (column).
      # [py]
      #   Y coordinate to test (row).
      #
      # Returns true if the point (px, py) is within the rectangle bounds.
      def contains?(px, py)
        px >= x && px < x + width && py >= y && py < y + height
      end
    end
end
