# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "minitest/autorun"
require "ratatui_ruby"

module CalendarDemo
  class TestCalendarDemo < Minitest::Test
    def setup
      RatatuiRuby.init_test_terminal(40, 20)
    end

    def test_demo_renders
      # We can't easily test the loop in run, but we can test the rendering logic
      now = Time.now
      calendar = RatatuiRuby::Calendar.new(
        year: now.year,
        month: now.month,
        header_style: RatatuiRuby::Style.new(fg: "yellow", modifiers: [:bold]),
        block: RatatuiRuby::Block.new(title: " Calendar (q = quit) ", borders: [:all]),
      )

      # Constrain the calendar to 24x10 characters
      view = RatatuiRuby::Layout.new(
        direction: :vertical,
        constraints: [
          RatatuiRuby::Constraint.length(10),
          RatatuiRuby::Constraint.min(0),
        ],
        children: [
          RatatuiRuby::Layout.new(
            direction: :horizontal,
            constraints: [
              RatatuiRuby::Constraint.length(24),
              RatatuiRuby::Constraint.min(0),
            ],
            children: [calendar, nil],
          ),
          nil,
        ],
      )

      RatatuiRuby.draw(view)
      content = RatatuiRuby.get_buffer_content

      assert_match(/Calendar Demo/, content)
      assert_match(/#{now.year}/, content)

      # Verify the size constraint: the terminal is 40x20
      # But the layout should be constrained to 24x10.
      lines = content.split("\n")

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
