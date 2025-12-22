# frozen_string_literal: true

require "test_helper"

class TestList < Minitest::Test
  def test_list_creation
    items = ["a", "b"]
    list = RatatuiRuby::List.new(items:, selected_index: 1)
    assert_equal items, list.items
    assert_equal 1, list.selected_index
  end

  def test_list_defaults
    list = RatatuiRuby::List.new
    assert_equal [], list.items
    assert_nil list.selected_index
    assert_nil list.block
  end

  def test_render
    with_test_terminal(10, 5) do
      list = RatatuiRuby::List.new(items: ["Item 1", "Item 2"], selected_index: 0)
      RatatuiRuby.draw(list)
      assert_equal ">> Item 1 ", buffer_content[0]
      assert_equal "   Item 2 ", buffer_content[1]
      assert_equal "          ", buffer_content[2]
      assert_equal "          ", buffer_content[3]
      assert_equal "          ", buffer_content[4]
    end
  end
end
