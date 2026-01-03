# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_center_demo/app"

class TestWidgetCenterDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetCenterDemo.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run
      assert_snapshot("initial_render")
    end
  end

  def test_interaction
    with_test_terminal do
      # Decrease width/height
      inject_key(:left)
      inject_key(:down)
      # Quit
      inject_key(:q)

      @app.run

      assert_snapshot("after_sizing")
    end
  end
end
