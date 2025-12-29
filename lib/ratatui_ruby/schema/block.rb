# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that wraps other widgets with a border and/or a title.
  #
  # [title] The title string to display on the border.
  # [title_alignment] The alignment of the title: [:left, :center, :right]
  # [borders] An array of symbols representing which borders to display:
  #           [:top, :bottom, :left, :right, :all, :none]
  # [border_color] The color of the border (e.g., "red", "#ff0000").
  # [border_type] The type of border to display:
  #               [:plain, :rounded, :double, :thick, :quadrant_inside, :quadrant_outside]
  # [style] The base style of the block (e.g., { fg: "blue", bg: "white" }).
  # [padding] The padding inside the block. Can be an Integer (uniform) or
  #           an Array of 4 Integers [left, right, top, bottom].
  # [titles] An array of titles. Each title can be a String or a Hash/Object
  #          with keys: content, alignment, position.
  class Block < Data.define(:title, :titles, :title_alignment, :borders, :border_color, :border_type, :style, :padding)
    # Creates a new Block.
    #
    # [title] The title string to display on the border.
    # [titles] An array of titles.
    # [title_alignment] The alignment of the title.
    # [borders] An array of symbols representing which borders to display.
    # [border_color] The color of the border.
    # [border_type] The type of border to display.
    # [style] The base style of the block.
    # [padding] The padding inside the block.
    def initialize(title: nil, titles: [], title_alignment: nil, borders: [:all], border_color: nil, border_type: nil, style: nil, padding: 0)
      super
    end
  end
end
