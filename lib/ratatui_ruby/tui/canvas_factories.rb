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

      # =====================================
      # Shape Dispatcher (TIMTOWTDI)
      # =====================================

      # Creates a shape by type symbol.
      #
      # Hard-coding method names limits flexibility. Programmatic shape creation
      # from user input or config files requires tedious case statements.
      #
      # This dispatcher routes shape creation through a single entry point.
      # Pass the type as a symbol and the remaining parameters as kwargs.
      #
      # Use it for dynamic shape generation, config-driven UIs, or when you
      # prefer explicit type specification over method names.
      #
      # Also available as: <tt>tui.circle</tt>, <tt>tui.shape_circle</tt>
      #
      # === Examples
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   # Direct dispatch
      #   tui.shape(:circle, x: 5.0, y: 5.0, radius: 2.5, color: :red)
      #
      #   # Dynamic shape creation from config
      #   config = { type: :rectangle, x: 0.0, y: 0.0, width: 10.0, height: 10.0 }
      #   tui.shape(config[:type], **config.except(:type))
      #--
      # SPDX-SnippetEnd
      #++
      #
      # @param type [Symbol] Shape type: :circle, :line, :point, :rectangle, :map, :label
      # @return [Widgets::Shape::*]
      def shape(type, **)
        case type
        when :circle then shape_circle(**)
        when :line then shape_line(**)
        when :point then shape_point(**)
        when :rectangle then shape_rectangle(**)
        when :map then shape_map(**)
        when :label then label(**)
        else
          raise ArgumentError, "Unknown shape type: #{type.inspect}. " \
            "Valid types: :circle, :line, :point, :rectangle, :map, :label"
        end
      end
    end
  end
end
