# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Initialize the terminal
class WidgetBlockTitles
  def run
    RatatuiRuby.run do |tui|
      loop do
        # Create a layout with multiple blocks demonstrating titles
        blocks = [
          tui.block(
            titles: [
              { content: "Top Left", alignment: :left, position: :top },
              { content: "Top Right", alignment: :right, position: :top },
            ],
            borders: [:all],
            border_color: "cyan"
          ),
          tui.block(
            titles: [
              { content: "Bottom Left", alignment: :left, position: :bottom },
              { content: "Bottom Center", alignment: :center, position: :bottom },
              { content: "Bottom Right", alignment: :right, position: :bottom },
            ],
            borders: [:all],
            border_color: "magenta"
          ),
          tui.block(
            titles: [
              "Simple String Title (Top Left Default)",
              { content: "Mixed Title", alignment: :center, position: :bottom },
            ],
            borders: [:all],
            border_color: "green"
          ),
        ]

        tui.draw do |frame|
          layout = tui.layout_split(
            frame.area,
            direction: :vertical,
            constraints: [
              tui.constraint(:length, 10),
              tui.constraint(:length, 10),
              tui.constraint(:length, 10),
            ]
          )

          layout.each_with_index do |area, i|
            frame.render_widget(blocks[i], area) if blocks[i]
          end
        end

        event = tui.poll_event
        break if event == "q" || event == :ctrl_c
      end
    end
  end
end

if __FILE__ == $0
  WidgetBlockTitles.new.run
end
