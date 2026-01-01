# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "minitest/autorun"
require_relative "../../../../examples/app_all_events/model/highlight"

class TestHighlight < Minitest::Test
  def setup
    @highlight = Highlight.new
  end

  def test_lit_returns_false_for_unlit_type
    refute @highlight.lit?(:key)
  end

  def test_lit_returns_false_for_different_unlit_types
    refute @highlight.lit?(:mouse)
    refute @highlight.lit?(:resize)
    refute @highlight.lit?(:paste)
    refute @highlight.lit?(:focus)
  end

  def test_light_up_then_lit_returns_true
    @highlight.light_up(:key)

    assert @highlight.lit?(:key)
  end

  def test_light_up_one_type_does_not_light_others
    @highlight.light_up(:key)

    refute @highlight.lit?(:mouse)
    refute @highlight.lit?(:resize)
  end

  def test_multiple_types_can_be_lit_independently
    @highlight.light_up(:key)
    @highlight.light_up(:mouse)

    assert @highlight.lit?(:key)
    assert @highlight.lit?(:mouse)
    refute @highlight.lit?(:resize)
  end

  def test_lit_returns_false_after_duration_expires
    @highlight.light_up(:key)
    sleep 0.35 # 350ms, duration is 300ms

    refute @highlight.lit?(:key)
  end

  def test_lit_returns_true_within_duration
    @highlight.light_up(:key)
    sleep 0.1 # 100ms, well within 300ms

    assert @highlight.lit?(:key)
  end

  def test_relighting_resets_timer
    @highlight.light_up(:key)
    sleep 0.2 # 200ms
    @highlight.light_up(:key) # Reset timer
    sleep 0.2 # Another 200ms (400ms total, but only 200ms since relight)

    assert @highlight.lit?(:key)
  end

  def test_duration_constant_is_300ms
    assert_equal 300, Highlight::DURATION_MS
  end

  def test_light_up_with_symbol_type
    @highlight.light_up(:custom_type)

    assert @highlight.lit?(:custom_type)
  end

  def test_light_up_with_string_type
    @highlight.light_up("string_type")

    assert @highlight.lit?("string_type")
    refute @highlight.lit?(:string_type)
  end

  def test_independent_instances
    highlight1 = Highlight.new
    highlight2 = Highlight.new

    highlight1.light_up(:key)

    assert highlight1.lit?(:key)
    refute highlight2.lit?(:key)
  end
end
