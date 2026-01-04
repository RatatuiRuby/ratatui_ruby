# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestTable < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_table_creation
    header = ["A", "B"]
    rows = [["1", "2"], ["3", "4"]]
    widths = [RatatuiRuby::Layout::Constraint.length(5), RatatuiRuby::Layout::Constraint.length(5)]
    t = RatatuiRuby::Widgets::Table.new(header:, rows:, widths:)
    assert_equal header, t.header
    assert_equal rows, t.rows
    assert_equal widths, t.widths
    assert_equal :when_selected, t.highlight_spacing
    assert_nil t.style
  end

  def test_table_creation_with_style
    style = RatatuiRuby::Style::Style.new(fg: :red)
    t = RatatuiRuby::Widgets::Table.new(rows: [], widths: [], style:, highlight_spacing: :always)
    assert_equal style, t.style
    assert_equal :always, t.highlight_spacing
  end

  def test_render
    with_test_terminal(20, 5) do
      t = RatatuiRuby::Widgets::Table.new(
        header: ["Col1", "Col2"],
        rows: [["Val1", "Val2"]],
        widths: [RatatuiRuby::Layout::Constraint.length(8), RatatuiRuby::Layout::Constraint.length(8)]
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
      t = RatatuiRuby::Widgets::Table.new(
        header: ["Col1", "Col2"],
        rows: [["Val1", "Val2"], ["Val3", "Val4"]],
        widths: [RatatuiRuby::Layout::Constraint.length(8), RatatuiRuby::Layout::Constraint.length(8)],
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
    widths = [RatatuiRuby::Layout::Constraint.length(10)]
    header = ["Header"]
    footer = ["Footer"]

    table = RatatuiRuby::Widgets::Table.new(
      header:,
      rows:,
      widths:,
      footer:,
      block: RatatuiRuby::Widgets::Block.new(borders: :all)
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
    widths = [RatatuiRuby::Layout::Constraint.length(20)]
    footer = [
      RatatuiRuby::Widgets::Paragraph.new(text: "Styled Footer", style: RatatuiRuby::Style::Style.new(fg: :red)),
    ]

    table = RatatuiRuby::Widgets::Table.new(
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
    widths = [RatatuiRuby::Layout::Constraint.length(10)]
    style = RatatuiRuby::Style::Style.new(fg: :blue, bg: :white)

    table = RatatuiRuby::Widgets::Table.new(
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
    widths = [RatatuiRuby::Layout::Constraint.length(10)]
    style = { fg: :red }

    table = RatatuiRuby::Widgets::Table.new(
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
    widths = [RatatuiRuby::Layout::Constraint.length(1), RatatuiRuby::Layout::Constraint.length(1)]

    # SpaceBetween should push columns to edges.
    table = RatatuiRuby::Widgets::Table.new(
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
    widths = [RatatuiRuby::Layout::Constraint.length(1), RatatuiRuby::Layout::Constraint.length(1)]

    # Start should push columns to left
    table = RatatuiRuby::Widgets::Table.new(
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
    widths = [RatatuiRuby::Layout::Constraint.length(1), RatatuiRuby::Layout::Constraint.length(1)]

    # column_spacing: 5
    table = RatatuiRuby::Widgets::Table.new(
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
    widths = [RatatuiRuby::Layout::Constraint.length(1)]

    # :always means we should see the spacing even if not selected
    table = RatatuiRuby::Widgets::Table.new(
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
    widths = [RatatuiRuby::Layout::Constraint.length(1)]

    # :never means no reserved space. "A" starts at col 0.
    table = RatatuiRuby::Widgets::Table.new(
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
    widths = [RatatuiRuby::Layout::Constraint.length(1)]

    # :when_selected (default) + Not selected -> No spacing (like :never)
    table = RatatuiRuby::Widgets::Table.new(
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
    widths = [RatatuiRuby::Layout::Constraint.length(1)]

    # :when_selected (default) + Selected -> Spacing (like :always) + Symbol
    table = RatatuiRuby::Widgets::Table.new(
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
    # Verify we can mix Strings and Text::Span (styled) in the same row
    styled_span = RatatuiRuby::Text::Span.new(content: "X", style: RatatuiRuby::Style::Style.new(fg: :red))
    rows = [["A", styled_span]]
    widths = [RatatuiRuby::Layout::Constraint.length(1), RatatuiRuby::Layout::Constraint.length(1)]

    table = RatatuiRuby::Widgets::Table.new(rows:, widths:)

    with_test_terminal(5, 1) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }

      # Check content
      assert_equal "A", RatatuiRuby.get_cell_at(0, 0).char

      # A (0) + space (1) + X (2)
      rendered_cell = RatatuiRuby.get_cell_at(2, 0)
      assert_equal "X", rendered_cell.char
      assert_equal :red, rendered_cell.fg
    end
  end

  def test_header_footer_cells
    # Use Text::Span for styled header/footer content
    header_span = RatatuiRuby::Text::Span.new(content: "H", style: RatatuiRuby::Style::Style.new(fg: :blue))
    footer_span = RatatuiRuby::Text::Span.new(content: "F", style: RatatuiRuby::Style::Style.new(fg: :green))

    table = RatatuiRuby::Widgets::Table.new(
      rows: [],
      widths: [RatatuiRuby::Layout::Constraint.length(1)],
      header: [header_span],
      footer: [footer_span]
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

  def test_offset_forces_scroll_position
    # 10 rows, terminal height 5 (header + 4 data rows), offset forces viewport
    rows = (0..9).map { |i| ["Row #{i}"] }
    with_test_terminal(20, 5) do
      table = RatatuiRuby::Widgets::Table.new(
        header: ["Header"],
        rows:,
        widths: [RatatuiRuby::Layout::Constraint.length(10)],
        selected_row: 5,
        offset: 5
      )
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      content = buffer_content.join("\n")
      # Offset 5 means first visible data row shows Row 5
      assert_includes content, "Row 5"
      assert_includes content, "Row 6"
    end
  end

  def test_offset_nil_allows_auto_scroll
    rows = (0..9).map { |i| ["Row #{i}"] }
    with_test_terminal(20, 4) do
      table = RatatuiRuby::Widgets::Table.new(
        header: ["Header"],
        rows:,
        widths: [RatatuiRuby::Layout::Constraint.length(10)],
        selected_row: 8 # Near the end
      )
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      content = buffer_content.join("\n")
      # Auto-scroll should make Row 8 visible
      assert_includes content, "Row 8"
    end
  end

  def test_offset_without_selection
    # Passive scroll: no selection, just viewing rows 5+
    rows = (0..9).map { |i| ["Row #{i}"] }
    with_test_terminal(20, 4) do
      table = RatatuiRuby::Widgets::Table.new(
        header: ["Header"],
        rows:,
        widths: [RatatuiRuby::Layout::Constraint.length(10)],
        selected_row: nil,
        offset: 5
      )
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      content = buffer_content.join("\n")
      # Offset 5 with no selection shows Rows 5, 6, etc.
      assert_includes content, "Row 5"
      assert_includes content, "Row 6"
    end
  end

  # Feature 1: Table cells now accept Text::Span and Text::Line
  def test_rich_text_cell_with_span
    span = RatatuiRuby::Text::Span.new(content: "Styled", style: RatatuiRuby::Style::Style.new(fg: :red))
    rows = [[span]]
    widths = [RatatuiRuby::Layout::Constraint.length(10)]
    table = RatatuiRuby::Widgets::Table.new(rows:, widths:)

    with_test_terminal(10, 1) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      assert_includes buffer_content.first, "Styled"
      # Verify style applied
      cell = RatatuiRuby.get_cell_at(0, 0)
      assert_equal :red, cell.fg
    end
  end

  def test_rich_text_cell_with_line
    line = RatatuiRuby::Text::Line.new(spans: [
      RatatuiRuby::Text::Span.new(content: "Hello ", style: RatatuiRuby::Style::Style.new(fg: :green)),
      RatatuiRuby::Text::Span.new(content: "World", style: RatatuiRuby::Style::Style.new(fg: :blue)),
    ])
    rows = [[line]]
    widths = [RatatuiRuby::Layout::Constraint.length(15)]
    table = RatatuiRuby::Widgets::Table.new(rows:, widths:)

    with_test_terminal(15, 1) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      content = buffer_content.first
      assert_includes content, "Hello"
      assert_includes content, "World"
      # Verify styles (green for first part, blue after space)
      assert_equal :green, RatatuiRuby.get_cell_at(0, 0).fg
      assert_equal :blue, RatatuiRuby.get_cell_at(6, 0).fg
    end
  end

  def test_rich_text_header_with_span
    header = [RatatuiRuby::Text::Span.new(content: "Title", style: RatatuiRuby::Style::Style.new(modifiers: [:bold]))]
    rows = [["Data"]]
    widths = [RatatuiRuby::Layout::Constraint.length(10)]
    table = RatatuiRuby::Widgets::Table.new(header:, rows:, widths:)

    with_test_terminal(10, 2) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      assert_includes buffer_content[0], "Title"
      assert RatatuiRuby.get_cell_at(0, 0).bold?
    end
  end

  # Feature 2: Row class for row-level styling
  def test_row_with_style
    row = RatatuiRuby::Widgets::Row.new(
      cells: ["Error", "Something went wrong"],
      style: RatatuiRuby::Style::Style.new(bg: :red)
    )
    rows = [["Normal", "Row"], row]
    widths = [RatatuiRuby::Layout::Constraint.length(10), RatatuiRuby::Layout::Constraint.length(20)]
    table = RatatuiRuby::Widgets::Table.new(rows:, widths:)

    with_test_terminal(30, 2) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      # First row: normal (no background)
      assert_nil RatatuiRuby.get_cell_at(0, 0).bg
      # Second row (Row object): red background
      assert_equal :red, RatatuiRuby.get_cell_at(0, 1).bg
    end
  end

  def test_row_with_height
    row = RatatuiRuby::Widgets::Row.new(cells: ["Tall"], height: 3)
    rows = [row]
    widths = [RatatuiRuby::Layout::Constraint.length(10)]
    table = RatatuiRuby::Widgets::Table.new(rows:, widths:)

    with_test_terminal(10, 5) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      # The row should occupy 3 lines (content on line 0, blanks on 1-2)
      assert_includes buffer_content[0], "Tall"
      # Lines 1 and 2 should be part of the row (empty/reserved space)
    end
  end

  def test_row_creation
    row = RatatuiRuby::Widgets::Row.new(cells: ["A", "B"], style: RatatuiRuby::Style::Style.new(fg: :blue), height: 2)
    assert_equal ["A", "B"], row.cells
    assert_equal :blue, row.style.fg
    assert_equal 2, row.height
  end

  # Feature 3: Widgets::Cell for per-cell styling
  def test_cell_creation
    cell = RatatuiRuby::Widgets::Cell.new(content: "Error", style: RatatuiRuby::Style::Style.new(bg: :red))
    assert_equal "Error", cell.content
    assert_equal :red, cell.style.bg
  end

  def test_cell_with_span_content
    span = RatatuiRuby::Text::Span.new(content: "Warning", style: RatatuiRuby::Style::Style.new(fg: :yellow))
    cell = RatatuiRuby::Widgets::Cell.new(content: span, style: RatatuiRuby::Style::Style.new(bg: :dark_gray))
    assert_equal span, cell.content
  end

  def test_cell_rendering_in_table
    cell = RatatuiRuby::Widgets::Cell.new(content: "Styled", style: RatatuiRuby::Style::Style.new(bg: :blue))
    rows = [[cell]]
    widths = [RatatuiRuby::Layout::Constraint.length(10)]
    table = RatatuiRuby::Widgets::Table.new(rows:, widths:)

    with_test_terminal(10, 1) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      assert_includes buffer_content.first, "Styled"
      # Verify cell-level style applied
      assert_equal :blue, RatatuiRuby.get_cell_at(0, 0).bg
    end
  end

  def test_cell_in_row
    # Widgets::Cell inside Widgets::Row
    styled_cell = RatatuiRuby::Widgets::Cell.new(content: "X", style: RatatuiRuby::Style::Style.new(fg: :green))
    row = RatatuiRuby::Widgets::Row.new(cells: ["A", styled_cell])
    rows = [row]
    widths = [RatatuiRuby::Layout::Constraint.length(3), RatatuiRuby::Layout::Constraint.length(3)]
    table = RatatuiRuby::Widgets::Table.new(rows:, widths:)

    with_test_terminal(10, 1) do
      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }
      # "X" at column 4 (after "A" + spacing)
      x_cell = RatatuiRuby.get_cell_at(4, 0)
      assert_equal "X", x_cell.char
      assert_equal :green, x_cell.fg
    end
  end

  # v0.7.0: row_highlight_style renamed from highlight_style
  def test_row_highlight_style_rendering
    with_test_terminal(20, 3) do
      rows = [["Row 1"], ["Row 2"]]
      widths = [RatatuiRuby::Layout::Constraint.length(10)]
      table = RatatuiRuby::Widgets::Table.new(
        rows:,
        widths:,
        selected_row: 1,
        row_highlight_style: RatatuiRuby::Style::Style.new(bg: :yellow)
      )

      RatatuiRuby.draw { |f| f.render_widget(table, f.area) }

      # Selected row (row 1 in data = line 1 in buffer) should have yellow bg
      cell = RatatuiRuby.get_cell_at(0, 1)
      assert_equal :yellow, cell.bg, "row_highlight_style should apply to selected row"

      # Unselected row should not have the highlight style
      unselected_cell = RatatuiRuby.get_cell_at(0, 0)
      refute_equal :yellow, unselected_cell.bg
    end
  end
end
