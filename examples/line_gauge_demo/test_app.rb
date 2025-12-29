# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestLineGaugeDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = LineGaugeDemoApp.new
  end

  def test_initial_render
    with_test_terminal(80, 24) do
      inject_key(:q)
      @app.run
      
      content = buffer_content.join("\n")
      assert_includes content, "LineGauge Widget Demo"
      assert_includes content, "20%"
      assert_includes content, "50%"
      assert_includes content, "80%"
      # Initial interactive gauge (20%)
      assert_includes content, "Current ratio: 1/3"
    end
  end

  def test_ratio_cycling
    with_test_terminal(80, 24) do
      # Cycle right twice
      inject_keys(:right, :right, :q)
      @app.run
      
      content = buffer_content.join("\n")
      assert_includes content, "80%"
      assert_includes content, "Current ratio: 3/3"
    end
  end
end
