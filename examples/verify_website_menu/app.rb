# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# Test 2: Inline menu example (fixed)
require "ratatui_ruby"

choices = ["Production", "Staging", "Development"]
index = 0

RatatuiRuby.run(viewport: :inline, height: 5) do |tui|
  loop do
    tui.draw do |frame|
      items = choices.map.with_index do |c, i|
        prefix = (i == index) ? "● " : "○ "
        "#{prefix}#{c}"
      end
      widget = tui.paragraph(
        text: items.join("\n"),
        block: tui.block(
          borders: :all,
          title: "Select Environment",
          titles: [{ content: "↑/↓ Enter | Ctrl+C: Cancel", position: :bottom, alignment: :right }]
        )
      )
      frame.render_widget(widget, frame.area)
    end

    case tui.poll_event
    in { type: :key, code: "up" }
      index = (index - 1) % choices.size
    in { type: :key, code: "down" }
      index = (index + 1) % choices.size
    in { type: :key, code: "enter" }
      area = tui.viewport_area
      RatatuiRuby.cursor_position = [0, area.y + area.height]
      break
    in { type: :key, code: "c", modifiers: ["ctrl"] }
      area = tui.viewport_area
      RatatuiRuby.cursor_position = [0, area.y + area.height]
      index = nil
      break
    else nil
    end
  end
end

puts
if index
  puts "Deploying to #{choices[index]}..."
else
  puts "Cancelled."
end
