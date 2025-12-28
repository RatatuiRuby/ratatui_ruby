# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"
require "ratatui_ruby/dsl"

class TestAppPattern < Minitest::Test
  def test_dsl_object_delegation
    with_test_terminal(20, 1) do
      RatatuiRuby.main_loop do |tui|
        p = tui.paragraph(text: "Builder Works")
        tui.draw(p)
        assert_equal "Builder Works       ", buffer_content[0]
        break
      end
    end
  end

  def test_dsl_shape_methods
    tui = RatatuiRuby::DSL.new

    point = tui.shape_point(x: 1.0, y: 2.0)
    assert_instance_of RatatuiRuby::Shape::Point, point
    assert_equal 1.0, point.x
    assert_equal 2.0, point.y

    line = tui.shape_line(x1: 0.0, y1: 0.0, x2: 10.0, y2: 10.0, color: :red)
    assert_instance_of RatatuiRuby::Shape::Line, line
    assert_equal 0.0, line.x1
    assert_equal :red, line.color

    rect = tui.shape_rectangle(x: 0.0, y: 0.0, width: 5.0, height: 5.0, color: :blue)
    assert_instance_of RatatuiRuby::Shape::Rectangle, rect

    circle = tui.shape_circle(x: 5.0, y: 5.0, radius: 2.5, color: :green)
    assert_instance_of RatatuiRuby::Shape::Circle, circle

    map = tui.shape_map(color: :yellow, resolution: :high)
    assert_instance_of RatatuiRuby::Shape::Map, map
  end

  def test_dsl_text_methods
    tui = RatatuiRuby::DSL.new

    span = tui.text_span(content: "hello")
    assert_instance_of RatatuiRuby::Text::Span, span
    assert_equal "hello", span.content

    line = tui.text_line(spans: [span])
    assert_instance_of RatatuiRuby::Text::Line, line
    assert_equal [span], line.spans
  end
end
