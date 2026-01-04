# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  class BarChart
    # A group of bars in a grouped bar chart.
    #
    # === Examples
    #
    #   BarChart::BarGroup.new(label: "Q1", bars: [BarChart::Bar.new(value: 10), BarChart::Bar.new(value: 20)])
    class BarGroup < Data.define(:label, :bars)
      ##
      # :attr_reader: label
      # The label of the group (String).

      ##
      # :attr_reader: bars
      # The bars in the group (Array of Bar).
    end
  end
end
