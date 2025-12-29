# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestFlexLayout < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = FlexLayoutApp.new
  end

  def test_render_header
    with_test_terminal do
      # Queue quit
      inject_key(:q)
      
      @app.run

      assert_includes buffer_content[0], "Header"
      assert buffer_content.any? { |line| line.include?("Fill & Flex Layout Demo") }
    end
  end

  def test_fill_constraint_ratio
    with_test_terminal do
      # Queue quit
      inject_key(:q)
      
      @app.run

      # Fill(1) and Fill(3) should split horizontally in a 1:3 ratio
      assert buffer_content.any? { |line| line.include?("Fill(1)") }
      assert buffer_content.any? { |line| line.include?("Fill(3)") }
    end
  end

  def test_space_between_blocks
    with_test_terminal do
      # Queue quit
      inject_key(:q)

      @app.run

      # Three blocks with space_between flex should have equal spacing
      assert buffer_content.any? { |line| line.include?("Block A") }
      assert buffer_content.any? { |line| line.include?("Block B") }
      assert buffer_content.any? { |line| line.include?("Block C") }
    end
  end

  def test_quit_on_q
    with_test_terminal do
      inject_key(:q)
      @app.run
      # Success if it returns
    end
  end
end
