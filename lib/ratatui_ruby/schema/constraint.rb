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
    def self.length(v)
      new(:length, v)
    end

    # Creates a percentage constraint.
    def self.percentage(v)
      new(:percentage, v)
    end

    # Creates a minimum size constraint.
    def self.min(v)
      new(:min, v)
    end
  end
end
