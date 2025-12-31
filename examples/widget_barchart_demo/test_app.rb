# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestWidgetBarchartDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetBarchartDemo.new
  end

  def test_render_initial_state
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert buffer_content.any? { |line| line.include?("BarChart Demo: Simple Hash") }
      assert buffer_content.any? { |line| line.include?("Controls") }
    end
  end

  def test_data_cycling
    with_test_terminal do
      # Cycle data (d) -> Styled Array -> Groups -> Simple Hash
      inject_keys(:d, :q)
      @app.run
      assert buffer_content.any? { |line| line.include?("BarChart Demo: Styled Array") }
    end

    with_test_terminal do
      inject_keys(:d, :q)
      @app.run
      assert buffer_content.any? { |line| line.include?("BarChart Demo: Groups") }
    end
  end

  def test_direction_toggle
    with_test_terminal do
      # Toggle direction (v)
      inject_keys(:v, :q)
      @app.run
      assert buffer_content.any? { |line| line.include?("Direction (horizontal)") }
    end
  end

  def test_width_gap_controls
    with_test_terminal do
      # Change width (w), gap (a), group gap (g)
      inject_keys(:w, :a, :g, :q)
      @app.run
      # Verify execution without crash
    end
  end

  def test_styles_controls
    with_test_terminal do
      # Change style (s), label (x), value (z), set (b)
      inject_keys(:s, :x, :z, :b, :q)
      @app.run
      # Verify execution without crash
    end
  end

  def test_mode_toggle
    with_test_terminal do
      # Toggle mini mode (m)
      inject_keys(:m, :q)
      @app.run
      assert buffer_content.any? { |line| line.include?("Mode (Mini)") }
    end
  end
end
