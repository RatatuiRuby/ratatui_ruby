# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestBlockTitles < Minitest::Test
  def test_block_creation_with_titles
    b = RatatuiRuby::Block.new(
      titles: [
        { content: "Title 1", alignment: :left, position: :top },
        { content: "Title 2", alignment: :right, position: :bottom }
      ]
    )
    assert_equal 2, b.titles.length
    assert_equal "Title 1", b.titles[0][:content]
    assert_equal :top, b.titles[0][:position]
  end

  def test_render_titles_top
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Block.new(
        borders: [:all],
        titles: [
          { content: "Left", alignment: :left },
          { content: "Right", alignment: :right }
        ]
      )
      RatatuiRuby.draw(b)
      # ┌Left─────────Right┐ (14 dashes + 4 chars + 5 chars = 23? Wait.)
      # Width 20. Corners take 2. 18 chars inside.
      # "Left" (4) + "Right" (5) = 9 chars.
      # 18 - 9 = 9 spaces/dashes.
      # Actually, Ratatui renders dashes.
      # Expected: ┌Left─────────Right┐
      assert_equal "┌Left─────────Right┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└──────────────────┘", buffer_content[2]
    end
  end

  def test_render_titles_bottom
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Block.new(
        borders: [:all],
        titles: [
          { content: "Bot", alignment: :center, position: :bottom }
        ]
      )
      RatatuiRuby.draw(b)
      # Width 20. 18 inside. "Bot" is 3. (18-3)/2 = 7 left, 8 right dashes.
      assert_equal "┌──────────────────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└───────Bot────────┘", buffer_content[2]
    end
  end

  def test_render_mixed_titles
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Block.new(
        borders: [:all],
        titles: [
          "Top", # Default top-left string
          { content: "Bot", alignment: :right, position: :bottom }
        ]
      )
      RatatuiRuby.draw(b)
      assert_equal "┌Top───────────────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└───────────────Bot┘", buffer_content[2]
    end
  end
end
