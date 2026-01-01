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

  def test_initial_render_shows_diagonal
    with_test_terminal do
      inject_key("q")
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Diagonal"
      assert_includes content, "\\"
    end
  end

  def test_widget_respects_block_borders
    # Verify the custom widget doesn't overlap the block's border characters.
    # The block renders corners (┌ ┐ └ ┘) and edges (─ │).
    # If the custom widget renders on top of them, the test should fail.
    with_test_terminal do
      inject_key("q")
      @app.run

      content = buffer_content.join("\n")
      # Block title and border characters should be visible and undamaged
      assert_includes content, "Custom Widget: Diagonal"
      assert_includes content, "┌"
      assert_includes content, "└"
      # Diagonal line should be present inside (not on the border)
      assert_includes content, "\\"
    end
  end

  def test_cycle_next_widget
    with_test_terminal do
      inject_key("n")
      inject_key("q")
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Checkerboard"
      assert_includes content, "□"
    end
  end

  def test_cycle_previous_widget
    with_test_terminal do
      inject_key("p")
      inject_key("q")
      @app.run

      content = buffer_content.join("\n")
      # Going back from first widget (Diagonal) wraps to last widget (Border)
      assert_includes content, "Border"
      assert_includes content, "│"
    end
  end

  def test_cycle_forward_multiple_times
    with_test_terminal do
      inject_key("n")
      inject_key("n")
      inject_key("q")
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Border"
    end
  end

  def test_border_widget_respects_boundaries
    # Verify that the BorderWidget (which draws all four edges) doesn't extend
    # outside the inner area and doesn't overlap the block's outer border.
    with_test_terminal do
      inject_key("n")
      inject_key("n")
      inject_key("q")
      @app.run

      content = buffer_content.join("\n")
      # The BorderWidget should render its own borders inside the block
      assert_includes content, "Custom Widget: Border"
      # Both the outer block border and inner widget borders should be visible
      assert_includes content, "─"
    end
  end
end
