# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ratatui_ruby"
require "minitest/autorun"
require "test_helper"

class TestGetTerminalArea < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_get_terminal_area_returns_rect
    with_test_terminal(80, 24) do
      area = RatatuiRuby.get_terminal_area

      assert_kind_of RatatuiRuby::Layout::Rect, area
    end
  end

  def test_terminal_area_alias_works
    with_test_terminal(80, 24) do
      area = RatatuiRuby.terminal_area

      assert_kind_of RatatuiRuby::Layout::Rect, area
    end
  end

  def test_viewport_area_alias_works
    with_test_terminal(80, 24) do
      area = RatatuiRuby.viewport_area

      assert_kind_of RatatuiRuby::Layout::Rect, area
    end
  end
end
