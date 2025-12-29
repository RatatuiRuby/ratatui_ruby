# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"
require_relative "hit_test"

class TestHitTestExample < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = HitTestApp.new
  end

  def test_initial_render_shows_both_panels
    with_test_terminal(80, 24) do
      inject_key(:q)
      @app.run

      content = buffer_content[0]
      assert_includes content, "Left Panel"
      assert_includes content, "Right Panel"
    end
  end

  def test_left_panel_click
    with_test_terminal(80, 24) do
      # Click in left half at x=10, then quit
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 10, y: 12))
      inject_key(:q)

      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Left Panel clicked"
      refute_includes content, "Right Panel clicked"
    end
  end

  def test_right_panel_click
    with_test_terminal(80, 24) do
      # Click in right half at x=50, then quit
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 50, y: 12))
      inject_key(:q)

      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Right Panel clicked"
      refute_includes content, "Left Panel clicked"
    end
  end

  def test_boundary_left_side
    with_test_terminal(80, 24) do
      # At 50/50 split (boundary at x=40), x=39 should be in left panel
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 39, y: 12))
      inject_key(:q)

      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Left Panel clicked"
      refute_includes content, "Right Panel clicked"
    end
  end

  def test_boundary_right_side
    with_test_terminal(80, 24) do
      # At 50/50 split, x=40 should be in right panel (exclusive boundary)
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 40, y: 12))
      inject_key(:q)

      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Right Panel clicked"
      refute_includes content, "Left Panel clicked"
    end
  end

  def test_ratio_change_affects_hit_testing
    with_test_terminal(80, 24) do
      # Shrink left panel to 30% using left arrow twice, then click at x=35
      inject_key("left")
      inject_key("left")
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 35, y: 12))
      inject_key(:q)

      @app.run

      content = buffer_content.join("\n")
      # At 30/70 split, x=35 should now be in right panel
      assert_includes content, "Right Panel clicked"
      refute_includes content, "Left Panel clicked"
    end
  end
end
