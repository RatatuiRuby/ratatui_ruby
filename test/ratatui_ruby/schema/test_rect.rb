# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestRect < Minitest::Test
  def test_rect_creation
    r = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
    assert_equal 10, r.x
    assert_equal 5, r.y
    assert_equal 80, r.width
    assert_equal 24, r.height
  end

  def test_rect_defaults
    r = RatatuiRuby::Layout::Rect.new
    assert_equal 0, r.x
    assert_equal 0, r.y
    assert_equal 0, r.width
    assert_equal 0, r.width
    assert_equal 0, r.height
  end

  def test_equality
    r1 = RatatuiRuby::Layout::Rect.new(x: 1, y: 2, width: 3, height: 4)
    r2 = RatatuiRuby::Layout::Rect.new(x: 1, y: 2, width: 3, height: 4)
    r3 = RatatuiRuby::Layout::Rect.new(x: 5, y: 6, width: 7, height: 8)

    assert_equal r1, r2
    refute_equal r1, r3
  end

  def test_contains_inside
    r = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 20, height: 10)
    assert r.contains?(10, 5)   # top-left corner
    assert r.contains?(15, 8)   # center
    assert r.contains?(29, 14)  # bottom-right inside
  end

  def test_contains_outside
    r = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 20, height: 10)
    refute r.contains?(9, 5)    # left of rect
    refute r.contains?(10, 4)   # above rect
    refute r.contains?(30, 5)   # right edge (exclusive)
    refute r.contains?(10, 15)  # bottom edge (exclusive)
    refute r.contains?(0, 0)    # origin
  end

  def test_contains_boundary_exclusive
    r = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 40, height: 24)
    assert r.contains?(0, 0)
    assert r.contains?(39, 23)
    refute r.contains?(40, 0)   # right boundary exclusive
    refute r.contains?(0, 24)   # bottom boundary exclusive
  end

  def test_intersects_overlapping
    r1 = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 10, height: 10)
    r2 = RatatuiRuby::Layout::Rect.new(x: 5, y: 5, width: 10, height: 10)
    assert r1.intersects?(r2)
    assert r2.intersects?(r1)
  end

  def test_intersects_contained
    outer = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 100, height: 100)
    inner = RatatuiRuby::Layout::Rect.new(x: 10, y: 10, width: 10, height: 10)
    assert outer.intersects?(inner)
    assert inner.intersects?(outer)
  end

  def test_intersects_adjacent_not_overlapping
    r1 = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 10, height: 10)
    r2 = RatatuiRuby::Layout::Rect.new(x: 10, y: 0, width: 10, height: 10) # touches right edge
    refute r1.intersects?(r2)
    refute r2.intersects?(r1)
  end

  def test_intersects_disjoint
    r1 = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 10, height: 10)
    r2 = RatatuiRuby::Layout::Rect.new(x: 50, y: 50, width: 10, height: 10)
    refute r1.intersects?(r2)
    refute r2.intersects?(r1)
  end

  def test_intersection_overlapping
    viewport = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 80, height: 24)
    widget = RatatuiRuby::Layout::Rect.new(x: 70, y: 20, width: 20, height: 10)
    result = viewport.intersection(widget)

    assert_equal 70, result.x
    assert_equal 20, result.y
    assert_equal 10, result.width  # 80 - 70 = 10 visible
    assert_equal 4, result.height  # 24 - 20 = 4 visible
  end

  def test_intersection_contained
    outer = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 100, height: 100)
    inner = RatatuiRuby::Layout::Rect.new(x: 10, y: 10, width: 20, height: 20)
    result = outer.intersection(inner)

    # Inner rect is fully contained, so intersection equals inner
    assert_equal inner, result
  end

  def test_intersection_disjoint_returns_nil
    r1 = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 10, height: 10)
    r2 = RatatuiRuby::Layout::Rect.new(x: 50, y: 50, width: 10, height: 10)
    assert_nil r1.intersection(r2)
    assert_nil r2.intersection(r1)
  end

  def test_intersection_adjacent_returns_nil
    r1 = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 10, height: 10)
    r2 = RatatuiRuby::Layout::Rect.new(x: 10, y: 0, width: 10, height: 10)
    assert_nil r1.intersection(r2)
  end

  def test_rect_is_ractor_shareable
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
    assert Ractor.shareable?(rect), "Rect should be Ractor.shareable? for thread/Ractor safety"
  end

  # Gap tests - verify missing methods from v1.0.0_blockers.md
  def test_rect_area
    rect = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 10, height: 5)
    assert_equal 50, rect.area
  end

  def test_rect_left
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
    assert_equal 10, rect.left
  end

  def test_rect_right
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
    assert_equal 90, rect.right
  end

  def test_rect_top
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
    assert_equal 5, rect.top
  end

  def test_rect_bottom
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
    assert_equal 29, rect.bottom
  end

  def test_rect_union
    r1 = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 10, height: 10)
    r2 = RatatuiRuby::Layout::Rect.new(x: 5, y: 5, width: 10, height: 10)
    result = r1.union(r2)
    assert_equal 0, result.x
    assert_equal 0, result.y
    assert_equal 15, result.width
    assert_equal 15, result.height
  end

  def test_rect_inner
    rect = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 20, height: 10)
    result = rect.inner(2)
    assert_equal 2, result.x
    assert_equal 2, result.y
    assert_equal 16, result.width
    assert_equal 6, result.height
  end

  # Rect#outer expands by margin (inverse of Rect#inner)
  def test_rect_outer_expands_by_margin
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 10, width: 20, height: 10)
    result = rect.outer(5)
    assert_equal 5, result.x      # 10 - 5
    assert_equal 5, result.y      # 10 - 5
    assert_equal 30, result.width # 20 + 10 (5*2)
    assert_equal 20, result.height # 10 + 10 (5*2)
  end

  def test_rect_outer_saturates_at_zero
    # When margin exceeds position, x/y saturate at 0
    rect = RatatuiRuby::Layout::Rect.new(x: 3, y: 2, width: 10, height: 10)
    result = rect.outer(5)
    assert_equal 0, result.x     # saturates at 0 (3 - 5 would be -2)
    assert_equal 0, result.y     # saturates at 0 (2 - 5 would be -3)
    # Width/height grow to fill the expanded area
    assert_equal 18, result.width  # right edge was at 13, now at 18 (13 + 5)
    assert_equal 17, result.height # bottom edge was at 12, now at 17 (12 + 5)
  end

  def test_rect_outer_is_inverse_of_inner
    # outer(margin).inner(margin) should return the original rect
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 10, width: 20, height: 10)
    result = rect.outer(3).inner(3)
    assert_equal rect, result
  end

  # Rect#resize changes dimensions while preserving position
  def test_rect_resize_changes_dimensions
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 20, height: 10)
    new_size = RatatuiRuby::Layout::Size.new(width: 40, height: 20)
    result = rect.resize(new_size)

    assert_equal 10, result.x      # position preserved
    assert_equal 5, result.y       # position preserved
    assert_equal 40, result.width  # new dimensions
    assert_equal 20, result.height # new dimensions
  end

  def test_rect_resize_returns_new_rect
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 20, height: 10)
    new_size = RatatuiRuby::Layout::Size.new(width: 5, height: 5)
    result = rect.resize(new_size)

    refute_same rect, result # should return a new instance
    assert_equal 20, rect.width # original unchanged
  end

  def test_rect_offset
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 20, height: 10)
    result = rect.offset(5, 3)
    assert_equal 15, result.x
    assert_equal 8, result.y
    assert_equal 20, result.width
    assert_equal 10, result.height
  end

  def test_rect_clamp
    inner = RatatuiRuby::Layout::Rect.new(x: -5, y: -5, width: 30, height: 30)
    bounds = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 20, height: 20)
    result = inner.clamp(bounds)
    assert_equal 0, result.x
    assert_equal 0, result.y
  end

  def test_rect_rows
    rect = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 5, height: 3)
    rows = rect.rows.to_a
    assert_equal 3, rows.size
  end

  def test_rect_columns
    rect = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 5, height: 3)
    cols = rect.columns.to_a
    assert_equal 5, cols.size
  end

  def test_rect_positions
    rect = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 2, height: 2)
    positions = rect.positions.to_a
    assert_equal 4, positions.size
  end

  def test_rect_empty
    empty_rect = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 0, height: 0)
    non_empty_rect = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 10, height: 5)
    assert empty_rect.empty?
    refute non_empty_rect.empty?
  end

  def test_rect_as_position
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
    pos = rect.as_position
    assert_equal 10, pos.x
    assert_equal 5, pos.y
  end

  def test_rect_as_size
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
    size = rect.as_size
    assert_equal 80, size.width
    assert_equal 24, size.height
  end

  # Ruby-idiomatic aliases (TIMTOWTDI)
  def test_rect_position_alias
    # Rect#position is an alias for Rect#as_position
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
    assert_equal rect.as_position, rect.position
  end

  def test_rect_size_alias
    # Rect#size is an alias for Rect#as_size
    rect = RatatuiRuby::Layout::Rect.new(x: 10, y: 5, width: 80, height: 24)
    assert_equal rect.as_size, rect.size
  end

  # Rect#centered_horizontally centers rect within constraint
  def test_rect_centered_horizontally
    rect = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 100, height: 24)
    constraint = RatatuiRuby::Layout::Constraint.length(40)
    result = rect.centered_horizontally(constraint)

    # Should be 40 wide, centered in 100 => x = 30
    assert_equal 30, result.x
    assert_equal 0, result.y
    assert_equal 40, result.width
    assert_equal 24, result.height
  end

  # Rect#centered_vertically centers rect within constraint
  def test_rect_centered_vertically
    rect = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 80, height: 100)
    constraint = RatatuiRuby::Layout::Constraint.length(20)
    result = rect.centered_vertically(constraint)

    # Should be 20 tall, centered in 100 => y = 40
    assert_equal 0, result.x
    assert_equal 40, result.y
    assert_equal 80, result.width
    assert_equal 20, result.height
  end

  # Rect#centered centers rect on both axes
  def test_rect_centered
    rect = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 100, height: 100)
    h_constraint = RatatuiRuby::Layout::Constraint.length(40)
    v_constraint = RatatuiRuby::Layout::Constraint.length(20)
    result = rect.centered(h_constraint, v_constraint)

    # Should be 40x20, centered in 100x100
    assert_equal 30, result.x     # (100 - 40) / 2
    assert_equal 40, result.y     # (100 - 20) / 2
    assert_equal 40, result.width
    assert_equal 20, result.height
  end
end
