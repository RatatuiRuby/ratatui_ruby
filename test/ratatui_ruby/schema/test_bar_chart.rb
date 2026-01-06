# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestBarChart < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_bar_chart_creation
    data = { "a" => 1, "b" => 2 }
    chart = RatatuiRuby::Widgets::BarChart.new(data:, bar_width: 5)
    assert_equal 2, chart.data.size

    group_a = chart.data[0]
    assert_kind_of RatatuiRuby::Widgets::BarChart::BarGroup, group_a
    assert_equal "a", group_a.label
    assert_equal 1, group_a.bars.first.value

    group_b = chart.data[1]
    assert_equal "b", group_b.label
    assert_equal 2, group_b.bars.first.value

    assert_equal 5, chart.bar_width
  end

  def test_bar_chart_defaults
    data = { "a" => 1 }
    chart = RatatuiRuby::Widgets::BarChart.new(data:)
    assert_equal 1, chart.data.size
    assert_equal 1, chart.data.first.bars.size
    assert_equal "a", chart.data.first.label
    assert_equal 1, chart.data.first.bars.first.value
    assert_equal 3, chart.bar_width
    assert_equal 1, chart.bar_gap
    assert_nil chart.max
    assert_nil chart.style
    assert_nil chart.block
    assert_nil chart.label_style
    assert_nil chart.value_style
  end

  def test_bar_chart_with_styles
    label_style = RatatuiRuby::Style::Style.new(fg: :red)
    value_style = RatatuiRuby::Style::Style.new(fg: :blue)
    chart = RatatuiRuby::Widgets::BarChart.new(data: { "a" => 1 }, label_style:, value_style:)
    assert_equal label_style, chart.label_style
    assert_equal value_style, chart.value_style
  end

  def test_render
    with_test_terminal(20, 5) do
      chart = RatatuiRuby::Widgets::BarChart.new(data: { "A" => 1, "B" => 2 }, bar_width: 3)
      RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
      assert_snapshots("barchart_render")
    end
  end

  def test_render_horizontal
    with_test_terminal(20, 5) do
      chart = RatatuiRuby::Widgets::BarChart.new(
        data: { "A" => 1, "B" => 2 },
        bar_width: 1,
        direction: :horizontal
      )
      RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
      assert_snapshots("barchart_horizontal")
    end
  end

  def test_styled_bar_group_label_renders_content_not_inspect_string
    styled_label = RatatuiRuby::Text::Line.new(
      spans: [
        RatatuiRuby::Text::Span.new(content: "Group", style: RatatuiRuby::Style::Style.new(fg: :yellow)),
      ]
    )

    bar_group = RatatuiRuby::Widgets::BarChart::BarGroup.new(
      label: styled_label,
      bars: [RatatuiRuby::Widgets::BarChart::Bar.new(value: 5)]
    )

    with_test_terminal(20, 5) do
      chart = RatatuiRuby::Widgets::BarChart.new(data: [bar_group], bar_width: 5)
      RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
      assert_snapshots("barchart_styled_label")
    end
  end

  def test_bar_set_three_levels
    # :three_levels uses simplified 3-level rendering
    with_test_terminal(20, 5) do
      chart = RatatuiRuby::Widgets::BarChart.new(
        data: { "A" => 1, "B" => 2, "C" => 3 },
        bar_width: 3,
        bar_set: :three_levels
      )
      RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
      assert_snapshots("barchart_three_levels")
    end
  end
end
