# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that splits an area into multiple sections based on constraints.
  #
  # [direction] The direction of the layout (:vertical or :horizontal).
  # [constraints] An array of Constraint objects defining the size of each section.
  # [children] An array of widgets to render within each section.
  # [flex] Controls how empty space is distributed (:legacy, :start, :center, :end,
  #        :space_between, :space_around).
  class Layout < Data.define(:direction, :constraints, :children, :flex)
    # :nodoc:
    FLEX_MODES = %i[legacy start center end space_between space_around].freeze

    # Creates a new Layout.
    #
    # [direction] The direction of the layout (:vertical or :horizontal).
    # [constraints] An array of Constraint objects defining the size of each section.
    # [children] An array of widgets to render within each section.
    # [flex] Controls how empty space is distributed (default: :legacy).
    def initialize(direction: :vertical, constraints: [], children: [], flex: :legacy)
      super
    end
  end
end
