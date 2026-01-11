# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  class TUI
    # Text factory methods for Session.
    #
    # Provides convenient access to Text::Span and Text::Line
    # without fully qualifying the class names.
    module TextFactories
      # Creates a Text::Span.
      # @return [Text::Span]
      def text_span(...)
        Text::Span.new(...)
      end

      # Creates a Text::Span (alias).
      # @return [Text::Span]
      def span(...)
        Text::Span.new(...)
      end

      # Creates a Text::Line.
      # @return [Text::Line]
      def text_line(...)
        Text::Line.new(...)
      end

      # Creates a Text::Line (alias).
      # @return [Text::Line]
      def line(...)
        Text::Line.new(...)
      end

      # Calculates the display width of a string.
      # @return [Integer]
      def text_width(string)
        Text.width(string)
      end

      # =====================================
      # Text Dispatcher (TIMTOWTDI)
      # =====================================

      # Creates a text element by type symbol.
      #
      # Building text programmatically requires knowing which method to call.
      # When the text type comes from config or user input, you need a dispatcher.
      #
      # This method routes text creation through a single entry point.
      # Pass the type as a symbol and the remaining parameters as kwargs.
      #
      # Use it for dynamic text generation or config-driven rendering.
      #
      # Also available as: <tt>tui.span</tt>, <tt>tui.text_span</tt>
      #
      # === Examples
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   tui.text(:span, content: "Hello", style: Style.with(fg: :blue))
      #   tui.text(:line, spans: [tui.span(content: "World")])
      #--
      # SPDX-SnippetEnd
      #++
      #
      # @param type [Symbol] Text type: :span, :line
      # @return [Text::Span, Text::Line]
      def text(type, **)
        case type
        when :span then text_span(**)
        when :line then text_line(**)
        else
          raise ArgumentError, "Unknown text type: #{type.inspect}. Valid types: :span, :line"
        end
      end
    end
  end
end
