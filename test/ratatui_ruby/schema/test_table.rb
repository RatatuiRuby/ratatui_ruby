# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestTable < Minitest::Test
  def test_table_creation
    header = ["A", "B"]
    rows = [["1", "2"], ["3", "4"]]
    widths = [RatatuiRuby::Constraint.length(5), RatatuiRuby::Constraint.length(5)]
    t = RatatuiRuby::Table.new(header:, rows:, widths:)
    assert_equal header, t.header
    assert_equal rows, t.rows
    assert_equal widths, t.widths
  end

  def test_render
    with_test_terminal(20, 5) do
      t = RatatuiRuby::Table.new(
        header: ["Col1", "Col2"],
        rows: [["Val1", "Val2"]],
        widths: [RatatuiRuby::Constraint.length(8), RatatuiRuby::Constraint.length(8)]
      )
      RatatuiRuby.draw(t)
      assert_equal "Col1     Col2       ", buffer_content[0]
      assert_equal "Val1     Val2       ", buffer_content[1]
      assert_equal "                    ", buffer_content[2]
      assert_equal "                    ", buffer_content[3]
      assert_equal "                    ", buffer_content[4]
    end
  end

  def test_render_with_selection
    with_test_terminal(20, 5) do
      t = RatatuiRuby::Table.new(
        header: ["Col1", "Col2"],
        rows: [["Val1", "Val2"], ["Val3", "Val4"]],
        widths: [RatatuiRuby::Constraint.length(8), RatatuiRuby::Constraint.length(8)],
        selected_row: 1,
        highlight_symbol: "> "
      )
      RatatuiRuby.draw(t)
      assert_equal "  Col1     Col2     ", buffer_content[0]
      assert_equal "  Val1     Val2     ", buffer_content[1]
      assert_equal "> Val3     Val4     ", buffer_content[2]
    end
  end
end
