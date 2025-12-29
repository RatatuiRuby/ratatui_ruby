# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestBlock < Minitest::Test
    include RatatuiRuby::TestHelper
  def test_block_creation
    b = RatatuiRuby::Block.new(title: "Title", borders: [:top, :bottom], border_color: "red")
    assert_equal "Title", b.title
    assert_equal [:top, :bottom], b.borders
    assert_equal "red", b.border_color
  end

  def test_block_creation_with_style
    b = RatatuiRuby::Block.new(style: { fg: "blue" })
    assert_equal({ fg: "blue" }, b.style)
  end

  def test_render_with_style_hash
    with_test_terminal(20, 3) do
      # Should not raise NoMethodError
      b = RatatuiRuby::Block.new(borders: [:all], style: { fg: "blue" })
      RatatuiRuby.draw(b)
      # Content check is tricky without color inspection support in test helper,
      # but successful execution confirms the fix.
      assert_equal "┌──────────────────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└──────────────────┘", buffer_content[2]
    end
  end

  def test_block_creation_with_title_alignment
    b = RatatuiRuby::Block.new(title: "Title", title_alignment: :center)
    assert_equal :center, b.title_alignment
  end

  def test_block_creation_with_border_type
    b = RatatuiRuby::Block.new(border_type: :rounded)
    assert_equal :rounded, b.border_type
  end

  def test_block_creation_with_title_style
    b = RatatuiRuby::Block.new(title_style: { fg: "yellow" })
    assert_equal({ fg: "yellow" }, b.title_style)
  end

  def test_block_defaults
    b = RatatuiRuby::Block.new
    assert_nil b.title
    assert_equal [], b.titles
    assert_nil b.title_style
    assert_equal [:all], b.borders
    assert_nil b.border_color
    assert_nil b.border_type
    assert_nil b.style
    assert_equal [], b.children
  end

  def test_render
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Block.new(borders: [:all], title: "Title")
      RatatuiRuby.draw(b)
      assert_equal "┌Title─────────────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└──────────────────┘", buffer_content[2]
      assert_equal "└──────────────────┘", buffer_content[2]
    end
  end

  def test_render_title_alignment_center
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Block.new(borders: [:all], title: "Title", title_alignment: :center)
      RatatuiRuby.draw(b)
      # Available width 18. Title 5. (18-5)/2 = 6. 6 spaces left, 7 right.
      assert_equal "┌──────Title───────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└──────────────────┘", buffer_content[2]
    end
  end

  def test_render_title_alignment_right
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Block.new(borders: [:all], title: "Title", title_alignment: :right)
      RatatuiRuby.draw(b)
      # Available width 18. Title 5. 13 spaces left.
      assert_equal "┌─────────────Title┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└──────────────────┘", buffer_content[2]
    end
  end

  def test_render_rounded
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Block.new(borders: [:all], border_type: :rounded)
      RatatuiRuby.draw(b)
      assert_equal "╭──────────────────╮", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "╰──────────────────╯", buffer_content[2]
    end
  end

  def test_render_double
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Block.new(borders: [:all], border_type: :double)
      RatatuiRuby.draw(b)
      assert_equal "╔══════════════════╗", buffer_content[0]
      assert_equal "║                  ║", buffer_content[1]
      assert_equal "╚══════════════════╝", buffer_content[2]
    end
  end

  def test_render_thick
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Block.new(borders: [:all], border_type: :thick)
      RatatuiRuby.draw(b)
      assert_equal "┏━━━━━━━━━━━━━━━━━━┓", buffer_content[0]
      assert_equal "┃                  ┃", buffer_content[1]
      assert_equal "┗━━━━━━━━━━━━━━━━━━┛", buffer_content[2]
    end
  end
  def test_render_with_padding_uniform
    with_test_terminal(20, 5) do
      # 1px padding on all sides
      b = RatatuiRuby::Block.new(borders: [:all], padding: 1)
      p = RatatuiRuby::Paragraph.new(text: "Hello", block: b)
      RatatuiRuby.draw(p)

      assert_equal "┌──────────────────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "│ Hello            │", buffer_content[2]
      assert_equal "│                  │", buffer_content[3]
      assert_equal "└──────────────────┘", buffer_content[4]
    end
  end

  def test_render_with_padding_array
    with_test_terminal(20, 5) do
      # Left: 2, Right: 0, Top: 1, Bottom: 0
      b = RatatuiRuby::Block.new(borders: [:all], padding: [2, 0, 1, 0])
      p = RatatuiRuby::Paragraph.new(text: "Hello", block: b)
      RatatuiRuby.draw(p)

      assert_equal "┌──────────────────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "│  Hello           │", buffer_content[2]
      # Remaining lines are empty
      assert_equal "│                  │", buffer_content[3]
      assert_equal "└──────────────────┘", buffer_content[4]
    end
  end
  def test_render_titles
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Block.new(
        borders: [:all],
        titles: [
          { content: "TopLeft", alignment: :left, position: :top },
          { content: "TopRight", alignment: :right, position: :top },
          { content: "BottomCenter", alignment: :center, position: :bottom }
        ]
      )
      RatatuiRuby.draw(b)
      # Inner width: 18. TopLeft(7) + TopRight(8) = 15. 18-15 = 3 dashes.
      assert_equal "┌TopLeft───TopRight┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└───BottomCenter───┘", buffer_content[2]
    end
  end

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
