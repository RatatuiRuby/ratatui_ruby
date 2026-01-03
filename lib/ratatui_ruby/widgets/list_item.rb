# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  module Widgets
  # A styled list item combining content with optional style.
  #
  # By default, List items are strings. For more control over styling individual rows,
  # wrap the content in a ListItem to apply a style specific to that item.
  #
  # The content can be a String, Text::Span, or Text::Line. The style applies to the
  # entire row background.
  #
  # === Examples
  #
  #   # Item with red background
  #   ListItem.new(content: "Error", style: Style.new(bg: :red))
  #
  #   # Item with styled content
  #   ListItem.new(
  #     content: Text::Span.new(content: "Status: OK", style: Style.new(fg: :green, modifiers: [:bold]))
  #   )
  class ListItem < Data.define(:content, :style)
    ##
    # :attr_reader: content
    # The content to display (String, Text::Span, or Text::Line).

    ##
    # :attr_reader: style
    # The style to apply to the item (optional Style).

    # Creates a new ListItem.
    #
    # [content] String, Text::Span, or Text::Line.
    # [style] Style object (optional).
    def initialize(content:, style: nil)
      super
    end
  end
  end
end
