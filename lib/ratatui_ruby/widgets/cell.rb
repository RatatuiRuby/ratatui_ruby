# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Widgets
    # A styled table cell combining content with optional styling.
    #
    # By default, Table cells are plain strings. For more control over cell styling,
    # wrap the content in a Cell object to apply cell-level background style.
    #
    # The content can be a String, Text::Span, or Text::Line.
    # The style applies to the entire cell area (background).
    #
    # === Examples
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   # Cell with yellow background
    #   Widgets::Cell.new(content: "Warning", style: Style::Style.new(bg: :yellow))
    #
    #   # Cell with rich text content
    #   Widgets::Cell.new(
    #     content: Text::Line.new(spans: [
    #       Text::Span.new(content: "Error: ", style: Style::Style.new(fg: :red)),
    #       Text::Span.new(content: "Details here")
    #     ]),
    #     style: Style::Style.new(bg: :dark_gray)
    #   )
    #--
    # SPDX-SnippetEnd
    #++
    class Cell < Data.define(:content, :style)
      include CoerceableWidget

      ##
      # :attr_reader: content
      # The content to display (String, Text::Span, or Text::Line).

      ##
      # :attr_reader: style
      # The style to apply to the cell area (optional Style::Style).

      # Creates a new Cell.
      #
      # [content] String, Text::Span, or Text::Line.
      # [style] Style::Style object (optional).
      def initialize(content:, style: nil)
        super
      end
    end
  end
end
