# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Defines constraints for layout sections.
  #
  # [type] the type of constraint (:length, :percentage, :min).
  # [value] the numeric value of the constraint.
  class Constraint < Data.define(:type, :value)
    # Creates a length constraint.
    # [v] the length value.
    def self.length(v)
      new(type: :length, value: v)
    end

    # Creates a percentage constraint.
    # [v] the percentage value.
    def self.percentage(v)
      new(type: :percentage, value: v)
    end

    # Creates a minimum size constraint.
    # [v] the minimum value.
    def self.min(v)
      new(type: :min, value: v)
    end
  end
end
