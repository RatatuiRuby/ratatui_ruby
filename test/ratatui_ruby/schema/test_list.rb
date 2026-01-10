# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestList < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_list_creation
    items = ["a", "b"]
    list = RatatuiRuby::Widgets::List.new(items:, selected_index: 1)
    assert_equal items, list.items
    assert_equal 1, list.selected_index
  end

  def test_list_defaults
    list = RatatuiRuby::Widgets::List.new
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
      list = RatatuiRuby::Widgets::List.new(items: ["Item 1", "Item 2"], selected_index: 0)
      RatatuiRuby.draw { |f| f.render_widget(list, f.area) }

      assert_equal "> Item 1            ", buffer_content[0]
      assert_equal "  Item 2            ", buffer_content[1]
    end
  end

  def test_render_with_custom_symbol
    with_test_terminal(20, 5) do
      list = RatatuiRuby::Widgets::List.new(
        items: ["Item 1", "Item 2"],
        selected_index: 1,
        highlight_symbol: ">> "
      )
      RatatuiRuby.draw { |f| f.render_widget(list, f.area) }
      assert_equal "   Item 1           ", buffer_content[0]
      assert_equal ">> Item 2           ", buffer_content[1]
    end
  end

  def test_render_bottom_to_top
    with_test_terminal(20, 3) do
      list = RatatuiRuby::Widgets::List.new(
        items: ["Item 1", "Item 2"],
        selected_index: 0,
        direction: :bottom_to_top
      )
      RatatuiRuby.draw { |f| f.render_widget(list, f.area) }
      # In BottomToTop, the first item is at the bottom
      assert_equal "  Item 2            ", buffer_content[1]
      assert_equal "> Item 1            ", buffer_content[2]
    end
  end

  def test_invalid_direction
    assert_raises(ArgumentError) {
      list = RatatuiRuby::Widgets::List.new(items: [], direction: :invalid)
      with_test_terminal(10, 10) do
        RatatuiRuby.draw { |f| f.render_widget(list, f.area) }
      end
    }
  end

  def test_highlight_spacing_always
    with_test_terminal(20, 3) do
      list = RatatuiRuby::Widgets::List.new(
        items: ["Item 1", "Item 2"],
        selected_index: nil,
        highlight_symbol: ">> ",
        highlight_spacing: :always
      )
      RatatuiRuby.draw { |f| f.render_widget(list, f.area) }
      # Even with no selection, spacing column is always reserved
      assert_equal "   Item 1           ", buffer_content[0]
      assert_equal "   Item 2           ", buffer_content[1]
    end
  end

  def test_highlight_spacing_when_selected
    with_test_terminal(20, 3) do
      # With selection
      list = RatatuiRuby::Widgets::List.new(
        items: ["Item 1", "Item 2"],
        selected_index: 0,
        highlight_symbol: ">> ",
        highlight_spacing: :when_selected
      )
      RatatuiRuby.draw { |f| f.render_widget(list, f.area) }
      assert_equal ">> Item 1           ", buffer_content[0]
      assert_equal "   Item 2           ", buffer_content[1]
    end
  end

  def test_highlight_spacing_when_selected_no_selection
    with_test_terminal(20, 3) do
      # Without selection, no spacing
      list = RatatuiRuby::Widgets::List.new(
        items: ["Item 1", "Item 2"],
        selected_index: nil,
        highlight_symbol: ">> ",
        highlight_spacing: :when_selected
      )
      RatatuiRuby.draw { |f| f.render_widget(list, f.area) }
      assert_equal "Item 1              ", buffer_content[0]
      assert_equal "Item 2              ", buffer_content[1]
    end
  end

  def test_highlight_spacing_never
    with_test_terminal(20, 3) do
      list = RatatuiRuby::Widgets::List.new(
        items: ["Item 1", "Item 2"],
        selected_index: 0,
        highlight_symbol: ">> ",
        highlight_spacing: :never
      )
      RatatuiRuby.draw { |f| f.render_widget(list, f.area) }
      # With :never, no spacing column or symbol is shown
      assert_equal "Item 1              ", buffer_content[0]
      assert_equal "Item 2              ", buffer_content[1]
    end
  end

  def test_offset_forces_scroll_position
    # 10 items, terminal height 3, offset forces viewport to start at item 5
    items = (0..9).map { |i| "Item #{i}" }
    with_test_terminal(20, 3) do
      list = RatatuiRuby::Widgets::List.new(
        items:,
        selected_index: 5,
        offset: 5
      )
      RatatuiRuby.draw { |f| f.render_widget(list, f.area) }
      # Offset 5 means first visible row shows Item 5
      assert_equal "> Item 5            ", buffer_content[0]
      assert_equal "  Item 6            ", buffer_content[1]
      assert_equal "  Item 7            ", buffer_content[2]
    end
  end

  def test_offset_nil_allows_auto_scroll
    # Without offset, Ratatui auto-scrolls to show selection
    items = (0..9).map { |i| "Item #{i}" }
    with_test_terminal(20, 3) do
      list = RatatuiRuby::Widgets::List.new(
        items:,
        selected_index: 8 # Near the end
      )
      RatatuiRuby.draw { |f| f.render_widget(list, f.area) }
      # Auto-scroll should make Item 8 visible
      content = buffer_content.join("\n")
      assert_includes content, "Item 8"
    end
  end

  def test_offset_without_selection
    # Passive scroll: no selection, just viewing items 5-7
    items = (0..9).map { |i| "Item #{i}" }
    with_test_terminal(20, 3) do
      list = RatatuiRuby::Widgets::List.new(
        items:,
        selected_index: nil,
        offset: 5
      )
      RatatuiRuby.draw { |f| f.render_widget(list, f.area) }
      # Offset 5 with no selection shows Items 5, 6, 7
      assert_equal "Item 5              ", buffer_content[0]
      assert_equal "Item 6              ", buffer_content[1]
      assert_equal "Item 7              ", buffer_content[2]
    end
  end

  def test_style_applies_to_list_area
    with_test_terminal(20, 3) do
      list = RatatuiRuby::Widgets::List.new(
        items: ["Item 1", "Item 2"],
        style: RatatuiRuby::Style::Style.new(fg: :cyan)
      )
      RatatuiRuby.draw { |f| f.render_widget(list, f.area) }

      ansi_output = render_rich_buffer
      # Cyan foreground = ANSI 36
      assert_includes ansi_output, "\e[36m", "List style should apply cyan foreground"
    end
  end

  def test_highlight_style_applies_to_selected_item
    with_test_terminal(20, 3) do
      list = RatatuiRuby::Widgets::List.new(
        items: ["Item 1", "Item 2"],
        selected_index: 0,
        highlight_style: RatatuiRuby::Style::Style.new(bg: :yellow)
      )
      RatatuiRuby.draw { |f| f.render_widget(list, f.area) }

      ansi_output = render_rich_buffer
      # Yellow background = ANSI 43
      assert_includes ansi_output, "\e[43m", "List highlight_style should apply yellow background"
    end
  end

  def test_selected_predicate
    assert RatatuiRuby::Widgets::List.new(items: ["a"], selected_index: 0).selected?
    refute RatatuiRuby::Widgets::List.new(items: ["a"]).selected?
    refute RatatuiRuby::Widgets::List.new(items: ["a"], selected_index: nil).selected?
  end

  def test_empty_predicate
    assert RatatuiRuby::Widgets::List.new(items: []).empty?
    refute RatatuiRuby::Widgets::List.new(items: ["a"]).empty?
  end

  def test_len
    # Ratatui-aligned: list.len() returns number of items
    assert_equal 0, RatatuiRuby::Widgets::List.new(items: []).len
    assert_equal 1, RatatuiRuby::Widgets::List.new(items: ["a"]).len
    assert_equal 3, RatatuiRuby::Widgets::List.new(items: %w[a b c]).len
  end

  def test_length_and_size_aliases
    # Ruby-idiomatic aliases for len
    list = RatatuiRuby::Widgets::List.new(items: %w[a b c])
    assert_equal list.len, list.length
    assert_equal list.len, list.size
  end

  def test_highlight_spacing_constants
    assert_equal :always, RatatuiRuby::Widgets::List::HIGHLIGHT_ALWAYS
    assert_equal :when_selected, RatatuiRuby::Widgets::List::HIGHLIGHT_WHEN_SELECTED
    assert_equal :never, RatatuiRuby::Widgets::List::HIGHLIGHT_NEVER
  end

  def test_direction_constants
    assert_equal :top_to_bottom, RatatuiRuby::Widgets::List::DIRECTION_TOP_TO_BOTTOM
    assert_equal :bottom_to_top, RatatuiRuby::Widgets::List::DIRECTION_BOTTOM_TO_TOP
  end
end
