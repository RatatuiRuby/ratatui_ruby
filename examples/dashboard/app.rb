# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

include RatatuiRuby

class DashboardApp
  include RatatuiRuby

  def initialize
    @items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    @selected_index = 0
  end

  def run
    RatatuiRuby.run do
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private

  def render
    selected_item = @items[@selected_index]

    sidebar = List.new(
      items: @items,
      selected_index: @selected_index,
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
        Constraint.min(0),
      ],
      children: [sidebar, main_content]
    )

    RatatuiRuby.draw(layout)
  end

  def handle_input
    case RatatuiRuby.poll_event
    in {type: :key, code: "q" | "esc"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    in type: :key, code: "up"
      @selected_index = (@selected_index - 1) % @items.length
    in type: :key, code: "down"
      @selected_index = (@selected_index + 1) % @items.length
    else
      nil
    end
  end
end

DashboardApp.new.run if __FILE__ == $0
