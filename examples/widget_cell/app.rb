# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# A custom widget that fills its area with a checkered pattern using Cell objects.
class CheckeredBackground
  def initialize(tui)
    @tui = tui
  end

  def render(area)
    cell = @tui.cell(char: "░", fg: :dark_gray)
    commands = []
    area.height.times do |y|
      area.width.times do |x|
        # Checkerboard logic
        if (x + y).even?
          # Use a dim cell for the background pattern
          commands << @tui.draw_cell(area.x + x, area.y + y, cell)
        end
      end
    end
    commands
  end
end

class WidgetCell
  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      # Define some reusable cells for our table
      ok_cell = @tui.cell(char: "OK", fg: :green)
      fail_cell = @tui.cell(char: "FAIL", fg: :red, modifiers: ["bold"])
      pending_cell = @tui.cell(char: "...", fg: :yellow, modifiers: ["dim"])

      # A mix of Strings and Cells in rows
      rows = [
        ["Database", ok_cell],
        ["Cache", ok_cell],
        ["Worker", fail_cell],
        ["Analytics", pending_cell],
        ["Web Server", @tui.cell(char: "RESTARTING", fg: :blue, modifiers: ["rapid_blink"])],
      ]

      table = @tui.table(
        header: ["Service", @tui.cell(char: "Status", modifiers: ["underlined"])],
        rows:,
        widths: [
          @tui.constraint_percentage(70),
          @tui.constraint_percentage(30),
        ],
        block: @tui.block(title: "System Status", borders: :all),
        column_spacing: 1
      )

      # Main loop
      loop do
        @tui.draw do |frame|
          # Create a layout that holds both widgets
          # We use a vertical layout:
          # Top: Custom CheckeredBackground with specific height
          # Bottom: Table using remaining space
          top_area, bottom_area = @tui.layout_split(
            frame.area,
            direction: :vertical,
            constraints: [
              @tui.constraint_length(10), # Top section
              @tui.constraint_min(0), # Bottom section
            ]
          )

          # Top Child: An Overlay of Paragraph on top of CheckeredBackground
          overlay = @tui.overlay(
            layers: [
              CheckeredBackground.new(@tui),
              @tui.center(
                width_percent: 50,
                height_percent: 50,
                child: @tui.paragraph(
                  text: "Custom Widget\n(CheckeredBackground)",
                  alignment: :center,
                  block: @tui.block(borders: :all, title: "Overlay")
                )
              ),
            ]
          )
          frame.render_widget(overlay, top_area)

          # Bottom Child: The Table
          frame.render_widget(table, bottom_area)
        end

        case @tui.poll_event
        in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
          break
        else
          nil
        end
      end
    end
  end
end

if __FILE__ == $0
  WidgetCell.new.run
end
