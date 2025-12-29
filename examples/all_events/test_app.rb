# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestAllEvents < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = AllEventsApp.new
  end

  def test_initial_state
    with_test_terminal(80, 24) do
      # Queue quit event
      inject_key(:q)
      
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Press any key..."
      assert_includes content, "Click or scroll..."
      assert_includes content, "80×24"
      assert_includes content, "Paste text or change focus..."
    end
  end

  def test_key_event_updates_panel
    with_test_terminal(80, 24) do
      inject_keys(:a, :q)
      
      @app.run

      assert_includes buffer_content.join("\n"), "Key: a"
    end
  end

  def test_key_event_with_modifiers
    with_test_terminal(80, 24) do
      inject_keys(:ctrl_s, :q)
      
      @app.run

      assert_includes buffer_content.join("\n"), "Key: s [ctrl]"
    end
  end

  def test_mouse_event_updates_panel
    with_test_terminal(80, 24) do
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 10, y: 5))
      inject_key(:q)
      
      @app.run

      assert_includes buffer_content.join("\n"), "down: left at (10, 5)"
    end
  end

  def test_resize_event_updates_panel
    with_test_terminal(80, 24) do
      inject_event(RatatuiRuby::Event::Resize.new(width: 120, height: 40))
      inject_key(:q)
      
      @app.run

      assert_includes buffer_content.join("\n"), "120×40"
    end
  end

  def test_paste_event_updates_panel
    with_test_terminal(80, 24) do
      inject_event(RatatuiRuby::Event::Paste.new(content: "Hello, World!"))
      inject_key(:q)
      
      @app.run

      assert_includes buffer_content.join("\n"), 'Pasted: "Hello, World!"'
    end
  end

  def test_paste_event_truncates_long_content
    with_test_terminal(80, 24) do
      inject_event(RatatuiRuby::Event::Paste.new(content: "This is a very long string that should be truncated"))
      inject_key(:q)
      
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Pasted: "
      assert_includes content, "..."
    end
  end

  def test_focus_gained_updates_panel
    with_test_terminal(80, 24) do
      # Initial state is focused, so we lose then gain
      @app.instance_variable_set(:@focused, false)
      inject_event(RatatuiRuby::Event::FocusGained.new)
      inject_key(:q)
      
      @app.run

      assert_includes buffer_content.join("\n"), "Focus gained! ✓"
    end
  end

  def test_focus_lost_updates_panel
    with_test_terminal(80, 24) do
      inject_event(RatatuiRuby::Event::FocusLost.new)
      inject_key(:q)
      
      @app.run

      assert_includes buffer_content.join("\n"), "Focus lost..."
    end
  end

  def test_quit_on_q
    with_test_terminal(80, 24) do
      inject_key(:q)
      # Wait... run should just return normally
      @app.run
      # If it returns, the test passes (no timeout/hang)
    end
  end

  def test_quit_on_ctrl_c
    with_test_terminal(80, 24) do
      inject_key(:ctrl_c)
      @app.run
    end
  end
end
