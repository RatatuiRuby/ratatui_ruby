# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "minitest/autorun"
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require_relative "app"

class TestCalendarDemoApp < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = CalendarDemoApp.new
  end

  def test_demo_renders
    with_test_terminal do
      inject_keys(:down, :down, :q)

      @app.run

      content = buffer_content
      rendered_text = content.join("\n")

      assert_match(/Calendar \(w=toggle/, rendered_text)
      assert_match(/#{Time.now.year}/, rendered_text)

      # Verify the size constraint: the terminal is 80x24
      # But the layout should be constrained to 24x10.
      lines = content

      # First 10 rows: first 24 chars can have content, 24..79 should be empty
      10.times do |i|
        assert_equal " " * 56, lines[i][24..79], "Row #{i} should be empty after column 24"
      end

      # Rows 10..23 should be completely empty
      (10..23).each do |i|
        assert_equal " " * 80, lines[i], "Row #{i} should be completely empty"
      end
    end
  end

  def test_toggle_weekdays_header
    with_test_terminal do
      inject_keys("w", "w", :q)

      @app.run

      content = buffer_content
      rendered_text = content.join("\n")

      # The app should render successfully with weekdays toggled
      assert_match(/#{Time.now.year}/, rendered_text)
    end
  end

  def test_toggle_surrounding
    with_test_terminal do
      inject_keys("s", "s", :q)

      @app.run

      content = buffer_content
      rendered_text = content.join("\n")

      # The app should render successfully with surrounding toggled
      assert_match(/#{Time.now.year}/, rendered_text)
    end
  end
end
