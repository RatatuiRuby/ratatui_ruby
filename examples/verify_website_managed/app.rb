# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# Test 3: Managed loop example
require "ratatui_ruby"

RatatuiRuby.run do |tui|
  loop do
    tui.draw do |frame|
      frame.render_widget(
        tui.paragraph(
          text: "Hello, RatatuiRuby!",
          alignment: :center,
          block: tui.block(
            title: "My App",
            titles: [{ content: "q: Quit", position: :bottom, alignment: :right }],
            borders: [:all],
            border_style: { fg: "cyan" }
          )
        ),
        frame.area
      )
    end

    case tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      break
    else nil
    end
  end
end
