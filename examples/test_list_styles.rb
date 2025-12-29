# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "list_styles"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

class TestListStylesExample < Minitest::Test
  def setup
    @app = ListStylesApp.new
  end

  def test_render_initial_state
    with_test_terminal(50, 20) do
      @app.render

      assert buffer_content.any? { |line| line.include?(">> Item 1") }
      assert buffer_content.any? { |line| line.include?("   Item 2") }
    end
  end

  def test_navigation_down
    inject_event(RatatuiRuby::Event::Key.new(code: "down"))
    @app.handle_input

    with_test_terminal(50, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("   Item 1") }
      assert buffer_content.any? { |line| line.include?(">> Item 2") }
    end
  end

  def test_navigation_up
    # Move down to Item 2
    inject_event(RatatuiRuby::Event::Key.new(code: "down"))
    @app.handle_input

    # Move up back to Item 1
    inject_event(RatatuiRuby::Event::Key.new(code: "up"))
    @app.handle_input

    with_test_terminal(50, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?(">> Item 1") }
    end
  end

  def test_quit
    inject_event(RatatuiRuby::Event::Key.new(code: "q"))
    status = @app.handle_input
    assert_equal :quit, status
  end
end
