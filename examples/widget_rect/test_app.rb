# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestWidgetRect < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetRect.new
  end

  def test_initial_render_shows_menu_and_content
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Menu"
      assert_includes content, "Dashboard"
      assert_includes content, "Analytics"
      assert_includes content, "Content"
      assert_includes content, "Active View: Dashboard"
      assert_includes content, "Rect Attributes"
    end
  end

  def test_sidebar_click_shows_contains_result
    with_test_terminal do
      inject_click(x: 5, y: 2)
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "sidebar.contains?"
      assert_includes content, "=true"
    end
  end

  def test_content_area_click_shows_contains_result
    with_test_terminal do
      inject_click(x: 40, y: 5)
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "content.contains?"
      assert_includes content, "=true"
    end
  end

  def test_keyboard_navigation_down
    with_test_terminal do
      inject_key("down")
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Active View: Analytics"
    end
  end

  def test_keyboard_navigation_up_wraps
    with_test_terminal do
      inject_key("up")
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Active View: Help"
    end
  end

  def test_sidebar_width_shrink_updates_rect
    with_test_terminal do
      inject_key("left")
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "width:18"
      assert_includes content, "sidebar_width=18"
    end
  end

  def test_sidebar_width_expand_updates_rect
    with_test_terminal do
      inject_key("right")
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "width:22"
      assert_includes content, "sidebar_width=22"
    end
  end

  def test_rect_attributes_displayed
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Rect(x:"
      assert_includes content, "y:"
      assert_includes content, "width:"
      assert_includes content, "height:"
    end
  end

  def test_controls_area_click
    with_test_terminal do
      inject_click(x: 40, y: 20)
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "controls.contains?"
    end
  end
end
