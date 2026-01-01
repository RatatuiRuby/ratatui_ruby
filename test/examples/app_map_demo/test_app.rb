# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require "minitest/mock"
require_relative "../../../examples/app_map_demo/app"

class TestAppMapDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = AppMapDemo.new
  end

  def test_map_demo_renders
    with_test_terminal do
      # Queue events: turn off labels so buffer matches original, then quit
      inject_keys("l", "q")

      # Stub sleep to speed up test
      @app.stub :sleep, nil do
        @app.run
      end

      # Verify the buffer content reflects the rendered map (with labels off)
      expected_buffer = [
        "┌World Map ['b' bg, 'm' marker: braille, 'l' labels: off]──────────────────────┐",
        "│                     ⣀⢀⣀⣀⡀   ⢀⣀⡀ ⡀                                            │",
        "│            ⢠⣤⣰⣦⣶⣶⣿⣭⣿⣣⠶⠶⣿⣉⣉⠉⠉⠁  ⠁⠉⢽⠎⠁    ⠲⠶⠶⠖   ⠐⠛⢃⡀⣀⢤   ⢀⣐⣋⣷⠶⡤⣀    ⣀⡀⣀⡀      │",
        "│⢖⡀⡀⣤⡖⠒⠒⠤⠤⠤⠤⠶⠿⠿⣿⣹⢿⣿⣿⢿⣭⣽⣿⡒⣦⣀⠘⣷⠄  ⢀⡀⢼⣏⢀      ⡠⠤⠒⠶⡤⢀⣄⡀⢻⠯⠤⢾⣻⡗⠛⠉    ⠈⠉⠈⠈⠙⠒⠚⠋ ⠒⠐⠦⠤⠤⠤⠶│",
        "│⠉⠉⠻⣿⣃⣀⣤⡤⣄⣀⡀       ⢠⠒⠛⠳⡟⠳⣿⣏ ⠙⠦⠴⠋⠁ ⠈⠛⠋⠁⢀⡀ ⣖⡉⢰⢾⣥⡄⠙⠉⠁     ⠈              ⢀⣀⣀⡠⣤⣦⢤⠤⠛│",
        "│   ⠒⠛⠉⠁   ⠿⣄⡀      ⠉⠓⢖⠎ ⢀⣘⣲⡄        ⠰⣾⣟⣄⠼⠛⠟⠚⠁                       ⠺⣶  ⢪⠜⠁   │",
        "│           ⠈⡟          ⢸⠭⠿⠛⠛        ⢀⡤⣿⢀⣠⣴⣆⡀⢀⣴⣶⢆ ⡶⣆               ⢀⣀⡔⣽⡅       │",
        "│            ⠳⣀       ⢀⣺⠉            ⠘⣧⢴⠧⠼⡿⠟⠻⣿⢭⣬⠉ ⠸⠿             ⢺⠟⣿⣠⣶⡟        │",
        "│             ⠘⢿⣄  ⡔⠒⠒⣿⡄            ⢀⡼    ⠈⠙⠋⠉⠛⣿⡀ ⢶⣤⣄⣀⡀          ⢠⡇⠈⠋          │",
        "│    ⠐⠦        ⠈⠉⢧⣘⢆⣴⡞⠛⣷⣤⣄          ⣯          ⣸⣷⡊⠉⣉⡽ ⠙⢲ ⢀⡴⠻⣄ ⢰⣶⠚⢙⡁            │",
        "│                 ⠈⠉⠛⢯⣇⣠⣴⢤⣤⡀        ⢧⡀      ⡠⠔⠊ ⠙⠷⢮⠅   ⠈⣇⣏  ⠉⣷⢄⠵ ⣸⣷⡄           │",
        "│                     ⢉⡇   ⠙⠲⡄       ⠙⠒⢒⣊⡲⡔⠉     ⣀⠎     ⠈⠋  ⠰⡿⡆⣠⠔⣗⣙⣣           │",
        "│                     ⢼      ⠉⠓⠲⣄      ⠈⠁⠈⢢     ⡼⠁           ⠘⢽⣝⣒⣻⡯⡛⢻⣮⢒⣦⡶⣄⡀    │",
        "│⡀                    ⠈⢢⡀      ⢰⠃         ⢸     ⢹⢀⣴             ⠉⠉⣙⣥⠖⣎⣽⡌⠃ ⠙⢀⡀ ⢀│",
        "│⠁                      ⢸    ⢀⣀⠏          ⠸⡄   ⣲⠁⡝⡞             ⣤⠖⠋  ⠈⠁⠑⣆  ⠶⠁ ⠉│",
        "│                       ⢸   ⢀⠞             ⢳  ⡰⠃ ⠉⠁             ⢹ ⢀⣀⣀⢀  ⢸⠆     │",
        "│                       ⡎⢀⣠⠽⠉              ⠈⠉⠉                  ⠈⠉⠉ ⠈⠛⠦⣤⠎    ⣷⡄│",
        "│                      ⢸⠇⢴⠁                           ⢀⡀               ⠛   ⠰⠾⠋ │",
        "│                      ⠘⠶⠧⠐⠛                          ⠈⠁                       │",
        "│                        ⢀⣠⡤                       ⣀⡀         ⡀ ⣀    ⡀         │",
        "│         ⢀⣀⣀⣀⣀⣀⡀⢠⣤⣄⣀⣀⣀⣠⣴⡿⢳         ⣀⡤⠤⠤⠤⠔⠶⠖⠲⠤⠒⠒⠒⠋⠉⠁⠉⠉⠹⠶⠒⠋⠉⠉⠉⠉⠈⠉⠈⠉⠉⠉⠉⠉⠉⠉⠒⠒⠲⢤⣤  │",
        "│   ⠰⠶⣶⣶⠏⠉⠉  ⠉ ⠈⠉⠉⠁    ⠶⢞⣩⣥⡄⣤⣶⣶⣀⣶⡶⠉⠉⠉                                     ⣠⣿   │",
        "│⠉⠉⠉⠉⠒⠘⠙⠓⠃                 ⠉                                               ⠈⠁⠉⠉│",
        "└──────────────────────────────────────────────────────────────────────────────┘",
      ]

      expected_buffer.each_with_index do |line, i|
        assert_equal line, buffer_content[i], "Line #{i} should match"
      end

      # Verify the background color is set on the view (Unit test of the view method)
      session = RatatuiRuby::Session.new
      view = @app.view(session, 0.0, :braille, nil)
      assert_nil view.background_color

      # Verify labels are included in the shapes (default show_labels: true)
      label_shapes = view.shapes.select { |s| s.is_a?(RatatuiRuby::Shape::Label) }
      assert_equal 5, label_shapes.size, "Should have 5 city labels"
      assert label_shapes.any? { |l| l.text == "London" }, "Should have London label"
      assert label_shapes.any? { |l| l.text == "Tokyo" }, "Should have Tokyo label"
    end
  end

  def test_labels_visible
    with_test_terminal do
      # Don't toggle labels - they're on by default
      inject_keys("q")
      @app.stub :sleep, nil do
        @app.run
      end
      # Labels should be visible - check for a city name in the buffer
      buffer_text = buffer_content.join
      assert_includes buffer_text, "London", "London label should be visible"
    end
  end

  def test_labels_toggle
    with_test_terminal do
      inject_keys("l", "q")
      @app.stub :sleep, nil do
        @app.run
      end
      # After pressing 'l', labels should be off - check title
      assert_includes buffer_content[0], "labels: off"
    end
  end

  def test_background_default
    with_test_terminal(timeout: 5) do
      inject_keys("q")
      @app.stub :sleep, nil do
        @app.run
      end
      # View is roughly at (1,1) to (18,8) inside borders. (10, 5) is safely inside.
      assert_cell_style(10, 5, bg: :black)
    end
  end

  def test_background_blue
    with_test_terminal(timeout: 5) do
      inject_keys("b", "q")
      @app.stub :sleep, nil do
        @app.run
      end
      assert_cell_style(10, 5, bg: :blue)
    end
  end

  def test_background_white
    with_test_terminal(timeout: 5) do
      inject_keys("b", "b", "q")
      @app.stub :sleep, nil do
        @app.run
      end
      assert_cell_style(10, 5, bg: :white)
    end
  end

  def test_background_transparent
    with_test_terminal(timeout: 5) do
      inject_keys("b", "b", "b", "q")
      @app.stub :sleep, nil do
        @app.run
      end
      # Transparent typically means no bg color set on the cell
      assert_cell_style(10, 5, bg: nil)
    end
  end

  def test_quit
    with_test_terminal do
      inject_key(:q)

      @app.stub :sleep, nil do
        @app.run
      end
    end
  end
end
