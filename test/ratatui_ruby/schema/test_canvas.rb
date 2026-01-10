# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestCanvas < Minitest::Test
  def test_point_creation
    p = RatatuiRuby::Widgets::Shape::Point.new(x: 1.0, y: 2.0)
    assert_equal 1.0, p.x
    assert_equal 2.0, p.y
  end

  def test_line_creation
    l = RatatuiRuby::Widgets::Shape::Line.new(x1: 0.0, y1: 0.0, x2: 10.0, y2: 10.0, color: "red")
    assert_equal 0.0, l.x1
    assert_equal 0.0, l.y1
    assert_equal 10.0, l.x2
    assert_equal 10.0, l.y2
    assert_equal "red", l.color
  end

  def test_rectangle_creation
    r = RatatuiRuby::Widgets::Shape::Rectangle.new(x: 0.0, y: 0.0, width: 10.0, height: 10.0, color: "blue")
    assert_equal 0.0, r.x
    assert_equal 0.0, r.y
    assert_equal 10.0, r.width
    assert_equal 10.0, r.height
    assert_equal "blue", r.color
  end

  def test_circle_creation
    c = RatatuiRuby::Widgets::Shape::Circle.new(x: 5.0, y: 5.0, radius: 2.5, color: "green")
    assert_equal 5.0, c.x
    assert_equal 5.0, c.y
    assert_equal 2.5, c.radius
    assert_equal "green", c.color
  end

  def test_map_creation
    m = RatatuiRuby::Widgets::Shape::Map.new(color: "yellow", resolution: :high)
    assert_equal "yellow", m.color
    assert_equal :high, m.resolution
  end

  def test_canvas_creation
    shapes = [
      RatatuiRuby::Widgets::Shape::Line.new(x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0, color: "white"),
    ]
    c = RatatuiRuby::Widgets::Canvas.new(
      shapes:,
      x_bounds: [-1.0, 1.0],
      y_bounds: [-1.0, 1.0],
      marker: :dot
    )
    assert_equal shapes, c.shapes
    assert_equal [-1.0, 1.0], c.x_bounds
    assert_equal [-1.0, 1.0], c.y_bounds
    assert_equal :dot, c.marker
    assert_nil c.background_color
  end

  def test_canvas_creation_with_background
    c = RatatuiRuby::Widgets::Canvas.new(background_color: :blue)
    assert_equal :blue, c.background_color
  end

  def test_canvas_defaults
    c = RatatuiRuby::Widgets::Canvas.new
    assert_equal [], c.shapes
    assert_equal [0.0, 100.0], c.x_bounds
    assert_equal [0.0, 100.0], c.y_bounds
    assert_equal :braille, c.marker
    assert_nil c.block
  end

  def test_canvas_half_block_marker
    c = RatatuiRuby::Widgets::Canvas.new(marker: :half_block)
    assert_equal :half_block, c.marker
  end

  #
  # Canvas#get_point - Coordinate Mapping Tests
  #
  # These tests demonstrate how get_point maps canvas coordinates
  # to normalized [0.0, 1.0] grid coordinates for hit testing.
  #

  def test_canvas_get_point_returns_normalized_coordinates
    # A canvas with 100x100 coordinate space
    c = RatatuiRuby::Widgets::Canvas.new(x_bounds: [0.0, 100.0], y_bounds: [0.0, 100.0])

    # Center point (50,50) should be at (0.5, 0.5) normalized
    result = c.get_point(50.0, 50.0)
    assert_equal [0.5, 0.5], result
  end

  def test_canvas_get_point_corners
    c = RatatuiRuby::Widgets::Canvas.new(x_bounds: [0.0, 100.0], y_bounds: [0.0, 100.0])

    # Bottom-left corner (0,0) -> (0.0, 1.0) because Y is inverted
    assert_equal [0.0, 1.0], c.get_point(0.0, 0.0)

    # Top-right corner (100,100) -> (1.0, 0.0)
    assert_equal [1.0, 0.0], c.get_point(100.0, 100.0)
  end

  def test_canvas_get_point_out_of_bounds_returns_nil
    c = RatatuiRuby::Widgets::Canvas.new(x_bounds: [0.0, 100.0], y_bounds: [0.0, 100.0])

    # Points outside bounds return nil
    assert_nil c.get_point(-1.0, 50.0)   # Left of bounds
    assert_nil c.get_point(101.0, 50.0)  # Right of bounds
    assert_nil c.get_point(50.0, -1.0)   # Below bounds
    assert_nil c.get_point(50.0, 101.0)  # Above bounds
  end

  def test_canvas_get_point_alias
    # Ruby-idiomatic: both #get_point and #point work
    c = RatatuiRuby::Widgets::Canvas.new(x_bounds: [0.0, 100.0], y_bounds: [0.0, 100.0])

    # point is an alias for get_point
    assert_equal c.get_point(50.0, 50.0), c.point(50.0, 50.0)

    # [] is also an alias
    assert_equal c.get_point(50.0, 50.0), c[50.0, 50.0]
  end
end
