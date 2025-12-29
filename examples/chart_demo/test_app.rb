# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestChartDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = ChartDemoApp.new
  end

  def test_render
    # Set a timeout since chart_demo has a sleep 0.1 in its loop
    with_test_terminal do
      inject_key(:q)
      @app.run
      
      content = buffer_content.join("\n")
      assert_includes content, "Chart Demo (Q to quit)"
      assert_includes content, "Time"
      assert_includes content, "Amplitude"
      assert_includes content, "Scatter"
      assert_includes content, "Line"
    end
  end
end
