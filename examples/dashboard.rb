# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

include RatatuiRuby

items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
selected_index = 0

RatatuiRuby.init_terminal

begin
  loop do
    selected_item = items[selected_index]

    sidebar = List.new(
      items: items,
      selected_index: selected_index,
      block: Block.new(title: "Files", borders: [:all])
    )

    main_content = Paragraph.new(
      text: "You selected: #{selected_item}",
      block: Block.new(title: "Content", borders: [:all])
    )

    layout = Layout.new(
      direction: :horizontal,
      constraints: [
        Constraint.percentage(30),
        Constraint.min(0)
      ],
      children: [sidebar, main_content]
    )

    RatatuiRuby.draw(layout)

    event = RatatuiRuby.poll_event
    if event
      case event[:code]
      when "q", "esc"
        break
      when "up"
        selected_index = (selected_index - 1) % items.length
      when "down"
        selected_index = (selected_index + 1) % items.length
      end
    end
  end
ensure
  RatatuiRuby.restore_terminal
end
