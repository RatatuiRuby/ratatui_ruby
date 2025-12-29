# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "list_styles"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

class TestListStylesExample < Minitest::Test
  def setup
    @app = ListStylesApp.new
  end

  def test_render_initial_state_no_selection
    with_test_terminal(80, 20) do
      inject_key(:q)

      @app.run

      # Default is :when_selected with no selection, so no highlight symbol column
      assert buffer_content.any? { |line| line.include?("Item 1") }
      assert buffer_content.any? { |line| line.include?("Item 2") }
      refute buffer_content.any? { |line| line.include?(">>") }
    end
  end

  def test_toggle_selection
    with_test_terminal(80, 20) do
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
    with_test_terminal(80, 20) do
      inject_keys(:down, :q)

      @app.run

      # Pressing down selects first item (index 0)
      assert buffer_content.any? { |line| line.include?(">> Item 1") }
    end
  end

  def test_navigation_down_twice
    with_test_terminal(80, 20) do
      inject_keys(:down, :down, :q)

      @app.run

      assert buffer_content.any? { |line| line.include?(">> Item 2") }
    end
  end

  def test_quit
    with_test_terminal(50, 20) do
      inject_key(:q)
      @app.run
      # Success
    end
  end

  def test_toggle_highlight_spacing
    with_test_terminal(80, 10) do
      assert_equal :when_selected, @app.highlight_spacing

      inject_key(:s)
      @app.handle_input
      assert_equal :always, @app.highlight_spacing

      inject_key(:s)
      @app.handle_input
      assert_equal :never, @app.highlight_spacing

      inject_key(:s)
      @app.handle_input
      assert_equal :when_selected, @app.highlight_spacing
    end
  end

  def test_spacing_always_shows_column_without_selection
    with_test_terminal(80, 10) do
      # Set spacing to :always
      inject_key(:s)
      @app.handle_input

      @app.render

      # With :always, spacing column is shown even without selection
      assert buffer_content.any? { |line| line.include?("   Item 1") }
    end
  end
end

