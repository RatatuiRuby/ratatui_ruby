# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestTableFlex < Minitest::Test
  def test_flex_space_between
    rows = [["A", "B"]]
    widths = [RatatuiRuby::Constraint.length(1), RatatuiRuby::Constraint.length(1)]

    # SpaceBetween should push columns to edges.
    table = RatatuiRuby::Table.new(
      rows: rows,
      widths: widths,
      flex: :space_between
    )

    with_test_terminal(10, 1) do
      RatatuiRuby.draw(table)
      line = buffer_content.first
      # "A        B" roughly
      # There should be significant whitespace between A and B
      assert_match(/A\s{5,}B/, line)
    end
  end

  def test_flex_start
    rows = [["A", "B"]]
    widths = [RatatuiRuby::Constraint.length(1), RatatuiRuby::Constraint.length(1)]

    # Start should push columns to left
    table = RatatuiRuby::Table.new(
      rows: rows,
      widths: widths,
      flex: :start
    )

    with_test_terminal(10, 1) do
      RatatuiRuby.draw(table)
      line = buffer_content.first
      # "A B       " roughly
      # Spacing between A and B should be small (default column spacing is 1)
      assert_match(/A\s{0,3}B\s{4,}/, line)
    end
  end
end
