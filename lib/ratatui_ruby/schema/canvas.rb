# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Namespace for canvas shape primitives (Point, Line, Rectangle, Circle, Map).
  # Distinct from text components and other Line usages.
  module Shape
    # A point in the canvas coordinate system.
    #
    # [x] The x-coordinate.
    # [y] The y-coordinate.
    class Point < Data.define(:x, :y)
    end

    # A line shape on a canvas.
    #
    # [x1] The starting x-coordinate.
    # [y1] The starting y-coordinate.
    # [x2] The ending x-coordinate.
    # [y2] The ending y-coordinate.
    # [color] The color of the line.
    class Line < Data.define(:x1, :y1, :x2, :y2, :color)
    end

    # A rectangle shape on a canvas.
    #
    # [x] The x-coordinate of the bottom-left corner.
    # [y] The y-coordinate of the bottom-left corner.
    # [width] The width of the rectangle.
    # [height] The height of the rectangle.
    # [color] The color of the rectangle.
    class Rectangle < Data.define(:x, :y, :width, :height, :color)
    end

    # A circle shape on a canvas.
    #
    # [x] The x-coordinate of the center.
    # [y] The y-coordinate of the center.
    # [radius] The radius of the circle.
    # [color] The color of the circle.
    class Circle < Data.define(:x, :y, :radius, :color)
    end

    # A world map shape on a canvas.
    #
    # [color] The color of the map.
    # [resolution] The resolution of the map (:low, :high).
    class Map < Data.define(:color, :resolution)
    end
  end

  # The Canvas Widget.
  #
  # [shapes] Array of shape objects (Shape::Line, Shape::Rectangle, Shape::Circle, Shape::Map).
  # [x_bounds] [min, max] range for the x-axis.
  # [y_bounds] [min, max] range for the y-axis.
  # [marker] The marker to use for drawing (:braille, :dot, :block, :bar).
  # [block] Optional Block widget to wrap the canvas.
  class Canvas < Data.define(:shapes, :x_bounds, :y_bounds, :marker, :block)
    # Creates a new Canvas.
    #
    # [shapes] Array of shape objects (Shape::Line, Shape::Rectangle, Shape::Circle, Shape::Map).
    # [x_bounds] [min, max] range for the x-axis.
    # [y_bounds] [min, max] range for the y-axis.
    # [marker] The marker to use for drawing (:braille, :dot, :block, :bar).
    # [block] Optional Block widget to wrap the canvas.
    def initialize(shapes: [], x_bounds: [0.0, 100.0], y_bounds: [0.0, 100.0], marker: :braille, block: nil)
      super
    end
  end
end
