# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestTableState < Minitest::Test
  include RatatuiRuby::TestHelper

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

  def test_table_state_selected_cell
    state = RatatuiRuby::TableState.new(nil)
    state.select(2)
    state.select_column(3)
    cell = state.selected_cell
    assert_equal [2, 3], cell
  end

  def test_table_state_selected_cell_returns_nil_when_incomplete
    state = RatatuiRuby::TableState.new(nil)
    assert_nil state.selected_cell

    state.select(2)
    assert_nil state.selected_cell

    state.select(nil)
    state.select_column(3)
    assert_nil state.selected_cell
  end

  def test_table_state_select_next_column
    state = RatatuiRuby::TableState.new(nil)
    state.select_column(0)
    state.select_next_column
    assert_equal 1, state.selected_column
  end

  def test_table_state_select_next_column_from_nil
    state = RatatuiRuby::TableState.new(nil)
    state.select_next_column
    assert_equal 0, state.selected_column
  end

  def test_table_state_select_previous_column
    state = RatatuiRuby::TableState.new(nil)
    state.select_column(5)
    state.select_previous_column
    assert_equal 4, state.selected_column
  end

  def test_table_state_select_previous_column_saturates_at_zero
    state = RatatuiRuby::TableState.new(nil)
    state.select_column(0)
    state.select_previous_column
    assert_equal 0, state.selected_column
  end

  def test_table_state_select_first_column
    state = RatatuiRuby::TableState.new(nil)
    state.select_column(5)
    state.select_first_column
    assert_equal 0, state.selected_column
  end

  def test_table_state_select_last_column
    state = RatatuiRuby::TableState.new(nil)
    state.select_column(0)
    state.select_last_column
    # select_last_column sets to usize::MAX, will be clamped on render
    refute_nil state.selected_column
  end

  def test_table_state_with_selected_cell
    state = RatatuiRuby::TableState.with_selected_cell([2, 3])
    assert_equal 2, state.selected
    assert_equal 3, state.selected_column
    assert_equal [2, 3], state.selected_cell
  end

  def test_table_state_with_selected_cell_nil
    state = RatatuiRuby::TableState.with_selected_cell(nil)
    assert_nil state.selected
    assert_nil state.selected_column
    assert_nil state.selected_cell
  end

  def test_table_state_select_next
    state = RatatuiRuby::TableState.new(nil)
    state.select(0)
    state.select_next
    assert_equal 1, state.selected
  end

  def test_table_state_select_previous
    state = RatatuiRuby::TableState.new(nil)
    state.select(5)
    state.select_previous
    assert_equal 4, state.selected
  end

  def test_table_state_select_first
    state = RatatuiRuby::TableState.new(nil)
    state.select(5)
    state.select_first
    assert_equal 0, state.selected
  end

  def test_table_state_select_last_sets_index_to_max_before_render
    state = RatatuiRuby::TableState.new(nil)
    state.select(0)
    state.select_last
    # Before render: huge value (usize::MAX)
    assert state.selected > 1_000_000_000
  end

  def test_table_state_select_last_clamps_to_actual_last_index_after_render
    with_test_terminal do
      state = RatatuiRuby::TableState.new(nil)
      state.select_last
      # Before render: huge value
      assert state.selected > 1_000_000_000

      table = RatatuiRuby::Widgets::Table.new(
        rows: [%w[A B C], %w[D E F], %w[G H I]],
        widths: [
          RatatuiRuby::Layout::Constraint.percentage(33),
          RatatuiRuby::Layout::Constraint.percentage(33),
          RatatuiRuby::Layout::Constraint.percentage(34),
        ]
      )
      RatatuiRuby.draw do |frame|
        frame.render_stateful_widget(table, frame.area, state)
      end

      # After render: clamped to actual last (index 2)
      assert_equal 2, state.selected
    end
  end
end
