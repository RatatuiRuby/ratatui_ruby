# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Layout
    # Defines a rectangular area in the terminal grid.
    #
    # Geometry management involves passing groups of four integers (`x, y, width, height`) repeatedly.
    # This is verbose and prone to parameter mismatch errors.
    #
    # This class encapsulates the geometry. It provides a standard primitive for passing area definitions
    # between layout engines and rendering functions.
    #
    # Use it when manual positioning is required or when querying layout results.
    #
    # === Examples
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   area = Layout::Rect.new(x: 0, y: 0, width: 80, height: 24)
    #   puts area.width # => 80
    #--
    # SPDX-SnippetEnd
    #++
    class Rect < Data.define(:x, :y, :width, :height)
      ##
      # :attr_reader: x
      # X coordinate (column) of the top-left corner (Integer, coerced via +to_int+ or +to_i+).

      ##
      # :attr_reader: y
      # Y coordinate (row) of the top-left corner (Integer, coerced via +to_int+ or +to_i+).

      ##
      # :attr_reader: width
      # Width in characters (Integer, coerced via +to_int+ or +to_i+).

      ##
      # :attr_reader: height
      # Height in characters (Integer, coerced via +to_int+ or +to_i+).

      # Creates a new Rect.
      #
      # All parameters accept any object responding to +to_int+ or +to_i+ (duck-typed).
      #
      # [x] Column index (Numeric).
      # [y] Row index (Numeric).
      # [width] Width in columns (Numeric).
      # [height] Height in rows (Numeric).
      def initialize(x: 0, y: 0, width: 0, height: 0)
        super(
          x: Integer(x),
          y: Integer(y),
          width: Integer(width),
          height: Integer(height)
        )
      end

      # Tests whether a point is inside this rectangle.
      #
      # Essential for hit testing mouse clicks against layout regions.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   area = Layout::Rect.new(x: 10, y: 5, width: 20, height: 10)
      #   area.contains?(15, 8) # => true
      #   area.contains?(5, 8)  # => false
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [px]
      #   X coordinate to test (column).
      # [py]
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Y coordinate to test (row).
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Returns true if the point (px, py) is within the rectangle bounds.
      def contains?(px, py)
        px >= x && px < x + width && py >= y && py < y + height
      end

      # Tests whether this rectangle overlaps with another.
      #
      # Essential for determining if a widget is visible within a viewport or clipping area.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   viewport = Layout::Rect.new(x: 0, y: 0, width: 80, height: 24)
      #   widget = Layout::Rect.new(x: 70, y: 20, width: 20, height: 10)
      #   viewport.intersects?(widget) # => true (partial overlap)
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [other]
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Another Rect to test against.
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Returns true if the rectangles overlap.
      def intersects?(other)
        x < other.x + other.width &&
          x + width > other.x &&
          y < other.y + other.height &&
          y + height > other.y
      end

      # Returns the overlapping area between this rectangle and another.
      #
      # Essential for calculating visible portions of widgets inside scroll views.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   viewport = Layout::Rect.new(x: 0, y: 0, width: 80, height: 24)
      #   widget = Layout::Rect.new(x: 70, y: 20, width: 20, height: 10)
      #   visible = viewport.intersection(widget)
      #   # => Rect(x: 70, y: 20, width: 10, height: 4)
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [other]
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Another Rect to intersect with.
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Returns a new Rect representing the intersection, or +nil+ if no overlap.
      def intersection(other)
        return nil unless intersects?(other)

        new_x = [x, other.x].max
        new_y = [y, other.y].max
        new_right = [x + width, other.x + other.width].min
        new_bottom = [y + height, other.y + other.height].min

        Rect.new(x: new_x, y: new_y, width: new_right - new_x, height: new_bottom - new_y)
      end

      # Left edge coordinate.
      #
      # Layout algorithms compute bounding boxes and check overlaps.
      # Reading <tt>rect.x</tt> forces you to remember that x means "left."
      #
      # Call <tt>left</tt> instead. Your code reads like prose.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   rect = Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
      #   rect.left # => 10
      #--
      # SPDX-SnippetEnd
      #++
      def left
        x
      end

      # Right edge coordinate.
      #
      # Bounds checks compare edges. Writing <tt>x + width</tt> inline clutters conditions.
      # Errors creep in when you forget the addition.
      #
      # This method computes and names the boundary. Returns the first column outside the rect.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   rect = Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
      #   rect.right # => 90
      #--
      # SPDX-SnippetEnd
      #++
      def right
        x + width
      end

      # Top edge coordinate.
      #
      # Layout algorithms compute bounding boxes and check overlaps.
      # Reading <tt>rect.y</tt> forces you to remember that y means "top."
      #
      # Call <tt>top</tt> instead. Your code reads like prose.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   rect = Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
      #   rect.top # => 5
      #--
      # SPDX-SnippetEnd
      #++
      def top
        y
      end

      # Bottom edge coordinate.
      #
      # Bounds checks compare edges. Writing <tt>y + height</tt> inline clutters conditions.
      # Errors creep in when you forget the addition.
      #
      # This method computes and names the boundary. Returns the first row outside the rect.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   rect = Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
      #   rect.bottom # => 29
      #--
      # SPDX-SnippetEnd
      #++
      def bottom
        y + height
      end

      # Total area in cells.
      #
      # Size comparisons and allocation calculations need area.
      # Computing <tt>width * height</tt> inline is noisy and error-prone.
      #
      # This method does the multiplication once.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   rect = Layout::Rect.new(x: 0, y: 0, width: 10, height: 5)
      #   rect.area # => 50
      #--
      # SPDX-SnippetEnd
      #++
      def area
        width * height
      end

      # True when the rect has zero area.
      #
      # Zero-width or zero-height rects break layout math.
      # Checking <tt>width == 0 || height == 0</tt> inline is tedious and easy to forget.
      #
      # Guard clauses call <tt>empty?</tt> to skip degenerate rects.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Layout::Rect.new(width: 0, height: 10).empty? # => true
      #   Layout::Rect.new(width: 10, height: 5).empty? # => false
      #--
      # SPDX-SnippetEnd
      #++
      def empty?
        width.zero? || height.zero?
      end

      # Bounding box containing both rectangles.
      #
      # Damage tracking and hit testing combine rects.
      # Computing min/max of all four edges inline is tedious and error-prone.
      #
      # This method returns the smallest rect that encloses both.
      #
      # [other] Rect to merge.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   r1 = Layout::Rect.new(x: 0, y: 0, width: 10, height: 10)
      #   r2 = Layout::Rect.new(x: 5, y: 5, width: 10, height: 10)
      #   r1.union(r2) # => Rect(x: 0, y: 0, width: 15, height: 15)
      #--
      # SPDX-SnippetEnd
      #++
      def union(other)
        new_x = [left, other.left].min
        new_y = [top, other.top].min
        new_right = [right, other.right].max
        new_bottom = [bottom, other.bottom].max

        Rect.new(
          x: new_x,
          y: new_y,
          width: new_right - new_x,
          height: new_bottom - new_y
        )
      end

      # Shrinks the rect by a uniform margin on all sides.
      #
      # Widgets render text inside borders. Subtracting margin from all four edges inline is verbose.
      # Off-by-one errors happen when you forget to double the margin.
      #
      # This method computes the content area. Returns a zero-area rect if margin exceeds dimensions.
      #
      # [margin] Integer padding on all sides.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   rect = Layout::Rect.new(x: 0, y: 0, width: 20, height: 10)
      #   rect.inner(2) # => Rect(x: 2, y: 2, width: 16, height: 6)
      #--
      # SPDX-SnippetEnd
      #++
      def inner(margin)
        doubled = margin * 2
        return Rect.new(x: 0, y: 0, width: 0, height: 0) if width < doubled || height < doubled

        Rect.new(
          x: x + margin,
          y: y + margin,
          width: width - doubled,
          height: height - doubled
        )
      end

      # Moves the rect without changing size.
      #
      # Animations and drag-and-drop shift widgets.
      # Adding offsets to x and y inline clutters the code.
      #
      # This method returns a translated copy.
      #
      # [dx] Horizontal shift (positive moves right).
      # [dy] Vertical shift (positive moves down).
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   rect = Layout::Rect.new(x: 10, y: 5, width: 20, height: 10)
      #   rect.offset(5, 3) # => Rect(x: 15, y: 8, width: 20, height: 10)
      #--
      # SPDX-SnippetEnd
      #++
      def offset(dx, dy)
        Rect.new(x: x + dx, y: y + dy, width:, height:)
      end

      # Constrains the rect to fit inside bounds.
      #
      # Popups and tooltips may extend beyond screen edges.
      # Manually clamping x, y, width, and height is verbose and error-prone.
      #
      # This method repositions and shrinks the rect to stay within bounds.
      #
      # [other] Bounding Rect.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   screen = Layout::Rect.new(x: 0, y: 0, width: 100, height: 100)
      #   popup = Layout::Rect.new(x: 80, y: 80, width: 30, height: 30)
      #   popup.clamp(screen) # => Rect(x: 70, y: 70, width: 30, height: 30)
      #--
      # SPDX-SnippetEnd
      #++
      def clamp(other)
        clamped_width = [width, other.width].min
        clamped_height = [height, other.height].min
        clamped_x = x.clamp(other.left, other.right - clamped_width)
        clamped_y = y.clamp(other.top, other.bottom - clamped_height)

        Rect.new(x: clamped_x, y: clamped_y, width: clamped_width, height: clamped_height)
      end

      # Iterates over horizontal slices.
      #
      # Lists render line by line. Looping <tt>height.times</tt> and constructing rects inline is noisy.
      #
      # This method yields each row as a Rect with height 1. Returns an Enumerator if no block given.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   rect = Layout::Rect.new(x: 0, y: 0, width: 5, height: 3)
      #   rect.rows.map { |r| r.y } # => [0, 1, 2]
      #--
      # SPDX-SnippetEnd
      #++
      def rows
        return to_enum(:rows) unless block_given?

        height.times do |i|
          yield Rect.new(x:, y: y + i, width:, height: 1)
        end
      end

      # Iterates over vertical slices.
      #
      # Grids render column by column. Looping <tt>width.times</tt> and constructing rects inline is noisy.
      #
      # This method yields each column as a Rect with width 1. Returns an Enumerator if no block given.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   rect = Layout::Rect.new(x: 0, y: 0, width: 5, height: 3)
      #   rect.columns.map { |c| c.x } # => [0, 1, 2, 3, 4]
      #--
      # SPDX-SnippetEnd
      #++
      def columns
        return to_enum(:columns) unless block_given?

        width.times do |i|
          yield Rect.new(x: x + i, y:, width: 1, height:)
        end
      end

      # Iterates over every cell in row-major order.
      #
      # Hit testing and pixel rendering touch every position.
      # Nested loops with manual coordinate math are verbose.
      #
      # This method yields <tt>[x, y]</tt> pairs. Returns an Enumerator if no block given.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   rect = Layout::Rect.new(x: 0, y: 0, width: 2, height: 2)
      #   rect.positions.to_a # => [[0, 0], [1, 0], [0, 1], [1, 1]]
      #--
      # SPDX-SnippetEnd
      #++
      def positions
        return to_enum(:positions) unless block_given?

        height.times do |row|
          width.times do |col|
            yield [x + col, y + row]
          end
        end
      end

      # Extracts the position (x, y) from this rect.
      #
      # Layout code sometimes separates position from size.
      # Extracting x and y into multiple variables is verbose.
      #
      # This method returns a Position object containing just the coordinates.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   rect = Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
      #   rect.as_position # => Position(x: 10, y: 5)
      #--
      # SPDX-SnippetEnd
      #++
      def as_position
        Position.new(x:, y:)
      end

      # Extracts the size (width, height) from this rect.
      #
      # Layout code sometimes separates size from position.
      # Extracting width and height into multiple variables is verbose.
      #
      # This method returns a Size object containing just the dimensions.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   rect = Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
      #   rect.as_size # => Size(width: 80, height: 24)
      #--
      # SPDX-SnippetEnd
      #++
      def as_size
        Size.new(width:, height:)
      end

      # Ruby-idiomatic aliases (TIMTOWTDI)
      alias position as_position
      alias size as_size
    end
  end
end
