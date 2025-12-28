# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestBlock < Minitest::Test
  def test_block_creation
    b = RatatuiRuby::Block.new(title: "Title", borders: [:top, :bottom], border_color: "red")
    assert_equal "Title", b.title
    assert_equal [:top, :bottom], b.borders
    assert_equal "red", b.border_color
  end

  def test_block_creation_with_border_type
    b = RatatuiRuby::Block.new(border_type: :rounded)
    assert_equal :rounded, b.border_type
  end

  def test_block_defaults
    b = RatatuiRuby::Block.new
    assert_nil b.title
    assert_equal [:all], b.borders
    assert_nil b.border_color
    assert_nil b.border_type
  end

  def test_render
    with_test_terminal(20, 3) do
      b = RatatuiRuby::Block.new(borders: [:all], title: "Title")
      RatatuiRuby.draw(b)
      assert_equal "┌Title─────────────┐", buffer_content[0]
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
end
