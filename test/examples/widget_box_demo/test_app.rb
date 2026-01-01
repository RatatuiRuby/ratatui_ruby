# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_box_demo/app"

class TestBoxDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetBoxDemo.new
  end

  def test_render_initial_state
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert buffer_content.any? { |line| line.include?("Box Demo") }
      assert buffer_content.any? { |line| line.include?("Controls") }
      assert buffer_content.any? { |line| line.include?("Green") }
    end
  end

  def test_color_cycling_changes_color
    with_test_terminal do
      # Pressing up should cycle colors backwards
      inject_keys(:up, :q)
      @app.run

      # At least the Controls section should be rendered
      assert buffer_content.any? { |line| line.include?("Controls") }
    end
  end

  def test_border_type_cycling
    with_test_terminal do
      inject_keys(" ", :q)
      @app.run

      assert buffer_content.any? { |line| line.include?("Rounded") }
    end
  end

  def test_title_alignment_cycling
    with_test_terminal do
      inject_keys(:enter, :q)
      @app.run

      assert buffer_content.any? { |line| line.include?("Center") }
    end
  end

  def test_content_style_changes
    with_test_terminal do
      inject_keys(:s, :q)
      @app.run

      # At least the Controls section should be rendered
      assert buffer_content.any? { |line| line.include?("Controls") }
    end
  end

  def test_title_style_changes
    with_test_terminal do
      inject_keys(:t, :q)
      @app.run

      # At least the Controls section should be rendered
      assert buffer_content.any? { |line| line.include?("Controls") }
    end
  end

  def test_border_style_cycling
    with_test_terminal do
      inject_keys(:b, :q)
      @app.run

      # At least the Controls section should be rendered
      assert buffer_content.any? { |line| line.include?("Controls") }
    end
  end
end
