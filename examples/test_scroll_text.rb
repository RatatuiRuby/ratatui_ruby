#!/usr/bin/env ruby
# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "minitest/autorun"
require "ratatui_ruby/test_helper"

# Load the demo
require_relative "./scroll_text"

class TestScrollText < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @demo = ScrollTextDemo.new
  end

  def test_demo_initialization
    assert_instance_of ScrollTextDemo, @demo
  end

  def test_initial_rendering
    with_test_terminal(60, 10) do
      @demo.render
      content = buffer_content
      
      # Should show Line 1 at the top (inside the block border)
      assert content[1].include?("Line 1")
      # Should show title with scroll position 0, 0
      assert content[0].include?("X: 0, Y: 0")
    end
  end

  def test_scroll_down
    inject_event(RatatuiRuby::Event::Key.new(code: "down"))
    @demo.handle_input
    
    with_test_terminal(60, 10) do
      @demo.render
      content = buffer_content
      
      # After scrolling down once, Line 2 should be at the top
      assert content[1].include?("Line 2"), "Expected Line 2 at top, got: #{content[1]}"
      # Line 1 should not be visible (scrolled off)
      refute content.any? { |line| line.include?("Line 1") }, "Line 1 should be scrolled off"
      # Should show Y scroll position 1
      assert content[0].include?("Y: 1")
    end
  end

  def test_scroll_right
    inject_event(RatatuiRuby::Event::Key.new(code: "right"))
    @demo.handle_input
    
    with_test_terminal(60, 10) do
      @demo.render
      content = buffer_content
      
      # After scrolling right once, first character should be cut off
      # "Line 1:" becomes "ine 1:"
      assert content[1].include?("ine 1:"), "Expected horizontal scroll, got: #{content[1]}"
      # Should show X scroll position 1
      assert content[0].include?("X: 1")
    end
  end

  def test_scroll_left_at_edge
    # Try to scroll left when already at x=0
    inject_event(RatatuiRuby::Event::Key.new(code: "left"))
    @demo.handle_input
    
    with_test_terminal(60, 10) do
      @demo.render
      content = buffer_content
      
      # Should still show full "Line 1:" (can't scroll left past 0)
      assert content[1].include?("Line 1:")
      # Should still show X scroll position 0
      assert content[0].include?("X: 0")
    end
  end

  def test_scroll_up_at_top
    # Try to scroll up when already at top (should stay at 0)
    inject_event(RatatuiRuby::Event::Key.new(code: "up"))
    @demo.handle_input
    
    with_test_terminal(60, 10) do
      @demo.render
      content = buffer_content
      
      # Should still show Line 1 at top (can't scroll above 0)
      assert content[1].include?("Line 1")
      # Should still show Y scroll position 0
      assert content[0].include?("Y: 0")
    end
  end

  def test_scroll_both_axes
    # Scroll down 2 times and right 3 times
    2.times do
      inject_event(RatatuiRuby::Event::Key.new(code: "down"))
      @demo.handle_input
    end
    3.times do
      inject_event(RatatuiRuby::Event::Key.new(code: "right"))
      @demo.handle_input
    end
    
    with_test_terminal(60, 10) do
      @demo.render
      content = buffer_content
      
      # After scrolling down 2 and right 3, Line 3 should be at top with first 3 chars cut
      # "Line 3:" becomes " 3:"
      assert content[1].include?(" 3:"), "Expected Line 3 scrolled right by 3, got: #{content[1]}"
      # Should show scroll position X: 3, Y: 2
      assert content[0].include?("X: 3, Y: 2")
    end
  end

  def test_quit
    inject_event(RatatuiRuby::Event::Key.new(code: "q"))
    status = @demo.handle_input
    assert_equal :quit, status
  end
end
