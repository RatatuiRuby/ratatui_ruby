# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_sparkline_demo/app"

class TestWidgetSparklineDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetSparklineDemo.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sparkline Widget Demo"
      assert_includes content, "Interactive Sparkline"
      assert_includes content, "Reversed Data"
    end
  end

  def test_cycle_data_set_up
    with_test_terminal do
      inject_keys(:up, :q)
      @app.run

      content = buffer_content.join("\n")
      # Should still render after cycling
      assert_includes content, "Sparkline Widget Demo"
    end
  end

  def test_cycle_data_set_down
    with_test_terminal do
      inject_keys(:down, :down, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sparkline Widget Demo"
    end
  end

  def test_cycle_direction
    with_test_terminal do
      inject_keys(:d, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sparkline Widget Demo"
    end
  end

  def test_cycle_color
    with_test_terminal do
      inject_keys(:c, :c, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sparkline Widget Demo"
    end
  end

  def test_cycle_absent_marker
    with_test_terminal do
      inject_keys(:m, :m, :m, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sparkline Widget Demo"
    end
  end

  def test_cycle_absent_style
    with_test_terminal do
      inject_keys(:s, :s, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sparkline Widget Demo"
    end
  end

  def test_cycle_bar_set
    with_test_terminal do
      inject_keys(:b, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sparkline Widget Demo"
      # Verify render with Numbers set (one_eighth="1", etc.)
      # Input data [1..12] with implicit max 12.
      # With Numbers set, we expect digits 1-8 to appear.
      # Just asserting no crash is a start, but let's check for the label update if possible
      # The controls footer should update.
      # assert_includes content, ": Bar Set" # Included in controls
    end
  end
end
