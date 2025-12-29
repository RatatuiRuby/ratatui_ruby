# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"
require_relative "app"

class TestScrollbarDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @demo = ScrollbarDemo.new
  end

  def test_initial_render
    with_test_terminal do
      # Queue quit event to exit loop immediately
      inject_key(:q)

      # Stub init_terminal/restore_terminal to use test terminal
      @demo.run

      content = buffer_content

      # Top border with title (truncated due to small width)
      assert_includes content[0], "Scroll"
      # First line of content
      assert_includes content[1], "Line 1"
      # Scrollbar area (far right)
      assert_equal "█", content[1][-1]
    end
  end

  def test_scroll_down
    with_test_terminal do
      # Queue scroll down + quit
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "scroll_down", x: 0, y: 0, button: "none"))
      inject_key(:q)

      @demo.run

      content = buffer_content

      # Now it should start from Line 2
      assert_includes content[1], "Line 2"
      refute_includes content[1], "Line 1"
    end
  end

  def test_scroll_up
    with_test_terminal do
      # Queue scroll down + scroll up + quit
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "scroll_down", x: 0, y: 0, button: "none"))
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "scroll_up", x: 0, y: 0, button: "none"))
      inject_key(:q)

      @demo.run

      content = buffer_content

      assert_includes content[1], "Line 1"
    end
  end

  def test_theme_cycling
    with_test_terminal do
      # Queue 's' + quit
      inject_keys(:s, :q)

      @demo.run

      content = buffer_content
      assert_match(/Theme: Rounded/, content[0])
    end
  end
end
