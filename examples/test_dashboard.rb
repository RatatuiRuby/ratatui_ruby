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
      # Queue quit
      inject_key(:q)

      @app.run

      assert buffer_content.any? { |line| line.include?("Item 1") }
      assert buffer_content.any? { |line| line.include?("You selected: Item 1") }
    end
  end

  def test_navigation
    with_test_terminal(60, 20) do
      # Move down then quit
      inject_keys(:down, :q)

      @app.run

      assert buffer_content.any? { |line| line.include?("You selected: Item 2") }
    end
  end
end
