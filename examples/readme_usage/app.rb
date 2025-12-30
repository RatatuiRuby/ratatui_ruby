# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require "ratatui_ruby"
class ReadmeUsageApp
  def run
    RatatuiRuby.run do |tui|
      loop do
        tui.draw \
          tui.paragraph \
            text: "Hello, Ratatui! Press 'q' to quit.",
            alignment: :center,
            block: tui.block(
              title: "My Ruby TUI App",
              borders: [:all],
              border_color: "cyan"
            )
        event = tui.poll_event
        break if event == "q" || event == :ctrl_c
      end
    end
  end
end

ReadmeUsageApp.new.run if __FILE__ == $PROGRAM_NAME
