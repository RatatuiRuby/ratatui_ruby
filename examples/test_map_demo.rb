# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "map_demo"

class TestMapDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_map_demo_renders
    # Use a specific terminal size to make assertions reliable
    with_test_terminal(20, 10) do
      view = MapDemo.view(0.0)
      RatatuiRuby.draw(view)

      expected_buffer = [
        "┌World Map Canvas──┐",
        "│⣀⣀⣠⣶⣶⣶⡖⣲⠂⣶⣒⣦⣤⠶⢤⣤⣄⣀│",
        "│⠹⠓⢦ ⠻⣿⡟⠉⣿⡿⣋⡁⠁  ⣴⠿⠋│",
        "│⢀⡀⠘⣆⣴⡏ ⢀⡟⠻⣿⣧⣀⣀⣹⠟  │",
        "│ ⠁ ⠈⢻⠿⣄⠘⢦⡔⢚⡏⠻⣽⣿⣀⡀ │",
        "│⠄   ⠘⡆⣸⠃ ⡇⣼⡆ ⠈⡻⢿⣻⠤│",
        "│     ⣷⠃  ⠙⠃ ⡀ ⠓⢳⢇⡆│",
        "│   ⢀⡀⣻  ⣀⣀⣀⣤⣁⣤⣤⣄⣀⡀│",
        "│⠾⠿⠉⠉⠙⠛⠛⠋⠁       ⠘⠧│",
        "└──────────────────┘",
      ]

      expected_buffer.each_with_index do |line, i|
        assert_equal line, buffer_content[i], "Line #{i} should match"
      end
    end
  end

  def test_quit
    # We need to use with_test_terminal because MapDemo.run calls init_terminal and draw
    with_test_terminal(80, 24) do
      # Inject 'q' event
      inject_event("key", { code: "q" })

      # MapDemo.run should exit immediately after polling the 'q' event
      # We use Timeout to prevent hanging if it's not quittable
      require "timeout"
      Timeout.timeout(1) do
        MapDemo.run
      end
    end
  end

  def test_map_demo_animation
    # Test that the animation actually happens within the run loop
    with_test_terminal(20, 10) do
      # We want to verify that the radius changes.
      # We'll mock RatatuiRuby.draw to capture the views being drawn.
      draw_calls = []

      # We need to preserve the original behavior of draw if we want to see it in the test terminal,
      # but for this test, we just want to inspect the view objects.

      # Using a lambda as a mock for RatatuiRuby.draw
      original_draw = RatatuiRuby.method(:draw)
      RatatuiRuby.define_singleton_method(:draw) do |view|
        draw_calls << view
        original_draw.call(view)
      end

      begin
        MapDemo.stub :sleep, nil do
          # Inject some non-quitting events to let it loop
          # radius starts at 0.0
          # 1st loop: radius becomes 0.5, draws, polls 'up', sleeps
          # 2nd loop: radius becomes 1.0, draws, polls 'up', sleeps
          # 3rd loop: radius becomes 1.5, draws, polls 'q', breaks
          inject_event("key", { code: "up" })
          inject_event("key", { code: "up" })
          inject_event("key", { code: "q" })

          MapDemo.run
        end
      ensure
        # Restore original draw method
        RatatuiRuby.define_singleton_method(:draw, &original_draw)
      end

      assert_operator draw_calls.size, :>=, 3

      # Check that the radius in each view is increasing
      radii = draw_calls.map { |v| v.shapes.find { |s| s.is_a?(RatatuiRuby::Circle) }.radius }

      assert_equal 0.5, radii[0]
      assert_equal 1.0, radii[1]
      assert_equal 1.5, radii[2]
    end
  end
end
