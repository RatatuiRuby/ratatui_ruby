# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"
require_relative "../../../examples/widget_scrollbar/app"

class TestWidgetScrollbarDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetScrollbar.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_scroll_down
    with_test_terminal do
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "scroll_down", x: 0, y: 0, button: "none"))
      inject_key(:q)
      @app.run

      assert_snapshot("after_scroll_down")
      assert_rich_snapshot("after_scroll_down")
    end
  end

  def test_scroll_up
    with_test_terminal do
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "scroll_down", x: 0, y: 0, button: "none"))
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "scroll_up", x: 0, y: 0, button: "none"))
      inject_key(:q)
      @app.run

      assert_snapshot("after_scroll_up")
      assert_rich_snapshot("after_scroll_up")
    end
  end

  def test_theme_cycling
    with_test_terminal do
      inject_keys(:s, :q)
      @app.run

      assert_snapshot("after_theme_cycle")
      assert_rich_snapshot("after_theme_cycle")
    end
  end
end
