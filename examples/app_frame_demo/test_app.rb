# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestFrameDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = AppFrameDemo.new
  end

  def test_render_initial_state
    with_test_terminal do
      # Queue quit
      inject_key(:q)

      @app.run

      # Verify Sidebar
      assert_buffer_includes "Menu"
      assert_buffer_includes "Dashboard"
      assert_buffer_includes "Analytics"

      # Verify Main Area
      assert_buffer_includes "Details"
      assert_buffer_includes "Active View: Dashboard"
      assert_buffer_includes "Last Action: Application Started"

      # Verify Layout (Sidebar is 20 wide)
      # The main content should start after column 20
      # We just check that content renders reasonably
      assert_buffer_includes "Frame Dimensions: 80x24"
    end
  end

  def test_hit_testing_sidebar
    with_test_terminal do
      # Click on "Analytics" (Index 1)
      # Sidebar starts at (0,0). Border at y=0. Content starts at y=1.
      # "Dashboard" is at y=1. "Analytics" is at y=2.
      # x can be anywhere in 1..18 (inside borders)
      inject_click(x: 5, y: 2)

      # Quit
      inject_key(:q)

      @app.run

      # Verify state change
      assert_buffer_includes "Active View: Analytics"
      assert_buffer_includes "Sidebar: Dashboard -> Analytics"
      assert_buffer_includes "Total Clicks: 1"
    end
  end

  def test_hit_testing_main_area
    with_test_terminal do
      # Click in main area
      # Sidebar is 0..19. Main area starts at 20.
      inject_click(x: 30, y: 5)

      # Quit
      inject_key(:q)

      @app.run

      # Verify state change
      assert_buffer_includes "Clicked Main Area at (30, 5)"
    end
  end

  private def assert_buffer_includes(text)
    content = buffer_content.join("\n")
    assert_includes content, text, "Expected buffer to include '#{text}'"
  end
end
