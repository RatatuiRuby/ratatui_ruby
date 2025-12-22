# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

def run
  RatatuiRuby.init_terminal

  loop do
    # 1. Logic/State (Recreate the entire tree every frame)
    view_tree = RatatuiRuby::Layout.new(
      direction: :vertical,
      children: [
        RatatuiRuby::Paragraph.new(text: "Hello", fg: "red", bg: "black"),
        RatatuiRuby::Paragraph.new(text: "World", fg: "blue", bg: "black"),
      ]
    )

    # 2. Render
    RatatuiRuby.draw(view_tree)

    # 3. Handle Events
    event = RatatuiRuby.poll_event
    break if event == "q"
  end
ensure
  RatatuiRuby.restore_terminal
end

run if __FILE__ == $0
