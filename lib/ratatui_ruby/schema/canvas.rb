# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  # Namespace for canvas shape primitives (Point, Line, Rectangle, Circle, Map, Label).
  # Distinct from text components and other Line usages.
  module Shape
    # A point in the canvas coordinate system.
    #
    # [x] The x-coordinate.
    # [y] The y-coordinate.
    class Point < Data.define(:x, :y)
      ##
      # :attr_reader: x
      # X coordinate (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: y
      # Y coordinate (Float, duck-typed via +to_f+).

      # Creates a new Point.
      #
      # [x] X coordinate (Numeric).
      # [y] Y coordinate (Numeric).
      def initialize(x:, y:)
        super(x: Float(x), y: Float(y))
      end
    end

    # A line shape on a canvas.
    #
    # [x1] The starting x-coordinate.
    # [y1] The starting y-coordinate.
    # [x2] The ending x-coordinate.
    # [y2] The ending y-coordinate.
    # [color] The color of the line.
    class Line < Data.define(:x1, :y1, :x2, :y2, :color)
      ##
      # :attr_reader: x1
      # Start X (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: y1
      # Start Y (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: x2
      # End X (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: y2
      # End Y (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: color
      # Line color.

      # Creates a new Line.
      #
      # [x1] Start X (Numeric).
      # [y1] Start Y (Numeric).
      # [x2] End X (Numeric).
      # [y2] End Y (Numeric).
      # [color] Line color (Symbol).
      def initialize(x1:, y1:, x2:, y2:, color:)
        super(x1: Float(x1), y1: Float(y1), x2: Float(x2), y2: Float(y2), color:)
      end
    end

    # A rectangle shape on a canvas.
    #
    # [x] The x-coordinate of the bottom-left corner.
    # [y] The y-coordinate of the bottom-left corner.
    # [width] The width of the rectangle.
    # [height] The height of the rectangle.
    # [color] The color of the rectangle.
    class Rectangle < Data.define(:x, :y, :width, :height, :color)
      ##
      # :attr_reader: x
      # Bottom-left X (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: y
      # Bottom-left Y (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: width
      # Width (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: height
      # Height (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: color
      # Color.

      # Creates a new Rectangle.
      #
      # [x] Bottom-left X (Numeric).
      # [y] Bottom-left Y (Numeric).
      # [width] Width (Numeric).
      # [height] Height (Numeric).
      # [color] Color (Symbol).
      def initialize(x:, y:, width:, height:, color:)
        super(x: Float(x), y: Float(y), width: Float(width), height: Float(height), color:)
      end
    end

    # A circle shape on a canvas.
    #
    # [x] The x-coordinate of the center.
    # [y] The y-coordinate of the center.
    # [radius] The radius of the circle.
    # [color] The color of the circle.
    class Circle < Data.define(:x, :y, :radius, :color)
      ##
      # :attr_reader: x
      # Center X (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: y
      # Center Y (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: radius
      # Radius (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: color
      # Color.

      # Creates a new Circle.
      #
      # [x] Center X (Numeric).
      # [y] Center Y (Numeric).
      # [radius] Radius (Numeric).
      # [color] Color (Symbol).
      def initialize(x:, y:, radius:, color:)
        super(x: Float(x), y: Float(y), radius: Float(radius), color:)
      end
    end

    # A world map shape on a canvas.
    #
    # [color] The color of the map.
    # [resolution] The resolution of the map (<tt>:low</tt>, <tt>:high</tt>).
    class Map < Data.define(:color, :resolution)
      ##
      # :attr_reader: color
      # Map color.

      ##
      # :attr_reader: resolution
      # Resolution (<tt>:low</tt> or <tt>:high</tt>).
    end
  end

  # Provides a drawing surface for custom shapes.
  #
  # Standard widgets cover standard cases. Sometimes you need to draw a map, a custom diagram, or a game.
  # Character grids are too coarse for fine detail.
  #
  # This widget increases the resolution. It uses Braille patterns or block characters to create a "sub-pixel" drawing surface.
  #
  # Use it to implement free-form graphics, high-resolution plots, or geographic maps.
  #
  # === Examples
  #
  #   Canvas.new(
  #     x_bounds: [-180, 180],
  #     y_bounds: [-90, 90],
  #     shapes: [
  #       Shape::Map.new(color: :green, resolution: :high),
  #       Shape::Circle.new(x: 0, y: 0, radius: 10, color: :red),
  #       Shape::Label.new(x: -122.4, y: 37.8, text: "San Francisco")
  #     ]
  #   )
  class Canvas < Data.define(:shapes, :x_bounds, :y_bounds, :marker, :block, :background_color)
    ##
    # :attr_reader: shapes
    # Array of shapes to render.
    #
    # Includes {Shape::Line}, {Shape::Circle}, {Shape::Map}, etc.

    ##
    # :attr_reader: x_bounds
    # [min, max] range for the x-axis.

    ##
    # :attr_reader: y_bounds
    # [min, max] range for the y-axis.

    ##
    # :attr_reader: marker
    # The marker type used for drawing.
    #
    # <tt>:braille</tt> (high res), <tt>:half_block</tt>, <tt>:dot</tt>, <tt>:block</tt>, <tt>:bar</tt>.

    ##
    # :attr_reader: block
    # Optional wrapping block.

    ##
    # :attr_reader: background_color
    # The background color of the canvas.

    # Creates a new Canvas.
    #
    # [shapes] Array of Shapes.
    # [x_bounds] Array of [min, max] (Numeric, duck-typed via +to_f+).
    # [y_bounds] Array of [min, max] (Numeric, duck-typed via +to_f+).
    # [marker] Symbol (default: <tt>:braille</tt>).
    # [block] Block (optional).
    # [background_color] Color (optional).
    def initialize(shapes: [], x_bounds: [0.0, 100.0], y_bounds: [0.0, 100.0], marker: :braille, block: nil, background_color: nil)
      super(
        shapes:,
        x_bounds: [Float(x_bounds[0]), Float(x_bounds[1])],
        y_bounds: [Float(y_bounds[0]), Float(y_bounds[1])],
        marker:,
        block:,
        background_color:
      )
    end
  end
end
