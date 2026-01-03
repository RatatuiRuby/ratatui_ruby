# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  class Session
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
    end
  end
end
