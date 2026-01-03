# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestChart < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_chart_creation
    ds = RatatuiRuby::Widgets::Dataset.new(name: "test", data: [[0.0, 0.0], [1.0, 1.0]], style: RatatuiRuby::Style::Style.new(fg: :red))
    x_axis = RatatuiRuby::Widgets::Axis.new(labels: ["0", "1"])
    y_axis = RatatuiRuby::Widgets::Axis.new(bounds: [0.0, 1.0])
    chart = RatatuiRuby::Widgets::Chart.new(datasets: [ds], x_axis:, y_axis:)
    assert_equal [ds], chart.datasets
    assert_equal x_axis, chart.x_axis
    assert_equal y_axis, chart.y_axis
  end

  def test_chart_defaults
    ds = RatatuiRuby::Widgets::Dataset.new(name: "test", data: [[0.0, 0.0]])
    x_axis = RatatuiRuby::Widgets::Axis.new
    y_axis = RatatuiRuby::Widgets::Axis.new(bounds: [0.0, 100.0])
    chart = RatatuiRuby::Widgets::Chart.new(datasets: [ds], x_axis:, y_axis:)
    assert_equal [ds], chart.datasets
    assert_nil chart.block
  end

  def test_render
    with_test_terminal(20, 10) do
      ds = RatatuiRuby::Widgets::Dataset.new(name: "Data", data: [[0.0, 0.0], [1.0, 1.0], [2.0, 2.0]])
      x_axis = RatatuiRuby::Widgets::Axis.new(labels: ["0", "1", "2"], bounds: [0.0, 2.0])
      y_axis = RatatuiRuby::Widgets::Axis.new(bounds: [0.0, 2.0])
      chart = RatatuiRuby::Widgets::Chart.new(datasets: [ds], x_axis:, y_axis:)
      RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
      # Basic assertion that chart renders without error
      refute_empty buffer_content[0]
    end
  end
end
