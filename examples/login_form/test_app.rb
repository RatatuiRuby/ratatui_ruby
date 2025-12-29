# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestLoginForm < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = LoginFormApp.new
  end

  def test_render_initial_state
    with_test_terminal(60, 20) do
      # Queue quit
      inject_keys(:esc)

      @app.run

      assert buffer_content.any? { |line| line.include?("Enter Username:") }
    end
  end

  def test_input_handling
    with_test_terminal(60, 20) do
      # Type 'a' then quit
      inject_keys("a", :esc)

      @app.run

      assert buffer_content.any? { |line| line.include?("Enter Username: [ a ]") }
    end
  end

  def test_popup_flow
    with_test_terminal(60, 20) do
      # Enter username 'user', press Enter, then quit
      inject_keys("u", "s", "e", "r", :enter, :q)

      @app.run

      assert buffer_content.any? { |line| line.include?("Successful!") }
    end
  end
end
