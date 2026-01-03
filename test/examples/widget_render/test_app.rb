# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_render/app"

class TestWidgetRender < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetRender.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key("q")
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_cycle_next_widget
    with_test_terminal do
      inject_keys("n", "q")
      @app.run

      assert_snapshot("after_cycle_next")
      assert_rich_snapshot("after_cycle_next")
    end
  end

  def test_cycle_previous_widget
    with_test_terminal do
      inject_keys("p", "q")
      @app.run

      assert_snapshot("after_cycle_previous")
      assert_rich_snapshot("after_cycle_previous")
    end
  end

  def test_cycle_to_border_widget
    with_test_terminal do
      inject_keys("n", "n", "q")
      @app.run

      assert_snapshot("border_widget")
      assert_rich_snapshot("border_widget")
    end
  end
end
