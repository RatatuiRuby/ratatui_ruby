# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# A demo showing Block padding capabilities
class BlockPaddingApp
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

        # Layout
        layout = RatatuiRuby::Layout.new(
          direction: :vertical,
          constraints: [
            RatatuiRuby::Constraint.length(10), # Uniform Padding
            RatatuiRuby::Constraint.length(10), # Directional Padding
            RatatuiRuby::Constraint.min(0),
          ],
          children: [para1, para2, para3]
        )

        tui.draw(layout)

        event = tui.poll_event
        break if event == "q" || event == :ctrl_c
      end
    end
  end
end

if __FILE__ == $0
  BlockPaddingApp.new.run
end
