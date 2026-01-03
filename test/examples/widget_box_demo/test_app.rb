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

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_color_cycling
    with_test_terminal do
      inject_keys(:up, :q)
      @app.run

      assert_snapshot("after_color_cycle")
      assert_rich_snapshot("after_color_cycle")
    end
  end

  def test_border_type_cycling
    with_test_terminal do
      inject_keys(" ", :q)
      @app.run

      assert_snapshot("after_border_cycle")
      assert_rich_snapshot("after_border_cycle")
    end
  end

  def test_title_alignment_cycling
    with_test_terminal do
      inject_keys(:enter, :q)
      @app.run

      assert_snapshot("after_title_align_cycle")
      assert_rich_snapshot("after_title_align_cycle")
    end
  end

  def test_content_style_cycling
    with_test_terminal do
      inject_keys(:s, :q)
      @app.run

      assert_snapshot("after_content_style_cycle")
      assert_rich_snapshot("after_content_style_cycle")
    end
  end

  def test_title_style_cycling
    with_test_terminal do
      inject_keys(:t, :q)
      @app.run

      assert_snapshot("after_title_style_cycle")
      assert_rich_snapshot("after_title_style_cycle")
    end
  end

  def test_border_style_cycling
    with_test_terminal do
      inject_keys(:b, :q)
      @app.run

      assert_snapshot("after_border_style_cycle")
      assert_rich_snapshot("after_border_style_cycle")
    end
  end
end
