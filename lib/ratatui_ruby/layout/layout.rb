# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Layout
    # Divides an area into smaller chunks.
    #
    # Terminal screens vary in size. Hardcoded positions break when the window resizes. You need a way to organize space dynamically.
    #
    # This class manages geometry. It splits a given area into multiple sections based on a list of constraints.
    #
    # Use layouts to build responsive grids. Stack sections vertically for a sidebar-main structure. Partition them horizontally for headers and footers. Let the layout engine do the math.
    #
    # {rdoc-image:/doc/images/widget_layout_split.png}[link:/examples/widget_layout_split/app_rb.html]
    #
    # === Example
    #
    # Run the interactive demo from the terminal:
    #
    #   ruby examples/widget_layout_split/app.rb
    class Layout < Data.define(:direction, :constraints, :children, :flex, :margin, :spacing)
      ##
      # :attr_reader: direction
      # Direction of the split.
      #
      # Either <tt>:vertical</tt> (top to bottom) or <tt>:horizontal</tt> (left to right).
      #
      #   layout.direction # => :vertical

      ##
      # :attr_reader: constraints
      # Array of rules defining section sizes.
      #
      # See RatatuiRuby::Layout::Constraint.

      ##
      # :attr_reader: children
      # Widgets to render in each section (optional).
      #
      # If provided, `children[i]` is rendered into the area defined by `constraints[i]`.

      ##
      # :attr_reader: flex
      # Strategy for distributing extra space.
      #
      # One of <tt>:legacy</tt>, <tt>:start</tt>, <tt>:center</tt>, <tt>:end</tt>, <tt>:space_between</tt>, <tt>:space_around</tt>.

      FLEX_MODES = %i[legacy start center end space_between space_around space_evenly].freeze # :nodoc:

      ##
      # Direction: split vertically (top to bottom).
      DIRECTION_VERTICAL = :vertical
      ##
      # Direction: split horizontally (left to right).
      DIRECTION_HORIZONTAL = :horizontal

      ##
      # Flex: use legacy sizing (default).
      FLEX_LEGACY = :legacy
      ##
      # Flex: align to start.
      FLEX_START = :start
      ##
      # Flex: center alignment.
      FLEX_CENTER = :center
      ##
      # Flex: align to end.
      FLEX_END = :end
      ##
      # Flex: space between elements.
      FLEX_SPACE_BETWEEN = :space_between
      ##
      # Flex: space around elements.
      FLEX_SPACE_AROUND = :space_around
      ##
      # Flex: space evenly between elements.
      FLEX_SPACE_EVENLY = :space_evenly

      ##
      # :attr_reader: margin
      # Margin around the layout area.
      #
      # Either a single <tt>Integer</tt> for uniform margin on all sides, or a
      # <tt>Hash</tt> with <tt>:horizontal</tt> and <tt>:vertical</tt> keys.
      #
      #   layout.margin # => 2

      ##
      # :attr_reader: spacing
      # Gap between segments (in cells).
      #
      # A positive integer that specifies the number of cells between each segment.
      #
      #   layout.spacing # => 1

      # Creates a new Layout.
      #
      # [direction]
      #   <tt>:vertical</tt> or <tt>:horizontal</tt> (default: <tt>:vertical</tt>).
      # [constraints]
      #   list of Constraint objects.
      # [children]
      #   List of widgets to render (optional).
      # [flex]
      #   Flex mode for spacing (default: <tt>:legacy</tt>).
      # [margin]
      #   Edge margin in cells (default: <tt>0</tt>).
      # [spacing]
      #   Gap between segments in cells (default: <tt>0</tt>).
      def initialize(direction: :vertical, constraints: [], children: [], flex: :legacy, margin: 0, spacing: 0)
        super
      end

      # Splits an area into multiple rectangles.
      #
      # This is a pure calculation helper for hit testing. It computes where
      # widgets *would* be placed without actually rendering them.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   rects = Layout::Layout.split(
      #     area,
      #     direction: :horizontal,
      #     constraints: [Layout::Constraint.percentage(50), Layout::Constraint.percentage(50)]
      #   )
      #   left, right = rects
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [area]
      #   The area to split. Can be a <tt>Rect</tt> or a <tt>Hash</tt> containing <tt>:x</tt>, <tt>:y</tt>, <tt>:width</tt>, and <tt>:height</tt>.
      # [direction]
      #   <tt>:vertical</tt> or <tt>:horizontal</tt> (default: <tt>:vertical</tt>).
      # [constraints]
      #   Array of <tt>Constraint</tt> objects defining section sizes.
      # [flex]
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Flex mode for spacing (default: <tt>:legacy</tt>).
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Returns an Array of <tt>Rect</tt> objects.
      def self.split(area, direction: :vertical, constraints:, flex: :legacy)
        # Coerce area to Rect for type safety (supports duck typing via _RectLike interface)
        rect = case area
               when Rect
                 area
               when Hash
                 Rect.new(
                   x: Integer(area.fetch(:x, 0)),
                   y: Integer(area.fetch(:y, 0)),
                   width: Integer(area.fetch(:width, 0)),
                   height: Integer(area.fetch(:height, 0))
                 )
               else
                 # Duck typing: accept any object responding to x, y, width, height
                 if area.respond_to?(:x) && area.respond_to?(:y) && area.respond_to?(:width) && area.respond_to?(:height)
                   # @type var rect_like: _RectLike
                   rect_like = area
                   Rect.new(x: rect_like.x, y: rect_like.y, width: rect_like.width, height: rect_like.height)
                 else
                   raise ArgumentError, "area must be a Rect, Hash, or respond to x/y/width/height, got #{area.class}"
                 end
        end
        raw_rects = _split(rect, direction, constraints, flex)
        raw_rects.map { |r| Rect.new(x: r[:x], y: r[:y], width: r[:width], height: r[:height]) }
      end

      # Splits an area into multiple rectangles, returning both segments and spacers.
      #
      # Layout splitting returns only the content areas. But some designs need to
      # render content in the gaps (dividers, separators, decorations).
      #
      # This method returns both the segments (content areas) and the spacers
      # (gaps between segments) as separate arrays. The spacers are the Rects
      # that represent the spacing between each segment.
      #
      # Use it to render custom separators or to calculate layout with spacing.
      #
      # [area]
      #   The area to split. Can be a <tt>Rect</tt> or a <tt>Hash</tt> containing <tt>:x</tt>, <tt>:y</tt>, <tt>:width</tt>, and <tt>:height</tt>.
      # [direction]
      #   <tt>:vertical</tt> or <tt>:horizontal</tt> (default: <tt>:vertical</tt>).
      # [constraints]
      #   Array of <tt>Constraint</tt> objects defining section sizes.
      # [flex]
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Flex mode for spacing (default: <tt>:legacy</tt>).
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Returns an Array of two Arrays: <tt>[segments, spacers]</tt>, each containing <tt>Rect</tt> objects.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   area = Rect.new(x: 0, y: 0, width: 100, height: 10)
      #   segments, spacers = Layout.split_with_spacers(
      #     area,
      #     direction: :horizontal,
      #     constraints: [Constraint.length(40), Constraint.length(40)],
      #     flex: :space_around
      #   )
      #   # segments: 2 Rects for content
      #   # spacers: Rects for gaps between/around segments
      #--
      # SPDX-SnippetEnd
      #++
      def self.split_with_spacers(area, direction: :vertical, constraints:, flex: :legacy)
        # Coerce area to Rect for type safety
        rect = case area
               when Rect
                 area
               when Hash
                 Rect.new(
                   x: Integer(area.fetch(:x, 0)),
                   y: Integer(area.fetch(:y, 0)),
                   width: Integer(area.fetch(:width, 0)),
                   height: Integer(area.fetch(:height, 0))
                 )
               else
                 if area.respond_to?(:x) && area.respond_to?(:y) && area.respond_to?(:width) && area.respond_to?(:height)
                   rect_like = area
                   Rect.new(x: rect_like.x, y: rect_like.y, width: rect_like.width, height: rect_like.height)
                 else
                   raise ArgumentError, "area must be a Rect, Hash, or respond to x/y/width/height, got #{area.class}"
                 end
        end
        raw_segments, raw_spacers = _split_with_spacers(rect, direction, constraints, flex)
        segments = raw_segments.map { |r| Rect.new(x: r[:x], y: r[:y], width: r[:width], height: r[:height]) }
        spacers = raw_spacers.map { |r| Rect.new(x: r[:x], y: r[:y], width: r[:width], height: r[:height]) }
        [segments, spacers]
      end
    end
  end
end
