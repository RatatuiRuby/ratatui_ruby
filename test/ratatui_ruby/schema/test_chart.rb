# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "ratatui_ruby"
require "minitest/autorun"
require_relative "../../test_helper"

module RatatuiRuby
  class TestChart < Minitest::Test
    include RatatuiRuby::TestHelper
    def setup
      RatatuiRuby.init_test_terminal(80, 24)
    end

    def teardown
      RatatuiRuby.restore_terminal
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

      with_test_terminal(80, 24) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        assert_snapshots("chart_rendering")
      end
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

      with_test_terminal(80, 24) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        assert_snapshots("axis_labels_alignment")
      end
    end

    def test_styled_axis_title_renders_content_not_inspect_string
      styled_title = Text::Line.new(
        spans: [Text::Span.new(content: "StyledTime", style: Style::Style.new(fg: :cyan))]
      )

      datasets = [
        Widgets::Dataset.new(name: "DS1", data: [[0.0, 0.0], [10.0, 10.0]], marker: :dot),
      ]

      chart = Widgets::Chart.new(
        datasets:,
        x_axis: Widgets::Axis.new(title: styled_title, bounds: [0.0, 10.0]),
        y_axis: Widgets::Axis.new(bounds: [0.0, 10.0])
      )

      with_test_terminal(40, 10) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        # Verifies content ("StyledTime" renders) and styling (cyan foreground)
        assert_snapshots("styled_axis_title")
      end
    end

    def test_styled_dataset_name_renders_content_not_inspect_string
      styled_name = Text::Line.new(
        spans: [Text::Span.new(content: "StyledDS", style: Style::Style.new(fg: :green))]
      )

      datasets = [
        Widgets::Dataset.new(name: styled_name, data: [[0.0, 0.0], [10.0, 10.0]], marker: :dot),
      ]

      chart = Widgets::Chart.new(
        datasets:,
        x_axis: Widgets::Axis.new(bounds: [0.0, 10.0]),
        y_axis: Widgets::Axis.new(bounds: [0.0, 10.0])
      )

      with_test_terminal(40, 10) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        # Verifies content ("StyledDS" renders) and styling (green foreground)
        assert_snapshots("styled_dataset_name")
      end
    end

    # Edge-center legend positions: :top, :bottom, :left, :right
    # These complement the corner positions (:top_left, :top_right, :bottom_left, :bottom_right)

    def test_legend_position_top
      chart = chart_with_legend_position(:top)

      with_test_terminal(30, 12) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        assert_snapshots("legend_position_top")
      end
    end

    def test_legend_position_bottom
      chart = chart_with_legend_position(:bottom)

      with_test_terminal(30, 12) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        assert_snapshots("legend_position_bottom")
      end
    end

    def test_legend_position_left
      chart = chart_with_legend_position(:left)

      with_test_terminal(30, 12) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        assert_snapshots("legend_position_left")
      end
    end

    def test_legend_position_right
      chart = chart_with_legend_position(:right)

      with_test_terminal(30, 12) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        assert_snapshots("legend_position_right")
      end
    end

    def test_half_block_marker
      # Verifies Chart Dataset supports :half_block marker (higher resolution than :dot)
      datasets = [
        Widgets::Dataset.new(
          name: "HB",
          data: [[0.0, 0.0], [10.0, 10.0]],
          marker: :half_block
        ),
      ]

      chart = Widgets::Chart.new(
        datasets:,
        x_axis: Widgets::Axis.new(bounds: [0.0, 10.0]),
        y_axis: Widgets::Axis.new(bounds: [0.0, 10.0])
      )

      with_test_terminal(30, 12) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        assert_snapshots("half_block_marker")
      end
    end

    def test_styled_axis_labels_renders_content_not_inspect_string
      styled_label_0 = Text::Line.new(
        spans: [Text::Span.new(content: "Start", style: Style::Style.new(fg: :yellow))]
      )
      styled_label_10 = Text::Line.new(
        spans: [Text::Span.new(content: "End", style: Style::Style.new(fg: :cyan))]
      )

      datasets = [
        Widgets::Dataset.new(name: "DS1", data: [[0.0, 0.0], [10.0, 10.0]], marker: :dot),
      ]

      chart = Widgets::Chart.new(
        datasets:,
        x_axis: Widgets::Axis.new(bounds: [0.0, 10.0], labels: [styled_label_0, styled_label_10]),
        y_axis: Widgets::Axis.new(bounds: [0.0, 10.0])
      )

      with_test_terminal(40, 10) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        content = buffer_content.join("\n")

        # The labels should render as "Start" and "End" not as "#<data RatatuiRuby::Text::Line..."
        assert_includes content, "Start", "Styled label content should appear in output"
        assert_includes content, "End", "Styled label content should appear in output"
        refute_includes content, "#<data", "Inspect string should not appear in output"
        refute_includes content, "Line", "Class name should not appear in output"

        # Verify the styling is actually applied (yellow = ANSI 33, cyan = ANSI 36)
        ansi_output = render_rich_buffer
        assert_includes ansi_output, "\e[33m", "First label should have yellow foreground"
        assert_includes ansi_output, "\e[36m", "Second label should have cyan foreground"
      end
    end

    private def chart_with_legend_position(position)
      Widgets::Chart.new(
        datasets: [Widgets::Dataset.new(name: "DS", data: [[0.0, 0.0], [10.0, 10.0]], marker: :dot)],
        x_axis: Widgets::Axis.new(bounds: [0.0, 10.0]),
        y_axis: Widgets::Axis.new(bounds: [0.0, 10.0]),
        legend_position: position
      )
    end
  end
end
