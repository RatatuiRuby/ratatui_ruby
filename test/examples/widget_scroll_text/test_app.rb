# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "minitest/autorun"
require "ratatui_ruby/test_helper"
require_relative "../../../examples/widget_scroll_text/app"

class TestWidgetScrollText < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetScrollText.new
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
      inject_keys(:down, :q)
      @app.run

      assert_snapshot("after_scroll_down")
      assert_rich_snapshot("after_scroll_down")
    end
  end

  def test_scroll_right
    with_test_terminal do
      inject_keys(:right, :q)
      @app.run

      assert_snapshot("after_scroll_right")
      assert_rich_snapshot("after_scroll_right")
    end
  end

  def test_scroll_left_at_edge
    with_test_terminal do
      inject_keys(:left, :q)
      @app.run

      assert_snapshot("after_scroll_left_edge")
      assert_rich_snapshot("after_scroll_left_edge")
    end
  end

  def test_scroll_up_at_top
    with_test_terminal do
      inject_keys(:up, :q)
      @app.run

      assert_snapshot("after_scroll_up_top")
      assert_rich_snapshot("after_scroll_up_top")
    end
  end

  def test_multiple_scrolls
    with_test_terminal do
      inject_keys(:down, :down, :right, :right, :right, :q)
      @app.run

      assert_snapshot("after_multiple_scrolls")
      assert_rich_snapshot("after_multiple_scrolls")
    end
  end
end
