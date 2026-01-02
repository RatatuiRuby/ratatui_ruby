# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestPollEvent < Minitest::Test
  def setup
    RatatuiRuby.init_test_terminal(80, 24)
    RatatuiRuby.clear_events
  end

  def teardown
    RatatuiRuby.restore_terminal
  end

  def test_poll_event_returns_none_when_no_events
    result = RatatuiRuby.poll_event
    assert_instance_of RatatuiRuby::Event::None, result
    assert_predicate result, :none?
  end

  def test_poll_key_event
    RatatuiRuby.inject_test_event("key", { code: "a", modifiers: ["ctrl"] })
    result = RatatuiRuby.poll_event

    assert_predicate result, :key?
    assert_equal "a", result.code
    assert_equal ["ctrl"], result.modifiers
  end

  def test_poll_mouse_event
    RatatuiRuby.inject_test_event("mouse", { kind: "down", button: "left", x: 10, y: 20, modifiers: ["shift"] })
    result = RatatuiRuby.poll_event

    assert_predicate result, :mouse?
    assert_predicate result, :down?
    assert_equal "left", result.button
    assert_equal 10, result.x
    assert_equal 20, result.y
    assert_equal ["shift"], result.modifiers
  end

  def test_poll_mouse_scroll
    RatatuiRuby.inject_test_event("mouse", { kind: "scroll_up", x: 5, y: 5 })
    result = RatatuiRuby.poll_event

    assert_predicate result, :mouse?
    assert_predicate result, :scroll_up?
    assert_equal "none", result.button
    assert_equal 5, result.x
    assert_equal 5, result.y
  end

  def test_poll_event_with_zero_timeout_returns_immediately
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    result = RatatuiRuby.poll_event(timeout: 0.0)
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

    assert_instance_of RatatuiRuby::Event::None, result
    assert_operator elapsed, :<, 0.01, "Zero timeout should return in under 10ms"
  end

  def test_poll_event_with_nil_timeout_returns_none_in_test_mode
    result = RatatuiRuby.poll_event(timeout: nil)
    assert_instance_of RatatuiRuby::Event::None, result
  end

  def test_poll_event_with_explicit_timeout_returns_injected_event
    RatatuiRuby.inject_test_event("key", { code: "x" })
    result = RatatuiRuby.poll_event(timeout: 0.1)

    assert_predicate result, :key?
    assert_equal "x", result.code
  end

  def test_poll_event_with_negative_timeout_raises_error
    assert_raises(ArgumentError) do
      RatatuiRuby.poll_event(timeout: -1.0)
    end
  end

  def test_poll_event_returns_frozen_none_event
    result = RatatuiRuby.poll_event
    assert_predicate result, :frozen?, "Event::None should be frozen for Ractor safety"
    assert Ractor.shareable?(result), "Event::None should be Ractor.shareable?"
  end

  def test_poll_event_returns_frozen_key_event
    RatatuiRuby.inject_test_event("key", { code: "a", modifiers: ["ctrl"] })
    result = RatatuiRuby.poll_event

    assert_predicate result, :frozen?, "Event::Key should be frozen for Ractor safety"
    assert_predicate result.modifiers, :frozen?, "Event::Key modifiers should be frozen"
    assert Ractor.shareable?(result), "Event::Key should be Ractor.shareable?"
  end

  def test_poll_event_returns_frozen_mouse_event
    RatatuiRuby.inject_test_event("mouse", { kind: "down", button: "left", x: 10, y: 20 })
    result = RatatuiRuby.poll_event

    assert_predicate result, :frozen?, "Event::Mouse should be frozen for Ractor safety"
    assert_predicate result.modifiers, :frozen?, "Event::Mouse modifiers should be frozen"
    assert Ractor.shareable?(result), "Event::Mouse should be Ractor.shareable?"
  end

  def test_poll_event_returns_frozen_resize_event
    RatatuiRuby.inject_test_event("resize", { width: 120, height: 40 })
    result = RatatuiRuby.poll_event

    assert_predicate result, :frozen?, "Event::Resize should be frozen for Ractor safety"
    assert Ractor.shareable?(result), "Event::Resize should be Ractor.shareable?"
  end

  def test_poll_event_returns_frozen_paste_event
    RatatuiRuby.inject_test_event("paste", { content: "hello" })
    result = RatatuiRuby.poll_event

    assert_predicate result, :frozen?, "Event::Paste should be frozen for Ractor safety"
    assert Ractor.shareable?(result), "Event::Paste should be Ractor.shareable?"
  end

  def test_poll_event_returns_frozen_focus_events
    RatatuiRuby.inject_test_event("focus_gained", {})
    result = RatatuiRuby.poll_event
    assert_predicate result, :frozen?, "Event::FocusGained should be frozen for Ractor safety"
    assert Ractor.shareable?(result), "Event::FocusGained should be Ractor.shareable?"

    RatatuiRuby.inject_test_event("focus_lost", {})
    result = RatatuiRuby.poll_event
    assert_predicate result, :frozen?, "Event::FocusLost should be frozen for Ractor safety"
    assert Ractor.shareable?(result), "Event::FocusLost should be Ractor.shareable?"
  end
end
