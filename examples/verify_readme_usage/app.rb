# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require "ratatui_ruby"
class VerifyReadmeUsage
  def run
    # [SYNC:START:main]
    RatatuiRuby.run do |tui|
      loop do
        tui.draw do |frame|
          frame.render_widget(
            tui.paragraph(
              text: "Hello, Ratatui! Press 'q' to quit.",
              alignment: :center,
              block: tui.block(
                title: "My Ruby TUI App",
                borders: [:all],
                border_color: "cyan"
              )
            ),
            frame.area
          )
        end
        case tui.poll_event
        in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
          break
        else
          nil
        end
      end
    end
    # [SYNC:END:main]
  end
end

VerifyReadmeUsage.new.run if __FILE__ == $PROGRAM_NAME
