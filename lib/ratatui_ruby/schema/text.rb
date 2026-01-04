# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  # Namespace for rich text components (Span, Line) and text utilities.
  # Distinct from canvas shapes and other Line usages.
  #
  # == Text Measurement
  #
  # The Text module provides a utility method for calculating the display width
  # of strings in terminal cells. This accounts for unicode complexity:
  #
  # - ASCII characters: 1 cell each
  # - CJK (Chinese, Japanese, Korean) characters: 2 cells each (full-width)
  # - Emoji: typically 2 cells each (varies by terminal)
  # - Combining marks: 0 cells (zero-width)
  #
  # This is essential for layout calculations in TUI applications, where you need to know
  # how much space a string will occupy on the screen, not just its byte or character length.
  #
  # === Use Cases
  #
  # - Auto-sizing widgets (Button, Badge) that fit their content
  # - Calculating padding or centering for text alignment
  # - Building responsive layouts that adapt to content width
  # - Measuring text for scrolling or truncation logic
  #
  # === Examples
  #
  #   # Simple ASCII text
  #   RatatuiRuby::Text.width("Hello")        # => 5
  #
  #   # With emoji
  #   RatatuiRuby::Text.width("Hello 👍")     # => 8 (5 + space + 2-width emoji)
  #
  #   # With CJK characters
  #   RatatuiRuby::Text.width("你好")         # => 4 (each CJK char is 2 cells)
  #
  #   # Mixed content
  #   RatatuiRuby::Text.width("Hi 你好 👍")   # => 11 (2 + space + 4 + space + 2)
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
      #   line = Text::Line.new(spans: [
      #     Text::Span.new(content: "Hello "),
      #     Text::Span.new(content: "世界")
      #   ])
      #   line.width  # => 10 (6 ASCII + 4 CJK)
      #
      # Returns: Integer (number of terminal cells)
      def width
        RatatuiRuby::Text.width(spans.map { |s| s.content.to_s }.join)
      end
    end

    ##
    # :method: width
    # :call-seq: width(string) -> Integer
    #
    # Calculates the display width of a string in terminal cells.
    #
    # Layout demands precision. Terminals measure space in cells, not characters. An ASCII letter occupies one cell. A Chinese character occupies two. An emoji occupies two. Combining marks occupy zero.
    #
    # Measuring width manually is error-prone. You can count <tt>string.length</tt>, but that counts characters, not cells. A string with one emoji counts as 1 character but occupies 2 cells.
    #
    # This method returns the true display width. Use it to auto-size widgets, calculate padding, center text, or build responsive layouts.
    #
    # === Examples
    #
    #   RatatuiRuby::Text.width("Hello")        # => 5 (5 ASCII chars × 1 cell)
    #
    #   RatatuiRuby::Text.width("你好")         # => 4 (2 CJK chars × 2 cells)
    #
    #   RatatuiRuby::Text.width("Hello 👍")     # => 8 (5 ASCII + 1 space + 1 emoji × 2)
    #
    #   # In the Session DSL (easier)
    #   RatatuiRuby.run do |tui|
    #     width = tui.text_width("Hello 👍")
    #   end
    #
    # [string] String to measure (String or object convertible to String)
    # Returns: Integer (number of terminal cells the string occupies)
    # Raises: TypeError if the argument is not a String
    #
    # (Native method implemented in Rust)
    def self.width(string)
      RatatuiRuby._text_width(string)
    end
  end
end
