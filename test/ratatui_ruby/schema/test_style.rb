# frozen_string_literal: true

require "test_helper"

class TestStyle < Minitest::Test
  def test_style_creation
    s = RatatuiRuby::Style.new(fg: :red, bg: :blue, modifiers: [:bold])
    assert_equal :red, s.fg
    assert_equal :blue, s.bg
    assert_equal [:bold], s.modifiers
  end
end
