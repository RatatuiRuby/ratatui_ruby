# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Namespace for rich text components (Span and Line).
  # Distinct from canvas shapes and other Line usages.
  module Text
    # A styled string fragment.
    #
    # Used to compose rich text where individual words or phrases can have distinct styles.
    # Multiple Spans are combined into a Line for display.
    #
    # [content] The text content of this span.
    # [style] The style to apply to this span (Style object or nil for no styling).
    class Span < Data.define(:content, :style)
      # Creates a new Span.
      #
      # [content] The text content of this span.
      # [style] The style to apply (Style object or nil for no styling).
      def initialize(content:, style: nil)
        super
      end

      # Helper to create a styled span more concisely.
      #
      #   Text::Span.styled("bold text", Style.new(modifiers: [:bold]))
      #
      # [content] The text content.
      # [style] The style to apply.
      def self.styled(content, style = nil)
        new(content:, style:)
      end
    end

    # A single line of text, composed of multiple Spans.
    #
    # Used to display rich text with inline styling where different words or phrases
    # can have distinct colors, modifiers, and other style attributes.
    #
    # [spans] Array of Span objects that compose this line.
    # [alignment] Optional alignment for this line (:left, :center, :right).
    class Line < Data.define(:spans, :alignment)
      # Creates a new Line.
      #
      # [spans] Array of Span objects (or array of strings/objects that can be coerced to spans).
      # [alignment] Optional alignment for this line (:left, :center, :right).
      def initialize(spans: [], alignment: nil)
        super
      end

      # Helper to create a line from a simple string.
      #
      #   Text::Line.from_string("plain text")
      #   # => Line with a single unstyled Span
      #
      # [content] The text content.
      # [alignment] Optional alignment.
      def self.from_string(content, alignment: nil)
        new(spans: [Span.new(content:, style: nil)], alignment:)
      end
    end
  end
end
