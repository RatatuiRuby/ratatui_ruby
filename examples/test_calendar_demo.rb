# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "minitest/autorun"
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require_relative "calendar_demo"

module CalendarDemo
  class TestCalendarDemo < Minitest::Test
    include RatatuiRuby::TestHelper


    def test_demo_renders
      with_test_terminal(40, 20) do
        inject_keys(:down, :down, :q)

        CalendarDemo.run

        content = buffer_content
        rendered_text = content.join("\n")

        assert_match(/Calendar \(q = quit\)/, rendered_text)
        assert_match(/#{Time.now.year}/, rendered_text)

        # Verify the size constraint: the terminal is 40x20
        # But the layout should be constrained to 24x10.
        lines = content

        # First 10 rows: first 24 chars can have content, 24..39 should be empty
        10.times do |i|
          assert_equal " " * 16, lines[i][24..39], "Row #{i} should be empty after column 24"
        end

        # Rows 10..19 should be completely empty
        (10..19).each do |i|
          assert_equal " " * 40, lines[i], "Row #{i} should be completely empty"
        end
      end
    end
  end
end
