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

  def test_initial_render_no_selection
    with_test_terminal(100, 20) do
      inject_key(:q)

      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sel: none"
      assert_includes content, "Style: Cyan"
      assert_includes content, "PID"
    end
  end

  def test_style_switching
    second_style_name = TableApp::STYLES[1][:name]
    
    with_test_terminal(100, 20) do
      inject_keys(:s, :q)
      
      @app.run
      
      content = buffer_content.join("\n")
      assert_includes content, "Style: #{second_style_name}"
    end
  end

  def test_toggle_selection
    with_test_terminal(100, 20) do
      assert_nil @app.selected_index

      inject_key(:x)
      @app.handle_input
      assert_equal 0, @app.selected_index

      inject_key(:x)
      @app.handle_input
      assert_nil @app.selected_index
    end
  end

  def test_navigation_selects_and_moves
    with_test_terminal(100, 20) do
      inject_keys(:down, :q)
      
      @app.run
      
      assert_equal 0, @app.selected_index
    end
  end

  def test_navigation_wrapping
    with_test_terminal(100, 20) do
      # Start nil, down->0, up->wraps to last
      inject_keys(:down, :up, :q)
      
      @app.run
      
      assert_equal PROCESSES.length - 1, @app.selected_index
    end
  end

  def test_quit
    with_test_terminal(100, 20) do
      inject_key(:q)
      @app.run
    end
  end

  def test_highlight_spacing_cycles
    with_test_terminal(100, 20) do
      # Mode order: [:always, :when_selected, :never]
      # Starting at :when_selected (index 1), 'h' goes to :never (index 2)
      assert_equal :when_selected, @app.highlight_spacing

      inject_key(:h)
      @app.handle_input
      assert_equal :never, @app.highlight_spacing

      inject_key(:h)
      @app.handle_input
      assert_equal :always, @app.highlight_spacing

      inject_key(:h)
      @app.handle_input
      assert_equal :when_selected, @app.highlight_spacing
    end
  end

  def test_spacing_always_shows_column_without_selection
    with_test_terminal(100, 20) do
      # Press 'h' twice to get to :always (when_selected -> never -> always)
      inject_key(:h)
      @app.handle_input
      inject_key(:h)
      @app.handle_input

      @app.render

      # With :always, spacing column is shown even without selection
      content = buffer_content[2] # First data row
      assert_match(/\s+1234/, content)
    end
  end
end
