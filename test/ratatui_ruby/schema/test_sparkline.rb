# frozen_string_literal: true

require "test_helper"

class TestSparkline < Minitest::Test
  def test_sparkline_creation
    data = [1, 2, 3]
    sparkline = RatatuiRuby::Sparkline.new(data:, max: 10)
    assert_equal data, sparkline.data
    assert_equal 10, sparkline.max
  end

  def test_sparkline_defaults
    data = [1, 2, 3]
    sparkline = RatatuiRuby::Sparkline.new(data:)
    assert_equal data, sparkline.data
    assert_nil sparkline.max
    assert_nil sparkline.style
    assert_nil sparkline.block
  end

  def test_render
    with_test_terminal(10, 3) do
      spark = RatatuiRuby::Sparkline.new(data: [1, 2, 3, 4])
      RatatuiRuby.draw(spark)
      assert_equal "  ▂█      ", buffer_content[0]
      assert_equal " ▄██      ", buffer_content[1]
      assert_equal "▆███      ", buffer_content[2]
    end
  end
end
