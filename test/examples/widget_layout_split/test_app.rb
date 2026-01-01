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

      content = buffer_content.join("\n")
      assert_includes content, "Layout.split Demo"
      assert_includes content, "Block 1"
      assert_includes content, "Block 2"
      assert_includes content, "Block 3"
    end
  end

  def test_controls_display
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Controls"
      assert_includes content, "Direction"
      assert_includes content, "Flex"
      assert_includes content, "Constraints"
    end
  end

  def test_direction_cycling
    with_test_terminal do
      inject_key("d") # Cycle to Horizontal
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Horizontal"
    end
  end

  def test_flex_cycling
    with_test_terminal do
      inject_key("f") # Cycle to Start
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # Should show "Start" flex mode
      assert_includes content, "Start"
    end
  end

  def test_constraint_cycling
    with_test_terminal do
      inject_key("c") # Cycle to Length
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # Should show "Length" constraint type
      assert_includes content, "Length"
    end
  end

  def test_quit_on_q
    with_test_terminal do
      inject_key(:q)
      @app.run
      # Success if it returns
    end
  end

  def test_quit_on_ctrl_c
    with_test_terminal do
      inject_key(:ctrl_c)
      @app.run
      # Success if it returns
    end
  end

  def test_multiple_cycles
    with_test_terminal do
      # Cycle through multiple options
      inject_key("d") # Horizontal
      inject_key("d") # Back to Vertical
      inject_key("f") # Start
      inject_key("f") # Center
      inject_key("c") # Length
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # Should show Vertical, Center, Length
      assert_includes content, "Vertical"
      assert_includes content, "Center"
      assert_includes content, "Length"
    end
  end

  def test_all_flex_modes_accessible
    with_test_terminal do
      # Cycle through all 7 flex modes
      7.times { inject_key("f") }
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # After 7 cycles, should be back to Legacy
      assert_includes content, "Legacy"
    end
  end
end
