# frozen_string_literal: true

require "test_helper"

class TestBlock < Minitest::Test
  def test_block_creation
    b = RatatuiRuby::Block.new(title: "Title", borders: [:top, :bottom], border_color: "red")
    assert_equal "Title", b.title
    assert_equal [:top, :bottom], b.borders
    assert_equal "red", b.border_color
  end

  def test_block_defaults
    b = RatatuiRuby::Block.new
    assert_nil b.title
    assert_equal [:all], b.borders
    assert_nil b.border_color
  end

  def test_render
    with_test_terminal(10, 3) do
      b = RatatuiRuby::Block.new(borders: [:all], title: "Title")
      RatatuiRuby.draw(b)
      assert_equal "┌Title───┐", buffer_content[0]
      assert_equal "│        │", buffer_content[1]
      assert_equal "└────────┘", buffer_content[2]
    end
  end
end
