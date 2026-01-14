# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ratatui_ruby"
require "minitest/autorun"
require "test_helper"

class TestInsertBefore < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_insert_before_accepts_height_and_widget
    paragraph = RatatuiRuby::Widgets::Paragraph.new(text: "Inserted content")
    viewport = RatatuiRuby::Terminal::Viewport.inline(5)

    with_test_terminal(80, 24, viewport:) do
      # insert_before only works with inline viewports
      RatatuiRuby.insert_before(1, paragraph)
    end
  end

  def test_insert_before_raises_invariant_error_when_not_inline_viewport
    paragraph = RatatuiRuby::Widgets::Paragraph.new(text: "Inserted content")

    with_test_terminal do
      # TestBackend uses fullscreen viewport, so insert_before should raise
      error = assert_raises(RatatuiRuby::Error::Invariant) do
        RatatuiRuby.insert_before(1, paragraph)
      end

      assert_includes error.message, "inline viewport"
    end
  end

  def test_insert_before_renders_paragraph_widget
    paragraph = RatatuiRuby::Widgets::Paragraph.new(text: "Status: Complete")
    viewport = RatatuiRuby::Terminal::Viewport.inline(5)

    with_test_terminal(80, 24, viewport:) do
      RatatuiRuby.insert_before(1, paragraph)

      # Verify the widget was actually rendered into the scrollback buffer
      # The buffer should contain "Status: Complete" in the inserted line
      buffer = RatatuiRuby.get_buffer_content
      assert_includes buffer, "Status: Complete"
    end
  end

  def test_insert_before_with_block_renders_widget
    viewport = RatatuiRuby::Terminal::Viewport.inline(5)

    with_test_terminal(80, 24, viewport:) do
      RatatuiRuby.insert_before(2) do
        RatatuiRuby::Widgets::Paragraph.new(text: "Block form\nworks too")
      end

      buffer = RatatuiRuby.get_buffer_content
      assert_includes buffer, "Block form"
      assert_includes buffer, "works too"
    end
  end

  def test_insert_before_renders_block_widget
    viewport = RatatuiRuby::Terminal::Viewport.inline(5)
    block_widget = RatatuiRuby::Widgets::Block.new(title: "Status")

    with_test_terminal(80, 24, viewport:) do
      RatatuiRuby.insert_before(1, block_widget)

      buffer = RatatuiRuby.get_buffer_content
      assert_includes buffer, "Status"
    end
  end
end
