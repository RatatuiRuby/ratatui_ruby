# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  module Shape
    # A text label on a canvas.
    #
    # Labels render text at specific coordinates in canvas space.
    # Unlike shapes, labels are always rendered on top of all other canvas elements.
    #
    # [x] The x-coordinate in canvas space (Numeric).
    # [y] The y-coordinate in canvas space (Numeric).
    # [text] The text content (String or Text::Line).
    # [style] Optional style for the text.
    #
    # === Examples
    #
    #   # Simple label
    #   Shape::Label.new(x: 0, y: 0, text: "Origin")
    #
    #   # Styled label
    #   Shape::Label.new(
    #     x: -122.4, y: 37.8,
    #     text: "San Francisco",
    #     style: Style.new(fg: :cyan, add_modifier: :bold)
    #   )
    #
    #   # Label with Text::Line for rich formatting
    #   Shape::Label.new(
    #     x: 0.0, y: 0.0,
    #     text: Text::Line.new(spans: [
    #       Text::Span.new(content: "Hello ", style: Style.new(fg: :red)),
    #       Text::Span.new(content: "World", style: Style.new(fg: :blue))
    #     ])
    #   )
    class Label < Data.define(:x, :y, :text, :style)
      ##
      # :attr_reader: x
      # X coordinate in canvas space (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: y
      # Y coordinate in canvas space (Float, duck-typed via +to_f+).

      ##
      # :attr_reader: text
      # Text content (String or Text::Line).

      ##
      # :attr_reader: style
      # Optional style for the text.

      # Creates a new Label.
      #
      # [x] X coordinate (Numeric).
      # [y] Y coordinate (Numeric).
      # [text] Text content (String or Text::Line).
      # [style] Style (optional).
      def initialize(x:, y:, text:, style: nil)
        super(x: Float(x), y: Float(y), text:, style:)
      end
    end
  end
end
