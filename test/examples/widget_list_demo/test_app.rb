# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_list_demo/app"

class TestWidgetListDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetListDemo.new
  end

  def test_render_initial_state
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("List Widget Demo") }
      assert content.any? { |line| line.include?("Large List") }
      assert content.any? { |line| line.include?("Item 1") }
    end
  end

  def test_navigate_down
    with_test_terminal do
      inject_keys(:down, :q)
      @app.run

      content = buffer_content
      # Initial large list, down selects first item (Item 1)
      assert content.any? { |line| line.include?(">> Item 1") }
    end
  end

  def test_navigate_up_wraps
    with_test_terminal do
      inject_keys(:up, :q)
      @app.run

      content = buffer_content
      # Should wrap to last item of Large List (Item 200)
      assert content.any? { |line| line.include?(">> Item 200") }
    end
  end

  def test_toggle_selection_on
    with_test_terminal do
      inject_keys(:x, :q)
      @app.run

      content = buffer_content
      # Selects index 0 (Item 1)
      assert content.any? { |line| line.include?(">> Item 1") }
      assert content.any? { |line| line.include?("Selection: 0") }
    end
  end

  def test_toggle_selection_off
    with_test_terminal do
      inject_keys(:x, :x, :q)
      @app.run

      content = buffer_content
      refute content.any? { |line| line.include?(">> ") && line.include?("Item 1") }
      assert content.any? { |line| line.include?("Selection: none") }
    end
  end

  def test_cycle_item_set
    with_test_terminal do
      inject_keys(:i, :q)
      @app.run

      content = buffer_content
      # Cycles to next set: Colors
      assert content.any? { |line| line.include?("Colors") }
      assert content.any? { |line| line.include?("Red") }
    end
  end

  def test_cycle_item_set_multiple_times
    with_test_terminal do
      # 0=Large, 1=Colors, 2=Fruits, 3=Programming
      inject_keys(:i, :i, :i, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Programming") }
      assert content.any? { |line| line.include?("Ruby") }
    end
  end

  def test_cycle_highlight_style
    with_test_terminal do
      inject_keys(:h, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Yellow on Black") }
    end
  end

  def test_cycle_highlight_symbol
    with_test_terminal do
      inject_keys(:x, :y, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("▶") }
    end
  end

  def test_cycle_direction
    with_test_terminal do
      inject_keys(:d, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Bottom to Top") }
    end
  end

  def test_cycle_spacing
    with_test_terminal do
      inject_keys(:s, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("List Widget Demo") }
    end
  end

  def test_spacing_always_shows_column
    with_test_terminal do
      # Need to enable always spacing (:s) on Item list
      inject_keys(:s, :q)
      @app.run

      content = buffer_content
      # With :always spacing, unselected items are indented
      assert content.any? { |line| line.include?("   Item 1") }
    end
  end

  def test_cycle_base_style
    with_test_terminal do
      inject_keys(:b, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("List Widget Demo") }
    end
  end

  def test_cycle_repeat_symbol
    with_test_terminal do
      inject_keys(:r, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("List Widget Demo") }
    end
  end

  def test_selection_resets_on_item_set_change
    with_test_terminal do
      inject_keys(:x, :down, :i, :q)
      @app.run

      content = buffer_content
      # After changing item set to Colors, selection should reset
      assert content.any? { |line| line.include?("Selection: none") }
    end
  end

  def test_quit_with_ctrl_c
    with_test_terminal do
      inject_keys("c", :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("List Widget Demo") }
    end
  end

  def test_demo_title_always_visible
    with_test_terminal do
      inject_keys(:i, :h, :y, :d, :s, :b, :r, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("List Widget Demo") }
    end
  end

  def test_cycle_scroll_padding
    with_test_terminal do
      inject_keys(:p, :q)
      @app.run

      content = buffer_content
      # 0=None, 1=1 item
      assert content.any? { |line| line.include?("Scroll Padding (1 item)") }
    end
  end

  def test_scroll_padding_changes_display
    with_test_terminal do
      # Switch to Colors (i), Toggle select (x), scroll down, toggle padding (p)
      inject_keys(:i, :x, :down, :p, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Colors") }
      # Selected index 1 (Orange) of Colors
      assert content.any? { |line| line.include?(">> Orange") }
    end
  end

  def test_multiple_navigation_and_options
    with_test_terminal do
      # Interactive usage smoke test
      inject_keys(:down, :h, :down, :y, :up, :b, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("List Widget Demo") }
    end
  end
end
