# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestFrameCount < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_frame_count_exists
    with_test_terminal(80, 24) do
      # frame_count should be queryable on Terminal
      count = RatatuiRuby.frame_count
      assert_kind_of Integer, count
    end
  end

  def test_frame_count_increments_after_draw
    with_test_terminal(80, 24) do
      initial_count = RatatuiRuby.frame_count

      RatatuiRuby.draw(RatatuiRuby::Widgets::Paragraph.new(text: "test"))

      after_draw = RatatuiRuby.frame_count
      assert_equal initial_count + 1, after_draw, "frame_count should increment by 1 after draw"
    end
  end

  def test_frame_count_stable_without_draw
    with_test_terminal(80, 24) do
      first_call = RatatuiRuby.frame_count
      second_call = RatatuiRuby.frame_count

      assert_equal first_call, second_call, "frame_count should not change between calls without draw"
    end
  end

  def test_frame_count_resets_on_new_terminal
    # First terminal session
    RatatuiRuby.init_test_terminal(80, 24)
    RatatuiRuby.draw(RatatuiRuby::Widgets::Paragraph.new(text: "test"))
    assert_equal 1, RatatuiRuby.frame_count, "frame_count should be 1 after first draw"
    RatatuiRuby.restore_terminal

    # Second terminal session - should reset to 0
    RatatuiRuby.init_test_terminal(80, 24)
    assert_equal 0, RatatuiRuby.frame_count, "frame_count should reset to 0 for new terminal"
    RatatuiRuby.draw(RatatuiRuby::Widgets::Paragraph.new(text: "test"))
    assert_equal 1, RatatuiRuby.frame_count, "frame_count should be 1 after first draw of new terminal"
    RatatuiRuby.restore_terminal
  end

  def test_frame_count_raises_when_terminal_not_initialized
    # Ensure terminal is not initialized
    RatatuiRuby.restore_terminal if RatatuiRuby.terminal_active?

    error = assert_raises(RatatuiRuby::Error::Invariant) do
      RatatuiRuby.frame_count
    end
    # Good DX: WHAT went wrong, WHY, HOW TO FIX
    assert_match(/frame_count/, error.message, "should say WHAT failed")
    assert_match(/not initialized/, error.message, "should say WHY")
    assert_match(/init_terminal/, error.message, "should say HOW TO FIX (manual)")
    assert_match(/RatatuiRuby\.run/, error.message, "should say HOW TO FIX (managed)")
  end
end
