# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that wraps other widgets with a border and/or a title.
  #
  # [title] The title string to display on the border.
  # [borders] An array of symbols representing which borders to display:
  #           [:top, :bottom, :left, :right, :all, :none]
  # [border_color] The color of the border (e.g., "red", "#ff0000").
  # [border_type] The type of border to display:
  #               [:plain, :rounded, :double, :thick, :quadrant_inside, :quadrant_outside]
  class Block < Data.define(:title, :borders, :border_color, :border_type)
    # Creates a new Block.
    #
    # [title] The title string to display on the border.
    # [borders] An array of symbols representing which borders to display.
    # [border_color] The color of the border.
    # [border_type] The type of border to display.
    def initialize(title: nil, borders: [:all], border_color: nil, border_type: nil)
      super
    end
  end
end
