# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require "ratatui_ruby"

class QuickstartLifecycleApp
  def run
    # 1. Initialize the terminal
    RatatuiRuby.init_terminal

    begin
      # The Main Loop
      loop do
        # 2. Create your UI (Immediate Mode)
        # We define a Paragraph widget inside a Block with a title and borders.
        view = RatatuiRuby::Paragraph.new(
          text: "Hello, Ratatui! Press 'q' to quit.",
          alignment: :center,
          block: RatatuiRuby::Block.new(
            title: "My Ruby TUI App",
            title_alignment: :center,
            borders: [:all],
            border_color: "cyan",
            style: { fg: "white" }
          )
        )

        # 3. Draw the UI
        RatatuiRuby.draw do |frame|
          frame.render_widget(view, frame.area)
        end

        # 4. Poll for events
        event = RatatuiRuby.poll_event
        break if event.key? && event.code == "q"
      end
    ensure
      # 5. Restore the terminal to its original state
      RatatuiRuby.restore_terminal
    end
  end
end

QuickstartLifecycleApp.new.run if __FILE__ == $PROGRAM_NAME
