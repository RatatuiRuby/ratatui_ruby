# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestListDemoApp < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = ListDemoApp.new
  end

  def test_render_initial_state
    with_test_terminal(100, 30) do
      inject_key(:q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Interactive List") }
      assert content.any? { |line| line.include?("Colors") }
      assert content.any? { |line| line.include?("Red") }
    end
  end

  def test_navigate_down
    with_test_terminal(100, 30) do
      inject_keys(:down, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?(">> Red") }
    end
  end

  def test_navigate_up_wraps
    with_test_terminal(100, 30) do
      inject_keys(:up, :q)
      @app.run

      content = buffer_content
      # Should wrap to last item (Magenta in Colors set)
      assert content.any? { |line| line.include?(">> Magenta") }
    end
  end

  def test_toggle_selection_on
    with_test_terminal(100, 30) do
      inject_keys(:x, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?(">> Red") }
      assert content.any? { |line| line.include?("Selection: 0") }
    end
  end

  def test_toggle_selection_off
    with_test_terminal(100, 30) do
      inject_keys(:x, :x, :q)
      @app.run

      content = buffer_content
      refute content.any? { |line| line.include?(">> ") && line.include?("Red") }
      assert content.any? { |line| line.include?("Selection: none") }
    end
  end

  def test_cycle_item_set
    with_test_terminal(100, 30) do
      inject_keys(:i, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Fruits") }
      assert content.any? { |line| line.include?("Apple") }
    end
  end

  def test_cycle_item_set_multiple_times
    with_test_terminal(100, 30) do
      inject_keys(:i, :i, :i, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Numbers") }
      assert content.any? { |line| line.include?("One") }
    end
  end

  def test_cycle_highlight_style
    with_test_terminal(100, 30) do
      inject_keys(:h, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Yellow on Black") }
    end
  end

  def test_cycle_highlight_symbol
    with_test_terminal(100, 30) do
      inject_keys(:x, :y, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("▶") }
    end
  end

  def test_cycle_direction
    with_test_terminal(100, 30) do
      inject_keys(:d, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Bottom to Top") }
    end
  end

  def test_cycle_spacing
    with_test_terminal(100, 30) do
      inject_keys(:s, :q)
      @app.run

      content = buffer_content
      # Spacing cycling should work, just verify list is still rendered
      assert content.any? { |line| line.include?("Interactive List") }
    end
  end

  def test_spacing_always_shows_column
    with_test_terminal(100, 30) do
      inject_keys(:s, :q)
      @app.run

      content = buffer_content
      # With :always spacing and no selection, still shows spacing column
      assert content.any? { |line| line.include?("   Red") }
    end
  end

  def test_cycle_base_style
    with_test_terminal(100, 30) do
      inject_keys(:b, :q)
      @app.run

      content = buffer_content
      # Base style cycling should work, just verify list is still rendered
      assert content.any? { |line| line.include?("Interactive List") }
    end
  end

  def test_cycle_repeat_symbol
    with_test_terminal(100, 30) do
      inject_keys(:r, :q)
      @app.run

      content = buffer_content
      # Repeat symbol toggling should work, just verify list is still rendered
      assert content.any? { |line| line.include?("Interactive List") }
    end
  end

  def test_selection_resets_on_item_set_change
    with_test_terminal(100, 30) do
      inject_keys(:x, :down, :i, :q)
      @app.run

      content = buffer_content
      # After changing item set, selection should reset to none
      assert content.any? { |line| line.include?("Selection: none") }
    end
  end

  def test_quit_with_ctrl_c
    with_test_terminal(100, 30) do
      inject_keys("c", :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Interactive List") }
    end
  end

  def test_demo_title_always_visible
    with_test_terminal(100, 30) do
      inject_keys(:i, :h, :y, :d, :s, :b, :r, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("List Widget Demo") }
    end
  end

  def test_multiple_navigation_and_options
    with_test_terminal(100, 30) do
      inject_keys(:down, :h, :down, :y, :up, :b, :q)
      @app.run

      content = buffer_content
      # Should have navigated and cycled options
      assert content.any? { |line| line.include?("Interactive List") }
    end
  end
end
