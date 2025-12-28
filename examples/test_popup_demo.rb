# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "popup_demo"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

class TestPopupDemo < Minitest::Test
  def setup
    @app = PopupDemo.new
  end

  def test_render_initial_state
    with_test_terminal(60, 20) do
      @app.render

      # Should have background text
      assert buffer_content.any? { |line| line.include?("BACKGROUND RED") }

      # Should have popup with "Clear is DISABLED" message
      assert buffer_content.any? { |line| line.include?("Clear is DISABLED") }
      assert buffer_content.any? { |line| line.include?("Style Bleed: Popup is RED!") }
    end
  end

  def test_toggle_clear
    with_test_terminal(60, 20) do
      # Initial state: Clear disabled
      @app.render
      assert buffer_content.any? { |line| line.include?("Clear is DISABLED") }

      # Toggle Clear on
      inject_event("key", { code: " " })
      @app.handle_input

      @app.render
      assert buffer_content.any? { |line| line.include?("Clear is ENABLED") }
      assert buffer_content.any? { |line| line.include?("Resets background to default") }

      # Toggle Clear off
      inject_event("key", { code: " " })
      @app.handle_input

      @app.render
      assert buffer_content.any? { |line| line.include?("Clear is DISABLED") }
    end
  end

  def test_quit
    inject_event("key", { code: "q" })
    status = @app.handle_input
    assert_equal :quit, status
  end
end
