# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "login_form"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

class TestLoginForm < Minitest::Test
  def setup
    @app = LoginFormApp.new
  end

  def test_render_initial_state
    with_test_terminal(60, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Enter Username:") }
      # Initial cursor position check could be tricky without inspecting cursor state,
      # but we can rely on visual cursor rendering if we had a way to check attributes,
      # or just assume the widget logic puts it there.
    end
  end

  def test_input_handling
    # Type 'a'
    inject_event("key", { code: "a" })
    @app.handle_input

    with_test_terminal(60, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Enter Username: [ a ]") }
    end
  end

  def test_popup_flow
    # Enter username 'user'
    %w[u s e r].each do |char|
      inject_event("key", { code: char })
      @app.handle_input
    end

    # Press Enter
    inject_event("key", { code: "enter" })
    @app.handle_input

    with_test_terminal(60, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Successful!") }
    end

    # Press 'q' to quit popup/app
    inject_event("key", { code: "q" })
    status = @app.handle_input
    assert_equal :quit, status
  end
end
