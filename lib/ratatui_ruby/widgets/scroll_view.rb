# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Widgets
    # Scrolls arbitrary widget content by rendering to a virtual buffer
    # and copying the visible viewport.
    #
    # Unlike Paragraph's built-in scroll, this works with any widget tree:
    # layouts, nested blocks, styled text, tables, etc.
    #
    # === Examples
    #
    #   ScrollView.new(
    #     child: tui.layout(direction: :vertical, ...),
    #     scroll: [scroll_y, 0],
    #     content_height: total_lines
    #   )
    class ScrollView < Data.define(:child, :scroll, :content_height)
      include CoerceableWidget

      # Creates a new ScrollView.
      #
      # [child]
      #   The widget tree to scroll.
      # [scroll]
      #   Scroll offset as [y, x]. Only vertical (y) is used currently.
      # [content_height]
      #   Total height of the content in rows. Used to size the virtual buffer.
      def initialize(child:, scroll: [0, 0], content_height: 0)
        super
      end
    end
  end
end
