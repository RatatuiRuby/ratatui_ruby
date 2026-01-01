# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestTable < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_table_creation
    header = ["A", "B"]
    rows = [["1", "2"], ["3", "4"]]
    widths = [RatatuiRuby::Constraint.length(5), RatatuiRuby::Constraint.length(5)]
    t = RatatuiRuby::Table.new(header:, rows:, widths:)
    assert_equal header, t.header
    assert_equal rows, t.rows
    assert_equal widths, t.widths
    assert_equal :when_selected, t.highlight_spacing
    assert_nil t.style
  end

  def test_table_creation_with_style
    style = RatatuiRuby::Style.new(fg: :red)
    t = RatatuiRuby::Table.new(rows: [], widths: [], style:, highlight_spacing: :always)
    assert_equal style, t.style
    assert_equal :always, t.highlight_spacing
  end

  def test_render
    with_test_terminal(20, 5) do
      t = RatatuiRuby::Table.new(
        header: ["Col1", "Col2"],
        rows: [["Val1", "Val2"]],
        widths: [RatatuiRuby::Constraint.length(8), RatatuiRuby::Constraint.length(8)]
      )
      RatatuiRuby.draw { |f| f.render_widget(t, f.area) }
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
      RatatuiRuby.draw { |f| f.render_widget(t, f.area) }
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
      header:,
      rows:,
      widths:,
      footer:,
      block: RatatuiRuby::Block.new(borders: :all)
    )

    with_test_terminal(20, 7) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
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
      RatatuiRuby::Paragraph.new(text: "Styled Footer", style: RatatuiRuby::Style.new(fg: :red)),
    ]

    table = RatatuiRuby::Table.new(
      rows:,
      widths:,
      footer:
    )

    with_test_terminal(20, 5) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
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
      rows:,
      widths:,
      style:
    )

    with_test_terminal(20, 5) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
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
      rows:,
      widths:,
      style:
    )

    with_test_terminal(20, 5) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      content = buffer_content
      assert_includes content[0], "Row 1"
    end
  end

  def test_flex_space_between
    rows = [["A", "B"]]
    widths = [RatatuiRuby::Constraint.length(1), RatatuiRuby::Constraint.length(1)]

    # SpaceBetween should push columns to edges.
    table = RatatuiRuby::Table.new(
      rows:,
      widths:,
      flex: :space_between
    )

    with_test_terminal(10, 1) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
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
      rows:,
      widths:,
      flex: :start
    )

    with_test_terminal(10, 1) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      line = buffer_content.first
      # "A B       " roughly
      # Spacing between A and B should be small (default column spacing is 1)
      assert_match(/A\s{0,3}B\s{4,}/, line)
    end
  end

  def test_column_spacing
    rows = [["A", "B"]]
    widths = [RatatuiRuby::Constraint.length(1), RatatuiRuby::Constraint.length(1)]

    # column_spacing: 5
    table = RatatuiRuby::Table.new(
      rows:,
      widths:,
      column_spacing: 5
    )

    with_test_terminal(10, 1) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      line = buffer_content.first
      # "A     B" (5 spaces)
      assert_match(/A\s{5}B/, line)
    end
  end

  def test_highlight_spacing_always
    rows = [["A"]]
    widths = [RatatuiRuby::Constraint.length(1)]

    # :always means we should see the spacing even if not selected
    table = RatatuiRuby::Table.new(
      rows:,
      widths:,
      highlight_spacing: :always,
      highlight_symbol: "> "
    )

    with_test_terminal(5, 1) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      # "  " (2 spaces) + "A" (1 char) + "  " (padding to 5?)
      # Content: "  A  "
      assert_equal ["  A  "], buffer_content
    end
  end

  def test_highlight_spacing_never
    rows = [["A"]]
    widths = [RatatuiRuby::Constraint.length(1)]

    # :never means no reserved space. "A" starts at col 0.
    table = RatatuiRuby::Table.new(
      rows:,
      widths:,
      highlight_spacing: :never,
      highlight_symbol: "> "
    )

    with_test_terminal(5, 1) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      # "A    "
      assert_equal ["A    "], buffer_content
    end
  end

  def test_highlight_spacing_when_selected_unselected
    rows = [["A"]]
    widths = [RatatuiRuby::Constraint.length(1)]

    # :when_selected (default) + Not selected -> No spacing (like :never)
    table = RatatuiRuby::Table.new(
      rows:,
      widths:,
      highlight_spacing: :when_selected,
      highlight_symbol: "> "
    )

    with_test_terminal(5, 1) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      assert_equal ["A    "], buffer_content
    end
  end

  def test_highlight_spacing_when_selected_selected
    rows = [["A"]]
    widths = [RatatuiRuby::Constraint.length(1)]

    # :when_selected (default) + Selected -> Spacing (like :always) + Symbol
    table = RatatuiRuby::Table.new(
      rows:,
      widths:,
      highlight_spacing: :when_selected,
      highlight_symbol: "> ",
      selected_row: 0
    )

    with_test_terminal(5, 1) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      # "> A  "
      assert_equal ["> A  "], buffer_content
    end
  end

  def test_mixed_cell_content
    # Verify we can mix Strings and Cells in the same row
    cell = RatatuiRuby::Cell.new(char: "X", fg: :red)
    rows = [["A", cell]]
    widths = [RatatuiRuby::Constraint.length(1), RatatuiRuby::Constraint.length(1)]

    table = RatatuiRuby::Table.new(rows:, widths:)

    with_test_terminal(5, 1) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }

      # Check content
      assert_equal "A", RatatuiRuby.get_cell_at(0, 0).char

      rendered_cell = RatatuiRuby.get_cell_at(1, 0) # Spacing? default column_spacing is 1
      # A (0) + space (1) + X (2)

      rendered_cell = RatatuiRuby.get_cell_at(2, 0)
      assert_equal "X", rendered_cell.char
      assert_equal :red, rendered_cell.fg
    end
  end

  def test_header_footer_cells
    header_cell = RatatuiRuby::Cell.new(char: "H", fg: :blue)
    footer_cell = RatatuiRuby::Cell.new(char: "F", fg: :green)

    table = RatatuiRuby::Table.new(
      rows: [],
      widths: [RatatuiRuby::Constraint.length(1)],
      header: [header_cell],
      footer: [footer_cell]
    )

    with_test_terminal(5, 3) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      # Check header (row 0)
      h = RatatuiRuby.get_cell_at(0, 0)
      assert_equal "H", h.char
      assert_equal :blue, h.fg

      # Check footer (row 1 or 2 depending on render height. with 0 rows and 3 height...
      # Usually header take 1, body takes rest, footer takes 1.
      # Let's search for "F"

      found_f = false
      3.times do |y|
        c = RatatuiRuby.get_cell_at(0, y)
        if c.char == "F"
          assert_equal :green, c.fg
          found_f = true
        end
      end
      assert found_f, "Footer cell not found"
    end
  end
end
