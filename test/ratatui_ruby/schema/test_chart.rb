# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "ratatui_ruby"
require "minitest/autorun"
require_relative "../../test_helper"

module RatatuiRuby
  class TestChart < Minitest::Test
    include RatatuiRuby::TestHelper
    def setup
      RatatuiRuby.init_test_terminal(80, 24)
    end

    def test_chart_rendering
      datasets = [
        Widgets::Dataset.new(
          name: "TestDS",
          data: [[0.0, 0.0], [10.0, 10.0]],
          style: Style::Style.new(fg: :red),
          marker: :dot,
        ),
      ]

      chart = Widgets::Chart.new(
        datasets:,
        x_axis: Widgets::Axis.new(title: "Time", bounds: [0.0, 10.0], labels: %w[0 10]),
        y_axis: Widgets::Axis.new(title: "Value", bounds: [0.0, 10.0], labels: %w[0 10]),
        block: Widgets::Block.new(title: "Test Chart"),
      )

      RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
      buffer = RatatuiRuby.get_buffer_content

      # Check for axis titles
      assert_includes buffer, "Time"
      assert_includes buffer, "Value"
      # Check for block title
      assert_includes buffer, "Test Chart"
      # Check for dataset name
      assert_includes buffer, "TestDS"
      # Check for labels
      assert_includes buffer, "0"
      assert_includes buffer, "10"
    end

    def test_axis_labels_alignment
      datasets = [
        Widgets::Dataset.new(
          name: "TestDS",
          data: [[0.0, 0.0], [10.0, 10.0]],
          style: Style::Style.new(fg: :green),
          marker: :dot,
        ),
      ]

      # Test with centered X-axis labels and right-aligned Y-axis labels
      chart = Widgets::Chart.new(
        datasets:,
        x_axis: Widgets::Axis.new(
          title: "Time",
          bounds: [0.0, 10.0],
          labels: %w[0 5 10],
          labels_alignment: :center,
        ),
        y_axis: Widgets::Axis.new(
          title: "Value",
          bounds: [0.0, 10.0],
          labels: %w[0 5 10],
          labels_alignment: :right,
        ),
        block: Widgets::Block.new(title: "Aligned Chart"),
      )

      RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
      buffer = RatatuiRuby.get_buffer_content

      # Verify the chart renders with alignment settings
      assert_includes buffer, "Time"
      assert_includes buffer, "Value"
      assert_includes buffer, "Aligned Chart"
      assert_includes buffer, "TestDS"
    end

    def test_line_chart_backward_compatibility
      datasets = [
        Widgets::Dataset.new(
          name: "TestDS",
          data: [[0.0, 0.0], [10.0, 10.0]],
          style: Style::Style.new(fg: :blue),
        ),
      ]

      line_chart = Widgets::Chart.new(
        datasets:,
        x_labels: %w[X0 X10],
        y_labels: %w[Y0 Y10],
        y_bounds: [0.0, 10.0],
        block: Widgets::Block.new(title: "Legacy Chart"),
      )

      RatatuiRuby.draw { |f| f.render_widget(line_chart, f.area) }
      buffer = RatatuiRuby.get_buffer_content

      assert_includes buffer, "Legacy Chart"
      assert_includes buffer, "X0"
      assert_includes buffer, "X10"
      assert_includes buffer, "Y0"
      assert_includes buffer, "Y10"
      assert_includes buffer, "TestDS"
    end
  end
end
