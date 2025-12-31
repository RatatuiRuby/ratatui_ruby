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
end
