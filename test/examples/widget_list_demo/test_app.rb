# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_list_demo/app"

class TestWidgetListDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetListDemo.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_navigate_down
    with_test_terminal do
      inject_keys(:down, :q)
      @app.run

      assert_snapshot("after_navigate_down")
      assert_rich_snapshot("after_navigate_down")
    end
  end

  def test_navigate_up_wraps
    with_test_terminal do
      inject_keys(:up, :q)
      @app.run

      assert_snapshot("after_navigate_up_wrap")
      assert_rich_snapshot("after_navigate_up_wrap")
    end
  end

  def test_toggle_selection
    with_test_terminal do
      inject_keys(:x, :q)
      @app.run

      assert_snapshot("after_toggle_selection")
      assert_rich_snapshot("after_toggle_selection")
    end
  end

  def test_cycle_item_set
    with_test_terminal do
      inject_keys(:i, :q)
      @app.run

      assert_snapshot("after_item_set_cycle")
      assert_rich_snapshot("after_item_set_cycle")
    end
  end

  def test_cycle_highlight_style
    with_test_terminal do
      inject_keys(:h, :q)
      @app.run

      assert_snapshot("after_highlight_style_cycle")
      assert_rich_snapshot("after_highlight_style_cycle")
    end
  end

  def test_cycle_highlight_symbol
    with_test_terminal do
      inject_keys(:x, :y, :q)
      @app.run

      assert_snapshot("after_highlight_symbol_cycle")
      assert_rich_snapshot("after_highlight_symbol_cycle")
    end
  end

  def test_cycle_direction
    with_test_terminal do
      inject_keys(:d, :q)
      @app.run

      assert_snapshot("after_direction_cycle")
      assert_rich_snapshot("after_direction_cycle")
    end
  end

  def test_cycle_spacing
    with_test_terminal do
      inject_keys(:s, :q)
      @app.run

      assert_snapshot("after_spacing_cycle")
      assert_rich_snapshot("after_spacing_cycle")
    end
  end

  def test_cycle_base_style
    with_test_terminal do
      inject_keys(:b, :q)
      @app.run

      assert_snapshot("after_base_style_cycle")
      assert_rich_snapshot("after_base_style_cycle")
    end
  end

  def test_cycle_repeat_symbol
    with_test_terminal do
      inject_keys(:r, :q)
      @app.run

      assert_snapshot("after_repeat_symbol_cycle")
      assert_rich_snapshot("after_repeat_symbol_cycle")
    end
  end

  def test_cycle_scroll_padding
    with_test_terminal do
      inject_keys(:p, :q)
      @app.run

      assert_snapshot("after_scroll_padding_cycle")
      assert_rich_snapshot("after_scroll_padding_cycle")
    end
  end

  def test_cycle_offset_mode
    with_test_terminal do
      inject_keys(:o, :q)
      @app.run

      assert_snapshot("after_offset_mode_cycle")
      assert_rich_snapshot("after_offset_mode_cycle")
    end
  end

  def test_multiple_navigation_and_options
    with_test_terminal do
      inject_keys(:down, :h, :down, :y, :up, :b, :q)
      @app.run

      assert_snapshot("after_multiple_interactions")
      assert_rich_snapshot("after_multiple_interactions")
    end
  end
end
