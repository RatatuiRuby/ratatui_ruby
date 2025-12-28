# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# A custom widget that draws a diagonal line.
class DiagonalWidget
  def render(area, buffer)
    # Draw a diagonal line within the area
    (0..10).each do |i|
      next if area.x + i >= area.x + area.width || area.y + i >= area.y + area.height

      buffer.set_string(
        area.x + i,
        area.y + i,
        "\\",
        RatatuiRuby::Style.new(fg: :red, modifiers: [:bold])
      )
    end
  end
end

RatatuiRuby.main_loop do |tui|
  tui.draw(
    RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.percentage(50),
        RatatuiRuby::Constraint.percentage(50),
      ],
      children: [
        RatatuiRuby::Paragraph.new(text: "Above custom widget"),
        DiagonalWidget.new,
      ]
    )
  )

  event = RatatuiRuby.poll_event
  break if event && event[:type] == :key && event[:code] == "q"
end
