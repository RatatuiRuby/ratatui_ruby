# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestDraw < Minitest::Test
  include RatatuiRuby::TestHelper

  class CustomWidget
    def initialize(cell)
      @cell = cell
    end

    def render(area)
      [RatatuiRuby::Draw.cell(0, 0, @cell)]
    end
  end

  def test_draw_cell
    cell = RatatuiRuby::Buffer::Cell.new(char: "X", fg: :red, bg: :blue, modifiers: ["bold"])
    widget = CustomWidget.new(cell)

    with_test_terminal(10, 5) do
      RatatuiRuby.draw { |f| f.render_widget(widget, f.area) }

      rendered_cell = RatatuiRuby.get_cell_at(0, 0)
      assert_equal "X", rendered_cell.char
      assert_equal :red, rendered_cell.fg
      assert_equal :blue, rendered_cell.bg
      assert rendered_cell.bold?
    end
  end

  class OverwritingWidget
    def render(area)
      [
        RatatuiRuby::Draw.cell(0, 0, RatatuiRuby::Buffer::Cell.char("A")),
        RatatuiRuby::Draw.cell(0, 0, RatatuiRuby::Buffer::Cell.char("B")),
      ]
    end
  end

  def test_draw_cell_overwrite
    with_test_terminal(10, 5) do
      RatatuiRuby.draw { |f| f.render_widget(OverwritingWidget.new, f.area) }
      assert_equal "B", RatatuiRuby.get_cell_at(0, 0).char
    end
  end

  class OutOfBoundsWidget
    def render(area)
      # Should not crash
      [RatatuiRuby::Draw.cell(100, 100, RatatuiRuby::Buffer::Cell.char("X"))]
    end
  end

  def test_draw_cell_out_of_bounds
    with_test_terminal(10, 5) do
      RatatuiRuby.draw { |f| f.render_widget(OutOfBoundsWidget.new, f.area) }
      # No assertion needed, just verifying no crash
      assert_equal " ", RatatuiRuby.get_cell_at(9, 4).char # Unaffected
    end
  end

  # Buffer query methods - Note: these use computed values, not Rust bindings
  def test_buffer_index_of
    with_test_terminal(10, 5) do
      index = RatatuiRuby::Buffer.index_of(5, 2)
      assert_equal 25, index # 2 * 10 + 5
    end
  end

  def test_buffer_pos_of
    with_test_terminal(10, 5) do
      x, y = RatatuiRuby::Buffer.pos_of(25)
      assert_equal 5, x
      assert_equal 2, y
    end
  end

  def test_buffer_get
    with_test_terminal(10, 5) do
      RatatuiRuby.draw { |f| f.render_widget(RatatuiRuby::Widgets::Paragraph.new(text: "Hi"), f.area) }
      cell = RatatuiRuby::Buffer.get(0, 0)
      assert_equal "H", cell.char
    end
  end

  def test_buffer_content
    with_test_terminal(10, 5) do
      RatatuiRuby.draw { |f| f.render_widget(RatatuiRuby::Widgets::Paragraph.new(text: "Hi"), f.area) }
      cells = RatatuiRuby::Buffer.content
      assert_equal 50, cells.size # 10 * 5 = 50 cells
      assert_equal "H", cells[0].char
      assert_equal "i", cells[1].char
    end
  end

  # Ruby-idiomatic alias (TIMTOWTDI)
  def test_buffer_subscript_alias
    # Buffer[x, y] is an alias for Buffer.get(x, y)
    with_test_terminal(10, 5) do
      RatatuiRuby.draw { |f| f.render_widget(RatatuiRuby::Widgets::Paragraph.new(text: "Hi"), f.area) }
      assert_equal RatatuiRuby::Buffer.get(0, 0), RatatuiRuby::Buffer[0, 0]
      assert_equal "H", RatatuiRuby::Buffer[0, 0].char
    end
  end
end
