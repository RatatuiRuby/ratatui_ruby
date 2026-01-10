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
      # Returns: Integer (number of terminal cells).
      def width
        RatatuiRuby::Text.width(spans.map { |s| s.content.to_s }.join)
      end

      # Left-aligns this line of text.
      #
      # Convenience shortcut for <tt>alignment: :left</tt>. Setting the alignment of a Line
      # overrides the alignment of its parent Text or Widget.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   line = Text::Line.new(spans: [Text::Span.new(content: "Hello")])
      #   aligned = line.left_aligned
      #   aligned.alignment  # => :left
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Returns: Line.
      def left_aligned
        with(alignment: :left)
      end

      # Center-aligns this line of text.
      #
      # Convenience shortcut for <tt>alignment: :center</tt>. Setting the alignment of a Line
      # overrides the alignment of its parent Text or Widget.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   line = Text::Line.new(spans: [Text::Span.new(content: "Hello")])
      #   centered = line.centered
      #   centered.alignment  # => :center
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Returns: Line.
      def centered
        with(alignment: :center)
      end

      # Right-aligns this line of text.
      #
      # Convenience shortcut for <tt>alignment: :right</tt>. Setting the alignment of a Line
      # overrides the alignment of its parent Text or Widget.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   line = Text::Line.new(spans: [Text::Span.new(content: "Hello")])
      #   aligned = line.right_aligned
      #   aligned.alignment  # => :right
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Returns: Line.
      def right_aligned
        with(alignment: :right)
      end

      # Adds a span to the line.
      #
      # Since Line is immutable (a Data subclass), this returns a new Line with the span appended.
      # The original line remains unchanged.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   line = Text::Line.new(spans: [Text::Span.new(content: "Hello, ")])
      #   extended = line.push_span(Text::Span.new(content: "world!"))
      #   extended.spans.size  # => 2
      #   line.spans.size      # => 1 (original unchanged)
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [span] Span to append.
      #
      # Returns: Line.
      def push_span(span)
        with(spans: spans + [span])
      end

      # Patches the style of this line, adding modifiers from the given style.
      #
      # Applies <tt>patch_style</tt> to each span in the line. Use this when you want to layer
      # styles on all spans without replacing their existing styles.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   line = Text::Line.new(spans: [Text::Span.new(content: "Hello")])
      #   styled = line.patch_style(Style::Style.new(fg: :red))
      #   styled.spans.first.style.fg  # => :red
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [patch] Style::Style to merge onto each span.
      #
      # Returns: Line.
      def patch_style(patch)
        with(spans: spans.map { |s| s.patch_style(patch) })
      end

      # Resets the style of this line.
      #
      # Applies <tt>reset_style</tt> to each span in the line, clearing all styling.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   line = Text::Line.new(spans: [
      #     Text::Span.new(content: "styled", style: Style::Style.new(fg: :red))
      #   ])
      #   reset = line.reset_style
      #   reset.spans.first.style  # => nil
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Returns: Line.
      def reset_style
        with(spans: spans.map(&:reset_style))
      end
    end
  end
end
