# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"
require "ratatui_ruby/session"

class TestSession < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_session_delegation
    with_test_terminal(20, 1) do
      RatatuiRuby.run do |tui|
        loop do
          p = tui.paragraph(text: "Builder Works")
          tui.draw(p)
          assert_equal "Builder Works       ", buffer_content[0]
          break
        end
      end
    end
  end

  def test_session_shape_methods
    tui = RatatuiRuby::Session.new

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

  def test_session_text_methods
    tui = RatatuiRuby::Session.new

    span = tui.text_span(content: "hello")
    assert_instance_of RatatuiRuby::Text::Span, span
    assert_equal "hello", span.content

    line = tui.text_line(spans: [span])
    assert_instance_of RatatuiRuby::Text::Line, line
    assert_equal [span], line.spans
  end

  def test_session_class_method_wrapping
    tui = RatatuiRuby::Session.new

    # Test Layout.split -> layout_split
    # We pass a mock or simple rect to avoid complex setup, just asserting delegation works
    area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 10, height: 10)
    constraints = [RatatuiRuby::Constraint.percentage(50), RatatuiRuby::Constraint.percentage(50)]

    rects = tui.layout_split(area, direction: :horizontal, constraints:)
    assert_kind_of Array, rects
    assert_equal 2, rects.size
    expected_first = RatatuiRuby::Rect.new(x: 0, y: 0, width: 5, height: 10)
    assert_equal expected_first, rects.first

    expected_second = RatatuiRuby::Rect.new(x: 5, y: 0, width: 5, height: 10)
    assert_equal expected_second, rects.last

    # Test Constraint.percentage -> constraint_percentage
    constraint = tui.constraint_percentage(50)
    assert_equal RatatuiRuby::Constraint.percentage(50), constraint
  end

  def test_session_bar_chart_methods
    tui = RatatuiRuby::Session.new

    bar = tui.bar_chart_bar(value: 10, label: "Bar 1")
    assert_equal RatatuiRuby::BarChart::Bar.new(value: 10, label: "Bar 1"), bar

    group = tui.bar_chart_bar_group(label: "Group 1", bars: [bar])
    assert_equal RatatuiRuby::BarChart::BarGroup.new(label: "Group 1", bars: [bar]), group

    chart = tui.bar_chart(data: [group], bar_width: 5)
    assert_equal RatatuiRuby::BarChart.new(data: [group], bar_width: 5), chart
  end
end
