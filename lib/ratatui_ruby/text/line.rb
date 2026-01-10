# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Text
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
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2025 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   Text::Line.new(
    #     spans: [
    #       Text::Span.styled("User: ", Style.new(modifiers: [:bold])),
    #       Text::Span.styled("kerrick", Style.new(fg: :blue))
    #     ]
    #   )
    #--
    # SPDX-SnippetEnd
    #++
    class Line < Data.define(:spans, :alignment, :style)
      ##
      # :attr_reader: spans
      # Array of Span objects.

      ##
      # :attr_reader: alignment
      # Alignment within the container.
      #
      # <tt>:left</tt>, <tt>:center</tt>, or <tt>:right</tt>.

      ##
      # :attr_reader: style
      # Line-level style applied to all spans.
      #
      # A Style object that sets colors/modifiers for the entire line.

      # Creates a new Line.
      #
      # [spans] Array of Span objects (or Strings).
      # [alignment] Symbol (optional).
      # [style] Style object (optional).
      def initialize(spans: [], alignment: nil, style: nil)
        super
      end

      # Creates a simple line from a string.
      #
      #   Text::Line.from_string("Hello")
      def self.from_string(content, alignment: nil)
        new(spans: [Span.new(content:, style: nil)], alignment:)
      end

      # Calculates the display width of this line in terminal cells.
      #
      # Sums the widths of all span contents using the same unicode-aware
      # algorithm as Text.width. Useful for layout calculations.
      #
      # === Examples
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   line = Text::Line.new(spans: [
      #     Text::Span.new(content: "Hello "),
      #     Text::Span.new(content: "世界")
      #   ])
      #   line.width  # => 10 (6 ASCII + 4 CJK)
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Returns: Integer (number of terminal cells)
      def width
        RatatuiRuby::Text.width(spans.map { |s| s.content.to_s }.join)
      end
    end
  end
end
