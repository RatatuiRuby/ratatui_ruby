# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestRatatuiRuby < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_that_it_has_a_version_number
    refute_nil ::RatatuiRuby::VERSION
  end

  def test_init_and_restore
    # Verify that terminal initialization and restoration works correctly
    # and sets the internal state.
    RatatuiRuby.init_test_terminal(20, 10)
    assert_equal "                    ", RatatuiRuby.get_buffer_content.split("\n")[0]
  ensure
    RatatuiRuby.restore_terminal
  end

  def test_draw
    # Use the test backend to verify rendering
    RatatuiRuby.init_test_terminal(10, 5)
    p = RatatuiRuby::Widgets::Paragraph.new(text: "Hello")
    RatatuiRuby.draw { |f| f.render_widget(p, f.area) }

    lines = RatatuiRuby.get_buffer_content.split("\n")
    assert_equal "Hello     ", lines[0]
    assert_equal "          ", lines[1]
    assert_equal "          ", lines[2]
    assert_equal "          ", lines[3]
    assert_equal "          ", lines[4]
  ensure
    RatatuiRuby.restore_terminal
  end

  def test_draw_block
    RatatuiRuby.init_test_terminal(10, 5)
    RatatuiRuby.draw do |frame|
      p = RatatuiRuby::Widgets::Paragraph.new(text: "Block")
      frame.render_widget(p, frame.area)
    end

    lines = RatatuiRuby.get_buffer_content.split("\n")
    assert_equal "Block     ", lines[0]
  ensure
    RatatuiRuby.restore_terminal
  end

  def test_draw_validation
    assert_raises(ArgumentError) do
      RatatuiRuby.draw(RatatuiRuby::Widgets::Paragraph.new(text: "Both")) { |it| puts it.inspect }
    end

    assert_raises(ArgumentError) { RatatuiRuby.draw }
  end

  def test_resize
    RatatuiRuby.init_test_terminal(10, 5)
    RatatuiRuby.resize_terminal(20, 3)
    p = RatatuiRuby::Widgets::Paragraph.new(text: "Widened")
    RatatuiRuby.draw { |f| f.render_widget(p, f.area) }

    lines = RatatuiRuby.get_buffer_content.split("\n")
    assert_equal 3, lines.length
    assert_equal "Widened             ", lines[0]
    assert_equal "                    ", lines[1]
    assert_equal "                    ", lines[2]
  ensure
    RatatuiRuby.restore_terminal
  end

  def test_poll_event
    # Verify poll_event returns Event::None when no input is available (timeout is 16ms in Rust)
    with_test_terminal(10, 5) do
      event = RatatuiRuby.poll_event
      assert_instance_of RatatuiRuby::Event::None, event
      assert_predicate event, :none?
    end
  end
end
