# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestStatefulRendering < Minitest::Test
  include RatatuiRuby::TestHelper

  # === ListState Tests ===

  def test_list_state_initialization_default
    state = RatatuiRuby::ListState.new(nil)
    assert_nil state.selected
    assert_equal 0, state.offset
  end

  def test_list_state_initialization_with_selection
    state = RatatuiRuby::ListState.new(5)
    assert_equal 5, state.selected
  end

  def test_list_state_select_and_deselect
    state = RatatuiRuby::ListState.new(nil)
    state.select(3)
    assert_equal 3, state.selected
    state.select(nil)
    assert_nil state.selected
  end

  # Gap test - ListState#select_next from v1.0.0_blockers.md
  def test_list_state_select_next
    skip "v1.0.0 Blocker: ListState#select_next not implemented. See doc/contributors/v1.0.0_blockers.md"
    state = RatatuiRuby::ListState.new(nil)
    state.select(0)
    state.select_next
    assert_equal 1, state.selected
  end

  # Gap test - ListState#select_previous from v1.0.0_blockers.md
  def test_list_state_select_previous
    skip "v1.0.0 Blocker: ListState#select_previous not implemented. See doc/contributors/v1.0.0_blockers.md"
    state = RatatuiRuby::ListState.new(nil)
    state.select(5)
    state.select_previous
    assert_equal 4, state.selected
  end

  # Gap test - ListState#select_first from v1.0.0_blockers.md
  def test_list_state_select_first
    skip "v1.0.0 Blocker: ListState#select_first not implemented. See doc/contributors/v1.0.0_blockers.md"
    state = RatatuiRuby::ListState.new(nil)
    state.select(5)
    state.select_first
    assert_equal 0, state.selected
  end

  # Gap test - ListState#select_last from v1.0.0_blockers.md
  def test_list_state_select_last
    skip "v1.0.0 Blocker: ListState#select_last not implemented. See doc/contributors/v1.0.0_blockers.md"
    state = RatatuiRuby::ListState.new(nil)
    state.select(0)
    state.select_last
    # Note: select_last requires knowing total items count
    refute_nil state.selected
  end

  # === TableState Tests ===

  def test_table_state_initialization_default
    state = RatatuiRuby::TableState.new(nil)
    assert_nil state.selected
    assert_nil state.selected_column
    assert_equal 0, state.offset
  end

  def test_table_state_initialization_with_selection
    state = RatatuiRuby::TableState.new(2)
    assert_equal 2, state.selected
  end

  def test_table_state_column_selection
    state = RatatuiRuby::TableState.new(nil)
    state.select_column(1)
    assert_equal 1, state.selected_column
    state.select_column(nil)
    assert_nil state.selected_column
  end

  # Gap test - TableState#selected_cell from v1.0.0_blockers.md
  def test_table_state_selected_cell
    skip "v1.0.0 Blocker: TableState#selected_cell not implemented. See doc/contributors/v1.0.0_blockers.md"
    state = RatatuiRuby::TableState.new(nil)
    state.select(2)
    state.select_column(3)
    cell = state.selected_cell
    assert_equal [2, 3], cell
  end

  # Gap test - TableState#select_next_column from v1.0.0_blockers.md
  def test_table_state_select_next_column
    skip "v1.0.0 Blocker: TableState#select_next_column not implemented. See doc/contributors/v1.0.0_blockers.md"
    state = RatatuiRuby::TableState.new(nil)
    state.select_column(0)
    state.select_next_column
    assert_equal 1, state.selected_column
  end

  # Gap test - TableState#select_previous_column from v1.0.0_blockers.md
  def test_table_state_select_previous_column
    skip "v1.0.0 Blocker: TableState#select_previous_column not implemented. See doc/contributors/v1.0.0_blockers.md"
    state = RatatuiRuby::TableState.new(nil)
    state.select_column(5)
    state.select_previous_column
    assert_equal 4, state.selected_column
  end

  # Gap test - TableState#select_first_column from v1.0.0_blockers.md
  def test_table_state_select_first_column
    skip "v1.0.0 Blocker: TableState#select_first_column not implemented. See doc/contributors/v1.0.0_blockers.md"
    state = RatatuiRuby::TableState.new(nil)
    state.select_column(5)
    state.select_first_column
    assert_equal 0, state.selected_column
  end

  # Gap test - TableState#select_last_column from v1.0.0_blockers.md
  def test_table_state_select_last_column
    skip "v1.0.0 Blocker: TableState#select_last_column not implemented. See doc/contributors/v1.0.0_blockers.md"
    state = RatatuiRuby::TableState.new(nil)
    state.select_column(0)
    state.select_last_column
    # select_last_column needs to know column count
    refute_nil state.selected_column
  end

  # Gap test - TableState with_selected_cell from v1.0.0_blockers.md
  def test_table_state_with_selected_cell
    skip "v1.0.0 Blocker: TableState.with_selected_cell not implemented. See doc/contributors/v1.0.0_blockers.md"
    state = RatatuiRuby::TableState.with_selected_cell([2, 3])
    assert_equal 2, state.selected
    assert_equal 3, state.selected_column
  end

  # === ScrollbarState Tests ===

  def test_scrollbar_state_initialization
    state = RatatuiRuby::ScrollbarState.new(100)
    assert_equal 100, state.content_length
    assert_equal 0, state.position
  end

  def test_scrollbar_state_position_navigation
    state = RatatuiRuby::ScrollbarState.new(10)
    state.next
    assert_equal 1, state.position
    state.prev
    assert_equal 0, state.position
  end

  def test_scrollbar_state_first_and_last
    state = RatatuiRuby::ScrollbarState.new(10)
    state.position = 5
    state.first
    assert_equal 0, state.position
    state.last
    assert_equal 9, state.position
  end

  # === render_stateful_widget Tests ===

  def test_render_stateful_widget_with_list
    with_test_terminal(20, 5) do
      state = RatatuiRuby::ListState.new(nil)
      state.select(1)

      list = RatatuiRuby::Widgets::List.new(items: %w[A B C])

      RatatuiRuby.draw do |frame|
        frame.render_stateful_widget(list, frame.area, state)
      end

      # ListState selection (1) should be used, highlighting "B"
      assert_equal "  A                 ", buffer_content[0]
      assert_equal "> B                 ", buffer_content[1]
      assert_equal "  C                 ", buffer_content[2]
    end
  end

  def test_list_state_trumps_widget_selected_index
    with_test_terminal(20, 5) do
      state = RatatuiRuby::ListState.new(nil)
      state.select(2) # State says item 2

      # Widget says selected_index: 0
      list = RatatuiRuby::Widgets::List.new(items: %w[A B C], selected_index: 0)

      RatatuiRuby.draw do |frame|
        frame.render_stateful_widget(list, frame.area, state)
      end

      # State wins: item 2 should be highlighted
      assert_equal "  A                 ", buffer_content[0]
      assert_equal "  B                 ", buffer_content[1]
      assert_equal "> C                 ", buffer_content[2]
    end
  end

  def test_render_stateful_widget_with_table
    with_test_terminal(20, 5) do
      state = RatatuiRuby::TableState.new(nil)
      state.select(0)

      table = RatatuiRuby::Widgets::Table.new(
        rows: [%w[A B], %w[C D]],
        widths: [RatatuiRuby::Layout::Constraint.length(5), RatatuiRuby::Layout::Constraint.length(5)]
      )

      RatatuiRuby.draw do |frame|
        frame.render_stateful_widget(table, frame.area, state)
      end

      # Should render without error
      refute_empty buffer_content.join
    end
  end

  def test_render_stateful_widget_with_scrollbar
    with_test_terminal(5, 10) do
      state = RatatuiRuby::ScrollbarState.new(100)
      state.position = 50

      # For stateful rendering, widget still needs content_length and position,
      # but state takes precedence
      scrollbar = RatatuiRuby::Widgets::Scrollbar.new(
        content_length: 100,
        position: 0,
        orientation: :vertical_right
      )

      RatatuiRuby.draw do |frame|
        frame.render_stateful_widget(scrollbar, frame.area, state)
      end

      # Should render without error
      refute_empty buffer_content.join
    end
  end

  def test_render_stateful_widget_raises_for_unsupported_combination
    with_test_terminal(20, 5) do
      paragraph = RatatuiRuby::Widgets::Paragraph.new(text: "Hello")
      list_state = RatatuiRuby::ListState.new(nil)

      error = assert_raises(ArgumentError) do
        RatatuiRuby.draw do |frame|
          frame.render_stateful_widget(paragraph, frame.area, list_state)
        end
      end

      assert_match(%r{Unsupported widget/state combination}, error.message)
    end
  end
end
