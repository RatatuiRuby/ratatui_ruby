# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestRatatuiRuby < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::RatatuiRuby::VERSION
  end

  def test_paragraph_creation
    p = RatatuiRuby::Paragraph.new(text: "Hello", fg: "red", bg: "black")
    assert_equal "Hello", p.text
    assert_equal "red", p.style.fg
    assert_equal "black", p.style.bg
  end

  def test_paragraph_defaults
    p = RatatuiRuby::Paragraph.new(text: "Hello")
    assert_equal "Hello", p.text
    assert_nil p.style.fg
    assert_nil p.style.bg
    assert_equal [], p.style.modifiers
    assert_nil p.block
  end

  def test_style_creation
    s = RatatuiRuby::Style.new(fg: :red, bg: :blue, modifiers: [:bold])
    assert_equal :red, s.fg
    assert_equal :blue, s.bg
    assert_equal [:bold], s.modifiers
  end

  def test_gauge_creation
    g = RatatuiRuby::Gauge.new(ratio: 0.5, label: "50%", style: RatatuiRuby::Style.new(fg: :green))
    assert_equal 0.5, g.ratio
    assert_equal "50%", g.label
    assert_equal :green, g.style.fg
  end

  def test_table_creation
    header = ["A", "B"]
    rows = [["1", "2"], ["3", "4"]]
    widths = [RatatuiRuby::Constraint.length(5), RatatuiRuby::Constraint.length(5)]
    t = RatatuiRuby::Table.new(header:, rows:, widths:)
    assert_equal header, t.header
    assert_equal rows, t.rows
    assert_equal widths, t.widths
  end

  def test_layout_creation
    p = RatatuiRuby::Paragraph.new(text: "Hello")
    l = RatatuiRuby::Layout.new(direction: :vertical, constraints: [RatatuiRuby::Constraint.percentage(100)], children: [p])
    assert_equal :vertical, l.direction
    assert_equal 1, l.constraints.length
    assert_equal :percentage, l.constraints.first.type
    assert_equal 100, l.constraints.first.value
    assert_equal [p], l.children
  end

  def test_layout_defaults
    l = RatatuiRuby::Layout.new
    assert_equal :vertical, l.direction
    assert_equal [], l.constraints
    assert_equal [], l.children
  end

  def test_constraint_creation
    c1 = RatatuiRuby::Constraint.length(10)
    assert_equal :length, c1.type
    assert_equal 10, c1.value

    c2 = RatatuiRuby::Constraint.percentage(50)
    assert_equal :percentage, c2.type
    assert_equal 50, c2.value

    c3 = RatatuiRuby::Constraint.min(5)
    assert_equal :min, c3.type
    assert_equal 5, c3.value
  end

  def test_list_creation
    items = ["a", "b"]
    list = RatatuiRuby::List.new(items:, selected_index: 1)
    assert_equal items, list.items
    assert_equal 1, list.selected_index
  end

  def test_list_defaults
    list = RatatuiRuby::List.new
    assert_equal [], list.items
    assert_nil list.selected_index
    assert_nil list.block
  end

  def test_nested_layout
    p = RatatuiRuby::Paragraph.new(text: "Inner")
    inner = RatatuiRuby::Layout.new(direction: :horizontal, children: [p])
    outer = RatatuiRuby::Layout.new(direction: :vertical, children: [inner])
    assert_equal [inner], outer.children
    assert_equal [p], outer.children.first.children
  end

  def test_block_creation
    b = RatatuiRuby::Block.new(title: "Title", borders: [:top, :bottom], border_color: "red")
    assert_equal "Title", b.title
    assert_equal [:top, :bottom], b.borders
    assert_equal "red", b.border_color
  end

  def test_block_defaults
    b = RatatuiRuby::Block.new
    assert_nil b.title
    assert_equal [:all], b.borders
    assert_nil b.border_color
  end

  def test_tabs_creation
    titles = ["A", "B"]
    tabs = RatatuiRuby::Tabs.new(titles:, selected_index: 0)
    assert_equal titles, tabs.titles
    assert_equal 0, tabs.selected_index
  end

  def test_tabs_defaults
    tabs = RatatuiRuby::Tabs.new
    assert_equal [], tabs.titles
    assert_equal 0, tabs.selected_index
    assert_nil tabs.block
  end

  def test_bar_chart_creation
    data = { "a" => 1, "b" => 2 }
    chart = RatatuiRuby::BarChart.new(data:, bar_width: 5)
    assert_equal data, chart.data
    assert_equal 5, chart.bar_width
  end

  def test_bar_chart_defaults
    data = { "a" => 1 }
    chart = RatatuiRuby::BarChart.new(data:)
    assert_equal data, chart.data
    assert_equal 3, chart.bar_width
    assert_equal 1, chart.bar_gap
    assert_nil chart.max
    assert_nil chart.style
    assert_nil chart.block
  end
end
