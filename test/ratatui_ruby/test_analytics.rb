# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"
require_relative "../../examples/analytics"

class TestAnalyticsApp < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = AnalyticsApp.new
  end

  def test_initial_render
    # Initial state: Divider " | ", Style Yellow/Bold
    with_test_terminal(60, 10) do
      @app.render
      content = buffer_content
      
      # Check title instructions
      assert_includes content[0], "Views (Space: style, 'd': divider, 'q': quit)"
      
      # Check divider " | "
      tabs_line = content[1]
      assert_includes tabs_line, "|"
    end
  end

  def test_switch_divider
    with_test_terminal(60, 10) do
      # Initial render to ensure state
      @app.render
      content = buffer_content
      assert_includes content[1], "|"

      # Press 'd': " • "
      inject_event(RatatuiRuby::Event::Key.new(code: "d"))
      @app.handle_input
      @app.render
      
      content = buffer_content
      tabs_line = content[1]
      assert_includes tabs_line, "•"
      refute_includes tabs_line, "|"

      # Press 'd' again: " > "
      inject_event(RatatuiRuby::Event::Key.new(code: "d"))
      @app.handle_input
      @app.render
      
      content = buffer_content
      tabs_line = content[1]
      assert_includes tabs_line, ">"
    end
  end

  def test_switch_style
    with_test_terminal(60, 10) do
      # Press 'Space' to toggle style
      inject_event(RatatuiRuby::Event::Key.new(code: " "))
      @app.handle_input
      @app.render
      
      # Just asserting it rendered effectively
      content = buffer_content
      assert_includes content[0], "Views"
      
      # We could verify inspected state if we really wanted to, 
      # but ensuring no crash and successful render is a good baseline for this example test.
    end
  end
end
