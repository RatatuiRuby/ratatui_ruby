# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestLineChart < Minitest::Test
  def test_line_chart_creation
    ds = RatatuiRuby::Dataset.new(name: "test", data: [[0.0, 0.0], [1.0, 1.0]], color: "red")
    chart = RatatuiRuby::LineChart.new(datasets: [ds], x_labels: ["0", "1"])
    assert_equal [ds], chart.datasets
    assert_equal ["0", "1"], chart.x_labels
  end

  def test_line_chart_defaults
    ds = RatatuiRuby::Dataset.new(name: "test", data: [[0.0, 0.0]])
    chart = RatatuiRuby::LineChart.new(datasets: [ds])
    assert_equal [ds], chart.datasets
    assert_equal [], chart.x_labels
    assert_equal [], chart.y_labels
    assert_equal [0.0, 100.0], chart.y_bounds
    assert_nil chart.block
  end

  def test_render
    with_test_terminal(20, 10) do
      ds = RatatuiRuby::Dataset.new(name: "Data", data: [[0.0, 0.0], [1.0, 1.0], [2.0, 2.0]])
      chart = RatatuiRuby::LineChart.new(datasets: [ds], x_labels: ["0", "1", "2"])
      RatatuiRuby.draw(chart)
      assert_equal "│                   ", buffer_content[0]
      assert_equal "│                   ", buffer_content[1]
      assert_equal "│                   ", buffer_content[2]
      assert_equal "│                   ", buffer_content[3]
      assert_equal "│                   ", buffer_content[4]
      assert_equal "│                   ", buffer_content[5]
      assert_equal "│                   ", buffer_content[6]
      assert_equal "│⡀        ⢀        ⠠", buffer_content[7]
      assert_equal "└───────────────────", buffer_content[8]
      assert_equal "0         1        2", buffer_content[9]
    end
  end
end
