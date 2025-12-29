# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "box_demo"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

class TestBoxDemo < Minitest::Test
  def setup
    @app = BoxDemoApp.new
  end

  def test_render_initial_state
    with_test_terminal(40, 10) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Box Demo") }
      assert buffer_content.any? { |line| line.include?("Press Arrow Keys") }
    end
  end

  def test_interaction
    inject_event(RatatuiRuby::Event::Key.new(code: "up"))
    @app.handle_input

    with_test_terminal(40, 10) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Up Pressed!") }
    end
  end
  def test_title_alignment_cycle
    # Width 40. Title "Box Demo - plain" (16 chars).

    # 1. Initial State (Left)
    with_test_terminal(40, 10) do
      @app.render
      # Line 0: ┌Box Demo - plain──────────────────────┐
      top_line = buffer_content[0]
      assert_match(/^┌Box Demo - plain.+┐/, top_line, "Title should be left-aligned initially")
    end
    
    # 2. Switch to Center
    inject_event(RatatuiRuby::Event::Key.new(code: "enter"))
    @app.handle_input

    with_test_terminal(40, 10) do
      @app.render
      # Check text feedback
      assert buffer_content.any? { |line| line.include?("Aligned center") }
      
      # Check actual title position. 
      # "Box Demo - plain" should be centered.
      # (40 - 2 (borders) - 16) / 2 = 11 spaces padding on each side inside borders.
      # Line 0: ┌───────────Box Demo - plain───────────┐
      # We check for border chars (implied by non-whitespace) or just match the structure
      top_line = buffer_content[0]
      # Using .+ to match the horizontal lines
      assert_match(/┌.+Box Demo - plain.+┐/, top_line, "Title should be centered")
    end

    # 3. Switch to Right
    inject_event(RatatuiRuby::Event::Key.new(code: "enter"))
    @app.handle_input

    with_test_terminal(40, 10) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Aligned right") }
      
      # Check actual title position. 
      # "Box Demo - plain" should be on the right.
      # Line 0: ┌──────────────────────Box Demo - plain┐
      # Line 0: ┌──────────────────────Box Demo - plain┐
      top_line = buffer_content[0]
      assert_match(/Box Demo - plain┐$/, top_line, "Title should be right-aligned")
    end

    # 4. Switch back to Left
    inject_event(RatatuiRuby::Event::Key.new(code: "enter"))
    @app.handle_input

    with_test_terminal(40, 10) do
      @app.render
      top_line = buffer_content[0]
      assert_match(/^┌Box Demo - plain.+┐/, top_line, "Title should be left-aligned again")
    end
  end

  def test_border_type_cycle
    # Initial state is :plain.
    # Press Space to switch to :rounded
    inject_event(RatatuiRuby::Event::Key.new(code: " "))
    @app.handle_input

    with_test_terminal(40, 10) do
      @app.render
      # Check text feedback
      assert buffer_content.any? { |line| line.include?("Switched to rounded") }
      
      # Check visual representation of rounded corners
      # Top-left is ╭ (U+256D), Top-right is ╮ (U+256E), Bottom-left is ╰ (U+2570), Bottom-right is ╯ (U+256F)
      top_line = buffer_content[0]
      assert_match(/^╭/, top_line, "Should have rounded top-left corner")
      assert_match(/╮$/, top_line, "Should have rounded top-right corner")
    end

    # Press Space again to switch to :double
    inject_event(RatatuiRuby::Event::Key.new(code: " "))
    @app.handle_input

    with_test_terminal(40, 10) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Switched to double") }
      
      # Check visual representation of double corners
      # Top-left is ╔ (U+2554)
      top_line = buffer_content[0]
      assert_match(/^╔/, top_line, "Should have double top-left corner")
    end
  end
end
