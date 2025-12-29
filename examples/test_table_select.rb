#!/usr/bin/env ruby
# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
$LOAD_PATH.unshift File.expand_path("../test", __dir__)
require "test_helper"
require_relative "table_select"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

# Smoke test to ensure the table_select example can be loaded and instantiated
class TestTableSelect < Minitest::Test
  def setup
    @app = TableApp.new
  end

  def test_initial_render
    with_test_terminal(60, 20) do
      @app.render
      content = buffer_content.join("\n")
      assert_includes content, "Process Monitor"
      assert_includes content, "style: Cyan"
      assert_includes content, "PID"
    end
  end

  def test_style_switching
    # Default is Cyan (index 0). Pressing 's' should switch to Red (index 1).
    first_style_name = TableApp::STYLES[0][:name]
    second_style_name = TableApp::STYLES[1][:name]
    
    assert_equal 0, @app.current_style_index
    assert_equal first_style_name, "Cyan"

    inject_event(RatatuiRuby::Event::Key.new(code: "s"))
    @app.handle_input

    assert_equal 1, @app.current_style_index
    assert_equal second_style_name, "Red"

    with_test_terminal(60, 20) do
      @app.render
      content = buffer_content.join("\n")
      assert_includes content, "style: #{second_style_name}"
    end
  end

  def test_row_selection
    assert_equal 0, @app.selected_index

    # Move down
    inject_event(RatatuiRuby::Event::Key.new(code: "j"))
    @app.handle_input
    assert_equal 1, @app.selected_index

    # Move up
    inject_event(RatatuiRuby::Event::Key.new(code: "k"))
    @app.handle_input
    assert_equal 0, @app.selected_index
    
    # Wrap around up
    inject_event(RatatuiRuby::Event::Key.new(code: "up"))
    @app.handle_input
    assert_equal PROCESSES.length - 1, @app.selected_index
  end

  def test_quit
    inject_event(RatatuiRuby::Event::Key.new(code: "q"))
    result = @app.handle_input
    assert_equal :quit, result
  end
end
