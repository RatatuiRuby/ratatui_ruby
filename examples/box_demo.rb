# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

def run
  RatatuiRuby.init_terminal

  color = "green"
  text = "Press Arrow Keys (q to quit)"

  loop do
    # 1. State/View
    block = RatatuiRuby::Block.new(
      title: "Box Demo",
      borders: [:all],
      border_color: "green"
    )

    view_tree = RatatuiRuby::Paragraph.new(
      text:,
      fg: color,
      block:
    )

    # 2. Render
    RatatuiRuby.draw(view_tree)

    # 3. Events
    event = RatatuiRuby.poll_event
    next if event.nil?

    if event[:type] == :key
      case event[:code]
      when "q"
        break
      when "up"
        color = "red"
        text = "Up Pressed!"
      when "down"
        color = "blue"
        text = "Down Pressed!"
      when "left"
        color = "yellow"
        text = "Left Pressed!"
      when "right"
        color = "magenta"
        text = "Right Pressed!"
      end
    end
  end
ensure
  RatatuiRuby.restore_terminal
end

run if __FILE__ == $0
