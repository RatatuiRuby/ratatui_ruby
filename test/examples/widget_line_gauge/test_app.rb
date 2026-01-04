# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_line_gauge/app"

class TestLineGaugeDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetLineGauge.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_ratio_cycling_right
    with_test_terminal do
      inject_keys(:right, :right, :q)
      @app.run

      assert_snapshot("after_ratio_right")
      assert_rich_snapshot("after_ratio_right")
    end
  end

  def test_ratio_cycling_left
    with_test_terminal do
      inject_keys(:left, :q)
      @app.run

      assert_snapshot("after_ratio_left")
      assert_rich_snapshot("after_ratio_left")
    end
  end

  def test_filled_symbol_cycling
    with_test_terminal do
      inject_keys(:f, :q)
      @app.run

      assert_snapshot("after_filled_symbol_cycle")
      assert_rich_snapshot("after_filled_symbol_cycle")
    end
  end

  def test_filled_color_cycling
    with_test_terminal do
      inject_keys(:c, :c, :q)
      @app.run

      assert_snapshot("after_filled_color_cycle")
      assert_rich_snapshot("after_filled_color_cycle")
    end
  end

  def test_unfilled_symbol_cycling
    with_test_terminal do
      inject_keys(:u, :q)
      @app.run

      assert_snapshot("after_unfilled_symbol_cycle")
      assert_rich_snapshot("after_unfilled_symbol_cycle")
    end
  end

  def test_unfilled_color_cycling
    with_test_terminal do
      inject_keys(:x, :q)
      @app.run

      assert_snapshot("after_unfilled_color_cycle")
      assert_rich_snapshot("after_unfilled_color_cycle")
    end
  end

  def test_base_style_cycling
    with_test_terminal do
      inject_keys(:b, :q)
      @app.run

      assert_snapshot("after_base_style_cycle")
      assert_rich_snapshot("after_base_style_cycle")
    end
  end

  def test_multiple_attribute_changes
    with_test_terminal do
      inject_keys(:right, :f, :c, :b, :q)
      @app.run

      assert_snapshot("after_multiple_changes")
      assert_rich_snapshot("after_multiple_changes")
    end
  end
end
