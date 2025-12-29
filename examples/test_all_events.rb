# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "all_events"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

class TestAllEvents < Minitest::Test
  def setup
    @app = AllEventsApp.new
  end

  def test_initial_state
    with_test_terminal(80, 24) do
      @app.render
      content = buffer_content.join("\n")
      assert_includes content, "Press any key..."
      assert_includes content, "Click or scroll..."
      assert_includes content, "Resize the terminal..."
      assert_includes content, "Paste text or change focus..."
    end
  end

  def test_key_event_updates_panel
    with_test_terminal(80, 24) do
      inject_event(RatatuiRuby::Event::Key.new(code: "a"))
      @app.handle_input
      @app.render

      assert_includes buffer_content.join("\n"), "Key: a"
    end
  end

  def test_key_event_with_modifiers
    with_test_terminal(80, 24) do
      inject_event(RatatuiRuby::Event::Key.new(code: "s", modifiers: ["ctrl"]))
      @app.handle_input
      @app.render

      assert_includes buffer_content.join("\n"), "Key: s [ctrl]"
    end
  end

  def test_mouse_event_updates_panel
    with_test_terminal(80, 24) do
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 10, y: 5))
      @app.handle_input
      @app.render

      assert_includes buffer_content.join("\n"), "down: left at (10, 5)"
    end
  end

  def test_resize_event_updates_panel
    with_test_terminal(120, 40) do
      # Note: The app's handle_input handles the resize event by updating @resize_info
      inject_event(RatatuiRuby::Event::Resize.new(width: 120, height: 40))
      @app.handle_input
      @app.render

      assert_includes buffer_content.join("\n"), "120×40"
    end
  end

  def test_paste_event_updates_panel
    with_test_terminal(80, 24) do
      inject_event(RatatuiRuby::Event::Paste.new(content: "Hello, World!"))
      @app.handle_input
      @app.render

      assert_includes buffer_content.join("\n"), 'Pasted: "Hello, World!"'
    end
  end

  def test_paste_event_truncates_long_content
    with_test_terminal(80, 24) do
      inject_event(RatatuiRuby::Event::Paste.new(content: "This is a very long string that should be truncated"))
      @app.handle_input
      @app.render

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
      @app.handle_input
      @app.render

      assert_includes buffer_content.join("\n"), "Focus gained! ✓"
    end
  end

  def test_focus_lost_updates_panel
    with_test_terminal(80, 24) do
      inject_event(RatatuiRuby::Event::FocusLost.new)
      @app.handle_input
      @app.render

      assert_includes buffer_content.join("\n"), "Focus lost..."
    end
  end

  def test_quit_on_q
    inject_event(RatatuiRuby::Event::Key.new(code: "q"))
    result = @app.handle_input

    assert_equal :quit, result
  end

  def test_quit_on_ctrl_c
    inject_event(RatatuiRuby::Event::Key.new(code: "c", modifiers: ["ctrl"]))
    result = @app.handle_input

    assert_equal :quit, result
  end
end
