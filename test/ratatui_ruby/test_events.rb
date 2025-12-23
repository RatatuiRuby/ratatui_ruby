# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestEvents < Minitest::Test
  def setup
    RatatuiRuby.init_test_terminal(80, 24)
  end

  def teardown
    RatatuiRuby.restore_terminal
  end

  def test_poll_event_returns_nil_when_no_events
    result = RatatuiRuby.poll_event
    assert_nil result
  end

  def test_poll_key_event
    RatatuiRuby.inject_test_event("key", { code: "a", modifiers: ["ctrl"] })
    result = RatatuiRuby.poll_event

    assert_equal :key, result[:type]
    assert_equal "a", result[:code]
    assert_equal ["ctrl"], result[:modifiers]
  end

  def test_poll_mouse_event
    RatatuiRuby.inject_test_event("mouse", { kind: "down", button: "left", x: 10, y: 20, modifiers: ["shift"] })
    result = RatatuiRuby.poll_event

    assert_equal :mouse, result[:type]
    assert_equal :down, result[:kind]
    assert_equal :left, result[:button]
    assert_equal 10, result[:x]
    assert_equal 20, result[:y]
    assert_equal ["shift"], result[:modifiers]
  end

  def test_poll_mouse_scroll
    RatatuiRuby.inject_test_event("mouse", { kind: "scroll_up", x: 5, y: 5 })
    result = RatatuiRuby.poll_event

    assert_equal :mouse, result[:type]
    assert_equal :scroll_up, result[:kind]
    assert_equal :none, result[:button]
    assert_equal 5, result[:x]
    assert_equal 5, result[:y]
  end
end
