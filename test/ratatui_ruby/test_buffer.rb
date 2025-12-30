# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

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
    cell = RatatuiRuby::Cell.new(char: "X", fg: :red, bg: :blue, modifiers: ["bold"])
    widget = CustomWidget.new(cell)

    with_test_terminal(10, 5) do
      RatatuiRuby.draw(widget)

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
        RatatuiRuby::Draw.cell(0, 0, RatatuiRuby::Cell.char("A")),
        RatatuiRuby::Draw.cell(0, 0, RatatuiRuby::Cell.char("B"))
      ]
    end
  end

  def test_draw_cell_overwrite
    with_test_terminal(10, 5) do
      RatatuiRuby.draw(OverwritingWidget.new)
      assert_equal "B", RatatuiRuby.get_cell_at(0, 0).char
    end
  end

  class OutOfBoundsWidget
    def render(area)
      # Should not crash
      [RatatuiRuby::Draw.cell(100, 100, RatatuiRuby::Cell.char("X"))]
    end
  end

  def test_draw_cell_out_of_bounds
    with_test_terminal(10, 5) do
      RatatuiRuby.draw(OutOfBoundsWidget.new)
      # No assertion needed, just verifying no crash
      assert_equal " ", RatatuiRuby.get_cell_at(9, 4).char # Unaffected
    end
  end
end

