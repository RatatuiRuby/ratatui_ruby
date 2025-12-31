# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestMouseEvents < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = AppMouseEvents.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Mouse Event Plumbing"
      assert_includes content, "Waiting for Mouse..."
    end
  end

  def test_mouse_click
    with_test_terminal do
      # Click left button at 10, 5
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 10, y: 5))
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Left Click at [10, 5]"
    end
  end

  def test_mouse_scroll
    with_test_terminal do
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "scroll_down", button: "none", x: 20, y: 15))
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Scrolled Down"
      assert_includes content, "Position: [20, 15]"
    end
  end
end
