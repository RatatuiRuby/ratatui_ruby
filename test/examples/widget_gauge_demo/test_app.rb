# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_gauge_demo/app"

class TestGaugeDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetGaugeDemo.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_ratio_increment
    with_test_terminal do
      inject_keys(:right, :q)
      @app.run

      assert_snapshot("after_ratio_increment")
      assert_rich_snapshot("after_ratio_increment")
    end
  end

  def test_ratio_decrement
    with_test_terminal do
      inject_keys(:left, :q)
      @app.run

      assert_snapshot("after_ratio_decrement")
      assert_rich_snapshot("after_ratio_decrement")
    end
  end

  def test_gauge_color_cycling
    with_test_terminal do
      inject_keys(:g, :q)
      @app.run

      assert_snapshot("after_color_cycle")
      assert_rich_snapshot("after_color_cycle")
    end
  end

  def test_background_style_cycling
    with_test_terminal do
      inject_keys(:b, :q)
      @app.run

      assert_snapshot("after_background_cycle")
      assert_rich_snapshot("after_background_cycle")
    end
  end

  def test_unicode_toggle
    with_test_terminal do
      inject_keys(:u, :q)
      @app.run

      assert_snapshot("after_unicode_toggle")
      assert_rich_snapshot("after_unicode_toggle")
    end
  end

  def test_label_mode_cycling
    with_test_terminal do
      inject_keys(:l, :q)
      @app.run

      assert_snapshot("after_label_cycle")
      assert_rich_snapshot("after_label_cycle")
    end
  end

  def test_multiple_interactions
    with_test_terminal do
      inject_keys(:right, :g, :b, :u, :l, :q)
      @app.run

      assert_snapshot("after_multiple_interactions")
      assert_rich_snapshot("after_multiple_interactions")
    end
  end
end
