# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
    # Defines the visual container for a widget.
    #
    # Widgets often float in void. Without boundaries, interfaces become a chaotic mess of text. Users need structure to parse information.
    #
    # This widget creates that structure. It wraps content in borders. It labels sections with titles. It paints the background.
    #
    # Use blocks to define distinct areas. Group related information. Create a visual hierarchy that guides the user's eye.
    #
    # === Examples
    #
    #   # A simple bordered block
    #   Block.new(borders: [:all], title: "Logs")
    #
    #   # A complex block with styling and padding
    #   Block.new(
    #     title: "Status",
    #     borders: [:left, :right],
    #     style: Style.new(fg: :yellow),
    #     padding: [1, 1, 0, 0] # Left, Right, Top, Bottom
    #   )
    class Block < Data.define(:title, :titles, :title_alignment, :borders, :border_color, :border_type, :style, :padding)
      ##
      # :attr_reader: title
      # The main title displayed on the top border.
      #
      #   Block.new(title: "Main").title # => "Main"

      ##
      # :attr_reader: titles
      # Additional titles for complex labeling.
      #
      #   Block.new(titles: ["Top", "Bottom"]).titles

      ##
      # :attr_reader: title_alignment
      # Alignment of the main title.
      #
      # One of <tt>:left</tt>, <tt>:center</tt>, or <tt>:right</tt>.
      #
      #   Block.new(title_alignment: :center).title_alignment # => :center

      ##
      # :attr_reader: borders
      # Visible borders.
      #
      # An array containing any of <tt>:top</tt>, <tt>:bottom</tt>, <tt>:left</tt>, <tt>:right</tt>, or <tt>:all</tt>.
      #
      #   Block.new(borders: [:left, :right]).borders # => [:left, :right]

      ##
      # :attr_reader: border_color
      # Color of the border lines.

      ##
      # :attr_reader: border_type
      # Visual style of the border lines.
      #
      # One of <tt>:plain</tt>, <tt>:rounded</tt>, <tt>:double</tt>, <tt>:thick</tt>, etc.

      ##
      # :attr_reader: style
      # Base style (colors/modifiers) for the block content.

      ##
      # :attr_reader: padding
      # Inner padding.
      #
      # Can be a single Integer (uniform) or a 4-element Array (left, right, top, bottom).
      #
      #   Block.new(padding: 2).padding # => 2
      #   Block.new(padding: [1, 1, 0, 0]).padding # => [1, 1, 0, 0]

      # Creates a new Block.
      #
      # [title]
      #   Main title string (optional).
      # [titles]
      #   Array of additional titles (optional).
      # [title_alignment]
      #   Alignment symbol: <tt>:left</tt> (default), <tt>:center</tt>, <tt>:right</tt>.
      # [borders]
      #   Array of borders to show: <tt>:top</tt>, <tt>:bottom</tt>, <tt>:left</tt>, <tt>:right</tt>, or <tt>:all</tt> (default).
      # [border_color]
      #   Color string or symbol (e.g., <tt>:red</tt>).
      # [border_type]
      #   Symbol: <tt>:plain</tt> (default), <tt>:rounded</tt>, <tt>:double</tt>, <tt>:thick</tt>, <tt>:hidden</tt>.
      # [style]
      #   Style object or Hash for the block's content area.
      # [padding]
      #   Integer (uniform) or Array[4] (left, right, top, bottom).
      def initialize(title: nil, titles: [], title_alignment: nil, borders: [:all], border_color: nil, border_type: nil, style: nil, padding: 0)
        super
      end
    end
end
