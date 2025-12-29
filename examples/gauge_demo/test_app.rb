# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestGaugeDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = GaugeDemoApp.new
  end

  def test_initial_render
    with_test_terminal(80, 24) do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Interactive Gauge"
      assert_includes content, "Inverse"
      assert_includes content, "Min Threshold"
    end
  end

  def test_ratio_increment
    with_test_terminal(80, 24) do
      inject_key(:right)
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # After pressing right from index 3 (0.65), should be at index 4 (0.80)
      assert_includes content, "0.80"
    end
  end

  def test_ratio_decrement
    with_test_terminal(80, 24) do
      inject_key(:left)
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # After pressing left from index 3 (0.65), should be at index 2 (0.50)
      assert_includes content, "0.50"
    end
  end

  def test_gauge_color_cycling
    with_test_terminal(80, 24) do
      inject_key(:g)
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # After pressing g from index 0 (Green), should be at index 1 (Yellow)
      assert_includes content, "Yellow"
      refute_includes content, "Green"
    end
  end

  def test_background_style_cycling
    with_test_terminal(80, 24) do
      inject_key(:b)
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # After pressing b from index 1 (Dark Gray BG), should be at index 2 (White on Black)
      assert_includes content, "White on Black"
      refute_includes content, "Dark Gray BG"
    end
  end

  def test_unicode_toggle
    with_test_terminal(80, 24) do
      inject_key(:u)
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # After toggling unicode, should still show gauge controls
      assert_includes content, "Off"
    end
  end

  def test_label_mode_cycling
    with_test_terminal(80, 24) do
      inject_key(:l)
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # After pressing l from index 0 (Percentage), should be at index 1 (Ratio decimal)
      # The gauge should show decimal format instead of percentage
      assert_includes content, "0.65"
    end
  end

  def test_multiple_interactions
    with_test_terminal(80, 24) do
      inject_keys(:right, :g, :b, :u, :l, :q)
      @app.run

      content = buffer_content.join("\n")
      # Verify all controls are visible
      assert_includes content, "Adjust Ratio"
      assert_includes content, "Color"
      assert_includes content, "Background"
      assert_includes content, "Unicode"
      assert_includes content, "Label"
    end
  end
end
