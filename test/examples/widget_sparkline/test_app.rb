# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_sparkline/app"

class TestWidgetSparklineDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetSparkline.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_cycle_data_set
    with_test_terminal do
      inject_keys(:up, :q)
      @app.run

      assert_snapshot("after_data_cycle_up")
      assert_rich_snapshot("after_data_cycle_up")
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

  def test_cycle_color
    with_test_terminal do
      inject_keys(:c, :c, :q)
      @app.run

      assert_snapshot("after_color_cycle")
      assert_rich_snapshot("after_color_cycle")
    end
  end

  def test_cycle_absent_marker
    with_test_terminal do
      inject_keys(:m, :m, :m, :q)
      @app.run

      assert_snapshot("after_marker_cycle")
      assert_rich_snapshot("after_marker_cycle")
    end
  end

  def test_cycle_absent_style
    with_test_terminal do
      inject_keys(:s, :s, :q)
      @app.run

      assert_snapshot("after_style_cycle")
      assert_rich_snapshot("after_style_cycle")
    end
  end

  def test_cycle_bar_set
    with_test_terminal do
      inject_keys(:b, :q)
      @app.run

      assert_snapshot("after_bar_set_cycle")
      assert_rich_snapshot("after_bar_set_cycle")
    end
  end
end
