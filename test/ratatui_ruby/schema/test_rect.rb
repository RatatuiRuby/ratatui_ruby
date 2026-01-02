# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestRect < Minitest::Test
  def test_rect_creation
    r = RatatuiRuby::Rect.new(x: 10, y: 5, width: 80, height: 24)
    assert_equal 10, r.x
    assert_equal 5, r.y
    assert_equal 80, r.width
    assert_equal 24, r.height
  end

  def test_rect_defaults
    r = RatatuiRuby::Rect.new
    assert_equal 0, r.x
    assert_equal 0, r.y
    assert_equal 0, r.width
    assert_equal 0, r.width
    assert_equal 0, r.height
  end

  def test_equality
    r1 = RatatuiRuby::Rect.new(x: 1, y: 2, width: 3, height: 4)
    r2 = RatatuiRuby::Rect.new(x: 1, y: 2, width: 3, height: 4)
    r3 = RatatuiRuby::Rect.new(x: 5, y: 6, width: 7, height: 8)

    assert_equal r1, r2
    refute_equal r1, r3
  end

  def test_contains_inside
    r = RatatuiRuby::Rect.new(x: 10, y: 5, width: 20, height: 10)
    assert r.contains?(10, 5)   # top-left corner
    assert r.contains?(15, 8)   # center
    assert r.contains?(29, 14)  # bottom-right inside
  end

  def test_contains_outside
    r = RatatuiRuby::Rect.new(x: 10, y: 5, width: 20, height: 10)
    refute r.contains?(9, 5)    # left of rect
    refute r.contains?(10, 4)   # above rect
    refute r.contains?(30, 5)   # right edge (exclusive)
    refute r.contains?(10, 15)  # bottom edge (exclusive)
    refute r.contains?(0, 0)    # origin
  end

  def test_contains_boundary_exclusive
    r = RatatuiRuby::Rect.new(x: 0, y: 0, width: 40, height: 24)
    assert r.contains?(0, 0)
    assert r.contains?(39, 23)
    refute r.contains?(40, 0)   # right boundary exclusive
    refute r.contains?(0, 24)   # bottom boundary exclusive
  end

  def test_intersects_overlapping
    r1 = RatatuiRuby::Rect.new(x: 0, y: 0, width: 10, height: 10)
    r2 = RatatuiRuby::Rect.new(x: 5, y: 5, width: 10, height: 10)
    assert r1.intersects?(r2)
    assert r2.intersects?(r1)
  end

  def test_intersects_contained
    outer = RatatuiRuby::Rect.new(x: 0, y: 0, width: 100, height: 100)
    inner = RatatuiRuby::Rect.new(x: 10, y: 10, width: 10, height: 10)
    assert outer.intersects?(inner)
    assert inner.intersects?(outer)
  end

  def test_intersects_adjacent_not_overlapping
    r1 = RatatuiRuby::Rect.new(x: 0, y: 0, width: 10, height: 10)
    r2 = RatatuiRuby::Rect.new(x: 10, y: 0, width: 10, height: 10) # touches right edge
    refute r1.intersects?(r2)
    refute r2.intersects?(r1)
  end

  def test_intersects_disjoint
    r1 = RatatuiRuby::Rect.new(x: 0, y: 0, width: 10, height: 10)
    r2 = RatatuiRuby::Rect.new(x: 50, y: 50, width: 10, height: 10)
    refute r1.intersects?(r2)
    refute r2.intersects?(r1)
  end

  def test_intersection_overlapping
    viewport = RatatuiRuby::Rect.new(x: 0, y: 0, width: 80, height: 24)
    widget = RatatuiRuby::Rect.new(x: 70, y: 20, width: 20, height: 10)
    result = viewport.intersection(widget)

    assert_equal 70, result.x
    assert_equal 20, result.y
    assert_equal 10, result.width  # 80 - 70 = 10 visible
    assert_equal 4, result.height  # 24 - 20 = 4 visible
  end

  def test_intersection_contained
    outer = RatatuiRuby::Rect.new(x: 0, y: 0, width: 100, height: 100)
    inner = RatatuiRuby::Rect.new(x: 10, y: 10, width: 20, height: 20)
    result = outer.intersection(inner)

    # Inner rect is fully contained, so intersection equals inner
    assert_equal inner, result
  end

  def test_intersection_disjoint_returns_nil
    r1 = RatatuiRuby::Rect.new(x: 0, y: 0, width: 10, height: 10)
    r2 = RatatuiRuby::Rect.new(x: 50, y: 50, width: 10, height: 10)
    assert_nil r1.intersection(r2)
    assert_nil r2.intersection(r1)
  end

  def test_intersection_adjacent_returns_nil
    r1 = RatatuiRuby::Rect.new(x: 0, y: 0, width: 10, height: 10)
    r2 = RatatuiRuby::Rect.new(x: 10, y: 0, width: 10, height: 10)
    assert_nil r1.intersection(r2)
  end
end
