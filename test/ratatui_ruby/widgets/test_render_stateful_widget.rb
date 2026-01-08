# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestRenderStatefulWidget < Minitest::Test
  include RatatuiRuby::TestHelper

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
