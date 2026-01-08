# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestScrollbarState < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_scrollbar_state_initialization
    state = RatatuiRuby::ScrollbarState.new(100)
    assert_equal 100, state.content_length
    assert_equal 0, state.position
  end

  def test_scrollbar_state_position_navigation
    state = RatatuiRuby::ScrollbarState.new(10)
    state.next
    assert_equal 1, state.position
    state.prev
    assert_equal 0, state.position
  end

  def test_scrollbar_state_first_and_last
    state = RatatuiRuby::ScrollbarState.new(10)
    state.position = 5
    state.first
    assert_equal 0, state.position
    state.last
    assert_equal 9, state.position
  end
end
