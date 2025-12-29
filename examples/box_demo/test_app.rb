# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestBoxDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = BoxDemoApp.new
  end

  def test_render_initial_state
    with_test_terminal(40, 10) do
      # Queue quit
      inject_key(:q)

      @app.run

      assert buffer_content.any? { |line| line.include?("Box Demo") }
      assert buffer_content.any? { |line| line.include?("Press Arrow Keys") }
    end
  end

  def test_interaction
    with_test_terminal(40, 10) do
      # Press up then quit
      inject_keys(:up, :q)
      
      @app.run

      assert buffer_content.any? { |line| line.include?("Up Pressed!") }
    end
  end

  def test_title_alignment_cycle
    # We can check sequential states by running multiple times or checking final state.
    # To test behavior, we'll verify the final state after a sequence of inputs.
    
    # 1. Left (default) -> Center (enter) -> Right (enter) -> Left (enter)
    
    # Check Center (Enter once)
    with_test_terminal(40, 10) do
      inject_keys(:enter, :q)
      @app.run
      
      assert buffer_content.any? { |line| line.include?("Aligned center") }
      # "Box Demo - plain" should be centered.
      assert_match(/┌.+Box Demo - plain.+┐/, buffer_content[0], "Title should be centered")
    end
  end
  
  def test_title_alignment_right
    setup # reset app
    with_test_terminal(40, 10) do
      # Enter twice for Right
      inject_keys(:enter, :enter, :q)
      
      @app.run

      assert buffer_content.any? { |line| line.include?("Aligned right") }
      assert_match(/Box Demo - plain┐$/, buffer_content[0], "Title should be right-aligned")
    end
  end

  def test_border_type_cycle
    with_test_terminal(40, 10) do
      # Press Space (rounded) then quit
      inject_keys(" ", :q)
      
      @app.run

      assert buffer_content.any? { |line| line.include?("Switched to rounded") }
      top_line = buffer_content[0]
      assert_match(/^╭/, top_line, "Should have rounded top-left corner")
      assert_match(/╮$/, top_line, "Should have rounded top-right corner")
    end
  end
end
