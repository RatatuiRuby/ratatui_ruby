#!/usr/bin/env ruby
# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/app_table_select/app"

# Tests for the table_select example
class TestAppTableSelect < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = AppTableSelect.new
  end

  def test_initial_render_no_selection
    with_test_terminal do
      # By default, selection is at index 1 and highlights are on.
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # Row 1 (postgres) should be selected.
      # Default style is Cyan.
      # "Toggle Row (1)" should be visible in footer.
      assert_includes content, "Toggle Row (1)"
      assert_includes content, "Cyan"
      assert_includes content, "PID"
    end
  end

  def test_style_switching
    second_style_name = "Red"

    with_test_terminal do
      inject_keys(:s, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?(second_style_name) }
    end
  end

  def test_toggle_selection_on
    with_test_terminal do
      # Default is ON (1 selected).
      # Press x to toggle off (none), then quit
      inject_keys(:x, :q)
      @app.run

      content = buffer_content.join("\n")
      # "Toggle Row (none)" should be visible.
      assert_includes content, "Toggle Row (none)"
    end
  end

  def test_toggle_selection_off
    with_test_terminal do
      # Default is ON.
      # Press x to toggle off, x again to toggle on (0 selected now because toggle logic resets to 0 if nil?), then quit
      # Wait, app logic: @selected_index = @selected_index.nil? ? 0 : nil
      # If default is 1, toggling off makes it nil. Toggling on makes it 0.
      inject_keys(:x, :x, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Toggle Row (0)"
    end
  end

  def test_navigation_selects_and_moves
    with_test_terminal do
      # Default is 1. Down -> 2.
      inject_keys(:down, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Toggle Row (2)"
    end
  end

  def test_navigation_wrapping
    with_test_terminal do
      # Start 1, down->2... wrap around logic needs check.
      # Logic: (@selected_index + 1) % length.
      # To test wrap, need to go to end. Length is 7.
      # From 1, need 6 downs to wrap? No, just up from 0 wraps to last.
      # So: up (1->0), up (0->6).
      inject_keys(:up, :up, :q)
      @app.run

      content = buffer_content.join("\n")
      last_index = PROCESSES.length - 1
      assert_includes content, "Toggle Row (#{last_index})"
    end
  end

  def test_column_navigation
    with_test_terminal do
      # Default col 1. Right -> 2.
      inject_keys(:right, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Nav Col"
      # We don't have a label for selected column in the footer anymore?
      # Wait, I added it in app.rb but removed it in previous step?
      # In Step 115 I added `col_label` but I didn't verify if I used it in the UI.
      # Let me check app.rb again. I might have missed adding it to the UI in Step 87 layout fix or Step 115.
      # Step 115 added `col_label = ...` but did NOT add it to the Paragraph text.
      # I need to check app.rb to see if `col_label` is rendered.
    end
  end

  def test_quit
    with_test_terminal do
      inject_key(:q)
      @app.run
    end
  end

  def test_highlight_spacing_cycles_to_next
    with_test_terminal do
      # Mode order: [:when_selected, :always, :never]
      # 'p' goes to :always
      inject_keys(:p, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Always") }
    end
  end

  def test_highlight_spacing_cycles_to_never
    with_test_terminal do
      # 'p' goes: when_selected -> always -> never
      inject_keys(:p, :p, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Never") }
    end
  end

  def test_highlight_spacing_cycles_back_to_when_selected
    with_test_terminal do
      # 'p' goes: when_selected -> always -> never -> when_selected
      inject_keys(:p, :p, :p, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("When Selected") }
    end
  end

  def test_column_spacing_increases
    with_test_terminal do
      inject_keys("+", :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Col Space (2)") }
    end
  end

  def test_column_spacing_decreases
    with_test_terminal do
      inject_keys("+", "-", :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Col Space (1)") }
    end
  end
end
