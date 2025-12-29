# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ratatui_ruby"

# Using the RatatuiRuby.run block for automatic terminal setup/teardown
RatatuiRuby.run do |tui|
  # The Main Loop
  loop do
    # 1. Create your UI (Immediate Mode)
    # We define a Paragraph widget inside a Block with a title and borders.
    view = RatatuiRuby::Paragraph.new(
      text: "Hello, Ratatui! Press 'q' to quit.",
      align: :center,
      block: RatatuiRuby::Block.new(
        title: "My Ruby TUI App",
        borders: [:all],
        border_color: "cyan"
      )
    )

    # 2. Draw the UI
    tui.draw(view)

    # 3. Poll for events
    event = RatatuiRuby.poll_event
    break if event == "q" || event == :ctrl_c
  end
end
