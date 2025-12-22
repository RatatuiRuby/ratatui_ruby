# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Defines a border/title wrapper for widgets.
  #
  # [title] the title to display on the border.
  # [borders] an array of symbols [:top, :bottom, :left, :right, :all]
  # [border_color] the color of the border.
  class Block < Data.define(:title, :borders, :border_color)
    def initialize(title: nil, borders: [:all], border_color: nil)
      super
    end
  end
end
