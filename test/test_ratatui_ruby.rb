# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestRatatuiRuby < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::RatatuiRuby::VERSION
  end

  def test_init_and_restore
    # This is a smoke test to ensure calling these methods doesn't crash.

    RatatuiRuby.init_test_terminal(20, 10)
    assert true
  ensure
    RatatuiRuby.restore_terminal
  end

  def test_draw
    # Use the test backend to verify rendering

    RatatuiRuby.init_test_terminal(10, 5)
    p = RatatuiRuby::Paragraph.new(text: "Hello")
    RatatuiRuby.draw(p)

    buffer = RatatuiRuby.get_buffer_content

    # Buffer is returned as newline-separated string
    # 10x5 terminal
    # "Hello     \n          \n          \n          \n          \n"
    lines = buffer.split("\n")
    assert_equal "Hello     ", lines[0]
  ensure
    RatatuiRuby.restore_terminal
  end

  def test_resize
    RatatuiRuby.init_test_terminal(10, 5)
    RatatuiRuby.resize_terminal(20, 10)
    p = RatatuiRuby::Paragraph.new(text: "Widened")
    RatatuiRuby.draw(p)

    buffer = RatatuiRuby.get_buffer_content
    lines = buffer.split("\n")
    assert_equal 10, lines.length
    assert_equal 20, lines[0].length
    assert_equal "Widened             ", lines[0]
  ensure
    RatatuiRuby.restore_terminal
  end

  def test_poll_event
    # Verify poll_event returns nil when no input is available (timeout is 16ms in Rust)
    event = RatatuiRuby.poll_event
    assert_nil event
  end
end
