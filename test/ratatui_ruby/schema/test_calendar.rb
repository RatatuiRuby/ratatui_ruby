# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

module RatatuiRuby
  class TestCalendar < Minitest::Test
    include RatatuiRuby::TestHelper
    def test_calendar_rendering
      # December 2025
      with_test_terminal(22, 7) do
        # Default: show_month_header: false
        calendar = Widgets::Calendar.new(year: 2025, month: 12)
        RatatuiRuby.draw { |f| f.render_widget(calendar, f.area) }

        # Header is hidden, so calendar starts directly with weekdays or dates
        assert_equal " Su Mo Tu We Th Fr Sa ", buffer_content[0]
        assert_equal "     1  2  3  4  5  6 ", buffer_content[1]
        assert_equal "  7  8  9 10 11 12 13 ", buffer_content[2]
        assert_equal " 14 15 16 17 18 19 20 ", buffer_content[3]
        assert_equal " 21 22 23 24 25 26 27 ", buffer_content[4]
        assert_equal " 28 29 30 31          ", buffer_content[5]
      end
    end

    def test_calendar_with_header
      with_test_terminal(22, 7) do
        calendar = Widgets::Calendar.new(year: 2025, month: 12, show_month_header: true)
        RatatuiRuby.draw { |f| f.render_widget(calendar, f.area) }

        assert_equal "    December 2025     ", buffer_content[0]
        assert_equal " Su Mo Tu We Th Fr Sa ", buffer_content[1]
      end
    end

    def test_calendar_with_styles
      with_test_terminal(24, 10) do
        style = Style::Style.new(fg: "red")
        calendar = Widgets::Calendar.new(
          year: 2025,
          month: 12,
          default_style: style,
          header_style: style,
          show_month_header: true,
          block: Widgets::Block.new(title: "Test Block")
        )
        RatatuiRuby.draw { |f| f.render_widget(calendar, f.area) }

        assert_equal "┌Test Block────────────┐", buffer_content[0]
        assert_equal "│    December 2025     │", buffer_content[1]
        assert_equal "│ Su Mo Tu We Th Fr Sa │", buffer_content[2]
        assert_equal "│     1  2  3  4  5  6 │", buffer_content[3]
        assert_equal "│  7  8  9 10 11 12 13 │", buffer_content[4]
        assert_equal "│ 14 15 16 17 18 19 20 │", buffer_content[5]
        assert_equal "│ 21 22 23 24 25 26 27 │", buffer_content[6]
        assert_equal "│ 28 29 30 31          │", buffer_content[7]
        assert_equal "└──────────────────────┘", buffer_content[9]
      end
    end

    def test_default_style_applies_to_calendar
      with_test_terminal(22, 7) do
        calendar = Widgets::Calendar.new(
          year: 2025,
          month: 12,
          default_style: Style::Style.new(fg: :cyan)
        )
        RatatuiRuby.draw { |f| f.render_widget(calendar, f.area) }

        ansi_output = render_rich_buffer
        # Cyan foreground = ANSI 36
        assert_includes ansi_output, "\e[36m", "Calendar default_style should apply cyan foreground"
      end
    end

    def test_header_style_applies_to_month_header
      with_test_terminal(22, 8) do
        calendar = Widgets::Calendar.new(
          year: 2025,
          month: 12,
          show_month_header: true,
          header_style: Style::Style.new(fg: :magenta)
        )
        RatatuiRuby.draw { |f| f.render_widget(calendar, f.area) }

        ansi_output = render_rich_buffer
        # Magenta foreground = ANSI 35
        assert_includes ansi_output, "\e[35m", "Calendar header_style should apply magenta foreground"
      end
    end
  end
end
