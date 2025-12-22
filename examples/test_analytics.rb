# frozen_string_literal: true

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
    RatatuiRuby.stub :poll_event, { code: "right", type: :key } do
      @app.handle_input
    end

    with_test_terminal(50, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Analytics: Traffic") }
    end
  end

  def test_navigation_left
    # Move right to Traffic
    RatatuiRuby.stub :poll_event, { code: "right", type: :key } do
      @app.handle_input
    end
    # Move left back to Revenue
    RatatuiRuby.stub :poll_event, { code: "left", type: :key } do
      @app.handle_input
    end

    with_test_terminal(50, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Analytics: Revenue") }
    end
  end

  def test_quit
    status = RatatuiRuby.stub :poll_event, { code: "q", type: :key } do
      @app.handle_input
    end
    assert_equal :quit, status
  end
end
