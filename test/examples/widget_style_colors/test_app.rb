# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_style_colors/app"

class TestWidgetStyleColors < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetStyleColors.new
  end

  def test_renders_with_title
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Hex Color Gradient"
    end
  end

  def test_renders_gradient_cells
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # Should have many spaces (gradient cells)
      assert content.length > 500
    end
  end

  def test_exit_on_q
    with_test_terminal do
      inject_key(:q)
      @app.run
      # If we get here without hanging, exit worked
      assert true
    end
  end
end
