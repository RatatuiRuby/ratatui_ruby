# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestListState < Minitest::Test
  include RatatuiRuby::TestHelper

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

  def test_select_next_increments_selected_index
    state = RatatuiRuby::ListState.new(nil)
    state.select(0)
    state.select_next
    assert_equal 1, state.selected
  end

  def test_select_next_selects_first_item_when_nothing_selected
    state = RatatuiRuby::ListState.new(nil)
    assert_nil state.selected
    state.select_next
    assert_equal 0, state.selected
  end

  def test_select_next_increments_past_any_bounds_before_render
    state = RatatuiRuby::ListState.new(nil)
    state.select(100)
    state.select_next
    assert_equal 101, state.selected
  end

  def test_select_previous_decrements_selected_index
    state = RatatuiRuby::ListState.new(nil)
    state.select(5)
    state.select_previous
    assert_equal 4, state.selected
  end

  def test_select_previous_selects_max_index_when_nothing_selected
    state = RatatuiRuby::ListState.new(nil)
    assert_nil state.selected
    state.select_previous
    assert state.selected > 1_000_000_000
  end

  def test_select_previous_stays_at_zero_when_at_zero
    state = RatatuiRuby::ListState.new(nil)
    state.select(0)
    state.select_previous
    assert_equal 0, state.selected
  end

  def test_select_first_sets_index_to_zero
    state = RatatuiRuby::ListState.new(nil)
    state.select(5)
    state.select_first
    assert_equal 0, state.selected
  end

  def test_select_first_sets_index_to_zero_when_nothing_selected
    state = RatatuiRuby::ListState.new(nil)
    state.select(nil)
    state.select_first
    assert_equal 0, state.selected
  end

  def test_select_last_sets_index_to_max_before_render
    state = RatatuiRuby::ListState.new(nil)
    state.select(0)
    state.select_last
    assert state.selected > 1_000_000_000
  end

  def test_select_last_clamps_to_actual_last_index_after_render
    with_test_terminal do
      state = RatatuiRuby::ListState.new(nil)
      state.select_last
      # Before render: huge value
      assert state.selected > 1_000_000_000

      list = RatatuiRuby::Widgets::List.new(items: %w[A B C])
      RatatuiRuby.draw do |frame|
        frame.render_stateful_widget(list, frame.area, state)
      end

      # After render: clamped to actual last (index 2)
      assert_equal 2, state.selected
    end
  end

  def test_select_next_past_bounds_clamps_to_last_after_render
    with_test_terminal do
      state = RatatuiRuby::ListState.new(nil)
      state.select(100)
      assert_equal 100, state.selected

      list = RatatuiRuby::Widgets::List.new(items: %w[A B C])
      RatatuiRuby.draw do |frame|
        frame.render_stateful_widget(list, frame.area, state)
      end

      # After render: clamped to actual last (index 2)
      assert_equal 2, state.selected
    end
  end

  def test_select_previous_from_nil_clamps_to_last_after_render
    with_test_terminal do
      state = RatatuiRuby::ListState.new(nil)
      state.select_previous
      # Before render: huge value
      assert state.selected > 1_000_000_000

      list = RatatuiRuby::Widgets::List.new(items: %w[A B C])
      RatatuiRuby.draw do |frame|
        frame.render_stateful_widget(list, frame.area, state)
      end

      # After render: clamped to actual last (index 2)
      assert_equal 2, state.selected
    end
  end
end
