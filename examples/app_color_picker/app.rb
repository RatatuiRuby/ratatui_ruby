# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
$LOAD_PATH.unshift File.expand_path(__dir__)

require "ratatui_ruby"
require_relative "main_container"

# A terminal-based color picker application.
#
# Terminal users often need to select colors for themes or UI components.
# Manually typing hex codes and guessing how they will look is slow and error-prone.
#
# This application solves the problem by providing an interactive interface. It parses hex strings,
# generates palettes, and displays them visually in the terminal.
#
# === Architecture
#
# This example uses a Component-Based pattern:
# - **Components**: Self-contained UI elements with `render`, `handle_event`, and optional `tick`
# - **Container**: Owns layout, delegates to children, routes events via Chain of Responsibility
# - **Mediator**: Container interprets symbolic signals (`:consumed`, `:submitted`) for cross-component effects
#
# === Examples
#
#   AppColorPicker.new.run
#
class AppColorPicker
  # Creates a new <tt>AppColorPicker</tt> instance.
  def initialize
    @container = nil
  end

  # Starts the terminal session and enters the main event loop.
  #
  # This method initializes the terminal, creates the MainContainer, and runs
  # the event loop until the user quits.
  #
  # === Example
  #
  #   app = AppColorPicker.new
  #   app.run
  #
  def run
    RatatuiRuby.run do |tui|
      @container = MainContainer.new(tui)

      loop do
        @container.tick
        tui.draw { |frame| @container.render(tui, frame, frame.area) }

        event = tui.poll_event
        break if quit_event?(event)

        @container.handle_event(event)
      end
    end
  end

  private def quit_event?(event)
    case event
    in { type: :key, code: "q" } | { type: :key, code: "esc" } |
       { type: :key, code: "c", modifiers: [/ctrl/] }
      true
    else
      false
    end
  end
end

AppColorPicker.new.run if __FILE__ == $PROGRAM_NAME
