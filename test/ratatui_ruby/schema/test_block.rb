# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestBlock < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_block_creation
    b = RatatuiRuby::Widgets::Block.new(title: "Title", borders: [:top, :bottom], border_color: "red")
    assert_equal "Title", b.title
    assert_equal [:top, :bottom], b.borders
    assert_equal "red", b.border_color
  end

  def test_block_creation_with_style
    b = RatatuiRuby::Widgets::Block.new(style: { fg: "blue" })
    assert_equal({ fg: "blue" }, b.style)
  end

  def test_render_with_style_hash
    with_test_terminal(20, 3) do
      # Should not raise NoMethodError
      b = RatatuiRuby::Widgets::Block.new(borders: [:all], style: { fg: "blue" })
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
      # Content check is tricky without color inspection support in test helper,
      # but successful execution confirms the fix.
      assert_equal "┌──────────────────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└──────────────────┘", buffer_content[2]
    end
  end

  def test_block_creation_with_title_alignment
    b = RatatuiRuby::Widgets::Block.new(title: "Title", title_alignment: :center)
    assert_equal :center, b.title_alignment
  end

  def test_block_creation_with_border_type
    b = RatatuiRuby::Widgets::Block.new(border_type: :rounded)
    assert_equal :rounded, b.border_type
  end

  def test_block_creation_with_title_style
    b = RatatuiRuby::Widgets::Block.new(title_style: { fg: "yellow" })
    assert_equal({ fg: "yellow" }, b.title_style)
  end

  def test_block_defaults
    b = RatatuiRuby::Widgets::Block.new
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
      b = RatatuiRuby::Widgets::Block.new(borders: [:all], title: "Title")
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
      assert_equal "┌Title─────────────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└──────────────────┘", buffer_content[2]
      assert_equal "└──────────────────┘", buffer_content[2]
    end
  end

  def test_render_title_alignment_center
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Widgets::Block.new(borders: [:all], title: "Title", title_alignment: :center)
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
      # Available width 18. Title 5. (18-5)/2 = 6. 6 spaces left, 7 right.
      assert_equal "┌──────Title───────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└──────────────────┘", buffer_content[2]
    end
  end

  def test_render_title_alignment_right
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Widgets::Block.new(borders: [:all], title: "Title", title_alignment: :right)
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
      # Available width 18. Title 5. 13 spaces left.
      assert_equal "┌─────────────Title┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└──────────────────┘", buffer_content[2]
    end
  end

  def test_render_rounded
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Widgets::Block.new(borders: [:all], border_type: :rounded)
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
      assert_equal "╭──────────────────╮", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "╰──────────────────╯", buffer_content[2]
    end
  end

  def test_render_double
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Widgets::Block.new(borders: [:all], border_type: :double)
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
      assert_equal "╔══════════════════╗", buffer_content[0]
      assert_equal "║                  ║", buffer_content[1]
      assert_equal "╚══════════════════╝", buffer_content[2]
    end
  end

  def test_render_thick
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Widgets::Block.new(borders: [:all], border_type: :thick)
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
      assert_equal "┏━━━━━━━━━━━━━━━━━━┓", buffer_content[0]
      assert_equal "┃                  ┃", buffer_content[1]
      assert_equal "┗━━━━━━━━━━━━━━━━━━┛", buffer_content[2]
    end
  end

  def test_render_with_padding_uniform
    with_test_terminal(20, 5) do
      # 1px padding on all sides
      b = RatatuiRuby::Widgets::Block.new(borders: [:all], padding: 1)
      p = RatatuiRuby::Widgets::Paragraph.new(text: "Hello", block: b)
      RatatuiRuby.draw { |f| f.render_widget(p, f.area) }

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
      b = RatatuiRuby::Widgets::Block.new(borders: [:all], padding: [2, 0, 1, 0])
      p = RatatuiRuby::Widgets::Paragraph.new(text: "Hello", block: b)
      RatatuiRuby.draw { |f| f.render_widget(p, f.area) }

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
      b = RatatuiRuby::Widgets::Block.new(
        borders: [:all],
        titles: [
          { content: "TopLeft", alignment: :left, position: :top },
          { content: "TopRight", alignment: :right, position: :top },
          { content: "BottomCenter", alignment: :center, position: :bottom },
        ]
      )
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
      # Inner width: 18. TopLeft(7) + TopRight(8) = 15. 18-15 = 3 dashes.
      assert_equal "┌TopLeft───TopRight┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└───BottomCenter───┘", buffer_content[2]
    end
  end

  def test_block_creation_with_titles
    b = RatatuiRuby::Widgets::Block.new(
      titles: [
        { content: "Title 1", alignment: :left, position: :top },
        { content: "Title 2", alignment: :right, position: :bottom },
      ]
    )
    assert_equal 2, b.titles.length
    assert_equal "Title 1", b.titles[0][:content]
    assert_equal :top, b.titles[0][:position]
  end

  def test_render_titles_top
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Widgets::Block.new(
        borders: [:all],
        titles: [
          { content: "Left", alignment: :left },
          { content: "Right", alignment: :right },
        ]
      )
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
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
      b = RatatuiRuby::Widgets::Block.new(
        borders: [:all],
        titles: [
          { content: "Bot", alignment: :center, position: :bottom },
        ]
      )
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
      # Width 20. 18 inside. "Bot" is 3. (18-3)/2 = 7 left, 8 right dashes.
      assert_equal "┌──────────────────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└───────Bot────────┘", buffer_content[2]
    end
  end

  def test_render_mixed_titles
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Widgets::Block.new(
        borders: [:all],
        titles: [
          "Top", # Default top-left string
          { content: "Bot", alignment: :right, position: :bottom },
        ]
      )
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
      assert_equal "┌Top───────────────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└───────────────Bot┘", buffer_content[2]
    end
  end

  def test_block_creation_with_border_set
    set = { top_left: "1", top_right: "2", bottom_left: "3", bottom_right: "4" }
    b = RatatuiRuby::Widgets::Block.new(border_set: set)
    assert_equal set, b.border_set
  end

  def test_block_creation_with_border_set_short_keys
    set = { tl: "1", tr: "2", bl: "3", br: "4" }
    expected = { top_left: "1", top_right: "2", bottom_left: "3", bottom_right: "4" }
    b = RatatuiRuby::Widgets::Block.new(border_set: set)
    assert_equal expected, b.border_set
  end

  def test_block_creation_with_border_set_mixed_keys
    set = { tl: "1", tr: "2", bottom_left: "3", br: "4" }
    expected = { top_left: "1", top_right: "2", bottom_left: "3", bottom_right: "4" }
    b = RatatuiRuby::Widgets::Block.new(border_set: set)
    assert_equal expected, b.border_set
  end

  def test_render_with_border_set
    with_test_terminal(20, 3) do
      # Full custom set
      set = {
        top_left: "1",
        top_right: "2",
        bottom_left: "3",
        bottom_right: "4",
        vertical_left: "5",
        vertical_right: "6",
        horizontal_top: "7",
        horizontal_bottom: "8",
      }
      b = RatatuiRuby::Widgets::Block.new(borders: [:all], border_set: set)
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
      assert_equal "17777777777777777772", buffer_content[0]
      assert_equal "5                  6", buffer_content[1]
      assert_equal "38888888888888888884", buffer_content[2]
    end
  end

  def test_render_with_partial_border_set
    with_test_terminal(20, 3) do
      set = { top_left: "@" }
      b = RatatuiRuby::Widgets::Block.new(borders: [:all], border_set: set)
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
      assert_equal "@──────────────────┐", buffer_content[0]
      assert_equal "│                  │", buffer_content[1]
      assert_equal "└──────────────────┘", buffer_content[2]
    end
  end

  def test_render_titles_with_styled_line
    # This test verifies that Text::Line objects with styled spans can be used
    # as title content, not just plain strings. This exercises the Rust-side
    # parse_titles function's ability to parse Line objects.
    with_test_terminal(30, 3) do
      styled_title = RatatuiRuby::Text::Line.new(
        spans: [
          RatatuiRuby::Text::Span.new(content: "emate", style: RatatuiRuby::Style::Style.new(fg: :yellow)),
        ]
      )
      b = RatatuiRuby::Widgets::Block.new(
        borders: [:all],
        titles: [
          { content: "My App" },
          { content: styled_title, alignment: :right },
        ]
      )
      RatatuiRuby.draw { |f| f.render_widget(b, f.area) }
      # The styled Line should render as text, not as "#<data RatatuiRuby::Text::Line...>"
      assert_equal "┌My App─────────────────emate┐", buffer_content[0]
      refute_includes buffer_content[0], "#<data"
      refute_includes buffer_content[0], "RatatuiRuby"
    end
  end
end
