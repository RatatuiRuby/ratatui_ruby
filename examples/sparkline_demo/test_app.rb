# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestSparklineDemoApp < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = SparklineDemoApp.new
  end

  def test_initial_render
    with_test_terminal(80, 24) do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sparkline Widget Demo"
      assert_includes content, "Interactive Sparkline"
      assert_includes content, "Reversed Data"
    end
  end

  def test_cycle_data_set_up
    with_test_terminal(80, 24) do
      inject_keys(:up, :q)
      @app.run

      content = buffer_content.join("\n")
      # Should still render after cycling
      assert_includes content, "Sparkline Widget Demo"
    end
  end

  def test_cycle_data_set_down
    with_test_terminal(80, 24) do
      inject_keys(:down, :down, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sparkline Widget Demo"
    end
  end

  def test_cycle_direction
    with_test_terminal(80, 24) do
      inject_keys(:d, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sparkline Widget Demo"
    end
  end

  def test_cycle_color
    with_test_terminal(80, 24) do
      inject_keys(:c, :c, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sparkline Widget Demo"
    end
  end

  def test_cycle_absent_marker
    with_test_terminal(80, 24) do
      inject_keys(:m, :m, :m, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sparkline Widget Demo"
    end
  end

  def test_cycle_absent_style
    with_test_terminal(80, 24) do
      inject_keys(:s, :s, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sparkline Widget Demo"
    end
  end
end
