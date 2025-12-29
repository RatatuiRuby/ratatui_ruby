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
    assert_nil t.style
  end

  def test_table_creation_with_style
    style = RatatuiRuby::Style.new(fg: :red)
    t = RatatuiRuby::Table.new(rows: [], widths: [], style: style)
    assert_equal style, t.style
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
  def test_footer_rendering
    rows = [["Row 1"]]
    widths = [RatatuiRuby::Constraint.length(10)]
    header = ["Header"]
    footer = ["Footer"]

    table = RatatuiRuby::Table.new(
      header: header,
      rows: rows,
      widths: widths,
      footer: footer,
      block: RatatuiRuby::Block.new(borders: :all)
    )

    with_test_terminal(20, 7) do
      RatatuiRuby.draw(table)
      content = buffer_content

      # Check for header
      assert_includes content.join("\n"), "Header"
      # Check for footer
      assert_includes content.join("\n"), "Footer"
      
      # Visual check (borders + content)
      # Line 0: top border
      # Line 1: Header
      # Line 2: header border (if any? Table default rendering usually has one)
      # ... content ...
      # Line 5: Footer
      # Line 6: bottom border
    end
  end

  def test_footer_styling
    rows = [["Row 1"]]
    widths = [RatatuiRuby::Constraint.length(20)]
    footer = [
      RatatuiRuby::Paragraph.new(text: "Styled Footer", style: RatatuiRuby::Style.new(fg: :red))
    ]

    table = RatatuiRuby::Table.new(
      rows: rows,
      widths: widths,
      footer: footer
    )

    with_test_terminal(20, 5) do
      RatatuiRuby.draw(table)
      content = buffer_content
      # In a real terminal we'd check styles, but here we just check content presence implies it rendered.
      assert_includes content.join("\n"), "Styled Footer"
    end
  end

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
