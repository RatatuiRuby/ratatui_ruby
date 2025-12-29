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

# Tests for the table_select example
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

  def test_toggle_selection_on
    with_test_terminal(100, 20) do
      # Press x to toggle on, then quit
      inject_keys(:x, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sel: 0"
      refute_includes content, "Sel: none"
    end
  end

  def test_toggle_selection_off
    with_test_terminal(100, 20) do
      # Press x to toggle on, x again to toggle off, then quit
      inject_keys(:x, :x, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sel: none"
    end
  end

  def test_navigation_selects_and_moves
    with_test_terminal(100, 20) do
      inject_keys(:down, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Sel: 0"
    end
  end

  def test_navigation_wrapping
    with_test_terminal(100, 20) do
      # Start nil, down->0, up->wraps to last
      inject_keys(:down, :up, :q)
      @app.run

      content = buffer_content.join("\n")
      last_index = PROCESSES.length - 1
      assert_includes content, "Sel: #{last_index}"
    end
  end

  def test_quit
    with_test_terminal(100, 20) do
      inject_key(:q)
      @app.run
    end
  end

  def test_highlight_spacing_cycles_to_never
    with_test_terminal(100, 20) do
      # Mode order: [:always, :when_selected, :never], starting at :when_selected
      # 'h' goes to :never
      inject_keys(:h, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Spacing: never"
    end
  end

  def test_highlight_spacing_cycles_to_always
    with_test_terminal(100, 20) do
      # 'h' goes: when_selected -> never -> always
      inject_keys(:h, :h, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Spacing: always"
    end
  end

  def test_highlight_spacing_cycles_back_to_when_selected
    with_test_terminal(100, 20) do
      # 'h' goes: when_selected -> never -> always -> when_selected
      inject_keys(:h, :h, :h, :q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Spacing: when_selected"
    end
  end
end
