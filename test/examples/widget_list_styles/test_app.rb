# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_list_styles/app"

class TestListStylesExample < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetListStyles.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
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

  def test_navigation
    with_test_terminal do
      inject_keys(:down, :down, :q)
      @app.run

      assert_snapshot("after_navigation")
      assert_rich_snapshot("after_navigation")
    end
  end

  def test_highlight_spacing_always
    with_test_terminal do
      inject_keys(:s, :q)
      @app.run

      assert_snapshot("after_spacing_always")
      assert_rich_snapshot("after_spacing_always")
    end
  end

  def test_highlight_spacing_never
    with_test_terminal do
      inject_keys(:s, :s, :q)
      @app.run

      assert_snapshot("after_spacing_never")
      assert_rich_snapshot("after_spacing_never")
    end
  end

  def test_direction_cycling
    with_test_terminal do
      inject_keys(:d, :q)
      @app.run

      assert_snapshot("after_direction_cycle")
      assert_rich_snapshot("after_direction_cycle")
    end
  end

  def test_repeat_symbol_toggle
    with_test_terminal do
      inject_keys(:r, :q)
      @app.run

      assert_snapshot("after_repeat_toggle")
      assert_rich_snapshot("after_repeat_toggle")
    end
  end
end
