# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "minitest/autorun"
require "ratatui_ruby"

# Tests documenting duck typing behavior for Layout.split and widget bar_set.
# These tests verify that any object responding to the right methods works,
# not just the canonical types.
class TestDuckTyping < Minitest::Test
  # === Layout.split accepts _RectLike duck types ===
  #
  # Any object responding to x, y, width, height can be used as an area.
  # This enables interoperability with custom geometry classes.

  def test_layout_split_accepts_rect_like_object
    # Define a custom Rect-like class (not RatatuiRuby::Layout::Rect)
    rect_like = Class.new do
      def x = 10
      def y = 20
      def width = 100
      def height = 50
    end.new

    # Should work without raising
    constraints = [
      RatatuiRuby::Layout::Constraint.percentage(50),
      RatatuiRuby::Layout::Constraint.percentage(50),
    ]

    rects = RatatuiRuby::Layout::Layout.split(
      rect_like,
      direction: :horizontal,
      constraints:
    )

    assert_equal 2, rects.size
    assert_kind_of RatatuiRuby::Layout::Rect, rects.first
    assert_equal 10, rects.first.x
    assert_equal 20, rects.first.y
  end

  def test_layout_split_accepts_struct_with_rect_attributes
    # Struct is a common Ruby pattern that should work
    rect_struct = Struct.new(:x, :y, :width, :height).new(0, 0, 80, 24)

    # Use Constraint.fill to get deterministic results - fills remaining space
    constraints = [RatatuiRuby::Layout::Constraint.fill(1)]

    rects = RatatuiRuby::Layout::Layout.split(
      rect_struct,
      direction: :vertical,
      constraints:
    )

    assert_equal 1, rects.size
    assert_equal 0, rects.first.x
    assert_equal 0, rects.first.y
    assert_equal 80, rects.first.width
    assert_equal 24, rects.first.height # fill(1) takes all available height
  end

  def test_layout_split_accepts_data_define_rect
    # Data.define is Ruby 3.2+ pattern
    rect_data = Data.define(:x, :y, :width, :height).new(x: 5, y: 5, width: 40, height: 20)

    constraints = [RatatuiRuby::Layout::Constraint.min(5)]

    rects = RatatuiRuby::Layout::Layout.split(
      rect_data,
      direction: :horizontal,
      constraints:
    )

    assert_equal 1, rects.size
    assert_equal 5, rects.first.x
    assert_equal 5, rects.first.y
  end
end
