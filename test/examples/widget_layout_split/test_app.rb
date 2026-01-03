# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_layout_split/app"

class TestWidgetLayoutSplit < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetLayoutSplit.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_direction_cycling
    with_test_terminal do
      inject_keys("d", :q)
      @app.run

      assert_snapshot("after_direction_cycle")
      assert_rich_snapshot("after_direction_cycle")
    end
  end

  def test_flex_cycling
    with_test_terminal do
      inject_keys("f", :q)
      @app.run

      assert_snapshot("after_flex_cycle")
      assert_rich_snapshot("after_flex_cycle")
    end
  end

  def test_constraint_cycling
    with_test_terminal do
      inject_keys("c", :q)
      @app.run

      assert_snapshot("after_constraint_cycle")
      assert_rich_snapshot("after_constraint_cycle")
    end
  end

  def test_multiple_cycles
    with_test_terminal do
      inject_keys("d", "d", "f", "f", "c", :q)
      @app.run

      assert_snapshot("after_multiple_cycles")
      assert_rich_snapshot("after_multiple_cycles")
    end
  end

  def test_all_flex_modes
    with_test_terminal do
      7.times { inject_key("f") }
      inject_key(:q)
      @app.run

      assert_snapshot("after_all_flex_cycles")
      assert_rich_snapshot("after_all_flex_cycles")
    end
  end
end
