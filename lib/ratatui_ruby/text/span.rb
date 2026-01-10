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
      #   Text::Span.styled("Bold", Style.new(modifiers: [:bold]))
      def self.styled(content, style = nil)
        new(content:, style:)
      end
    end
  end
end
