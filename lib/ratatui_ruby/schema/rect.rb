# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A rectangle in the terminal grid.
  #
  # [x] The x-coordinate of the top-left corner.
  # [y] The y-coordinate of the top-left corner.
  # [width] The width of the rectangle.
  # [height] The height of the rectangle.
  class Rect < Data.define(:x, :y, :width, :height)
    # Creates a new Rect.
    #
    # [x] The x-coordinate of the top-left corner.
    # [y] The y-coordinate of the top-left corner.
    # [width] The width of the rectangle.
    # [height] The height of the rectangle.
    def initialize(x: 0, y: 0, width: 0, height: 0)
      super
    end
  end
end
