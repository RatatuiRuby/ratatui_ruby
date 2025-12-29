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
    class Block < Data.define(:title, :titles, :title_alignment, :title_style, :borders, :border_color, :border_type, :style, :padding)
      ##
      # :attr_reader: title
      # The main title displayed on the top border.
      #
      # === Example
      #
      #   Block.new(title: "Main").title # => "Main"

      ##
      # :attr_reader: titles
      # Additional titles for complex labeling.
      #
      # Each title can be a <tt>String</tt> or a <tt>Hash</tt> with keys <tt>:content</tt>, <tt>:alignment</tt>, <tt>:position</tt> (<tt>:top</tt> or <tt>:bottom</tt>), and <tt>:style</tt>.
      #
      # === Example
      #
      #   Block.new(titles: ["Top", { content: "Bottom", position: :bottom }]).titles

      ##
      # :attr_reader: title_alignment
      # Alignment of the main title.
      #
      # One of <tt>:left</tt>, <tt>:center</tt>, or <tt>:right</tt>.
      #
      # === Example
      #
      #   Block.new(title_alignment: :center).title_alignment # => :center

      ##
      # :attr_reader: title_style
      # Style applied to all titles if not overridden.
      #
      # === Example
      #
      #   Block.new(title_style: Style.new(fg: :red)).title_style

      ##
      # :attr_reader: borders
      # Visible borders.
      #
      # An array containing any of <tt>:top</tt>, <tt>:bottom</tt>, <tt>:left</tt>, <tt>:right</tt>, or <tt>:all</tt>.
      #
      # === Example
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
      # Can be a single <tt>Integer</tt> (uniform) or a 4-element <tt>Array</tt> (left, right, top, bottom).
      #
      # === Example
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
      # [title_style]
      #   Base style for all titles (optional).
      # [borders]
      #   Array of borders to show: <tt>:top</tt>, <tt>:bottom</tt>, <tt>:left</tt>, <tt>:right</tt>, or <tt>:all</tt> (default).
      # [border_color]
      #   Color string or symbol (e.g., <tt>:red</tt>).
      # [border_type]
      #   Symbol: <tt>:plain</tt> (default), <tt>:rounded</tt>, <tt>:double</tt>, <tt>:thick</tt>, <tt>:hidden</tt>, <tt>:quadrant_inside</tt>, <tt>:quadrant_outside</tt>.
      # [style]
      #   Style object or Hash for the block's content area.
      # [padding]
      #   Integer (uniform) or Array[4] (left, right, top, bottom).
      def initialize(title: nil, titles: [], title_alignment: nil, title_style: nil, borders: [:all], border_color: nil, border_type: nil, style: nil, padding: 0)
        super
      end
    end
end
