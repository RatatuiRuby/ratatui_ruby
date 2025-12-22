# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Defines constraints for layout sections or table columns.
  #
  # [type] The type of constraint (:length, :percentage, :min).
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
  end
end
