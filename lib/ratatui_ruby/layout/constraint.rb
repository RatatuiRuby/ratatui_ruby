# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  module Layout
    # Defines the sizing rule for a layout section.
    #
    # Flexible layouts need rules. You can't just place widgets at absolute coordinates; they must adapt to changing terminal sizes.
    #
    # This class defines the rules of engagement. It tells the layout engine exactly how much space a section requires relative to others.
    #
    # Mix and match fixed lengths, percentages, ratios, and minimums. Build layouts that breathe.
    #
    # === Examples
    #
    #   Layout::Constraint.length(5)      # Exactly 5 cells
    #   Layout::Constraint.percentage(50) # Half the available space
    #   Layout::Constraint.min(10)        # At least 10 cells, maybe more
    #   Layout::Constraint.fill(1)        # Fill remaining space (weight 1)
    class Constraint < Data.define(:type, :value)
      ##
      # :attr_reader: type
      # The type of constraint.
      #
      # <tt>:length</tt>, <tt>:percentage</tt>, <tt>:min</tt>, <tt>:max</tt>, <tt>:fill</tt>, or <tt>:ratio</tt>.

      ##
      # :attr_reader: value
      # The numeric value (or array for ratio) associated with the rule.

      # Requests a fixed size.
      #
      #   Layout::Constraint.length(10) # 10 characters wide/high
      #
      # [v] Number of cells (Integer).
      def self.length(v)
        new(type: :length, value: Integer(v))
      end

      # Requests a percentage of available space.
      #
      #   Layout::Constraint.percentage(25) # 25% of the area
      #
      # [v] Percentage 0-100 (Integer).
      def self.percentage(v)
        new(type: :percentage, value: Integer(v))
      end

      # Enforces a minimum size.
      #
      #   Layout::Constraint.min(5) # At least 5 cells
      #
      # This section will grow if space permits, but never shrink below +v+.
      #
      # [v] Minimum cells (Integer).
      def self.min(v)
        new(type: :min, value: Integer(v))
      end

      # Enforces a maximum size.
      #
      #   Layout::Constraint.max(10) # At most 10 cells
      #
      # [v] Maximum cells (Integer).
      def self.max(v)
        new(type: :max, value: Integer(v))
      end

      # Fills remaining space proportionally.
      #
      #   Layout::Constraint.fill(1) # Equal share
      #   Layout::Constraint.fill(2) # Double share
      #
      # Fill constraints distribute any space left after satisfying strict rules.
      # They behave like flex-grow. A fill(2) takes twice as much space as a fill(1).
      #
      # [v] Proportional weight (Integer, default: 1).
      def self.fill(v = 1)
        new(type: :fill, value: Integer(v))
      end

      # Requests a specific ratio of the total space.
      #
      #   Layout::Constraint.ratio(1, 3) # 1/3rd of the area
      #
      # [numerator] Top part of fraction (Integer).
      # [denominator] Bottom part of fraction (Integer).
      def self.ratio(numerator, denominator)
        new(type: :ratio, value: [Integer(numerator), Integer(denominator)])
      end
    end
  end
end
