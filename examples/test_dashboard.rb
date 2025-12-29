# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "dashboard"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

class TestDashboard < Minitest::Test
  def setup
    @app = DashboardApp.new
  end

  def test_render_initial_state
    with_test_terminal(60, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Item 1") }
      assert buffer_content.any? { |line| line.include?("You selected: Item 1") }
    end
  end

  def test_navigation
    inject_event(RatatuiRuby::Event::Key.new(code: "down"))
    @app.handle_input

    with_test_terminal(60, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("You selected: Item 2") }
    end
  end
end
