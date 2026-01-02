# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_text_width/app"

class TestWidgetTextWidth < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetTextWidth.new
  end

  def test_initial_render_shows_sample
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "ASCII"
      assert_includes content, "Hello, World!"
    end
  end

  def test_navigation_up
    with_test_terminal do
      inject_key(:up)
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # Pressing up from index 0 should wrap to last sample (Empty at index 4)
      assert_includes content, "Empty"
    end
  end

  def test_navigation_down
    with_test_terminal do
      inject_key(:down)
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # Pressing down from index 0 should go to index 1 (CJK)
      assert_includes content, "CJK"
    end
  end

  def test_cjk_width_calculation
    with_test_terminal do
      inject_key(:down) # Move to CJK sample
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # "你好世界" = 4 CJK characters × 2 cells each = 8 cells
      assert_includes content, "Display Width: 8 cells"
    end
  end

  def test_mixed_content_width
    with_test_terminal do
      # Navigate to Mixed sample (index 3)
      inject_key(:down)
      inject_key(:down)
      inject_key(:down)
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # "Hi 你好 👍" = 2 + 1 + 4 + 1 + 2 = 10 cells
      assert_includes content, "Display Width: 10 cells"
    end
  end

  def test_shows_controls
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Select"
      assert_includes content, "Quit"
    end
  end
end
