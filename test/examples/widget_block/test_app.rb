# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_block/app"

class TestWidgetBlockDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetBlock.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run
      assert_snapshot("initial_render")
    end
  end

  def test_cycling_attributes
    with_test_terminal do
      inject_key("t") # Cycle title
      inject_key("a") # Cycle alignment
      inject_key("b") # Cycle borders
      inject_key("p") # Cycle padding
      inject_key(:q)
      @app.run
      assert_snapshot("after_cycling")
    end
  end
end
