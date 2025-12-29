# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestPopupDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = PopupDemo.new
  end

  def test_render_initial_state
    with_test_terminal(80, 24) do
      # Queue quit
      inject_key(:q)

      @app.run

      # Should have background text
      assert buffer_content.any? { |line| line.include?("BACKGROUND RED") }

      # Should have popup with "Clear is DISABLED" message
      assert buffer_content.any? { |line| line.include?("Clear is DISABLED") }
      assert buffer_content.any? { |line| line.include?("Style Bleed: Popup is RED!") }
    end
  end

  def test_toggle_clear
    with_test_terminal(80, 24) do
      # Toggle Clear on then quit
      inject_keys(" ", :q)

      @app.run

      assert buffer_content.any? { |line| line.include?("Clear is ENABLED") }
      assert buffer_content.any? { |line| line.include?("Resets background to default") }
    end
  end

  def test_quit
    with_test_terminal(80, 24) do
      inject_key(:q)
      @app.run
      # Success
    end
  end
end
