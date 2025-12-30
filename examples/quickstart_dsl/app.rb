# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require "ratatui_ruby"

class QuickstartDslApp
  def run
    # 1. Initialize the terminal, start the run loop, and ensure the terminal is restored.
    RatatuiRuby.run do |tui|
      loop do
        # 2. Create your UI with methods instead of classes.
        view = tui.paragraph(
          text: "Hello, Ratatui! Press 'q' to quit.",
          alignment: :center,
          block: tui.block(
            title: "My Ruby TUI App",
            borders: [:all],
            border_color: "cyan"
          )
        )

        # 3. Use RatatuiRuby methods, too.
        tui.draw(view)
        event = tui.poll_event

        break if event == "q" || event == :ctrl_c
      end
    end
  end
end

QuickstartDslApp.new.run if __FILE__ == $PROGRAM_NAME
