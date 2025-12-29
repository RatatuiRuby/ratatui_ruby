# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestHitTestExample < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = HitTestApp.new
  end

  def test_initial_render_shows_both_panels
    with_test_terminal(80, 24) do
      inject_key(:q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Left Panel") }
      assert content.any? { |line| line.include?("Right Panel") }
    end
  end

  def test_left_panel_click
    with_test_terminal(80, 24) do
      # Click in left half at x=10, then quit
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 10, y: 12))
      inject_key(:q)

      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Left Panel clicked") }
    end
  end

  def test_right_panel_click
    with_test_terminal(80, 24) do
      # Click in right half at x=50, then quit
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 50, y: 12))
      inject_key(:q)

      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Right Panel clicked") }
    end
  end

  def test_ratio_change_decreases_left
    with_test_terminal(80, 24) do
      # Shrink left panel using left arrow
      inject_keys("left", :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("40%") }
    end
  end

  def test_ratio_change_increases_left
    with_test_terminal(80, 24) do
      # Expand left panel using right arrow
      inject_keys("right", :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("60%") }
    end
  end

  def test_ratio_minimum_boundary
    with_test_terminal(80, 24) do
      # Try to go below 10%
      inject_keys("left", "left", "left", "left", "left", :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("10%") }
    end
  end

  def test_ratio_maximum_boundary
    with_test_terminal(80, 24) do
      # Try to go above 90%
      inject_keys("right", "right", "right", "right", "right", "right", "right", "right", "right", :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("90%") }
    end
  end
end
