# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "../test_helper"

class LineGaugeDemoTest < Minitest::Test
  include RatatuiRuby::TestHelper

  # Unit tests for LineGauge data class
  def test_line_gauge_creates_valid_nodes
    gauge1 = RatatuiRuby::LineGauge.new(
      ratio: 0.3,
      label: "30% - Quick Progress",
      style: RatatuiRuby::Style.new(fg: :red),
      block: RatatuiRuby::Block.new(title: "LineGauge Example 1")
    )

    assert_equal 0.3, gauge1.ratio
    assert_equal "30% - Quick Progress", gauge1.label
    assert_equal :red, gauge1.style.fg
    assert_equal "LineGauge Example 1", gauge1.block.title
  end

  def test_line_gauge_multiple_ratios
    [0.0, 0.25, 0.5, 0.75, 1.0].each do |ratio|
      gauge = RatatuiRuby::LineGauge.new(ratio:)
      assert_equal ratio, gauge.ratio
    end
  end

  def test_line_gauge_render
    with_test_terminal(40, 10) do
      gauge = RatatuiRuby::LineGauge.new(
        ratio: 0.65,
        label: "65%",
        style: RatatuiRuby::Style.new(fg: :green),
        block: RatatuiRuby::Block.new(title: "Test")
      )

      layout = RatatuiRuby::Layout.new(
        direction: :vertical,
        constraints: [
          RatatuiRuby::Constraint.length(3),
          RatatuiRuby::Constraint.min(0),
        ],
        children: [
          gauge,
          RatatuiRuby::Paragraph.new(text: "Done"),
        ]
      )

      RatatuiRuby.draw { |f| f.render_widget(layout, f.area) }

      assert_snapshot("line_gauge_render")
      assert_rich_snapshot("line_gauge_render")
    end
  end
end
