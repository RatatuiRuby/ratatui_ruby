# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ratatui_ruby"

# 1. Initialize the terminal, start the main loop, and ensure the terminal is restored.
RatatuiRuby.main_loop do |tui|
  # 2. Create your UI with methods instead of classes.
  view = tui.paragraph(
    text: "Hello, Ratatui! Press 'q' to quit.",
    align: :center,
    block: tui.block(
      title: "My Ruby TUI App",
      borders: [:all],
      border_color: "cyan"
    )
  )

  # 3. Use RatatuiRuby methods, too.
  tui.draw(view)
  event = tui.poll_event

  if event && event[:type] == :key && event[:code] == "q"
    break
  end
end
