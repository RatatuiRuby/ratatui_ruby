# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_canvas_demo/app"

class TestWidgetCanvasDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetCanvasDemo.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      # The canvas demo is animated/time-based, but our test harness
      # runs faster than the frame loop sleep (or injects keys immediately),
      # and the time increments by 0.1 per loop.
      # The first render happens with time=0.1
      # Since we can't easily control the time variable inside the app from here
      # without modifying the app, we accept that it will render the state at t=0.1.
      # Since math is deterministic, this should be fine as long as we don't sleep randomly.

      assert_snapshot("initial_render")
    end
  end
end
