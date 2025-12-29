#!/usr/bin/env ruby
# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "minitest/autorun"
require "ratatui_ruby/test_helper"

require_relative "app"

class TestScrollText < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @demo = ScrollTextDemo.new
  end

  def test_demo_initialization
    assert_instance_of ScrollTextDemo, @demo
  end

  def test_initial_rendering
    with_test_terminal(80, 10) do
      # Queue quit
      inject_key(:q)
      
      @demo.run

      content = buffer_content
      
      # Should show Line 1 somewhere in the output
      assert content.any? { |line| line.include?("Line 1") }
      # Should show controls sidebar
      assert content.any? { |line| line.include?("Controls") }
      assert content.any? { |line| line.include?("↑: Scroll Up (0)") }
    end
  end

  def test_scroll_down
    with_test_terminal(80, 10) do
      # Scroll down then quit
      inject_keys(:down, :q)

      @demo.run

      content = buffer_content
      
      # Should show controls with updated Y position
      assert content.any? { |line| line.include?("↓: Scroll Down") }
    end
  end

  def test_scroll_right
    with_test_terminal(80, 10) do
      # Scroll right then quit
      inject_keys(:right, :q)

      @demo.run

      content = buffer_content
      
      # Should render without error
      assert content.any? { |line| line.include?("Controls") }
    end
  end

  def test_scroll_left_at_edge
    with_test_terminal(80, 10) do
      # Scroll left then quit (boundary test)
      inject_keys(:left, :q)

      @demo.run

      content = buffer_content
      
      # Should still show the controls
      assert content.any? { |line| line.include?("↑: Scroll Up") }
    end
  end

  def test_scroll_up_at_top
    with_test_terminal(80, 10) do
      # Scroll up then quit (boundary test)
      inject_keys(:up, :q)

      @demo.run

      content = buffer_content
      
      # Should still show the controls
      assert content.any? { |line| line.include?("Controls") }
    end
  end

  def test_multiple_scrolls
    with_test_terminal(80, 10) do
      # Scroll down and right multiple times
      inject_keys(:down, :down, :right, :right, :right, :q)

      @demo.run

      content = buffer_content
      
      # Should render without error
      assert content.any? { |line| line.include?("Scrollable Text") }
    end
  end
end
