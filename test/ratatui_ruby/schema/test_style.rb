# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

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
end
