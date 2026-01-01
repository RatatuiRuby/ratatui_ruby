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
  # {rdoc-image:/doc/images/widget_calendar_demo.png}[link:/examples/widget_calendar_demo/app_rb.html]
  #
  # === Example
  #
  # Run the interactive demo from the terminal:
  #
  #   ruby examples/widget_calendar_demo/app.rb
  class Calendar < Data.define(:year, :month, :events, :default_style, :header_style, :block, :show_weekdays_header, :show_surrounding, :show_month_header)
    ##
    # :attr_reader: year
    # The year to display (Integer).

    ##
    # :attr_reader: month
    # The month to display (1–12).

    ##
    # :attr_reader: events
    # A Hash mapping Dates to Styles for event highlighting.
    # Keys must be `Date` objects (or objects responding to `day`, `month`, `year`).
    # Values must be `Style` objects.

    ##
    # :attr_reader: default_style
    # Style for the days.

    ##
    # :attr_reader: header_style
    # Style for the month name header.

    ##
    # :attr_reader: block
    # Optional wrapping block.

    ##
    # :attr_reader: show_weekdays_header
    # Whether to show the weekday header (Mon, Tue, etc.).

    ##
    # :attr_reader: show_surrounding
    # Style for dates from surrounding months. If <tt>nil</tt>, surrounding dates are hidden.

    # Creates a new Calendar.
    #
    # [year] Integer.
    # [month] Integer.
    # [events] Hash<Date, Style>. Optional.
    # [default_style] Style.
    # [header_style] Style.
    # [block] Block.
    # [show_weekdays_header] Boolean. Whether to show the weekday header.
    # [show_surrounding] <tt>Style</tt> or <tt>nil</tt>. Style for surrounding month dates.
    def initialize(year:, month:, events: {}, default_style: nil, header_style: nil, block: nil, show_weekdays_header: true, show_surrounding: nil, show_month_header: false)
      super(
        year: Integer(year),
        month: Integer(month),
        events:,
        default_style:,
        header_style:,
        block:,
        show_weekdays_header:,
        show_surrounding:,
        show_month_header:
      )
    end
  end
end
