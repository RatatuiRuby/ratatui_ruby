# frozen_string_literal: true

require "test_helper"

class TestCursor < Minitest::Test
  def test_cursor_creation
    cursor = RatatuiRuby::Cursor.new(x: 10, y: 5)
    assert_equal 10, cursor.x
    assert_equal 5, cursor.y
  end

  def test_render
    with_test_terminal(10, 5) do
      # Cursor is a ghost widget, it shouldn't affect the buffer content (cells).
      # It sets the cursor state.
      cursor = RatatuiRuby::Cursor.new(x: 5, y: 2)
      RatatuiRuby.draw(cursor)
      
      assert_equal [5, 2], cursor_position

      assert_equal "          ", buffer_content[0]
      assert_equal "          ", buffer_content[1]
      assert_equal "          ", buffer_content[2]
      assert_equal "          ", buffer_content[3]
      assert_equal "          ", buffer_content[4]
    end
  end
end
