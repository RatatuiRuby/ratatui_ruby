# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
    # Displays a block of text.
    #
    # Raw strings are insufficient for UIs. They overflow constraints. They don't respect alignment (left, center, right).
    #
    # This widget creates a smart text container. It wraps content to fit the area. It aligns text as requested. It supports scrolling.
    #
    # Use it for everything from simple labels to complex, multi-paragraph documents.
    #
    # === Examples
    #
    #   # Basic Text
    #   Paragraph.new(text: "Hello, World!")
    #
    #   # Styled container with wrapping
    #   Paragraph.new(
    #     text: "This is a long line that will wrap automatically.",
    #     style: Style.new(fg: :green),
    #     wrap: true,
    #     block: Block.new(title: "Output", borders: [:all])
    #   )
    #
    #   # Scrolling mechanism
    #   Paragraph.new(text: large_text, scroll: [scroll_y, 0])
    class Paragraph < Data.define(:text, :style, :block, :wrap, :align, :scroll)
      ##
      # :attr_reader: text
      # The content to display.

      ##
      # :attr_reader: style
      # Base style for the text.

      ##
      # :attr_reader: block
      # Optional wrapping block.

      ##
      # :attr_reader: wrap
      # Whether to wrap text at the edge of the container (Boolean).

      ##
      # :attr_reader: align
      # Text alignment.
      #
      # <tt>:left</tt>, <tt>:center</tt>, or <tt>:right</tt>.

      ##
      # :attr_reader: scroll
      # Scroll offset [y, x].

      # Creates a new Paragraph.
      #
      # [text] String or Text::Line array.
      # [style] Style object.
      # [block] Block object.
      # [wrap] Boolean (default: false).
      # [align] Symbol (default: <tt>:left</tt>).
      # [scroll] Array of [y, x] integers (duck-typed via +to_int+).
      def initialize(text:, style: Style.default, block: nil, wrap: false, align: :left, scroll: [0, 0])
        super(
          text: text,
          style: style,
          block: block,
          wrap: wrap,
          align: align,
          scroll: [Integer(scroll[0]), Integer(scroll[1])]
        )
      end

      # Legacy constructor support.
      def self.new(text:, style: nil, fg: nil, bg: nil, block: nil, wrap: false, align: :left, scroll: [0, 0])
        style ||= Style.new(fg:, bg:)
        coerced_scroll = [Integer(scroll[0]), Integer(scroll[1])]
        super(text:, style:, block:, wrap:, align:, scroll: coerced_scroll)
      end
    end
end
