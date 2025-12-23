# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "box_demo"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

class TestBoxDemo < Minitest::Test
  def setup
    @app = BoxDemoApp.new
  end

  def test_render_initial_state
    with_test_terminal(40, 10) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Box Demo") }
      assert buffer_content.any? { |line| line.include?("Press Arrow Keys") }
    end
  end

  def test_interaction
    inject_event("key", { code: "up" })
    @app.handle_input

    with_test_terminal(40, 10) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Up Pressed!") }
    end
  end
end
