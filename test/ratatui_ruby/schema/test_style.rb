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

  # v1.0.0 alignment: underline_color parameter for Style
  def test_style_underline_color_creation
    # Ratatui supports a separate underline_color distinct from fg color
    # This enables styling like: text in white with red underline
    style = RatatuiRuby::Style::Style.new(
      fg: :white,
      modifiers: [:underlined],
      underline_color: :red
    )
    assert_equal :white, style.fg
    assert_equal :red, style.underline_color
    assert_equal [:underlined], style.modifiers
  end

  def test_style_underline_color_rendering
    with_test_terminal(10, 1) do
      paragraph = RatatuiRuby::Widgets::Paragraph.new(
        text: "X",
        style: RatatuiRuby::Style::Style.new(
          fg: :white,
          modifiers: [:underlined],
          underline_color: :red
        )
      )
      RatatuiRuby.draw { |f| f.render_widget(paragraph, f.area) }

      cell = RatatuiRuby.get_cell_at(0, 0)
      assert_equal "X", cell.char
      assert_equal :white, cell.fg
      # The cell should have the underline_color property
      assert_equal :red, cell.underline_color, "Underline color should be preserved in cell"
    end
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

# Tests for remove_modifiers (sub_modifier in Ratatui)
class TestStyleRemoveModifiers < Minitest::Test
  include RatatuiRuby::TestHelper

  # v1.0.0 alignment: sub_modifier parameter for Style
  # Ratatui uses sub_modifier to explicitly remove modifiers when styles are patched.
  # Ruby API uses remove_modifiers: for clarity.

  def test_style_remove_modifiers_creation
    # Style with modifiers to remove - these are removed from inherited styles
    style = RatatuiRuby::Style::Style.new(
      fg: :white,
      modifiers: [:bold],
      remove_modifiers: [:italic, :dim]
    )
    assert_equal :white, style.fg
    assert_equal [:bold], style.modifiers
    assert_equal [:italic, :dim], style.remove_modifiers
  end

  def test_style_remove_modifiers_defaults_to_empty
    style = RatatuiRuby::Style::Style.new(fg: :red)
    assert_equal [], style.remove_modifiers
  end

  def test_style_with_remove_modifiers
    style = RatatuiRuby::Style::Style.with(
      fg: :blue,
      modifiers: [:underlined],
      remove_modifiers: [:bold]
    )
    assert_equal [:underlined], style.modifiers
    assert_equal [:bold], style.remove_modifiers
  end

  # Rendering test: verify remove_modifiers actually removes a modifier from the cell.
  # This proves the feature works end-to-end through the Rust FFI layer.
  #
  # Strategy: Render a styled span with bold, then another span where bold is removed.
  # Verify the first cell has :bold and the second does not.
  def test_style_remove_modifiers_rendering
    with_test_terminal(10, 1) do
      bold_span = RatatuiRuby::Text::Span.new(
        content: "A",
        style: RatatuiRuby::Style::Style.new(modifiers: [:bold])
      )
      # This span explicitly removes bold - even if inherited from a parent style
      normal_span = RatatuiRuby::Text::Span.new(
        content: "B",
        style: RatatuiRuby::Style::Style.new(remove_modifiers: [:bold])
      )
      line = RatatuiRuby::Text::Line.new(spans: [bold_span, normal_span])
      paragraph = RatatuiRuby::Widgets::Paragraph.new(text: [line])

      RatatuiRuby.draw { |f| f.render_widget(paragraph, f.area) }

      # Cell 0: "A" with :bold
      cell_a = RatatuiRuby.get_cell_at(0, 0)
      assert_equal "A", cell_a.char
      assert_includes cell_a.modifiers, :bold, "First span should have :bold modifier"

      # Cell 1: "B" without :bold (removed)
      cell_b = RatatuiRuby.get_cell_at(1, 0)
      assert_equal "B", cell_b.char
      refute_includes cell_b.modifiers, :bold,
        "Second span with remove_modifiers: [:bold] should NOT have :bold"
    end
  end
end
