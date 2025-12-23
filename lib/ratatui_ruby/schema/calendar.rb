# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A Monthly Calendar widget.
  #
  # [year] Integer (e.g., 2025)
  # [month] Integer (1-12)
  # [day_style] Style (Style for regular days)
  # [header_style] Style (Style for the month title)
  # [block] Block
  class Calendar < Data.define(:year, :month, :day_style, :header_style, :block)
    # Creates a new Calendar.
    #
    # [year] Integer (e.g., 2025)
    # [month] Integer (1-12)
    # [day_style] Style (Style for regular days)
    # [header_style] Style (Style for the month title)
    # [block] Block
    def initialize(year:, month:, day_style: nil, header_style: nil, block: nil)
      super
    end
  end
end
