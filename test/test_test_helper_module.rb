# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"

class TestTestHelperModule < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_with_test_terminal
    called = false
    with_test_terminal(30, 15) do
      called = true
      # Verify dimensions roughly via buffer content size
      assert_equal 15, buffer_content.size
      assert_equal 30, buffer_content.first.length
    end
    assert called, "Block should have been executed"
  end

  def test_buffer_content
    with_test_terminal(20, 5) do
      # Render something simple directly to test backend if possible,
      # or just verify empty buffer structure
      lines = buffer_content
      assert_equal 5, lines.size
      assert_equal " " * 20, lines.first
    end
  end

  def test_cursor_position_default
    with_test_terminal(20, 10) do
      pos = cursor_position
      assert_kind_of Integer, pos[:x]
      assert_kind_of Integer, pos[:y]
      assert_equal 0, pos[:x]
      assert_equal 0, pos[:y]
    end
  end

  def test_inject_event
    with_test_terminal(20, 10) do
      inject_event(RatatuiRuby::Event::Key.new(code: "a", modifiers: ["ctrl"]))
      event = RatatuiRuby.poll_event
      assert_kind_of RatatuiRuby::Event::Key, event
      assert_equal "a", event.code
      assert_equal ["ctrl"], event.modifiers
    end
  end

  def test_timeout_enforcement
    # Should raise Timeout::Error if app doesn't exit within 0.1s
    assert_raises(Timeout::Error) do
      with_test_terminal(20, 10, timeout: 0.1) do
        # Simulate infinite loop
        loop { sleep 0.05 }
      end
    end
  end
  
  def test_timeout_disabled
    # Should not raise error if timeout is disabled (nil)
    start_time = Time.now
    with_test_terminal(20, 10, timeout: nil) do
      sleep 0.2
    end
    assert_operator Time.now - start_time, :>=, 0.2
  end

  def test_inject_keys_string
    with_test_terminal(20, 10) do
      inject_keys("a", "b")
      
      event1 = RatatuiRuby.poll_event
      assert_equal "a", event1.code
      assert_empty event1.modifiers

      event2 = RatatuiRuby.poll_event
      assert_equal "b", event2.code
      assert_empty event2.modifiers
    end
  end

  def test_inject_keys_symbol
    with_test_terminal(20, 10) do
      inject_keys(:enter, :ctrl_c, :alt_shift_left)
      
      event1 = RatatuiRuby.poll_event
      assert_equal "enter", event1.code
      assert_empty event1.modifiers

      event2 = RatatuiRuby.poll_event
      assert_equal "c", event2.code
      assert_equal ["ctrl"], event2.modifiers
      
      event3 = RatatuiRuby.poll_event
      assert_equal "left", event3.code
      assert_equal ["alt", "shift"], event3.modifiers
    end
  end

  def test_inject_keys_hash
    with_test_terminal(20, 10) do
      inject_keys({ code: "x", modifiers: ["alt"] })
      
      event = RatatuiRuby.poll_event
      assert_equal "x", event.code
      assert_equal ["alt"], event.modifiers
    end
  end

  def test_inject_keys_object
    with_test_terminal(20, 10) do
      key = RatatuiRuby::Event::Key.new(code: "y")
      inject_keys(key)
      
      event = RatatuiRuby.poll_event
      assert_equal key, event
    end
  end
end
