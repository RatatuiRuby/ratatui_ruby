# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../app"

class TestAppAllEvents < Minitest::Test
  include RatatuiRuby::TestHelper

  # Time pattern matches HH:MM:SS format
  TIME_PATTERN = /\d{2}:\d{2}:\d{2}/

  def setup
    @app = AppAllEvents.new
  end

  def test_initial_state
    with_test_terminal do
      inject_key(:q)
      @app.run
      assert_normalized_snapshot("initial_state")
    end
  end

  def test_unmodified_key_press
    with_test_terminal do
      inject_keys("a", :q)
      @app.run
      assert_normalized_snapshot("after_key_a")
    end
  end

  def test_modified_key_press
    with_test_terminal do
      inject_keys(:ctrl_x, :q)
      @app.run
      assert_normalized_snapshot("after_key_ctrl_x")
    end
  end

  def test_mouse_click
    with_test_terminal do
      inject_click(x: 40, y: 12)
      inject_key(:q)
      @app.run
      assert_normalized_snapshot("after_mouse_click")
    end
  end

  def test_focus_lost
    with_test_terminal do
      inject_event(RatatuiRuby::Event::FocusLost.new)
      inject_key(:q)
      @app.run
      assert_normalized_snapshot("after_focus_lost")
    end
  end

  def test_focus_gained_after_lost
    with_test_terminal do
      inject_event(RatatuiRuby::Event::FocusLost.new)
      inject_event(RatatuiRuby::Event::FocusGained.new)
      inject_key(:q)
      @app.run
      assert_normalized_snapshot("after_focus_regained")
    end
  end

  def test_paste_event
    with_test_terminal do
      inject_event(RatatuiRuby::Event::Paste.new(content: "Hello World"))
      inject_key(:q)
      @app.run
      assert_normalized_snapshot("after_paste")
    end
  end

  def test_resize_event
    with_test_terminal do
      inject_event(RatatuiRuby::Event::Resize.new(width: 100, height: 30))
      inject_key(:q)
      @app.run
      assert_normalized_snapshot("after_resize")
    end
  end

  def test_multiple_events_accumulate
    with_test_terminal do
      inject_keys("a", "b", "c")
      inject_click(x: 10, y: 5)
      inject_key(:q)
      @app.run
      assert_normalized_snapshot("after_multiple_events")
    end
  end

  def test_quit_with_q
    with_test_terminal do
      inject_key(:q)
      @app.run
      # If we reach here without timeout, quit worked
      assert true
    end
  end

  def test_quit_with_ctrl_c
    with_test_terminal do
      inject_key(:ctrl_c)
      @app.run
      # If we reach here without timeout, Ctrl+C quit worked
      assert true
    end
  end

  # Additional tests for mutation testing coverage

  def test_mouse_drag
    with_test_terminal do
      inject_drag(x: 25, y: 8)
      inject_key(:q)
      @app.run
      assert_normalized_snapshot("after_mouse_drag")
    end
  end

  def test_horizontal_resize
    with_test_terminal do
      inject_event(RatatuiRuby::Event::Resize.new(width: 100, height: 24))
      inject_key(:q)
      @app.run
      assert_normalized_snapshot("after_horizontal_resize")
    end
  end

  def test_vertical_resize
    with_test_terminal do
      inject_event(RatatuiRuby::Event::Resize.new(width: 80, height: 30))
      inject_key(:q)
      @app.run
      assert_normalized_snapshot("after_vertical_resize")
    end
  end

  def test_right_click
    with_test_terminal do
      inject_right_click(x: 50, y: 10)
      inject_key(:q)
      @app.run
      assert_normalized_snapshot("after_right_click")
    end
  end

  private def assert_normalized_snapshot(snapshot_name)
    assert_snapshot(snapshot_name) do |actual|
      # Normalize actual lines
      actual.map do |line|
        line.gsub(TIME_PATTERN, "XX:XX:XX")
          .gsub(/0x[0-9a-f]+/, "0xXXXXXX")
      end
    end
  end
end
