# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestClear < Minitest::Test
  def test_clear_creation
    clear = RatatuiRuby::Clear.new
    assert_nil clear.block
  end

  def test_clear_with_block
    block = RatatuiRuby::Block.new(title: "Test", borders: [:all])
    clear = RatatuiRuby::Clear.new(block: block)
    assert_equal block, clear.block
  end

  def test_render
    with_test_terminal(20, 5) do
      # Create a simple UI that demonstrates Clear widget
      # Without Clear, we just have empty space
      clear = RatatuiRuby::Clear.new
      RatatuiRuby.draw(clear)

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
      background = RatatuiRuby::Paragraph.new(text: "XXXXXXXXXXXXXXXXXXXX" * 5, wrap: true)

      # Then overlay Clear on top
      ui = RatatuiRuby::Overlay.new(
        layers: [
          background,
          RatatuiRuby::Clear.new
        ]
      )
      RatatuiRuby.draw(ui)

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
      clear = RatatuiRuby::Clear.new(
        block: RatatuiRuby::Block.new(title: "Cleared", borders: [:all])
      )
      RatatuiRuby.draw(clear)

      # Verify exact buffer content with border characters and title
      assert_equal "┌Cleared───────────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "│                  │", buffer_content[2]
      assert_equal "│                  │", buffer_content[3]
      assert_equal "└──────────────────┘", buffer_content[4]
    end
  end
end
