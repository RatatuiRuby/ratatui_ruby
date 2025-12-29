# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestTableStyle < Minitest::Test
  def test_style_rendering
    # We can't easily verify the colors in the test terminal output yet,
    # but we can verify it renders without crashing and maintains its layout.
    rows = [["Row 1"]]
    widths = [RatatuiRuby::Constraint.length(10)]
    style = RatatuiRuby::Style.new(fg: :blue, bg: :white)

    table = RatatuiRuby::Table.new(
      rows: rows,
      widths: widths,
      style: style
    )

    with_test_terminal(20, 5) do
      RatatuiRuby.draw(table)
      content = buffer_content
      assert_includes content[0], "Row 1"
    end
  end

  def test_style_hash_rendering
    # Verify Hash-based style also works
    rows = [["Row 1"]]
    widths = [RatatuiRuby::Constraint.length(10)]
    style = { fg: :red }

    table = RatatuiRuby::Table.new(
      rows: rows,
      widths: widths,
      style: style
    )

    with_test_terminal(20, 5) do
      RatatuiRuby.draw(table)
      content = buffer_content
      assert_includes content[0], "Row 1"
    end
  end
end
