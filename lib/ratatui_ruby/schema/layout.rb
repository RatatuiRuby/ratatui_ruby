# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
    # Divides an area into smaller chunks.
    #
    # Terminal screens vary in size. Hardcoded positions break when the window resizes. You need a way to organize space dynamically.
    #
    # This class manages geometry. It splits a given area into multiple sections based on a list of constraints.
    #
    # Use layouts to build responsive grids. Stack sections vertically for a sidebar-main structure. Partition them horizontally for headers and footers. Let the layout engine do the math.
    #
    # === Examples
    #
    #   # A simple vertical split (Sidebar / Main)
    #   Layout.new(
    #     direction: :horizontal,
    #     constraints: [
    #       Constraint.length(20), # Sidebar
    #       Constraint.min(0)      # Main content
    #     ]
    #   )
    #
    #   # Flex layout (Centering a block)
    #   Layout.new(
    #     direction: :vertical,
    #     flex: :center,
    #     constraints: [Constraint.length(10)], # A 10-row block centered vertically
    #     children: [modal_block]
    #   )
    class Layout < Data.define(:direction, :constraints, :children, :flex)
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
      # See RatatuiRuby::Constraint.

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

      # :nodoc:
      FLEX_MODES = %i[legacy start center end space_between space_around space_evenly].freeze

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
      def initialize(direction: :vertical, constraints: [], children: [], flex: :legacy)
        super
      end

      # Splits an area into multiple rectangles.
      #
      # This is a pure calculation helper for hit testing. It computes where
      # widgets *would* be placed without actually rendering them.
      #
      #   rects = Layout.split(
      #     area,
      #     direction: :horizontal,
      #     constraints: [Constraint.percentage(50), Constraint.percentage(50)]
      #   )
      #   left, right = rects
      #
      # [area]
      #   The area to split (a Rect or any object responding to x, y, width, height).
      # [direction]
      #   <tt>:vertical</tt> or <tt>:horizontal</tt> (default: <tt>:vertical</tt>).
      # [constraints]
      #   Array of Constraint objects defining section sizes.
      # [flex]
      #   Flex mode for spacing (default: <tt>:legacy</tt>).
      #
      # Returns an Array of Rect objects.
      def self.split(area, direction: :vertical, constraints:, flex: :legacy)
        raw_rects = _split(area, direction, constraints, flex)
        raw_rects.map { |r| Rect.new(x: r[:x], y: r[:y], width: r[:width], height: r[:height]) }
      end
    end
end
