# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_chart/app"

class TestChartDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    # Seed random for deterministic scatter plot data
    ENV["RATA_SEED"] = "42"
    @app = WidgetChart.new
  end

  def teardown
    ENV.delete("RATA_SEED")
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_marker_cycling
    with_test_terminal do
      inject_keys("m", :q)
      @app.run

      assert_snapshot("after_marker_cycle")
      assert_rich_snapshot("after_marker_cycle")
    end
  end

  def test_style_cycling
    with_test_terminal do
      inject_keys("s", :q)
      @app.run

      assert_snapshot("after_style_cycle")
      assert_rich_snapshot("after_style_cycle")
    end
  end

  def test_x_alignment_cycling
    with_test_terminal do
      inject_keys("x", :q)
      @app.run

      assert_snapshot("after_x_align_cycle")
      assert_rich_snapshot("after_x_align_cycle")
    end
  end

  def test_y_alignment_cycling
    with_test_terminal do
      inject_keys("y", :q)
      @app.run

      assert_snapshot("after_y_align_cycle")
      assert_rich_snapshot("after_y_align_cycle")
    end
  end

  def test_multiple_cycles
    with_test_terminal do
      inject_keys("m", "s", "x", "y", :q)
      @app.run

      assert_snapshot("after_multiple_cycles")
      assert_rich_snapshot("after_multiple_cycles")
    end
  end
end
