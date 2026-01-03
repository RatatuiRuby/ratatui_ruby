# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_text_width/app"

class TestWidgetTextWidth < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetTextWidth.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_navigation_up
    with_test_terminal do
      inject_keys(:up, :q)
      @app.run

      assert_snapshot("after_nav_up")
      assert_rich_snapshot("after_nav_up")
    end
  end

  def test_navigation_down
    with_test_terminal do
      inject_keys(:down, :q)
      @app.run

      assert_snapshot("after_nav_down")
      assert_rich_snapshot("after_nav_down")
    end
  end

  def test_cjk_sample
    with_test_terminal do
      inject_keys(:down, :q)
      @app.run

      assert_snapshot("cjk_sample")
      assert_rich_snapshot("cjk_sample")
    end
  end

  def test_mixed_sample
    with_test_terminal do
      inject_keys(:down, :down, :down, :q)
      @app.run

      assert_snapshot("mixed_sample")
      assert_rich_snapshot("mixed_sample")
    end
  end
end
