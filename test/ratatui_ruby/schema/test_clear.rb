# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestClear < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_clear_creation
    clear = RatatuiRuby::Widgets::Clear.new
    assert_nil clear.block
  end

  def test_clear_with_block
    block = RatatuiRuby::Widgets::Block.new(title: "Test", borders: [:all])
    clear = RatatuiRuby::Widgets::Clear.new(block:)
    assert_equal block, clear.block
  end

  def test_render
    with_test_terminal(20, 5) do
      # Create a simple UI that demonstrates Clear widget
      # Without Clear, we just have empty space
      clear = RatatuiRuby::Widgets::Clear.new
      RatatuiRuby.draw { |f| f.render_widget(clear, f.area) }

      # Verify entire buffer is cleared (every character)
      assert_equal "                    ", buffer_content[0]
      assert_equal "                    ", buffer_content[1]
      assert_equal "                    ", buffer_content[2]
      assert_equal "                    ", buffer_content[3]
      assert_equal "                    ", buffer_content[4]
    end
  end

  def test_render_clears_background
    with_test_terminal(20, 5) do
      # First, draw background text
      background = RatatuiRuby::Widgets::Paragraph.new(text: "XXXXXXXXXXXXXXXXXXXX" * 5, wrap: true)

      # Then overlay Clear on top
      ui = RatatuiRuby::Widgets::Overlay.new(
        layers: [
          background,
          RatatuiRuby::Widgets::Clear.new,
        ]
      )
      RatatuiRuby.draw { |f| f.render_widget(ui, f.area) }

      # Verify Clear erased the background (every character)
      assert_equal "                    ", buffer_content[0]
      assert_equal "                    ", buffer_content[1]
      assert_equal "                    ", buffer_content[2]
      assert_equal "                    ", buffer_content[3]
      assert_equal "                    ", buffer_content[4]
    end
  end

  def test_render_with_block
    with_test_terminal(20, 5) do
      clear = RatatuiRuby::Widgets::Clear.new(
        block: RatatuiRuby::Widgets::Block.new(title: "Cleared", borders: [:all])
      )
      RatatuiRuby.draw { |f| f.render_widget(clear, f.area) }

      # Verify exact buffer content with border characters and title
      assert_equal "┌Cleared───────────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "│                  │", buffer_content[2]
      assert_equal "│                  │", buffer_content[3]
      assert_equal "└──────────────────┘", buffer_content[4]
    end
  end
end
