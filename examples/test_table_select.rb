#!/usr/bin/env ruby
# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

# Smoke test to ensure the table_select example can be loaded and instantiated
class TestTableSelect < Minitest::Test
  def test_table_select_smoke
    # Verify the example can create a table with selection
    rows = [["1", "test", "10%"]]
    widths = [
      RatatuiRuby::Constraint.length(8),
      RatatuiRuby::Constraint.length(15),
      RatatuiRuby::Constraint.length(10)
    ]
    
    table = RatatuiRuby::Table.new(
      header: ["PID", "Name", "CPU"],
      rows: rows,
      widths: widths,
      selected_row: 0,
      highlight_style: RatatuiRuby::Style.new(fg: :yellow),
      highlight_symbol: "> ",
      block: RatatuiRuby::Block.new(title: "Test", borders: :all),
      footer: ["Footer"]
    )
    
    # Verify it can be drawn
    with_test_terminal(40, 10) do
      RatatuiRuby.draw(table)
      # Just verify it doesn't crash
      assert true
    end
  end
end
