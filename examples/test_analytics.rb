# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "analytics"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

class TestAnalytics < Minitest::Test
  def setup
    @app = AnalyticsApp.new
  end

  def test_render_initial_state
    with_test_terminal(50, 20) do
      @app.render

      # Check Tabs
      assert buffer_content.any? { |line| line.include?("Revenue") }
      assert buffer_content.any? { |line| line.include?("Traffic") }
      assert buffer_content.any? { |line| line.include?("Errors") }

      # Check initial selected tab content
      assert buffer_content.any? { |line| line.include?("Analytics: Revenue") }
    end
  end

  def test_navigation_right
    inject_event(RatatuiRuby::Event::Key.new(code: "right"))
    @app.handle_input

    with_test_terminal(50, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Analytics: Traffic") }
    end
  end

  def test_navigation_left
    # Move right to Traffic
    inject_event(RatatuiRuby::Event::Key.new(code: "right"))
    @app.handle_input

    # Move left back to Revenue
    inject_event(RatatuiRuby::Event::Key.new(code: "left"))
    @app.handle_input

    with_test_terminal(50, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Analytics: Revenue") }
    end
  end

  def test_quit
    inject_event(RatatuiRuby::Event::Key.new(code: "q"))
    status = @app.handle_input
    assert_equal :quit, status
  end
end
