# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "system_monitor"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

class TestSystemMonitor < Minitest::Test
  def setup
    @app = SystemMonitorApp.new
  end

  def test_render_initial_state
    with_test_terminal(60, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Processes") }
      assert buffer_content.any? { |line| line.include?("Memory Usage") }
      assert buffer_content.any? { |line| line.include?("50%") }
    end
  end

  def test_interaction
    # Increase percentage
    inject_event(RatatuiRuby::Event::Key.new(code: "up"))
    @app.handle_input

    with_test_terminal(60, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("55%") }
    end
  end
end
