# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
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
      # === Example
      #
      #   Text::Span.styled("Bold", Style::Style.new(modifiers: [:bold]))
      def self.styled(content, style = nil)
        new(content:, style:)
      end

      # Returns the unicode display width of the content in terminal cells.
      #
      # CJK characters and emoji count as 2 cells. ASCII characters count as 1 cell.
      # Use this to measure how much horizontal space a span will occupy.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   span = Text::Span.new(content: "Hello")
      #   span.width  # => 5
      #
      #   span = Text::Span.new(content: "你好")  # Chinese characters
      #   span.width  # => 4
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Returns: Integer.
      def width
        RatatuiRuby::Text.width(content.to_s)
      end

      # Creates a span with the default style.
      #
      # Use this factory method when you want unstyled text. It mirrors the Ratatui API.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   span = Text::Span.raw("test content")
      #   span.content  # => "test content"
      #   span.style    # => nil
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [content] String.
      #
      # Returns: Span.
      def self.raw(content)
        new(content:)
      end

      # Patches the style of the span, merging modifiers from the given style.
      #
      # Non-nil values from the patch style override the existing style. Use this when you want to
      # layer styles without replacing the entire style. Colors in the patch take precedence over
      # existing colors. Modifiers are combined.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   span = Text::Span.new(content: "test", style: Style::Style.new(fg: :green))
      #   patched = span.patch_style(Style::Style.new(bg: :yellow, modifiers: [:bold]))
      #   patched.style.fg  # => :green (preserved)
      #   patched.style.bg  # => :yellow (added)
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [patch] Style::Style to merge.
      #
      # Returns: Span.
      def patch_style(patch)
        return self if patch.nil?
        return with(style: patch) if style.nil?

        merged = Style::Style.new(
          fg: patch.fg.nil? ? style.fg : patch.fg,
          bg: patch.bg.nil? ? style.bg : patch.bg,
          modifiers: patch.modifiers.empty? ? style.modifiers : (style.modifiers + patch.modifiers).uniq
        )
        with(style: merged)
      end

      # Resets the style of the span.
      #
      # Returns a new span with no style applied. Use this to strip all styling.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   span = Text::Span.new(content: "styled", style: Style::Style.new(fg: :red))
      #   reset = span.reset_style
      #   reset.style  # => nil
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Returns: Span.
      def reset_style
        with(style: nil)
      end
    end
  end
end
