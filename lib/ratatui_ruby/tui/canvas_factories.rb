# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
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

      # =====================================
      # Terse Shape Aliases (DWIM)
      # =====================================

      # Creates a circle shape (terse alias).
      # @return [Widgets::Shape::Circle]
      alias circle shape_circle

      # Creates a point shape (terse alias).
      # @return [Widgets::Shape::Point]
      alias point shape_point

      # NOTE: No terse 'rectangle' alias - would conflict with Layout::Rect concept.
      # Use shape_rectangle() explicitly.

      # Creates a map shape (terse alias).
      # @return [Widgets::Shape::Map]
      alias map shape_map

      # Creates a label shape (terse alias).
      #
      # Note: shape_label is defined in WidgetFactories.
      # @return [Widgets::Shape::Label]
      def label(first = nil, **kwargs)
        Widgets::Shape::Label.coerce_args(first, kwargs)
      end

      # =====================================
      # Bidirectional Shape Aliases (*_shape)
      # =====================================

      # Creates a circle shape (bidirectional alias).
      # @return [Widgets::Shape::Circle]
      alias circle_shape shape_circle

      # Creates a point shape (bidirectional alias).
      # @return [Widgets::Shape::Point]
      alias point_shape shape_point

      # Creates a rectangle shape (bidirectional alias).
      # Note: Terse 'rectangle' is intentionally excluded to avoid confusion with Layout::Rect,
      # but 'rectangle_shape' is unambiguous.
      # @return [Widgets::Shape::Rectangle]
      alias rectangle_shape shape_rectangle

      # Creates a map shape (bidirectional alias).
      # @return [Widgets::Shape::Map]
      alias map_shape shape_map

      # Creates a label shape (bidirectional alias).
      # @return [Widgets::Shape::Label]
      alias label_shape label
    end
  end
end
