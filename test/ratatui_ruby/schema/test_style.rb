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
    color = RatatuiRuby::Style::Color.from_u32(0xFF0000) # Red
    refute_nil color
  end

  def test_color_from_hsl
    color = RatatuiRuby::Style::Color.from_hsl(0, 100, 50) # Red
    refute_nil color
  end

  def test_color_from_hsluv
    # HSLuv (0, 100, 50) should produce a reddish color
    # Using Ratatui test values as reference: Hsluv::new(12.18, 100.0, 53.2) => Rgb(255, 0, 0)
    color = RatatuiRuby::Style::Color.from_hsluv(12.177, 100, 53.23)
    refute_nil color
    assert_match(/#ff0000/i, color)
  end

  # Ruby-idiomatic aliases (TIMTOWTDI)
  def test_color_hex_alias
    # Color.hex is an alias for Color.from_u32
    assert_equal RatatuiRuby::Style::Color.from_u32(0xFF0000), RatatuiRuby::Style::Color.hex(0xFF0000)
  end

  def test_color_hsl_alias
    # Color.hsl is an alias for Color.from_hsl
    assert_equal RatatuiRuby::Style::Color.from_hsl(120, 100, 50), RatatuiRuby::Style::Color.hsl(120, 100, 50)
  end

  def test_color_hsluv_alias
    # Color.hsluv is an alias for Color.from_hsluv
    assert_equal RatatuiRuby::Style::Color.from_hsluv(12.177, 100, 53.23), RatatuiRuby::Style::Color.hsluv(12.177, 100, 53.23)
  end
end

# Tests for Style convenience methods
class TestStyleConvenience < Minitest::Test
  def test_style_with_creates_style
    style = RatatuiRuby::Style::Style.with(fg: :red, bg: :blue, modifiers: [:bold])
    assert_instance_of RatatuiRuby::Style::Style, style
    assert_equal :red, style.fg
    assert_equal :blue, style.bg
    assert_equal [:bold], style.modifiers
  end

  def test_style_with_defaults_to_nil_colors
    style = RatatuiRuby::Style::Style.with
    assert_nil style.fg
    assert_nil style.bg
    assert_equal [], style.modifiers
  end

  def test_style_with_equivalent_to_new
    # Style.with is a convenience alias for Style.new
    via_new = RatatuiRuby::Style::Style.new(fg: :green, bg: :black, modifiers: [:italic])
    via_with = RatatuiRuby::Style::Style.with(fg: :green, bg: :black, modifiers: [:italic])
    assert_equal via_new, via_with
  end
end
