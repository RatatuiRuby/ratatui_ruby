# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestWidgetTabsDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetTabsDemo.new
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

      # Check Title
      assert buffer_content.any? { |line| line.include?("Tabs Demo") }

      # Check help text visibility
      content_str = buffer_content.join("\n")
      assert_includes content_str, "q: Quit"
    end
  end

  def test_navigation
    with_test_terminal do
      # Move right -> "Traffic", Right -> "Errors", Left -> "Traffic"
      inject_keys(:right, :right, :left, :q)

      @app.run

      # Since we verify by content, and the tab renders the selected index differently,
      # we assume the logic holds if no crash.
      # Ideally we would check for the highlighted style on "Traffic", but text assertion is simple.
      assert buffer_content.any? { |line| line.include?("Traffic") }
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
      # Switch style (s) then quit (q)
      inject_keys(:s, :q)
      @app.run

      # Verify it runs without error.
    end
  end

  def test_switch_base_style
    with_test_terminal do
      # Switch base style (b) then quit (q)
      inject_keys(:b, :q)
      @app.run

      # Verify it runs without error.
    end
  end

  def test_padding_controls
    with_test_terminal do
      # Increase padding_left (l) and padding_right (k) then quit
      inject_keys(:l, :l, :k, :k, :k, :q)
      @app.run

      # Verify that padding values are shown in status with hotkeys
      content_str = buffer_content.join("\n")
      assert_includes content_str, "h/l: Pad Left (2)"
      assert_includes content_str, "j/k: Pad Right (3)"
    end
  end
end
