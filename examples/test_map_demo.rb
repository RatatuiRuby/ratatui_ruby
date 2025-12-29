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
        "┌World Map Canvas──┐",
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

  def test_map_demo_animation
    with_test_terminal(20, 10) do
      # We verify animation by inspecting the radius passed to view() method.
      # We spy on MapDemo.view.
      
      view_args = []
      # Needs to be a module method stub
      # We can use define_singleton_method or Minitest mock but stubbing a module method with tracking is tricky with just .stub
      # So we redefine it temporarily.

      original_view = MapDemo.method(:view)
      MapDemo.define_singleton_method(:view) do |radius|
        view_args << radius
        original_view.call(radius)
      end

      begin
        MapDemo.stub :sleep, nil do
          # 3 loops: radius 0.5 -> 1.0 -> 1.5 -> quit
          inject_keys(:up, :up, :q)

          MapDemo.run
        end
      ensure
        MapDemo.define_singleton_method(:view, &original_view)
      end

      # We asserted that it runs 3 times.
      # radii should be 0.5, 1.0, 1.5
      assert_operator view_args.size, :>=, 3
      assert_equal 0.5, view_args[0]
      assert_equal 1.0, view_args[1]
      assert_equal 1.5, view_args[2]
    end
  end
end
