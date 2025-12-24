# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ratatui_ruby"
RatatuiRuby.main_loop do |tui|
  tui.draw \
    tui.paragraph \
      text: "Hello, Ratatui! Press 'q' to quit.",
      align: :center,
      block: tui.block(
        title: "My Ruby TUI App",
        borders: [:all],
        border_color: "cyan"
      )
  event = tui.poll_event
  break if event && event[:type] == :key && event[:code] == "q"
end
