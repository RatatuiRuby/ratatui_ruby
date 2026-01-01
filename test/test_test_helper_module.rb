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

  def test_raises_when_injecting_outside_context
    error = assert_raises(RuntimeError) do
      inject_key("q")
    end
    assert_match(/Events must be injected/, error.message)
  end

  def test_allows_injecting_inside_context
    with_test_terminal(10, 5) do
      # Should not raise
      inject_key("q")
    end
  end

  def test_inject_mouse_modifiers
    with_test_terminal do
      inject_mouse(x: 10, y: 5, kind: :down, button: :left, modifiers: ["ctrl", "alt"])

      event = RatatuiRuby.poll_event
      assert_instance_of RatatuiRuby::Event::Mouse, event
      assert_equal "down", event.kind
      assert_equal 10, event.x
      assert_equal 5, event.y
      assert_equal "left", event.button
      assert_equal ["alt", "ctrl"], event.modifiers.sort
    end
  end

  def test_inject_mouse
    with_test_terminal do
      inject_mouse(x: 10, y: 5, kind: :down, button: :left)

      event = RatatuiRuby.poll_event
      assert_instance_of RatatuiRuby::Event::Mouse, event
      assert_equal "down", event.kind
      assert_equal 10, event.x
      assert_equal 5, event.y
      assert_equal "left", event.button
      assert_empty event.modifiers
    end
  end

  def test_inject_click
    with_test_terminal do
      inject_click(x: 20, y: 15, modifiers: ["ctrl"])

      event = RatatuiRuby.poll_event
      assert_instance_of RatatuiRuby::Event::Mouse, event
      assert_equal "down", event.kind
      assert_equal 20, event.x
      assert_equal 15, event.y
      assert_equal "left", event.button
      assert_equal ["ctrl"], event.modifiers
    end
  end

  def test_inject_right_click
    with_test_terminal do
      inject_right_click(x: 0, y: 0)

      event = RatatuiRuby.poll_event
      assert_instance_of RatatuiRuby::Event::Mouse, event
      assert_equal "down", event.kind
      assert_equal 0, event.x
      assert_equal 0, event.y
      assert_equal "right", event.button
    end
  end

  def test_inject_right_click_modifiers
    with_test_terminal do
      inject_right_click(x: 0, y: 0, modifiers: ["shift"])

      event = RatatuiRuby.poll_event
      assert_instance_of RatatuiRuby::Event::Mouse, event
      assert_equal "down", event.kind
      assert_equal 0, event.x
      assert_equal 0, event.y
      assert_equal "right", event.button
      assert_equal ["shift"], event.modifiers
    end
  end

  def test_inject_drag_modifiers
    with_test_terminal do
      inject_drag(x: 5, y: 10, button: :right, modifiers: ["ctrl"])

      event = RatatuiRuby.poll_event
      assert_instance_of RatatuiRuby::Event::Mouse, event
      assert_equal "drag", event.kind
      assert_equal 5, event.x
      assert_equal 10, event.y
      assert_equal "right", event.button
      assert_equal ["ctrl"], event.modifiers
    end
  end

  def test_assert_screen_matches_array
    with_test_terminal(20, 2) do
      # Setup buffer content mocked or real
      # Since we can't easily set buffer content without rendering, we'll
      # just rely on the fact that an empty terminal has empty lines.
      # For a 20x2 terminal, we expect 2 lines of 20 spaces.
      expected = [" " * 20, " " * 20]
      assert_screen_matches(expected)
    end
  end

  def test_assert_screen_matches_file
    with_test_terminal(20, 3) do
      # Using a temp file or fixture
      fixture_path = File.join(__dir__, "fixtures/snapshot.txt")
      # "Line 1", "Line 2", "Line 3"
      # We need to simulate the buffer having this content.
      # Since we can't inject "screen content" easily without a running app,
      # we can stub `buffer_content` on the test instance, but `buffer_content`
      # is a method on the module included in *this* class.
      #
      # We can use stubbing on the method:
      stub :buffer_content, ["Line 1", "Line 2", "Line 3"] do
        assert_screen_matches(fixture_path)
      end
    end
  end

  def test_assert_screen_matches_block
    with_test_terminal(20, 2) do
      dummy_content = ["Time: 12:00:00", "Status: OK"]
      expected_content = ["Time: XX:XX:XX", "Status: OK"]

      stub :buffer_content, dummy_content do
        assert_screen_matches(expected_content) do |actual|
          actual.map { |l| l.gsub(/\d{2}:\d{2}:\d{2}/, "XX:XX:XX") }
        end
      end
    end
  end

  def test_assert_screen_matches_failure
    with_test_terminal(20, 2) do
      expected = ["Line 1", "Line 2"]
      stub :buffer_content, ["Line 1", "Line 3"] do
        error = assert_raises(Minitest::Assertion) do
          assert_screen_matches(expected)
        end
        assert_match(/Line 2 mismatch/, error.message)
      end
    end
  end

  def test_assert_snapshot
    with_test_terminal(20, 2) do
      # We created test/snapshots/my_snapshot.txt with "Snapshot Content"
      expected = ["Snapshot Content"]

      stub :buffer_content, expected do
        # This should look for test/snapshots/my_snapshot.txt
        assert_snapshot("my_snapshot")
      end
    end
  end
end
