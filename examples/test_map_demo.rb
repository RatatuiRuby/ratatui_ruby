# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require "minitest/mock"
require_relative "map_demo"

class TestMapDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_map_demo_renders
    with_test_terminal(20, 10) do
      # Queue quit event
      inject_key(:q)

      # Stub sleep to speed up test
      MapDemo.stub :sleep, nil do
        MapDemo.run
      end

      # Verify the buffer content reflects the rendered map
      # radius should be 0.5 for the first frame
      expected_buffer = [
        "┌World Map ['b' bac┐",
        "│⡀⣀⣀⣤⣴⣶⣖⢲⡆⢠⣄⢤⣄⡤⣤⣠⣄⣀│",
        "│⠹⠷⢫⡉⠿⣿⡟⠉⢳⡾⣟⣉⠉  ⢰⣺⠛│",
        "│  ⠘⣦⣤⡏⠁ ⡼⠿⢿⣟⡀ ⢸⠿⠁ │",
        "│ ⠁ ⠈⠻⡿⣄ ⢇⣄⠞⡟⠹⢹⣿⡆  │",
        "│⠄    ⢧⢈⡇⠈⢹⢸⡅ ⠈⢻⢿⣟⣤│",
        "│     ⣼⠞  ⠘⠚⠁  ⠸⠲⡇⣦│",
        "│     ⢛⡇   ⢀⣀⣁⣀⣀⣀⣀⠁│",
        "│⠤⠾⠍⠉⠉⠻⠷⠖⠋⠉⠉ ⠉   ⠸⠧│",
        "└──────────────────┘",
      ]

      expected_buffer.each_with_index do |line, i|
        assert_equal line, buffer_content[i], "Line #{i} should match"
      end

      # Verify the background color is set on the view (Unit test of the view method)
      view = MapDemo.view(0.0, :braille, nil)
      assert_nil view.background_color
    end
  end

  def test_background_default
    with_test_terminal(20, 10, timeout: 5) do
      inject_keys("q")
      MapDemo.stub :sleep, nil do
        MapDemo.run
      end
      # View is roughly at (1,1) to (18,8) inside borders. (10, 5) is safely inside.
      assert_cell_style(10, 5, bg: :black)
    end
  end

  def test_background_blue
    with_test_terminal(20, 10, timeout: 5) do
      inject_keys("b", "q")
      MapDemo.stub :sleep, nil do
        MapDemo.run
      end
      assert_cell_style(10, 5, bg: :blue)
    end
  end

  def test_background_white
    with_test_terminal(20, 10, timeout: 5) do
      inject_keys("b", "b", "q")
      MapDemo.stub :sleep, nil do
        MapDemo.run
      end
      assert_cell_style(10, 5, bg: :white)
    end
  end

  def test_background_transparent
    with_test_terminal(20, 10, timeout: 5) do
      inject_keys("b", "b", "b", "q")
      MapDemo.stub :sleep, nil do
        MapDemo.run
      end
      # Transparent typically means no bg color set on the cell
      assert_cell_style(10, 5, bg: nil)
    end
  end

  def test_quit
    with_test_terminal(80, 24) do
      inject_key(:q)
      
      MapDemo.stub :sleep, nil do
        MapDemo.run
      end
    end
  end
end
