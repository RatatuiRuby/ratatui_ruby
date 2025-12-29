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
    with_test_terminal(100, 20) do
      # Queue quit
      inject_key(:q)

      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Process Monitor"
      assert_includes content, "Style: Cyan"
      assert_includes content, "PID"
    end
  end

  def test_style_switching
    # Default is Cyan (index 0). Pressing 's' should switch to Red (index 1).
    second_style_name = TableApp::STYLES[1][:name]
    
    with_test_terminal(100, 20) do
      # Press 's' then quit
      inject_keys(:s, :q)
      
      @app.run
      
      content = buffer_content.join("\n")
      assert_includes content, "Style: #{second_style_name}"
    end
  end

  def test_row_selection
    # We can check internal state or rendered output.
    # Since render uses state, we can verify rendered output if selection is visible.
    # Render highlights selected row.
    # We can also check state @app.selected_index if accessible (attr_reader).
    
    with_test_terminal(100, 20) do
      # Move down, then up, then quit

      # We need to run, check state/buffer?
      # If we run once, it processes all events.
      # To check intermediate state, we'd need to mock/hook.
      # Or just check final state after sequence.
      
      # Let's check finalizing state after a sequence.
      # Down (1), Down (2), Up (1), Up (0), Up (Wrap -> Last)
      
      inject_keys(:j, :j, :k, :k, :up, :q)
      
      @app.run
      
      # Should be at last item
      assert_equal PROCESSES.length - 1, @app.selected_index
    end
  end

  def test_quit
    with_test_terminal(100, 20) do
      inject_key(:q)
      @app.run
      # Success
    end
  end

  def test_column_spacing_change
    with_test_terminal(100, 20) do
      # Press '+' to increase spacing, then quit
      inject_keys(:+, :q)
      
      @app.run
      
      content = buffer_content.join("\n")
      assert_includes content, "Spacing: 2"
      assert_equal 2, @app.column_spacing
    end
  end

  def test_highlight_spacing_change
    with_test_terminal(100, 20) do
      # Initial is :when_selected. Press 'h' -> :never -> :always -> :when_selected
      # Let's switch to :never
      inject_keys(:h, :q)
      
      @app.run
      
      content = buffer_content.join("\n")
      assert_includes content, "Highlight: never"
      assert_equal :never, @app.highlight_spacing
    end
  end
end
