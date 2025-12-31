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
    tui.draw do |frame|
      chunks = tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          tui.constraint_length(3),
          tui.constraint_fill(1),
          tui.constraint_fill(1),
          tui.constraint_fill(1),
        ]
      )

      frame.render_widget(
        tui.paragraph(
          text: "Table Flex Layout (press 'q' to quit)",
          block: tui.block(title: "Header", borders: [:all])
        ),
        chunks[0]
      )

      frame.render_widget(
        tui.table(
          header: ["Legacy (Default)", "Table"],
          rows: [["Item 1", "Item 2"], ["Item 3", "Item 4"]],
          widths: [tui.constraint_length(20), tui.constraint_length(20)],
          block: tui.block(title: "Flex: :legacy (Default)", borders: [:all])
        ),
        chunks[1]
      )

      frame.render_widget(
        tui.table(
          header: ["Space", "Between"],
          rows: [["A", "B"], ["C", "D"]],
          widths: [tui.constraint_length(20), tui.constraint_length(20)],
          block: tui.block(title: "Flex: :space_between", borders: [:all]),
          flex: :space_between
        ),
        chunks[2]
      )

      frame.render_widget(
        tui.table(
          header: ["Space", "Around"],
          rows: [["E", "F"], ["G", "H"]],
          widths: [tui.constraint_length(20), tui.constraint_length(20)],
          block: tui.block(title: "Flex: :space_around", borders: [:all]),
          flex: :space_around
        ),
        chunks[3]
      )
    end
  end

  def handle_input(tui)
    event = tui.poll_event
    return unless event
    :quit if event == "q" || event == :ctrl_c
  end
end

TableFlexApp.new.run if __FILE__ == $0
