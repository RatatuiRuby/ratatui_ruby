# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_barchart/app"

class TestWidgetBarchartDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetBarchart.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_data_cycling
    with_test_terminal do
      inject_keys(:d, :q)
      @app.run

      assert_snapshot("after_data_cycle")
      assert_rich_snapshot("after_data_cycle")
    end
  end

  def test_direction_toggle
    with_test_terminal do
      inject_keys(:v, :q)
      @app.run

      assert_snapshot("after_direction_toggle")
      assert_rich_snapshot("after_direction_toggle")
    end
  end

  def test_width_gap_controls
    with_test_terminal do
      inject_keys(:w, :a, :g, :q)
      @app.run

      assert_snapshot("after_width_gap_changes")
      assert_rich_snapshot("after_width_gap_changes")
    end
  end

  def test_styles_controls
    with_test_terminal do
      inject_keys(:s, :x, :z, :b, :q)
      @app.run

      assert_snapshot("after_style_changes")
      assert_rich_snapshot("after_style_changes")
    end
  end

  def test_mode_toggle
    with_test_terminal do
      inject_keys(:m, :q)
      @app.run

      assert_snapshot("after_mode_toggle")
      assert_rich_snapshot("after_mode_toggle")
    end
  end
end
