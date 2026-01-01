# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "minitest/autorun"
require_relative "../../../../examples/app_all_events/model/event_color_cycle"

class TestEventColorCycle < Minitest::Test
  def setup
    @cycle = EventColorCycle.new
  end

  def test_first_color_is_cyan
    assert_equal :cyan, @cycle.next_color
  end

  def test_second_color_is_magenta
    @cycle.next_color
    assert_equal :magenta, @cycle.next_color
  end

  def test_third_color_is_yellow
    2.times { @cycle.next_color }
    assert_equal :yellow, @cycle.next_color
  end

  def test_wraps_back_to_cyan_after_yellow
    3.times { @cycle.next_color }
    assert_equal :cyan, @cycle.next_color
  end

  def test_full_cycle_sequence
    expected = %i[cyan magenta yellow cyan magenta yellow]
    actual = 6.times.map { @cycle.next_color }
    assert_equal expected, actual
  end

  def test_colors_constant_is_frozen
    assert_predicate EventColorCycle::COLORS, :frozen?
  end

  def test_colors_constant_has_three_colors
    assert_equal 3, EventColorCycle::COLORS.length
  end

  def test_independent_instances_have_independent_state
    cycle1 = EventColorCycle.new
    cycle2 = EventColorCycle.new

    cycle1.next_color
    cycle1.next_color

    assert_equal :cyan, cycle2.next_color
    assert_equal :yellow, cycle1.next_color
  end
end
