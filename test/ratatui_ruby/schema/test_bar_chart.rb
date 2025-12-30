# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestBarChart < Minitest::Test
    include RatatuiRuby::TestHelper
  def test_bar_chart_creation
    data = { "a" => 1, "b" => 2 }
    chart = RatatuiRuby::BarChart.new(data:, bar_width: 5)
    assert_equal 2, chart.data.size
    
    group_a = chart.data[0]
    assert_kind_of RatatuiRuby::BarChart::BarGroup, group_a
    assert_equal "a", group_a.label
    assert_equal 1, group_a.bars.first.value
    
    group_b = chart.data[1]
    assert_equal "b", group_b.label
    assert_equal 2, group_b.bars.first.value

    assert_equal 5, chart.bar_width
  end

  def test_bar_chart_defaults
    data = { "a" => 1 }
    chart = RatatuiRuby::BarChart.new(data:)
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
    label_style = RatatuiRuby::Style.new(fg: :red)
    value_style = RatatuiRuby::Style.new(fg: :blue)
    chart = RatatuiRuby::BarChart.new(data: { "a" => 1 }, label_style:, value_style:)
    assert_equal label_style, chart.label_style
    assert_equal value_style, chart.value_style
  end

  def test_render
    with_test_terminal(20, 5) do
      # 10x5 area
      chart = RatatuiRuby::BarChart.new(data: { "A" => 1, "B" => 2 }, bar_width: 3)
      RatatuiRuby.draw(chart)

      assert_equal "    ███             ", buffer_content[0]
      assert_equal "    ███             ", buffer_content[1]
      assert_equal "███ ███             ", buffer_content[2]
      assert_equal "█1█ █2█             ", buffer_content[3]
      assert_equal "A   B               ", buffer_content[4]
    end
  end

  def test_render_horizontal
    with_test_terminal(20, 5) do
      # 20x5 area, horizontal bars
      chart = RatatuiRuby::BarChart.new(
        data: { "A" => 1, "B" => 2 },
        bar_width: 1,
        direction: :horizontal
      )
      RatatuiRuby.draw(chart)

      # In horizontal mode, bars grow from left to right.
      # Labels and values are on the left of the bar.
      # Width is 20. Bar A (val 1), Bar B (val 2). Max is 2.
      # Bar A should be half width of Bar B.
      assert_equal "A 1████████         ", buffer_content[0]
      assert_equal "                    ", buffer_content[1]
      assert_equal "B 2█████████████████", buffer_content[2]
      assert_equal "                    ", buffer_content[3]
      assert_equal "                    ", buffer_content[4]
    end
  end
end
