# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestCanvas < Minitest::Test
  def test_point_creation
    p = RatatuiRuby::Shape::Point.new(x: 1.0, y: 2.0)
    assert_equal 1.0, p.x
    assert_equal 2.0, p.y
  end

  def test_line_creation
    l = RatatuiRuby::Shape::Line.new(x1: 0.0, y1: 0.0, x2: 10.0, y2: 10.0, color: "red")
    assert_equal 0.0, l.x1
    assert_equal 0.0, l.y1
    assert_equal 10.0, l.x2
    assert_equal 10.0, l.y2
    assert_equal "red", l.color
  end

  def test_rectangle_creation
    r = RatatuiRuby::Shape::Rectangle.new(x: 0.0, y: 0.0, width: 10.0, height: 10.0, color: "blue")
    assert_equal 0.0, r.x
    assert_equal 0.0, r.y
    assert_equal 10.0, r.width
    assert_equal 10.0, r.height
    assert_equal "blue", r.color
  end

  def test_circle_creation
    c = RatatuiRuby::Shape::Circle.new(x: 5.0, y: 5.0, radius: 2.5, color: "green")
    assert_equal 5.0, c.x
    assert_equal 5.0, c.y
    assert_equal 2.5, c.radius
    assert_equal "green", c.color
  end

  def test_map_creation
    m = RatatuiRuby::Shape::Map.new(color: "yellow", resolution: :high)
    assert_equal "yellow", m.color
    assert_equal :high, m.resolution
  end

  def test_canvas_creation
    shapes = [
      RatatuiRuby::Shape::Line.new(x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0, color: "white"),
    ]
    c = RatatuiRuby::Canvas.new(
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
    c = RatatuiRuby::Canvas.new(background_color: :blue)
    assert_equal :blue, c.background_color
  end

  def test_canvas_defaults
    c = RatatuiRuby::Canvas.new
    assert_equal [], c.shapes
    assert_equal [0.0, 100.0], c.x_bounds
    assert_equal [0.0, 100.0], c.y_bounds
    assert_equal :braille, c.marker
    assert_nil c.block
  end

  def test_canvas_half_block_marker
    c = RatatuiRuby::Canvas.new(marker: :half_block)
    assert_equal :half_block, c.marker
  end
end
