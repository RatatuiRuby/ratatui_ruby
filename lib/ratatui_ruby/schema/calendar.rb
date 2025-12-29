# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
    # Displays a monthly calendar grid.
    #
    # Dates are complex. Rendering them in a grid requires calculation of leap years, month lengths, and day-of-week offsets.
    # Use this widget to skip the boilerplate.
    #
    # This widget renders a standard monthly view. It highlights the current date. It structures time.
    #
    # Use it for date pickers, schedulers, or logs.
    #
    # === Examples
    #
    #   Calendar.new(
    #     year: 2025,
    #     month: 12,
    #     day_style: Style.new(fg: :white),
    #     header_style: Style.new(fg: :yellow, modifiers: [:bold])
    #   )
    class Calendar < Data.define(:year, :month, :day_style, :header_style, :block)
      ##
      # :attr_reader: year
      # The year to display (Integer).

      ##
      # :attr_reader: month
      # The month to display (1-12).

      ##
      # :attr_reader: day_style
      # Style for the days.

      ##
      # :attr_reader: header_style
      # Style for the month name header.

      ##
      # :attr_reader: block
      # Optional wrapping block.

      # Creates a new Calendar.
      #
      # [year] Integer.
      # [month] Integer.
      # [day_style] Style.
      # [header_style] Style.
      # [block] Block.
      def initialize(year:, month:, day_style: nil, header_style: nil, block: nil)
        super
      end
    end
end
