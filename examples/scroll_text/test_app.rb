#!/usr/bin/env ruby
# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "minitest/autorun"
require "ratatui_ruby/test_helper"

require_relative "app"

class TestScrollTextApp < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = ScrollTextApp.new
  end

  def test_demo_initialization
    assert_instance_of ScrollTextApp, @app
  end

  def test_initial_rendering
    with_test_terminal do
      # Queue quit
      inject_key(:q)

      @app.run

      content = buffer_content

      # Should show Line 1 somewhere in the output
      assert content.any? { |line| line.include?("Line 1") }
      # Should show controls
      assert content.any? { |line| line.include?("Controls") }
      assert content.any? { |line| line.include?("Vert Scroll (0/102)") }
    end
  end

  def test_scroll_down
    with_test_terminal do
      # Scroll down then quit
      inject_keys(:down, :q)

      @app.run

      content = buffer_content

      # Should show controls with updated Y position
      assert content.any? { |line| line.include?("Vert Scroll (1/102)") }
    end
  end

  def test_scroll_right
    with_test_terminal do
      # Scroll right then quit
      inject_keys(:right, :q)

      @app.run

      content = buffer_content

      # Should render without error
      assert content.any? { |line| line.include?("Controls") }
    end
  end

  def test_scroll_left_at_edge
    with_test_terminal do
      # Scroll left then quit (boundary test)
      inject_keys(:left, :q)

      @app.run

      content = buffer_content

      # Should still show the controls
      assert content.any? { |line| line.include?("Vert Scroll") }
    end
  end

  def test_scroll_up_at_top
    with_test_terminal do
      # Scroll up then quit (boundary test)
      inject_keys(:up, :q)

      @app.run

      content = buffer_content

      # Should still show the controls
      assert content.any? { |line| line.include?("Controls") }
    end
  end

  def test_multiple_scrolls
    with_test_terminal do
      # Scroll down and right multiple times
      inject_keys(:down, :down, :right, :right, :right, :q)

      @app.run

      content = buffer_content

      # Should render without error
      assert content.any? { |line| line.include?("Scrollable Text") }
    end
  end
end
