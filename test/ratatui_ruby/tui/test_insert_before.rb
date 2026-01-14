# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ratatui_ruby"
require "minitest/autorun"
require "test_helper"

class TestTUIInsertBefore < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_tui_insert_before_delegates_to_module_method
    paragraph = RatatuiRuby::Widgets::Paragraph.new(text: "TUI facade test")
    viewport = RatatuiRuby::Terminal::Viewport.inline(5)

    with_test_terminal(80, 24, viewport:) do
      tui = RatatuiRuby::TUI.new

      # Should delegate to RatatuiRuby.insert_before
      tui.insert_before(1, paragraph)

      buffer = RatatuiRuby.get_buffer_content
      assert_includes buffer, "TUI facade test"
    end
  end

  def test_tui_insert_before_with_block
    viewport = RatatuiRuby::Terminal::Viewport.inline(5)

    with_test_terminal(80, 24, viewport:) do
      tui = RatatuiRuby::TUI.new

      tui.insert_before(2) do
        RatatuiRuby::Widgets::Paragraph.new(text: "Block form via TUI")
      end

      buffer = RatatuiRuby.get_buffer_content
      assert_includes buffer, "Block form via TUI"
    end
  end
end
