# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestStyle < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_style_creation
    s = RatatuiRuby::Style::Style.new(fg: :red, bg: :blue, modifiers: [:bold])
    assert_equal :red, s.fg
    assert_equal :blue, s.bg
    assert_equal [:bold], s.modifiers
  end

  def test_style_creation_with_integers
    # 5 is Magenta in Xterm 256
    s = RatatuiRuby::Style::Style.new(fg: 5, bg: 10)
    assert_equal 5, s.fg
    assert_equal 10, s.bg
  end

  # v0.6.0: Integer colors render correctly (not just store)
  def test_indexed_color_rendering
    with_test_terminal(10, 1) do
      # Use Xterm 256 indexed colors: 21 is blue, 196 is red
      paragraph = RatatuiRuby::Widgets::Paragraph.new(
        text: "X",
        style: RatatuiRuby::Style::Style.new(fg: 21, bg: 196)
      )
      RatatuiRuby.draw { |f| f.render_widget(paragraph, f.area) }

      cell = RatatuiRuby.get_cell_at(0, 0)
      assert_equal "X", cell.char
      # Indexed colors are returned as :indexed_N symbols
      assert_equal :indexed_21, cell.fg, "Indexed fg color should be preserved"
      assert_equal :indexed_196, cell.bg, "Indexed bg color should be preserved"
    end
  end

  # :reset restores the terminal's default foreground/background color.
  # Unlike nil (which means "inherit from parent"), :reset explicitly
  # instructs the terminal to use its configured default.
  def test_reset_color_rendering
    with_test_terminal(10, 1) do
      paragraph = RatatuiRuby::Widgets::Paragraph.new(
        text: "X",
        style: RatatuiRuby::Style::Style.new(fg: :reset, bg: :reset)
      )
      RatatuiRuby.draw { |f| f.render_widget(paragraph, f.area) }

      cell = RatatuiRuby.get_cell_at(0, 0)
      assert_equal "X", cell.char
      # Reset colors are returned as nil (terminal default)
      assert_nil cell.fg, ":reset fg should render as nil (terminal default)"
      assert_nil cell.bg, ":reset bg should render as nil (terminal default)"
    end
  end

  # Gap tests - verify Color constructors from v1.0.0_blockers.md
  def test_color_from_u32
    skip "v1.0.0 Blocker: Color.from_u32 not implemented. See doc/contributors/v1.0.0_blockers.md"
    color = RatatuiRuby::Style::Color.from_u32(0xFF0000) # Red
    refute_nil color
  end

  def test_color_from_hsl
    skip "v1.0.0 Blocker: Color.from_hsl not implemented. See doc/contributors/v1.0.0_blockers.md"
    color = RatatuiRuby::Style::Color.from_hsl(0, 100, 50) # Red
    refute_nil color
  end

  def test_color_from_hsluv
    skip "v1.0.0 Blocker: Color.from_hsluv not implemented. See doc/contributors/v1.0.0_blockers.md"
    color = RatatuiRuby::Style::Color.from_hsluv(0, 100, 50)
    refute_nil color
  end
end
