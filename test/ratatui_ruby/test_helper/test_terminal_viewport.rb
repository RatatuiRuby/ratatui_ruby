# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ratatui_ruby"
require "minitest/autorun"
require "test_helper"

class TestTestHelperTerminalViewport < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_with_test_terminal_respects_inline_viewport_height
    viewport = RatatuiRuby::Terminal::Viewport.inline(5)

    with_test_terminal(80, 24, viewport:) do
      area = RatatuiRuby.get_viewport_area
      alias1 = RatatuiRuby.get_viewport_size
      alias2 = RatatuiRuby.viewport_area
      alias3 = RatatuiRuby.viewport_size

      # terminal_area should return viewport dimensions, not terminal dimensions
      assert_equal 5, area.height, "Area height should match viewport height"
      assert_equal 80, area.width
      assert_equal area, alias1
      assert_equal area, alias2
      assert_equal area, alias3
    end
  end

  def test_with_test_terminal_still_shows_full_terminal_area
    viewport = RatatuiRuby::Terminal::Viewport.inline(5)

    with_test_terminal(80, 24, viewport:) do
      area = RatatuiRuby.get_terminal_area
      alias1 = RatatuiRuby.get_terminal_size
      alias2 = RatatuiRuby.terminal_area
      alias3 = RatatuiRuby.terminal_size

      # terminal_area should return viewport dimensions, not terminal dimensions
      assert_equal 24, area.height, "Area height should match terminal height"
      assert_equal 80, area.width
      assert_equal area, alias1
      assert_equal area, alias2
      assert_equal area, alias3
    end
  end
end
