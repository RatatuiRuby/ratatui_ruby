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
    with_test_terminal do
      pos = cursor_position
      assert_kind_of Integer, pos[:x]
      assert_kind_of Integer, pos[:y]
      assert_equal 0, pos[:x]
      assert_equal 0, pos[:y]
    end
  end

  def test_inject_event
    with_test_terminal do
      inject_event(RatatuiRuby::Event::Key.new(code: "a", modifiers: ["ctrl"]))
      event = RatatuiRuby.poll_event
      assert_kind_of RatatuiRuby::Event::Key, event
      assert_equal "a", event.code
      assert_equal ["ctrl"], event.modifiers
    end
  end
end
