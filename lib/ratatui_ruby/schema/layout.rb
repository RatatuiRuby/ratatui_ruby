# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that splits an area into multiple sections.
  #
  # [direction] either :vertical or :horizontal.
  # [constraints] an array of Constraint objects.
  # [children] the widgets to render within the layout sections.
  class Layout < Data.define(:direction, :constraints, :children)
    # Creates a new Layout.
    #
    # [direction] :vertical or :horizontal.
    # [constraints] an array of Constraint objects.
    # [children] widgets to include in this layout.
    def initialize(direction: :vertical, constraints: [], children: [])
      super
    end
  end
end
