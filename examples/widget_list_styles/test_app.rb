# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestListStylesExample < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetListStyles.new
  end

  def test_render_initial_state_no_selection
    with_test_terminal do
      inject_key(:q)
      @app.run

      # Default is :when_selected with no selection, so no highlight symbol column
      content = buffer_content
      assert content.any? { |line| line.include?("Item 1") }
      assert content.any? { |line| line.include?("Item 2") }
      refute content.any? { |line| line.include?(">>") }
    end
  end

  def test_toggle_selection_on
    with_test_terminal do
      # Press x to toggle on, then quit
      inject_keys(:x, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?(">> Item 1") }
    end
  end

  def test_toggle_selection_off
    with_test_terminal do
      # Press x to toggle on, x again to toggle off, then quit
      inject_keys(:x, :x, :q)
      @app.run

      content = buffer_content
      refute content.any? { |line| line.include?(">>") }
    end
  end

  def test_navigation_selects_and_moves
    with_test_terminal do
      inject_keys(:down, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?(">> Item 1") }
    end
  end

  def test_navigation_down_twice
    with_test_terminal do
      inject_keys(:down, :down, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?(">> Item 2") }
    end
  end

  def test_quit
    with_test_terminal do
      inject_key(:q)
      @app.run
    end
  end

  def test_toggle_highlight_spacing_to_always
    with_test_terminal do
      # 's' cycles: when_selected -> always -> never
      inject_keys(:s, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Always") }
    end
  end

  def test_toggle_highlight_spacing_to_never
    with_test_terminal do
      inject_keys(:s, :s, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Never") }
    end
  end

  def test_toggle_highlight_spacing_back_to_when_selected
    with_test_terminal do
      inject_keys(:s, :s, :s, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("When Selected") }
    end
  end

  def test_direction_cycling
    with_test_terminal do
      inject_keys(:d, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Bottom to Top") }
    end
  end

  def test_spacing_always_shows_column_without_selection
    with_test_terminal do
      # Set spacing to :always
      inject_keys(:s, :q)
      @app.run

      content = buffer_content
      # With :always, spacing column is shown even without selection
      assert content.any? { |line| line.include?("   Item 1") }
    end
  end

  def test_repeat_highlight_symbol_toggle
    with_test_terminal do
      # Press r to toggle repeat mode, then quit
      inject_keys(:r, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Repeat Symbol") }
      assert content.any? { |line| line.include?("On") }
    end
  end

  def test_repeat_highlight_symbol_cycles_back
    with_test_terminal do
      # Press r twice to cycle back to Off
      inject_keys(:r, :r, :q)
      @app.run

      content = buffer_content
      assert content.any? { |line| line.include?("Repeat Symbol") }
      assert content.any? { |line| line.include?("Off") }
    end
  end
end
