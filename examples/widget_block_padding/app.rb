# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# A demo showing Block padding capabilities
class WidgetBlockPadding
  def run
    RatatuiRuby.run do |tui|
      loop do
        # 1. Uniform Padding
        block1 = RatatuiRuby::Block.new(
          title: "Uniform Padding (2)",
          borders: [:all],
          padding: 2
        )
        para1 = RatatuiRuby::Paragraph.new(
          text: "This text is padded by 2 on all sides.\nNotice the space between the border and this text.",
          block: block1
        )

        # 2. Directional Padding
        block2 = RatatuiRuby::Block.new(
          title: "Directional Padding [Left: 4, Right: 0, Top: 2, Bottom: 0]",
          borders: [:all],
          padding: [4, 0, 2, 0]
        )
        para2 = RatatuiRuby::Paragraph.new(
          text: "This text has different padding per side.\nLeft: 4, Top: 2.",
          block: block2
        )

        # Instructions
        para3 = RatatuiRuby::Paragraph.new(
          text: "Press 'q' to quit."
        )

        tui.draw do |frame|
          # Layout
          areas = RatatuiRuby::Layout.split(
            frame.area,
            direction: :vertical,
            constraints: [
              RatatuiRuby::Constraint.length(10), # Uniform Padding
              RatatuiRuby::Constraint.length(10), # Directional Padding
              RatatuiRuby::Constraint.min(0),
            ]
          )

          frame.render_widget(para1, areas[0])
          frame.render_widget(para2, areas[1])
          frame.render_widget(para3, areas[2])
        end

        event = tui.poll_event
        break if event == "q" || event == :ctrl_c
      end
    end
  end
end

if __FILE__ == $0
  WidgetBlockPadding.new.run
end
