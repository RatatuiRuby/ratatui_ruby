# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_table/app"

class TestWidgetTableDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetTable.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_style_switching
    with_test_terminal do
      inject_keys(:s, :q)
      @app.run

      assert_snapshot("after_style_switch")
      assert_rich_snapshot("after_style_switch")
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

  def test_navigation_down
    with_test_terminal do
      inject_keys(:down, :q)
      @app.run

      assert_snapshot("after_navigate_down")
      assert_rich_snapshot("after_navigate_down")
    end
  end

  def test_navigation_up_wrap
    with_test_terminal do
      inject_keys(:up, :up, :q)
      @app.run

      assert_snapshot("after_navigate_up_wrap")
      assert_rich_snapshot("after_navigate_up_wrap")
    end
  end

  def test_column_navigation
    with_test_terminal do
      inject_keys(:right, :q)
      @app.run

      assert_snapshot("after_column_navigate")
      assert_rich_snapshot("after_column_navigate")
    end
  end

  def test_highlight_spacing
    with_test_terminal do
      inject_keys(:p, :q)
      @app.run

      assert_snapshot("after_spacing_cycle")
      assert_rich_snapshot("after_spacing_cycle")
    end
  end

  def test_column_spacing_increase
    with_test_terminal do
      inject_keys("+", :q)
      @app.run

      assert_snapshot("after_col_space_increase")
      assert_rich_snapshot("after_col_space_increase")
    end
  end

  def test_offset_mode_cycle
    with_test_terminal do
      inject_keys(:o, :q)
      @app.run

      assert_snapshot("after_offset_mode_cycle")
      assert_rich_snapshot("after_offset_mode_cycle")
    end
  end
end
