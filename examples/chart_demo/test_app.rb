# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestChartDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = ChartDemoApp.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Chart Widget Demo"
      assert_includes content, "Time"
      assert_includes content, "Amplitude"
      assert_includes content, "Line"
      assert_includes content, "Scatter"
      assert_includes content, "Controls"
      # Verify controls are visible
      assert_includes content, "Marker"
      assert_includes content, "Style"
      assert_includes content, "Align"
    end
  end

  def test_marker_cycling
    with_test_terminal do
      inject_key("m") # Cycle marker
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # Should show the chart still renders
      assert_includes content, "Chart Widget Demo"
      assert_includes content, "Time"
    end
  end

  def test_style_cycling
    with_test_terminal do
      inject_key("s")  # Cycle style
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Chart Widget Demo"
      assert_includes content, "Time"
    end
  end

  def test_x_alignment_cycling
    with_test_terminal do
      inject_key("x")  # Cycle X-axis label alignment
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Chart Widget Demo"
      assert_includes content, "Time"
    end
  end

  def test_y_alignment_cycling
    with_test_terminal do
      inject_key("y")  # Cycle Y-axis label alignment
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Chart Widget Demo"
      assert_includes content, "Amplitude"
    end
  end

  def test_multiple_cycles
    with_test_terminal do
      inject_key("m")
      inject_key("s")
      inject_key("x")
      inject_key("y")
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Chart Widget Demo"
      # Chart and controls should all render
      assert_includes content, "Controls"
    end
  end
end
