# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "minitest/autorun"
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require_relative "../../../examples/widget_calendar/app"

class TestWidgetCalendarDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  # Use a fixed date for deterministic snapshots
  FIXED_DATE = Time.new(2026, 1, 3, 12, 0, 0)

  def setup
    @app = WidgetCalendar.new(date: FIXED_DATE)
  end

  private def assert_normalized_snapshots(snapshot_name)
    assert_snapshots(snapshot_name)
    assert_rich_snapshot(snapshot_name)
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_normalized_snapshots("initial_render")
    end
  end

  def test_toggle_weekdays_header
    with_test_terminal do
      inject_keys("w", :q)
      @app.run

      assert_normalized_snapshots("after_weekdays_toggle")
    end
  end

  def test_toggle_header
    with_test_terminal do
      inject_keys("h", :q)
      @app.run

      assert_normalized_snapshots("after_header_toggle")
    end
  end

  def test_toggle_surrounding
    with_test_terminal do
      inject_keys("s", :q)
      @app.run

      assert_normalized_snapshots("after_surrounding_toggle")
    end
  end

  def test_toggle_events
    with_test_terminal do
      inject_keys("e", :q)
      @app.run

      assert_normalized_snapshots("after_events_toggle")
    end
  end
end
