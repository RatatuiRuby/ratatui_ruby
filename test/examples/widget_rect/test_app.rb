# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_rect/app"

class TestWidgetRect < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetRect.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_sidebar_click
    with_test_terminal do
      inject_click(x: 5, y: 2)
      inject_key(:q)
      @app.run

      assert_snapshot("after_sidebar_click")
      assert_rich_snapshot("after_sidebar_click")
    end
  end

  def test_content_area_click
    with_test_terminal do
      inject_click(x: 40, y: 5)
      inject_key(:q)
      @app.run

      assert_snapshot("after_content_click")
      assert_rich_snapshot("after_content_click")
    end
  end

  def test_keyboard_navigation_down
    with_test_terminal do
      inject_keys("down", :q)
      @app.run

      assert_snapshot("after_nav_down")
      assert_rich_snapshot("after_nav_down")
    end
  end

  def test_keyboard_navigation_up_wraps
    with_test_terminal do
      inject_keys("up", :q)
      @app.run

      assert_snapshot("after_nav_up_wrap")
      assert_rich_snapshot("after_nav_up_wrap")
    end
  end

  def test_sidebar_width_shrink
    with_test_terminal do
      inject_keys("left", :q)
      @app.run

      assert_snapshot("after_width_shrink")
      assert_rich_snapshot("after_width_shrink")
    end
  end

  def test_sidebar_width_expand
    with_test_terminal do
      inject_keys("right", :q)
      @app.run

      assert_snapshot("after_width_expand")
      assert_rich_snapshot("after_width_expand")
    end
  end
end
