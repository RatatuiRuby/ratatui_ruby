# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestSparkline < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_sparkline_creation
    data = [1, 2, 3]
    sparkline = RatatuiRuby::Widgets::Sparkline.new(data:, max: 10)
    assert_equal data, sparkline.data
    assert_equal 10, sparkline.max
  end

  def test_sparkline_defaults
    data = [1, 2, 3]
    sparkline = RatatuiRuby::Widgets::Sparkline.new(data:)
    assert_equal data, sparkline.data
    assert_nil sparkline.max
    assert_nil sparkline.style
    assert_nil sparkline.block
  end

  def test_render
    with_test_terminal(10, 3) do
      spark = RatatuiRuby::Widgets::Sparkline.new(data: [1, 2, 3, 4])
      RatatuiRuby.draw { |f| f.render_widget(spark, f.area) }
      assert_snapshots("sparkline_render")
    end
  end

  def test_direction_default
    sparkline = RatatuiRuby::Widgets::Sparkline.new(data: [1, 2, 3])
    assert_equal :left_to_right, sparkline.direction
  end

  def test_direction_right_to_left
    with_test_terminal(10, 3) do
      spark = RatatuiRuby::Widgets::Sparkline.new(data: [1, 2, 3, 4], direction: :right_to_left)
      RatatuiRuby.draw { |f| f.render_widget(spark, f.area) }
      assert_snapshots("sparkline_right_to_left")
    end
  end

  def test_absent_value_symbol
    sparkline = RatatuiRuby::Widgets::Sparkline.new(
      data: [1, 2, 3],
      absent_value_symbol: "·"
    )
    assert_equal "·", sparkline.absent_value_symbol
  end

  def test_absent_value_style
    style = RatatuiRuby::Style::Style.new(fg: :red)
    sparkline = RatatuiRuby::Widgets::Sparkline.new(
      data: [1, 2, 3],
      absent_value_style: style
    )
    assert_equal style, sparkline.absent_value_style
  end

  def test_absent_value_rendering
    with_test_terminal(5, 1) do
      # Data with absent (nil) values: [1, nil, 2, nil, 3]
      # nil marks an absent value, distinct from 0
      spark = RatatuiRuby::Widgets::Sparkline.new(
        data: [1, nil, 2, nil, 3],
        absent_value_symbol: "-"
      )
      RatatuiRuby.draw { |f| f.render_widget(spark, f.area) }
      content = buffer_content[0]

      # Absent values (nil) should render as "-"
      # Non-absent values should render as sparkline bars
      assert_includes(content, "-", "Expected dashes for absent values")
      assert_equal(5, content.length, "Expected content to span the full width")
    end
  end

  def test_style_applies_to_sparkline
    with_test_terminal(10, 3) do
      spark = RatatuiRuby::Widgets::Sparkline.new(
        data: [1, 2, 3, 4],
        style: RatatuiRuby::Style::Style.new(fg: :cyan)
      )
      RatatuiRuby.draw { |f| f.render_widget(spark, f.area) }

      ansi_output = render_rich_buffer
      # Cyan foreground = ANSI 36
      assert_includes ansi_output, "\e[36m", "Sparkline style should apply cyan foreground"
    end
  end

  def test_absent_value_style_applies_to_gaps
    with_test_terminal(5, 1) do
      spark = RatatuiRuby::Widgets::Sparkline.new(
        data: [1, nil, 3],
        absent_value_symbol: "-",
        absent_value_style: RatatuiRuby::Style::Style.new(fg: :red)
      )
      RatatuiRuby.draw { |f| f.render_widget(spark, f.area) }

      ansi_output = render_rich_buffer
      # Red foreground = ANSI 31
      assert_includes ansi_output, "\e[31m", "Sparkline absent_value_style should apply red foreground"
    end
  end

  def test_bar_set_nine_levels
    # :nine_levels uses the full 9-character gradient (default ratatui behavior)
    with_test_terminal(10, 3) do
      spark = RatatuiRuby::Widgets::Sparkline.new(data: [1, 2, 3, 4], bar_set: :nine_levels)
      RatatuiRuby.draw { |f| f.render_widget(spark, f.area) }
      assert_snapshots("bar_set_nine_levels")
    end
  end

  def test_bar_set_three_levels
    # :three_levels uses simplified 3-level (empty, half, full)
    with_test_terminal(10, 3) do
      spark = RatatuiRuby::Widgets::Sparkline.new(data: [1, 2, 3, 4], bar_set: :three_levels)
      RatatuiRuby.draw { |f| f.render_widget(spark, f.area) }
      assert_snapshots("bar_set_three_levels")
    end
  end
end
