# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A point in the canvas coordinate system.
  # @param x [Float] The x-coordinate.
  # @param y [Float] The y-coordinate.
  class Point < Data.define(:x, :y)
  end

  # A line shape on a canvas.
  # @param x1 [Float] The starting x-coordinate.
  # @param y1 [Float] The starting y-coordinate.
  # @param x2 [Float] The ending x-coordinate.
  # @param y2 [Float] The ending y-coordinate.
  # @param color [String, Symbol] The color of the line.
  class Line < Data.define(:x1, :y1, :x2, :y2, :color)
  end

  # A rectangle shape on a canvas.
  # @param x [Float] The x-coordinate of the bottom-left corner.
  # @param y [Float] The y-coordinate of the bottom-left corner.
  # @param width [Float] The width of the rectangle.
  # @param height [Float] The height of the rectangle.
  # @param color [String, Symbol] The color of the rectangle.
  class Rectangle < Data.define(:x, :y, :width, :height, :color)
  end

  # A circle shape on a canvas.
  # @param x [Float] The x-coordinate of the center.
  # @param y [Float] The y-coordinate of the center.
  # @param radius [Float] The radius of the circle.
  # @param color [String, Symbol] The color of the circle.
  class Circle < Data.define(:x, :y, :radius, :color)
  end

  # A world map shape on a canvas.
  # @param color [String, Symbol] The color of the map.
  # @param resolution [Symbol] The resolution of the map (:low, :high).
  class Map < Data.define(:color, :resolution)
  end

  # The Canvas Widget.
  # @param shapes [Array] Array of shape objects (Line, Rectangle, Circle, Map).
  # @param x_bounds [Array<Float>] [min, max] range for the x-axis.
  # @param y_bounds [Array<Float>] [min, max] range for the y-axis.
  # @param marker [Symbol] The marker to use for drawing (:braille, :dot, :block, :bar).
  # @param block [Block, nil] Optional Block widget to wrap the canvas.
  class Canvas < Data.define(:shapes, :x_bounds, :y_bounds, :marker, :block)
    # Creates a new Canvas.
    # @param shapes [Array] Array of shape objects (Line, Rectangle, Circle, Map).
    # @param x_bounds [Array<Float>] [min, max] range for the x-axis.
    # @param y_bounds [Array<Float>] [min, max] range for the y-axis.
    # @param marker [Symbol] The marker to use for drawing (:braille, :dot, :block, :bar).
    # @param block [Block, nil] Optional Block widget to wrap the canvas.
    def initialize(shapes: [], x_bounds: [0.0, 100.0], y_bounds: [0.0, 100.0], marker: :braille, block: nil)
      super
    end
  end
end
