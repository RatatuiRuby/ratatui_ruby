# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

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
    assert_nil list.style
    assert_nil list.highlight_style
    assert_equal "> ", list.highlight_symbol
    assert_equal :when_selected, list.highlight_spacing
    assert_nil list.block
  end

  def test_render
    with_test_terminal(20, 3) do
      list = RatatuiRuby::List.new(items: ["Item 1", "Item 2"], selected_index: 0)
      RatatuiRuby.draw(list)

      assert_equal "> Item 1            ", buffer_content[0]
      assert_equal "  Item 2            ", buffer_content[1]
    end
  end

  def test_render_with_custom_symbol
    with_test_terminal(20, 5) do
      list = RatatuiRuby::List.new(
        items: ["Item 1", "Item 2"],
        selected_index: 1,
        highlight_symbol: ">> "
      )
      RatatuiRuby.draw(list)
      assert_equal "   Item 1           ", buffer_content[0]
      assert_equal ">> Item 2           ", buffer_content[1]
    end
  end

  def test_render_bottom_to_top
    with_test_terminal(20, 3) do
      list = RatatuiRuby::List.new(
        items: ["Item 1", "Item 2"],
        selected_index: 0,
        direction: :bottom_to_top
      )
      RatatuiRuby.draw(list)
      # In BottomToTop, the first item is at the bottom
      assert_equal "  Item 2            ", buffer_content[1]
      assert_equal "> Item 1            ", buffer_content[2]
    end
  end

  def test_invalid_direction
    assert_raises(ArgumentError) {
      list = RatatuiRuby::List.new(items: [], direction: :invalid)
      with_test_terminal(10, 10) do
        RatatuiRuby.draw(list)
      end
    }
  end

  def test_highlight_spacing_always
    with_test_terminal(20, 3) do
      list = RatatuiRuby::List.new(
        items: ["Item 1", "Item 2"],
        selected_index: nil,
        highlight_symbol: ">> ",
        highlight_spacing: :always
      )
      RatatuiRuby.draw(list)
      # Even with no selection, spacing column is always reserved
      assert_equal "   Item 1           ", buffer_content[0]
      assert_equal "   Item 2           ", buffer_content[1]
    end
  end

  def test_highlight_spacing_when_selected
    with_test_terminal(20, 3) do
      # With selection
      list = RatatuiRuby::List.new(
        items: ["Item 1", "Item 2"],
        selected_index: 0,
        highlight_symbol: ">> ",
        highlight_spacing: :when_selected
      )
      RatatuiRuby.draw(list)
      assert_equal ">> Item 1           ", buffer_content[0]
      assert_equal "   Item 2           ", buffer_content[1]
    end
  end

  def test_highlight_spacing_when_selected_no_selection
    with_test_terminal(20, 3) do
      # Without selection, no spacing
      list = RatatuiRuby::List.new(
        items: ["Item 1", "Item 2"],
        selected_index: nil,
        highlight_symbol: ">> ",
        highlight_spacing: :when_selected
      )
      RatatuiRuby.draw(list)
      assert_equal "Item 1              ", buffer_content[0]
      assert_equal "Item 2              ", buffer_content[1]
    end
  end

  def test_highlight_spacing_never
    with_test_terminal(20, 3) do
      list = RatatuiRuby::List.new(
        items: ["Item 1", "Item 2"],
        selected_index: 0,
        highlight_symbol: ">> ",
        highlight_spacing: :never
      )
      RatatuiRuby.draw(list)
      # With :never, no spacing column or symbol is shown
      assert_equal "Item 1              ", buffer_content[0]
      assert_equal "Item 2              ", buffer_content[1]
    end
  end
end

