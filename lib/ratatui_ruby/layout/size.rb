# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Layout
    # Terminal dimensions as width and height.
    #
    # Layout calculations need sizes. Passing width and height
    # as separate arguments is verbose and easy to swap by mistake.
    #
    # This class bundles dimensions into a single immutable object.
    # Extract it from a Rect or create it directly for sizing operations.
    #
    # Use it for terminal dimensions, widget sizing constraints,
    # or anywhere you need width/height without position.
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   size = Layout::Size.new(width: 80, height: 24)
    #   puts "Terminal is #{size.width} columns by #{size.height} rows"
    #
    #   # Extract from a Rect
    #   rect = Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
    #   size = rect.as_size # => Size(width: 80, height: 24)
    #--
    # SPDX-SnippetEnd
    #++
    class Size < Data.define(:width, :height)
      ##
      # :attr_reader: width
      # Width in terminal columns.

      ##
      # :attr_reader: height
      # Height in terminal rows.

      # Creates a new Size.
      #
      # [width] Width in columns (Integer, coerced via +Integer()+).
      # [height] Height in rows (Integer, coerced via +Integer()+).
      def initialize(width: 0, height: 0)
        super(width: Integer(width), height: Integer(height))
      end
    end
  end
end
