# frozen_string_literal: true

require "test_helper"

class TestGauge < Minitest::Test
  def test_gauge_creation
    g = RatatuiRuby::Gauge.new(ratio: 0.5, label: "50%", style: RatatuiRuby::Style.new(fg: :green))
    assert_equal 0.5, g.ratio
    assert_equal "50%", g.label
    assert_equal :green, g.style.fg
  end

  def test_render
    with_test_terminal(10, 1) do
      g = RatatuiRuby::Gauge.new(ratio: 0.5, label: "50%")
      RatatuiRuby.draw(g)
      assert_equal "███50%    ", buffer_content[0]
    end
  end
end
