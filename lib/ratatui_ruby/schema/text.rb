# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Namespace for rich text components (Span and Line).
  # Distinct from canvas shapes and other Line usages.
  module Text
    # A styled string fragment.
    #
    # Text is rarely uniform. You need to bold a keyword, colorize an error, or dim a timestamp.
    #
    # This class attaches style to content. It pairs a string with visual attributes.
    #
    # combine spans into a {Line} to create rich text.
    #
    # === Examples
    #
    #   Text::Span.new(content: "Error", style: Style.new(fg: :red, modifiers: [:bold]))
    class Span < Data.define(:content, :style)
      ##
      # :attr_reader: content
      # The text content.

      ##
      # :attr_reader: style
      # The style to apply.

      # Creates a new Span.
      #
      # [content] String.
      # [style] Style object (optional).
      def initialize(content:, style: nil)
        super
      end

      # Concise helper for styling.
      #
      #   Text::Span.styled("Bold", Style.new(modifiers: [:bold]))
      def self.styled(content, style = nil)
        new(content:, style:)
      end
    end

    # A sequence of styled spans.
    #
    # Words form sentences. Spans form lines.
    #
    # This class composes multiple {Span} objects into a single horizontal row of text.
    # It handles the layout of rich text fragments within the flow of a paragraph.
    #
    # Use it to build multi-colored headers, status messages, or log entries.
    #
    # === Examples
    #
    #   Text::Line.new(
    #     spans: [
    #       Text::Span.styled("User: ", Style.new(modifiers: [:bold])),
    #       Text::Span.styled("kerrick", Style.new(fg: :blue))
    #     ]
    #   )
    class Line < Data.define(:spans, :alignment)
      ##
      # :attr_reader: spans
      # Array of Span objects.

      ##
      # :attr_reader: alignment
      # Alignment within the container.
      #
      # <tt>:left</tt>, <tt>:center</tt>, or <tt>:right</tt>.

      # Creates a new Line.
      #
      # [spans] Array of Span objects (or Strings).
      # [alignment] Symbol (optional).
      def initialize(spans: [], alignment: nil)
        super
      end

      # Creates a simple line from a string.
      #
      #   Text::Line.from_string("Hello")
      def self.from_string(content, alignment: nil)
        new(spans: [Span.new(content:, style: nil)], alignment:)
      end
    end
  end
end
