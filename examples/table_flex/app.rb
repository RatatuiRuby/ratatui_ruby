# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

class TableFlexApp
  def run
    RatatuiRuby.run do |tui|
      loop do
        render(tui)
        break if handle_input(tui) == :quit
      end
    end
  end

  def render(tui)
    layout = tui.layout(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.length(3),
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.fill(1)
      ],
      children: [
        tui.paragraph(
          text: "Table Flex Layout (press 'q' to quit)",
          block: tui.block(title: "Header", borders: [:all])
        ),
        tui.table(
          header: ["Legacy (Default)", "Table"],
          rows: [["Item 1", "Item 2"], ["Item 3", "Item 4"]],
          widths: [RatatuiRuby::Constraint.length(20), RatatuiRuby::Constraint.length(20)],
          block: tui.block(title: "Flex: :legacy (Default)", borders: [:all])
        ),
        tui.table(
          header: ["Space", "Between"],
          rows: [["A", "B"], ["C", "D"]],
          widths: [RatatuiRuby::Constraint.length(20), RatatuiRuby::Constraint.length(20)],
          block: tui.block(title: "Flex: :space_between", borders: [:all]),
          flex: :space_between
        ),
        tui.table(
          header: ["Space", "Around"],
          rows: [["E", "F"], ["G", "H"]],
          widths: [RatatuiRuby::Constraint.length(20), RatatuiRuby::Constraint.length(20)],
          block: tui.block(title: "Flex: :space_around", borders: [:all]),
          flex: :space_around
        )
      ]
    )
    tui.draw(layout)
  end

  def handle_input(tui)
    event = tui.poll_event
    return unless event
    :quit if event == "q" || event == :ctrl_c
  end
end

TableFlexApp.new.run if __FILE__ == $0
