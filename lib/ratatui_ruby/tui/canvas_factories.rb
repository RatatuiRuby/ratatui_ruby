# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  class TUI
    # Canvas shape factory methods for Session.
    #
    # Provides convenient access to Widgets::Shape::* classes
    # for creating custom drawings on Canvas widgets.
    module CanvasFactories
      # Creates a map shape for Canvas.
      # @return [Widgets::Shape::Map]
      def shape_map(...)
        Widgets::Shape::Map.new(...)
      end

      # Creates a line shape for Canvas.
      # @return [Widgets::Shape::Line]
      def shape_line(...)
        Widgets::Shape::Line.new(...)
      end

      # Creates a point (single pixel) shape for Canvas.
      # @return [Widgets::Shape::Point]
      def shape_point(...)
        Widgets::Shape::Point.new(...)
      end

      # Creates a circle shape for Canvas.
      # @return [Widgets::Shape::Circle]
      def shape_circle(...)
        Widgets::Shape::Circle.new(...)
      end

      # Creates a rectangle shape for Canvas.
      # @return [Widgets::Shape::Rectangle]
      def shape_rectangle(...)
        Widgets::Shape::Rectangle.new(...)
      end
    end
  end
end
