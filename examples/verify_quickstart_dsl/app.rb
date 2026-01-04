# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require "ratatui_ruby"

class VerifyQuickstartDsl
  def run
    # [SYNC:START:main]
    # 1. Initialize the terminal, start the run loop, and ensure the terminal is restored.
    RatatuiRuby.run do |tui|
      loop do
        # 2. Create your UI with methods instead of classes.
        view = tui.paragraph(
          text: "Hello, Ratatui! Press 'q' to quit.",
          alignment: :center,
          block: tui.block(
            title: "My Ruby TUI App",
            title_alignment: :center,
            borders: [:all],
            border_color: "cyan",
            style: { fg: "white" }
          )
        )

        # 3. Use RatatuiRuby methods, too.
        tui.draw do |frame|
          frame.render_widget(view, frame.area)
        end

        # 4. Poll for events with pattern matching
        case tui.poll_event
        in { type: :key, code: "q" }
          break
        else
          # Ignore other events
        end
      end
    end
    # [SYNC:END:main]
  end
end

VerifyQuickstartDsl.new.run if __FILE__ == $PROGRAM_NAME
