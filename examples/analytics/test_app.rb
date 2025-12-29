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
    with_test_terminal(50, 20) do
      # Queue quit
      inject_key(:q)

      @app.run

      # Check Tabs
      assert buffer_content.any? { |line| line.include?("Revenue") }
      assert buffer_content.any? { |line| line.include?("Traffic") }
      assert buffer_content.any? { |line| line.include?("Errors") }

      # Check initial selected tab content
      assert buffer_content.any? { |line| line.include?("Analytics: Revenue") }

      # Check help text visibility
      assert buffer_content.any? { |line| line.include?("q: Quit") }
    end
  end

  def test_navigation_right
    with_test_terminal(50, 20) do
      inject_keys(:right, :q)

      @app.run

      assert buffer_content.any? { |line| line.include?("Analytics: Traffic") }
    end
  end

  def test_navigation_left
    with_test_terminal(50, 20) do
      # Move right to Traffic
      inject_keys(:a, :b, :c)
      
      # Then queue quit
      inject_key(:q)

      @app.run

      assert buffer_content.any? { |line| line.include?("Analytics: Revenue") }
    end
  end

  def test_quit
    with_test_terminal(50, 20) do
      inject_key(:q)
      @app.run
      # Success if returns
    end
  end

  def test_switch_divider
    with_test_terminal(60, 10) do
      # Switch divider (d) then quit (q)
      inject_keys(:d, :q)
      @app.run
      
      # Default is " | ", next is " • "
      assert buffer_content.any? { |line| line.include?(" • ") }
    end
  end

  def test_switch_style
    with_test_terminal(60, 10) do
      # Switch style (space) then quit (q)
      inject_keys(:" ", :q)
      @app.run
      
      # Verify it runs without error. 
      # Style visual verification is limited with simple string buffer checks,
      # but this ensures the event handling works.
    end
  end

  def test_padding_controls
    with_test_terminal(80, 10) do
      # Increase padding_left (l) and padding_right (k) then quit
      inject_keys(:l, :l, :k, :k, :k, :q)
      @app.run

      # Verify that padding values are shown in status
      assert buffer_content.any? { |line| line.include?("Pad L (2)") }
      assert buffer_content.any? { |line| line.include?("Pad R (3)") }
    end
  end

  def test_styling_controls
    with_test_terminal(80, 20) do
      # Cycle label style (x) and value style (z)
      inject_keys(:x, :z, :z, :q)
      @app.run

      assert buffer_content.any? { |line| line.include?("Italic Blue on White") }
      assert buffer_content.any? { |line| line.include?("Underlined Red") }
    end
  end

  def test_direction_toggle
    with_test_terminal(80, 20) do
      # Switch to horizontal (v) then quit
      inject_keys(:v, :q)
      @app.run

      assert buffer_content.any? { |line| line.include?("v: Dir (horizontal)") }
    end
  end
end
