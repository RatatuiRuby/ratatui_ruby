# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  class TUI
    # Layout factory methods for Session.
    #
    # Provides convenient access to Layout::Rect, Layout::Constraint,
    # and Layout::Layout without fully qualifying the class names.
    module LayoutFactories
      # Creates a Layout::Rect.
      # @return [Layout::Rect]
      def rect(...)
        Layout::Rect.new(...)
      end

      # Creates a Layout::Constraint.
      # @return [Layout::Constraint]
      def constraint(...)
        Layout::Constraint.new(...)
      end

      # Creates a Layout::Constraint.length.
      # @return [Layout::Constraint]
      def constraint_length(n)
        Layout::Constraint.length(n)
      end

      # Creates a Layout::Constraint.percentage.
      # @return [Layout::Constraint]
      def constraint_percentage(n)
        Layout::Constraint.percentage(n)
      end

      # Creates a Layout::Constraint.min.
      # @return [Layout::Constraint]
      def constraint_min(n)
        Layout::Constraint.min(n)
      end

      # Creates a Layout::Constraint.max.
      # @return [Layout::Constraint]
      def constraint_max(n)
        Layout::Constraint.max(n)
      end

      # Creates a Layout::Constraint.fill.
      # @return [Layout::Constraint]
      def constraint_fill(n = 1)
        Layout::Constraint.fill(n)
      end

      # Creates a Layout::Constraint.ratio.
      # @return [Layout::Constraint]
      def constraint_ratio(numerator, denominator)
        Layout::Constraint.ratio(numerator, denominator)
      end

      # Creates a Layout::Layout.
      # @return [Layout::Layout]
      def layout(...)
        Layout::Layout.new(...)
      end

      # Splits an area using Layout::Layout.split.
      # @return [Array<Layout::Rect>]
      def layout_split(area, direction: :vertical, constraints:, flex: :legacy)
        Layout::Layout.split(area, direction:, constraints:, flex:)
      end
    end
  end
end
