# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestBarChart < Minitest::Test
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

  def test_render
    with_test_terminal(20, 5) do
      # 10x5 area
      chart = RatatuiRuby::BarChart.new(data: { "A" => 1, "B" => 2 }, bar_width: 3)
      RatatuiRuby.draw(chart)

      assert_equal "    ███             ", buffer_content[0]
      assert_equal "    ███             ", buffer_content[1]
      assert_equal "███ ███             ", buffer_content[2]
      assert_equal "█1█ █2█             ", buffer_content[3]
      assert_equal " A   B              ", buffer_content[4]
    end
  end
end
