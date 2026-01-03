# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

# Tests for duck-typed numeric coercion across schema classes.
# All numeric parameters accept any object that responds to to_f (for floats)
# or to_int/to_i (for integers). Ruby's Integer() tries to_int first, then to_i.
class TestNumericCoercion < Minitest::Test
  # Duck-typed float object (responds to to_f)
  class DuckFloat
    def initialize(val) = @val = val
    def to_f = @val.to_f
  end

  # Duck-typed integer object (responds to to_int for exact conversion)
  # Ruby's Integer() prefers to_int, falls back to to_i
  class DuckInt
    def initialize(val) = @val = val
    def to_int = @val.to_i
  end

  # Duck-typed object using to_i (general conversion, also works)
  class DuckIntGeneral
    def initialize(val) = @val = val
    def to_i = @val.to_i
  end

  # ========== Float Coercion Tests ==========

  def test_shape_point_coerces_floats
    point = RatatuiRuby::Widgets::Shape::Point.new(x: DuckFloat.new(1.5), y: DuckFloat.new(2.5))
    assert_equal 1.5, point.x
    assert_equal 2.5, point.y
  end

  def test_shape_point_coerces_rationals
    point = RatatuiRuby::Widgets::Shape::Point.new(x: Rational(3, 2), y: Rational(5, 2))
    assert_equal 1.5, point.x
    assert_equal 2.5, point.y
  end

  def test_shape_point_rejects_nil
    assert_raises(TypeError) { RatatuiRuby::Widgets::Shape::Point.new(x: nil, y: 0) }
    assert_raises(TypeError) { RatatuiRuby::Widgets::Shape::Point.new(x: 0, y: nil) }
  end

  def test_shape_line_coerces_floats
    line = RatatuiRuby::Widgets::Shape::Line.new(
      x1: DuckFloat.new(0), y1: DuckFloat.new(0),
      x2: DuckFloat.new(10), y2: DuckFloat.new(10),
      color: :red
    )
    assert_equal 0.0, line.x1
    assert_equal 10.0, line.x2
  end

  def test_shape_rectangle_coerces_floats
    rect = RatatuiRuby::Widgets::Shape::Rectangle.new(
      x: Rational(1, 2), y: Rational(1, 2),
      width: Rational(10, 1), height: Rational(5, 1),
      color: :blue
    )
    assert_equal 0.5, rect.x
    assert_equal 10.0, rect.width
  end

  def test_shape_circle_coerces_floats
    circle = RatatuiRuby::Widgets::Shape::Circle.new(
      x: DuckFloat.new(5), y: DuckFloat.new(5),
      radius: DuckFloat.new(2.5), color: :green
    )
    assert_equal 5.0, circle.x
    assert_equal 2.5, circle.radius
  end

  def test_shape_label_coerces_floats
    label = RatatuiRuby::Widgets::Shape::Label.new(
      x: Rational(5, 2), y: Rational(5, 2),
      text: "Test"
    )
    assert_equal 2.5, label.x
    assert_equal 2.5, label.y
  end

  def test_canvas_bounds_coerce_floats
    canvas = RatatuiRuby::Widgets::Canvas.new(
      x_bounds: [Rational(-180, 1), Rational(180, 1)],
      y_bounds: [Rational(-90, 1), Rational(90, 1)]
    )
    assert_equal(-180.0, canvas.x_bounds[0])
    assert_equal 180.0, canvas.x_bounds[1]
    assert_equal(-90.0, canvas.y_bounds[0])
    assert_equal 90.0, canvas.y_bounds[1]
  end

  def test_gauge_ratio_coerces_float
    gauge = RatatuiRuby::Widgets::Gauge.new(ratio: Rational(1, 2))
    assert_equal 0.5, gauge.ratio
  end

  def test_gauge_percent_coerces_float
    gauge = RatatuiRuby::Widgets::Gauge.new(percent: DuckFloat.new(75))
    assert_equal 0.75, gauge.ratio
  end

  def test_line_gauge_ratio_coerces_float
    gauge = RatatuiRuby::Widgets::LineGauge.new(ratio: Rational(1, 4))
    assert_equal 0.25, gauge.ratio
  end

  def test_center_percentages_coerce_floats
    center = RatatuiRuby::Widgets::Center.new(
      child: RatatuiRuby::Widgets::Paragraph.new(text: "Test"),
      width_percent: Rational(50, 1),
      height_percent: Rational(50, 1)
    )
    assert_equal 50.0, center.width_percent
    assert_equal 50.0, center.height_percent
  end

  def test_axis_bounds_coerce_floats
    axis = RatatuiRuby::Widgets::Axis.new(bounds: [Rational(0, 1), Rational(100, 1)])
    assert_equal 0.0, axis.bounds[0]
    assert_equal 100.0, axis.bounds[1]
  end

  def test_dataset_data_coerces_floats
    dataset = RatatuiRuby::Widgets::Dataset.new(
      name: "Test",
      data: [[Rational(1, 1), Rational(2, 1)], [Rational(3, 1), Rational(4, 1)]]
    )
    assert_equal 1.0, dataset.data[0][0]
    assert_equal 2.0, dataset.data[0][1]
    assert_equal 3.0, dataset.data[1][0]
    assert_equal 4.0, dataset.data[1][1]
  end

  def test_line_chart_bounds_coerce_floats
    chart = RatatuiRuby::Widgets::Chart.new(
      datasets: [],
      y_bounds: [Rational(0, 1), Rational(100, 1)]
    )
    assert_equal 0.0, chart.y_bounds[0]
    assert_equal 100.0, chart.y_bounds[1]
  end

  # ========== Integer Coercion Tests ==========

  def test_rect_coerces_integers
    rect = RatatuiRuby::Layout::Rect.new(
      x: DuckInt.new(10), y: DuckInt.new(5),
      width: DuckInt.new(80), height: DuckInt.new(24)
    )
    assert_equal 10, rect.x
    assert_equal 5, rect.y
    assert_equal 80, rect.width
    assert_equal 24, rect.height
  end

  def test_rect_coerces_floats_to_integers
    rect = RatatuiRuby::Layout::Rect.new(x: 10.9, y: 5.1, width: 80.5, height: 24.9)
    assert_equal 10, rect.x
    assert_equal 5, rect.y
    assert_equal 80, rect.width
    assert_equal 24, rect.height
  end

  def test_rect_coerces_to_i_objects
    # to_i (general conversion) also works, not just to_int
    rect = RatatuiRuby::Layout::Rect.new(
      x: DuckIntGeneral.new(10), y: DuckIntGeneral.new(5),
      width: DuckIntGeneral.new(80), height: DuckIntGeneral.new(24)
    )
    assert_equal 10, rect.x
    assert_equal 5, rect.y
    assert_equal 80, rect.width
    assert_equal 24, rect.height
  end

  def test_cursor_coerces_integers
    cursor = RatatuiRuby::Widgets::Cursor.new(x: DuckInt.new(5), y: DuckInt.new(10))
    assert_equal 5, cursor.x
    assert_equal 10, cursor.y
  end

  def test_draw_string_coerces_integers
    cmd = RatatuiRuby::Draw.string(DuckInt.new(5), DuckInt.new(10), "Hello")
    assert_equal 5, cmd.x
    assert_equal 10, cmd.y
  end

  def test_draw_cell_coerces_integers
    cell = RatatuiRuby::Buffer::Cell.new(char: "X")
    cmd = RatatuiRuby::Draw.cell(DuckInt.new(5), DuckInt.new(10), cell)
    assert_equal 5, cmd.x
    assert_equal 10, cmd.y
  end

  def test_tabs_coerces_integers
    tabs = RatatuiRuby::Widgets::Tabs.new(
      titles: ["A", "B"],
      selected_index: DuckInt.new(1),
      padding_left: DuckInt.new(2),
      padding_right: DuckInt.new(3)
    )
    assert_equal 1, tabs.selected_index
    assert_equal 2, tabs.padding_left
    assert_equal 3, tabs.padding_right
  end

  def test_list_selected_index_coerces_or_nil
    list_nil = RatatuiRuby::Widgets::List.new(items: [], selected_index: nil)
    assert_nil list_nil.selected_index

    list_duck = RatatuiRuby::Widgets::List.new(items: [], selected_index: DuckInt.new(5))
    assert_equal 5, list_duck.selected_index
  end

  def test_list_optional_params_reject_false
    assert_raises(TypeError) { RatatuiRuby::Widgets::List.new(items: [], selected_index: false) }
  end

  def test_table_coerces_integers
    table = RatatuiRuby::Widgets::Table.new(
      rows: [],
      selected_row: DuckInt.new(2),
      selected_column: DuckInt.new(3),
      column_spacing: DuckInt.new(5)
    )
    assert_equal 2, table.selected_row
    assert_equal 3, table.selected_column
    assert_equal 5, table.column_spacing
  end

  def test_table_optional_params_allow_nil
    table = RatatuiRuby::Widgets::Table.new(rows: [], selected_row: nil, selected_column: nil)
    assert_nil table.selected_row
    assert_nil table.selected_column
  end

  def test_scrollbar_coerces_integers
    scrollbar = RatatuiRuby::Widgets::Scrollbar.new(
      content_length: DuckInt.new(100),
      position: DuckInt.new(25)
    )
    assert_equal 100, scrollbar.content_length
    assert_equal 25, scrollbar.position
  end

  def test_bar_chart_coerces_integers
    chart = RatatuiRuby::Widgets::BarChart.new(
      data: { "A" => 10 },
      bar_width: DuckInt.new(5),
      bar_gap: DuckInt.new(2),
      group_gap: DuckInt.new(3),
      max: DuckInt.new(100)
    )
    assert_equal 5, chart.bar_width
    assert_equal 2, chart.bar_gap
    assert_equal 3, chart.group_gap
    assert_equal 100, chart.max
  end

  def test_bar_chart_max_allows_nil
    chart = RatatuiRuby::Widgets::BarChart.new(data: { "A" => 10 }, max: nil)
    assert_nil chart.max
  end

  def test_bar_value_coerces_integer
    bar = RatatuiRuby::Widgets::BarChart::Bar.new(value: DuckInt.new(42))
    assert_equal 42, bar.value
  end

  def test_sparkline_coerces_integers
    sparkline = RatatuiRuby::Widgets::Sparkline.new(
      data: [DuckInt.new(1), DuckInt.new(2), nil, DuckInt.new(4)],
      max: DuckInt.new(10)
    )
    assert_equal [1, 2, nil, 4], sparkline.data
    assert_equal 10, sparkline.max
  end

  def test_sparkline_allows_nil_in_data
    sparkline = RatatuiRuby::Widgets::Sparkline.new(data: [1, nil, 3], max: nil)
    assert_equal [1, nil, 3], sparkline.data
    assert_nil sparkline.max
  end

  def test_calendar_coerces_integers
    calendar = RatatuiRuby::Widgets::Calendar.new(
      year: DuckInt.new(2025),
      month: DuckInt.new(12)
    )
    assert_equal 2025, calendar.year
    assert_equal 12, calendar.month
  end

  def test_constraint_factory_methods_coerce_integers
    assert_equal 10, RatatuiRuby::Layout::Constraint.length(DuckInt.new(10)).value
    assert_equal 50, RatatuiRuby::Layout::Constraint.percentage(DuckInt.new(50)).value
    assert_equal 5, RatatuiRuby::Layout::Constraint.min(DuckInt.new(5)).value
    assert_equal 20, RatatuiRuby::Layout::Constraint.max(DuckInt.new(20)).value
    assert_equal 2, RatatuiRuby::Layout::Constraint.fill(DuckInt.new(2)).value
    assert_equal [1, 3], RatatuiRuby::Layout::Constraint.ratio(DuckInt.new(1), DuckInt.new(3)).value
  end

  def test_paragraph_scroll_coerces_integers
    paragraph = RatatuiRuby::Widgets::Paragraph.new(
      text: "Test",
      scroll: [DuckInt.new(5), DuckInt.new(10)]
    )
    assert_equal [5, 10], paragraph.scroll
  end

  def test_block_padding_coerces_integers
    block_uniform = RatatuiRuby::Widgets::Block.new(padding: DuckInt.new(5))
    assert_equal 5, block_uniform.padding

    block_array = RatatuiRuby::Widgets::Block.new(
      padding: [DuckInt.new(1), DuckInt.new(2), DuckInt.new(3), DuckInt.new(4)]
    )
    assert_equal [1, 2, 3, 4], block_array.padding
  end
end
