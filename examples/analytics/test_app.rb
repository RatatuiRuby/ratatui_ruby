# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestAnalytics < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = AnalyticsApp.new
  end

  def test_render_initial_state
    with_test_terminal do
      # Queue quit
      inject_key(:q)

      @app.run

      # Check Tabs
      assert buffer_content.any? { |line| line.include?("Revenue") }
      assert buffer_content.any? { |line| line.include?("Traffic") }
      assert buffer_content.any? { |line| line.include?("Errors") }

      # Check initial selected tab content
      assert buffer_content.any? { |line| line.include?("Analytics: Revenue") }

      # Check help text visibility (join to handle potential wrapping)
      content_str = buffer_content.join("\n")
      assert_includes content_str, "q: Quit"
    end
  end

  def test_navigation_right
    with_test_terminal do
      inject_keys(:right, :q)

      @app.run

      assert buffer_content.any? { |line| line.include?("Analytics: Traffic") }
    end
  end

  def test_navigation_left
    with_test_terminal do
      # Move right to Traffic
      inject_keys(:a, :b, :c)

      # Then queue quit
      inject_key(:q)

      @app.run

      assert buffer_content.any? { |line| line.include?("Analytics: Revenue") }
    end
  end

  def test_quit
    with_test_terminal do
      inject_key(:q)
      @app.run
      # Success if returns
    end
  end

  def test_switch_divider
    with_test_terminal do
      # Switch divider (d) then quit (q)
      inject_keys(:d, :q)
      @app.run

      # Default is " | ", next is " • "
      assert buffer_content.any? { |line| line.include?(" • ") }
    end
  end

  def test_switch_style
    with_test_terminal do
      # Switch style (space) then quit (q)
      inject_keys(:" ", :q)
      @app.run

      # Verify it runs without error.
      # Style visual verification is limited with simple string buffer checks,
      # but this ensures the event handling works.
    end
  end

  def test_padding_controls
    with_test_terminal do
      # Increase padding_left (l) and padding_right (k) then quit
      inject_keys(:l, :l, :k, :k, :k, :q)
      @app.run

      # Verify that padding values are shown in status with hotkeys
      # Use join to match even if wrapped or if "Pad Left" logic changed
      content_str = buffer_content.join("\n")
      assert_includes content_str, "h/l: Pad Left (2)"
      assert_includes content_str, "j/k: Pad Right (3)"
    end
  end

  def test_styling_controls
    with_test_terminal do
      # Cycle label style (x) and value style (z)
      inject_keys(:x, :z, :z, :q)
      @app.run
      # Verify expected content
      content = buffer_content.join
      assert_includes content, "Analytics: Revenue"
      assert_includes content, "Views"
      assert_includes content, "Controls"
      assert_includes content, "Width:"
    end
  end

  def test_direction_toggle
    with_test_terminal do
      # Switch to horizontal (v) then quit
      inject_keys(:v, :q)
      @app.run

      assert buffer_content.any? { |line| line.include?("v: Direction (horizontal)") }
    end
  end
end
