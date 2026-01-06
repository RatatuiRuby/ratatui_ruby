# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestGauge < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_gauge_creation
    g = RatatuiRuby::Widgets::Gauge.new(ratio: 0.5, label: "50%", style: RatatuiRuby::Style::Style.new(fg: :green))
    assert_equal 0.5, g.ratio
    assert_equal "50%", g.label
    assert_equal :green, g.style.fg
  end

  def test_render
    with_test_terminal(20, 1) do
      g = RatatuiRuby::Widgets::Gauge.new(ratio: 0.5, label: "50%")
      RatatuiRuby.draw { |f| f.render_widget(g, f.area) }
      assert_equal "████████50%         ", buffer_content[0]
    end
  end

  def test_gauge_percent
    g = RatatuiRuby::Widgets::Gauge.new(percent: 50)
    assert_in_delta 0.5, g.ratio
  end

  def test_use_unicode_attributes
    g_default = RatatuiRuby::Widgets::Gauge.new(ratio: 0.5)
    assert_equal true, g_default.use_unicode

    g_false = RatatuiRuby::Widgets::Gauge.new(ratio: 0.5, use_unicode: false)
    assert_equal false, g_false.use_unicode
  end

  def test_style_applies_to_gauge
    with_test_terminal(20, 1) do
      g = RatatuiRuby::Widgets::Gauge.new(
        ratio: 0.5,
        style: RatatuiRuby::Style::Style.new(fg: :magenta)
      )
      RatatuiRuby.draw { |f| f.render_widget(g, f.area) }

      ansi_output = render_rich_buffer
      # Magenta foreground = ANSI 35
      assert_includes ansi_output, "\e[35m", "Gauge style should apply magenta foreground"
    end
  end

  def test_gauge_style_applies_to_filled_area
    with_test_terminal(20, 1) do
      g = RatatuiRuby::Widgets::Gauge.new(
        ratio: 0.5,
        gauge_style: RatatuiRuby::Style::Style.new(bg: :green)
      )
      RatatuiRuby.draw { |f| f.render_widget(g, f.area) }

      ansi_output = render_rich_buffer
      # Green background = ANSI 42
      assert_includes ansi_output, "\e[42m", "Gauge gauge_style should apply green background"
    end
  end

  def test_styled_label_renders_content_not_inspect_string
    styled_label = RatatuiRuby::Text::Span.new(
      content: "StyledLabel",
      style: RatatuiRuby::Style::Style.new(fg: :cyan)
    )

    with_test_terminal(25, 1) do
      g = RatatuiRuby::Widgets::Gauge.new(ratio: 0.5, label: styled_label)
      RatatuiRuby.draw { |f| f.render_widget(g, f.area) }
      line = buffer_content[0]

      # The label should render as "StyledLabel" not as "#<data RatatuiRuby::Text::Span..."
      assert_includes line, "StyledLabel", "Styled label content should appear in output"
      refute_includes line, "#<data", "Inspect string should not appear in output"
      refute_includes line, "Span", "Class name should not appear in output"

      # Verify the styling is actually applied (cyan = ANSI code 36)
      ansi_output = render_rich_buffer
      assert_includes ansi_output, "\e[36m", "Label should have cyan foreground"
    end
  end
end

class TestLineGauge < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_line_gauge_style_applies
    with_test_terminal(20, 1) do
      lg = RatatuiRuby::Widgets::LineGauge.new(
        ratio: 0.5,
        style: RatatuiRuby::Style::Style.new(fg: :cyan)
      )
      RatatuiRuby.draw { |f| f.render_widget(lg, f.area) }

      ansi_output = render_rich_buffer
      # Cyan foreground = ANSI 36
      assert_includes ansi_output, "\e[36m", "LineGauge style should apply cyan foreground"
    end
  end

  def test_line_gauge_filled_style_applies
    with_test_terminal(20, 1) do
      lg = RatatuiRuby::Widgets::LineGauge.new(
        ratio: 0.5,
        filled_style: RatatuiRuby::Style::Style.new(fg: :green)
      )
      RatatuiRuby.draw { |f| f.render_widget(lg, f.area) }

      ansi_output = render_rich_buffer
      # Green foreground = ANSI 32
      assert_includes ansi_output, "\e[32m", "LineGauge filled_style should apply green foreground"
    end
  end

  def test_line_gauge_unfilled_style_applies
    with_test_terminal(20, 1) do
      lg = RatatuiRuby::Widgets::LineGauge.new(
        ratio: 0.5,
        unfilled_style: RatatuiRuby::Style::Style.new(fg: :red)
      )
      RatatuiRuby.draw { |f| f.render_widget(lg, f.area) }

      ansi_output = render_rich_buffer
      # Red foreground = ANSI 31
      assert_includes ansi_output, "\e[31m", "LineGauge unfilled_style should apply red foreground"
    end
  end

  def test_styled_label_renders_content_not_inspect_string
    styled_label = RatatuiRuby::Text::Span.new(
      content: "StyledLG",
      style: RatatuiRuby::Style::Style.new(fg: :magenta)
    )

    with_test_terminal(25, 1) do
      lg = RatatuiRuby::Widgets::LineGauge.new(ratio: 0.5, label: styled_label)
      RatatuiRuby.draw { |f| f.render_widget(lg, f.area) }
      line = buffer_content[0]

      # The label should render as "StyledLG" not as "#<data RatatuiRuby::Text::Span..."
      assert_includes line, "StyledLG", "Styled label content should appear in output"
      refute_includes line, "#<data", "Inspect string should not appear in output"
      refute_includes line, "Span", "Class name should not appear in output"

      # Verify the styling is actually applied (magenta = ANSI code 35)
      ansi_output = render_rich_buffer
      assert_includes ansi_output, "\e[35m", "Label should have magenta foreground"
    end
  end
end
