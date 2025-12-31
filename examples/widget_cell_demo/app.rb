# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# A custom widget that fills its area with a checkered pattern using Cell objects.
class CheckeredBackground
  def render(area)
    cell = RatatuiRuby::Cell.new(char: "░", fg: :dark_gray)
    commands = []
    area.height.times do |y|
      area.width.times do |x|
        # Checkerboard logic
        if (x + y).even?
          # Use a dim cell for the background pattern
          commands << RatatuiRuby::Draw.cell(area.x + x, area.y + y, cell)
        end
      end
    end
    commands
  end
end

class WidgetCellDemo
  def main
    RatatuiRuby.run do |tui|
      # Define some reusable cells for our table
      ok_cell = RatatuiRuby::Cell.new(char: "OK", fg: :green)
      fail_cell = RatatuiRuby::Cell.new(char: "FAIL", fg: :red, modifiers: ["bold"])
      pending_cell = RatatuiRuby::Cell.new(char: "...", fg: :yellow, modifiers: ["dim"])

      # A mix of Strings and Cells in rows
      rows = [
        ["Database", ok_cell],
        ["Cache", ok_cell],
        ["Worker", fail_cell],
        ["Analytics", pending_cell],
        ["Web Server", RatatuiRuby::Cell.new(char: "RESTARTING", fg: :blue, modifiers: ["rapid_blink"])],
      ]

      table = RatatuiRuby::Table.new(
        header: ["Service", RatatuiRuby::Cell.new(char: "Status", modifiers: ["underlined"])],
        rows:,
        widths: [
          RatatuiRuby::Constraint.percentage(70),
          RatatuiRuby::Constraint.percentage(30),
        ],
        block: RatatuiRuby::Block.new(title: "System Status", borders: :all),
        column_spacing: 1
      )

      # Main loop
      loop do
        # Create a layout that holds both widgets
        # We use a vertical layout:
        # Top: Custom CheckeredBackground with specific height
        # Bottom: Table using remaining space

        # Note: CheckeredBackground renders to the area implicitly if passed as a child.
        # However, to overlay the paragraph, we might need a more complex structure or
        # wrapper. RatatuiRuby::Layout handles non-overlapping children.
        # To get the "Overlay" effect from my previous code (Paragraph over Background),
        # we would need to composite them. For now, let's just show them stacked or
        # using 'Overlay' widget if it exists.

        # Checking schema: Overlay exists? Yes: require_relative "ratatui_ruby/schema/overlay" in lib/ratatui_ruby.rb

        layout = RatatuiRuby::Layout.new(
          direction: :vertical,
          constraints: [
            RatatuiRuby::Constraint.length(10), # Top section
            RatatuiRuby::Constraint.min(0), # Bottom section
          ],
          children: [
            # Top Child: An Overlay of Paragraph on top of CheckeredBackground
            RatatuiRuby::Overlay.new(
              layers: [
                CheckeredBackground.new,
                RatatuiRuby::Center.new(
                  width_percent: 50,
                  height_percent: 50,
                  child: RatatuiRuby::Paragraph.new(
                    text: "Custom Widget Demo\n(CheckeredBackground)",
                    alignment: :center,
                    block: RatatuiRuby::Block.new(borders: :all, title: "Overlay")
                  )
                ),
              ]
            ),
            # Bottom Child: The Table
            table,
          ]
        )

        tui.draw(layout)

        event = RatatuiRuby.poll_event
        if event.is_a?(RatatuiRuby::Event::Key) && (event.code == "q" || (event.code == "c" && event.modifiers.include?("ctrl")))
          break
        end
      end
    end
  end
end

if __FILE__ == $0
  WidgetCellDemo.new.main
end
