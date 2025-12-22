# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that splits an area into multiple sections based on constraints.
  #
  # [direction] The direction of the layout (:vertical or :horizontal).
  # [constraints] An array of Constraint objects defining the size of each section.
  # [children] An array of widgets to render within each section.
  class Layout < Data.define(:direction, :constraints, :children)
    # Creates a new Layout.
    #
    # [direction] The direction of the layout (:vertical or :horizontal).
    # [constraints] An array of Constraint objects defining the size of each section.
    # [children] An array of widgets to render within each section.
    def initialize(direction: :vertical, constraints: [], children: [])
      super
    end
  end
end
