# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# A custom widget that draws a diagonal line.
class DiagonalWidget
  def render(area)
    # Draw a diagonal line within the area
    (0..10).filter_map do |i|
      next if i >= area.width || i >= area.height

      RatatuiRuby::Draw.string(
        area.x + i,
        area.y + i,
        "\\",
        RatatuiRuby::Style.new(fg: :red, modifiers: [:bold])
      )
    end
  end
end

class CustomWidgetApp
  def run
    RatatuiRuby.run do |tui|
      loop do
        tui.draw do |frame|
          layout = tui.layout_split(
            frame.area,
            direction: :vertical,
            constraints: [
              tui.constraint_percentage(50),
              tui.constraint_percentage(50),
            ]
          )

          frame.render_widget(tui.paragraph(text: "Above custom widget"), layout[0])
          frame.render_widget(DiagonalWidget.new, layout[1])
        end

        event = tui.poll_event
        break if event == "q" || event == :ctrl_c
      end
    end
  end
end

CustomWidgetApp.new.run if __FILE__ == $PROGRAM_NAME
