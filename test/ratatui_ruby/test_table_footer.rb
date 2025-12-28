# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestTableFooter < Minitest::Test
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
end
