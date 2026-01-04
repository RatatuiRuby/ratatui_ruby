# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require "faker"
require_relative "../../../examples/widget_tabs/app"

class TestWidgetTabsDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    Faker::Config.random = Random.new(42)
    @app = WidgetTabs.new
  end

  def teardown
    Faker::Config.random = nil
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_navigation
    with_test_terminal do
      inject_keys(:right, :right, :left, :q)
      @app.run

      assert_snapshot("after_navigation")
      assert_rich_snapshot("after_navigation")
    end
  end

  def test_switch_divider
    with_test_terminal do
      inject_keys(:d, :q)
      @app.run

      assert_snapshot("after_divider_switch")
      assert_rich_snapshot("after_divider_switch")
    end
  end

  def test_switch_style
    with_test_terminal do
      inject_keys(:s, :q)
      @app.run

      assert_snapshot("after_style_switch")
      assert_rich_snapshot("after_style_switch")
    end
  end

  def test_switch_base_style
    with_test_terminal do
      inject_keys(:b, :q)
      @app.run

      assert_snapshot("after_base_style_switch")
      assert_rich_snapshot("after_base_style_switch")
    end
  end

  def test_padding_controls
    with_test_terminal do
      inject_keys(:l, :l, :k, :k, :k, :q)
      @app.run

      assert_snapshot("after_padding_changes")
      assert_rich_snapshot("after_padding_changes")
    end
  end
end
