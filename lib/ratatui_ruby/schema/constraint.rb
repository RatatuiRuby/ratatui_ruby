# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Defines constraints for layout sections or table columns.
  #
  # [type] The type of constraint (:length, :percentage, :min, :max, :fill).
  # [value] The numeric value associated with the constraint.
  class Constraint < Data.define(:type, :value)
    # Creates a length constraint (fixed number of cells).
    #
    # [v] The length value in cells.
    def self.length(v)
      new(type: :length, value: v)
    end

    # Creates a percentage constraint (portion of available space).
    #
    # [v] The percentage value (0-100).
    def self.percentage(v)
      new(type: :percentage, value: v)
    end

    # Creates a minimum size constraint.
    #
    # [v] The minimum number of cells.
    def self.min(v)
      new(type: :min, value: v)
    end

    # Creates a maximum size constraint.
    #
    # [v] The maximum number of cells.
    def self.max(v)
      new(type: :max, value: v)
    end

    # Creates a fill constraint that takes remaining space proportionally.
    #
    # Fill constraints distribute remaining space among themselves proportionally
    # based on their values. For example, Fill(1) and Fill(3) would split space
    # in a 1:3 ratio.
    #
    # [v] The proportional weight (default: 1).
    def self.fill(v = 1)
      new(type: :fill, value: v)
    end
  end
end
