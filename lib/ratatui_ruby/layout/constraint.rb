# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

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
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   Layout::Constraint.length(5)      # Exactly 5 cells
    #   Layout::Constraint.percentage(50) # Half the available space
    #   Layout::Constraint.min(10)        # At least 10 cells, maybe more
    #   Layout::Constraint.fill(1)        # Fill remaining space (weight 1)
    #--
    # SPDX-SnippetEnd
    #++
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
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Layout::Constraint.length(10) # 10 characters wide/high
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [v] Number of cells (Integer).
      def self.length(v)
        new(type: :length, value: Integer(v))
      end

      # Requests a percentage of available space.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Layout::Constraint.percentage(25) # 25% of the area
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [v] Percentage 0-100 (Integer).
      def self.percentage(v)
        new(type: :percentage, value: Integer(v))
      end

      # Enforces a minimum size.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Layout::Constraint.min(5) # At least 5 cells
      #
      #--
      # SPDX-SnippetEnd
      #++
      # This section will grow if space permits, but never shrink below +v+.
      #
      # [v] Minimum cells (Integer).
      def self.min(v)
        new(type: :min, value: Integer(v))
      end

      # Enforces a maximum size.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Layout::Constraint.max(10) # At most 10 cells
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [v] Maximum cells (Integer).
      def self.max(v)
        new(type: :max, value: Integer(v))
      end

      # Fills remaining space proportionally.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Layout::Constraint.fill(1) # Equal share
      #   Layout::Constraint.fill(2) # Double share
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Fill constraints distribute any space left after satisfying strict rules.
      # They behave like flex-grow. A fill(2) takes twice as much space as a fill(1).
      #
      # [v] Proportional weight (Integer, default: 1).
      def self.fill(v = 1)
        new(type: :fill, value: Integer(v))
      end

      # Requests a specific ratio of the total space.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Layout::Constraint.ratio(1, 3) # 1/3rd of the area
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [numerator] Top part of fraction (Integer).
      # [denominator] Bottom part of fraction (Integer).
      def self.ratio(numerator, denominator)
        new(type: :ratio, value: [Integer(numerator), Integer(denominator)])
      end

      # Converts an array of lengths into an array of Length constraints.
      #
      # Complex layouts often use multiple fixed-size sections. Manually creating each constraint
      # clutters the code.
      #
      # This method maps over the input, returning a constraint array in one call.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Constraint.from_lengths([10, 20, 10])
      #   # => [Constraint.length(10), Constraint.length(20), Constraint.length(10)]
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [values] Enumerable of Integers.
      def self.from_lengths(values)
        values.map { |v| length(v) }
      end

      # Converts an array of percentages into an array of Percentage constraints.
      #
      # Percentage-based layouts distribute space proportionally. This method batches the creation.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Constraint.from_percentages([25, 50, 25])
      #   # => [Constraint.percentage(25), Constraint.percentage(50), Constraint.percentage(25)]
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [values] Enumerable of Integers (0-100).
      def self.from_percentages(values)
        values.map { |v| percentage(v) }
      end

      # Converts an array of minimums into an array of Min constraints.
      #
      # Minimum constraints ensure sections never shrink below a threshold. Batch them here.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Constraint.from_mins([5, 10, 5])
      #   # => [Constraint.min(5), Constraint.min(10), Constraint.min(5)]
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [values] Enumerable of Integers.
      def self.from_mins(values)
        values.map { |v| min(v) }
      end

      # Converts an array of maximums into an array of Max constraints.
      #
      # Maximum constraints cap section sizes. Batch them here.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Constraint.from_maxes([20, 30, 40])
      #   # => [Constraint.max(20), Constraint.max(30), Constraint.max(40)]
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [values] Enumerable of Integers.
      def self.from_maxes(values)
        values.map { |v| max(v) }
      end

      # Converts an array of weights into an array of Fill constraints.
      #
      # Fill constraints distribute remaining space by weight. Batch them here.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Constraint.from_fills([1, 2, 1])
      #   # => [Constraint.fill(1), Constraint.fill(2), Constraint.fill(1)]
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [values] Enumerable of Integers.
      def self.from_fills(values)
        values.map { |v| fill(v) }
      end

      # Converts an array of ratio pairs into an array of Ratio constraints.
      #
      # Ratio constraints define exact fractions of space. Batch them here.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Constraint.from_ratios([[1, 4], [2, 4], [1, 4]])
      #   # => [Constraint.ratio(1, 4), Constraint.ratio(2, 4), Constraint.ratio(1, 4)]
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [pairs] Enumerable of <tt>[numerator, denominator]</tt> arrays.
      def self.from_ratios(pairs)
        pairs.map { |n, d| ratio(n, d) }
      end
    end
  end
end
