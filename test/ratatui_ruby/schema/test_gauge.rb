# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

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
end
