# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestLineGaugeDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = LineGaugeDemoApp.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "LineGauge Widget Demo"
      assert_includes content, "Interactive Gauge"
      assert_includes content, "Inverse"
      assert_includes content, "←/→: Ratio"
      assert_includes content, "50%"
    end
  end

  def test_ratio_cycling_right
    with_test_terminal do
      inject_keys(:right, :right, :q)
      @app.run

      content = buffer_content.join("\n")
      # After 2 right presses: index 2 -> 3 -> 4 (80%)
      assert_includes content, "80%"
    end
  end

  def test_ratio_cycling_left
    with_test_terminal do
      inject_keys(:left, :q)
      @app.run

      content = buffer_content.join("\n")
      # After 1 left press: index 2 -> 1 (35%)
      assert_includes content, "35%"
    end
  end

  def test_filled_symbol_cycling
    with_test_terminal do
      inject_keys(:f, :q)
      @app.run

      content = buffer_content.join("\n")
      # Default filled_symbol_index is 0 (█), after press becomes 1 (▓)
      assert_includes content, "Dark Shade"
    end
  end

  def test_filled_color_cycling
    with_test_terminal do
      inject_keys(:c, :c, :q)
      @app.run

      content = buffer_content.join("\n")
      # Default is index 2 (Green), after 2 presses -> 4 (Blue)
      assert_includes content, "Blue"
    end
  end

  def test_unfilled_symbol_cycling
    with_test_terminal do
      inject_keys(:u, :q)
      @app.run

      content = buffer_content.join("\n")
      # Default is index 0 (Light Shade), after press becomes 1 (Dot)
      assert_includes content, "Dot"
    end
  end

  def test_unfilled_color_cycling
    with_test_terminal do
      inject_keys(:x, :q)
      @app.run

      content = buffer_content.join("\n")
      # Default is index 1 (Dark Gray), after press becomes 2 (Gray)
      assert_includes content, "Gray"
    end
  end

  def test_base_style_cycling
    with_test_terminal do
      inject_keys(:b, :q)
      @app.run

      content = buffer_content.join("\n")
      # Default is index 0 (None), after press becomes 1 (Bold White)
      assert_includes content, "Bold White"
    end
  end

  def test_quit_with_ctrl_c
    with_test_terminal do
      inject_key(:ctrl_c)
      @app.run
      # Success if returns without hanging
    end
  end

  def test_multiple_attribute_changes
    with_test_terminal do
      inject_keys(:right, :f, :c, :b, :q)
      @app.run

      content = buffer_content.join("\n")
      # Verify some of the changes took effect
      assert_includes content, "65%"  # ratio changed
      assert_includes content, "Dark Shade"  # filled_symbol changed
    end
  end
end
