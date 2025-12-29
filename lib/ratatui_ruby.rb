# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "ratatui_ruby/version"
require_relative "ratatui_ruby/schema/rect"
require_relative "ratatui_ruby/schema/paragraph"
require_relative "ratatui_ruby/schema/layout"
require_relative "ratatui_ruby/schema/block"
require_relative "ratatui_ruby/schema/constraint"
require_relative "ratatui_ruby/schema/list"
require_relative "ratatui_ruby/schema/style"
require_relative "ratatui_ruby/schema/gauge"
require_relative "ratatui_ruby/schema/line_gauge"
require_relative "ratatui_ruby/schema/table"
require_relative "ratatui_ruby/schema/tabs"
require_relative "ratatui_ruby/schema/bar_chart"
require_relative "ratatui_ruby/schema/sparkline"
require_relative "ratatui_ruby/schema/chart"
require_relative "ratatui_ruby/schema/clear"
require_relative "ratatui_ruby/schema/cursor"
require_relative "ratatui_ruby/schema/overlay"
require_relative "ratatui_ruby/schema/center"
require_relative "ratatui_ruby/schema/scrollbar"
require_relative "ratatui_ruby/schema/canvas"
require_relative "ratatui_ruby/schema/calendar"
require_relative "ratatui_ruby/schema/canvas"
require_relative "ratatui_ruby/schema/calendar"
require_relative "ratatui_ruby/schema/text"
require_relative "ratatui_ruby/event"

begin
  require "ratatui_ruby/ratatui_ruby"
rescue LoadError
  # Fallback for development/CI if the bundle is not in the load path
  require_relative "ratatui_ruby/ratatui_ruby"
end

# Main entry point for the library.
#
# Terminal UIs require low-level control using C/Rust and high-level abstraction in Ruby.
#
# This module bridges the gap. It provides the native methods to initialize the terminal, handle raw mode, and render the widget tree.
#
# Use `RatatuiRuby.run` to start your application.
module RatatuiRuby
  # Generic error class for RatatuiRuby.
  class Error < StandardError; end

  ##
  # :method: init_terminal
  # :call-seq: init_terminal() -> nil
  #
  # Initializes the terminal for TUI mode.
  # Enters alternate screen and enables raw mode.
  #
  # (Native method implemented in Rust)

  ##
  # :method: restore_terminal
  # :call-seq: restore_terminal() -> nil
  #
  # Restores the terminal to its original state.
  # Leaves alternate screen and disables raw mode.
  #
  # (Native method implemented in Rust)

  ##
  # :method: draw
  # :call-seq: draw(node) -> nil
  #
  # Draws the given UI node tree to the terminal.
  # [node] the root node of the UI tree (Paragraph, Layout).
  #
  # (Native method implemented in Rust)

  ##
  # :method: poll_event
  # :call-seq: poll_event() -> Event, nil
  #
  # Checks for user input.
  #
  # Returns a discrete event (Key, Mouse, Resize) if one is available in the queue.
  # Returns nil immediately if the queue is empty (non-blocking).
  #
  # === Example
  #
  #   event = RatatuiRuby.poll_event
  #   puts "Key pressed" if event.is_a?(RatatuiRuby::Event::Key)
  #
  def self.poll_event
    raw = _poll_event
    return nil if raw.nil?

    case raw[:type]
    when :key
      Event::Key.new(code: raw[:code], modifiers: raw[:modifiers] || [])
    when :mouse
      Event::Mouse.new(
        kind: raw[:kind].to_s,
        x: raw[:x],
        y: raw[:y],
        button: raw[:button].to_s,
        modifiers: raw[:modifiers] || []
      )
    when :resize
      Event::Resize.new(width: raw[:width], height: raw[:height])
    when :paste
      Event::Paste.new(content: raw[:content])
    when :focus_gained
      Event::FocusGained.new
    when :focus_lost
      Event::FocusLost.new
    else
      # Fallback for unknown events, though ideally we cover them all
      nil
    end
  end

  # (Native method _poll_event implemented in Rust)

  ##
  # :method: inject_test_event
  # :call-seq: inject_test_event(event_type, data) -> nil
  #
  # Injects a mock event into the event queue for testing purposes.
  # [event_type] "key" or "mouse"
  # [data] a Hash containing event data
  #
  #   inject_test_event("key", { code: "a" })
  #
  # (Native method implemented in Rust)

  ##
  # :method: run
  # :call-seq: run { |session| ... } -> Object
  #
  # Starts the TUI application lifecycle.
  #
  # Managing generic setup/teardown (raw mode, alternate screen) manualy is error-prone. If your app crashes, the terminal might be left in a broken state.
  #
  # This method handles the safety net. It initializes the terminal, yields a {Session}, and ensures the terminal state is restored even if exceptions occur.
  #
  # === Example
  #
  #   RatatuiRuby.run do |tui|
  #     tui.draw(tui.paragraph(text: "Hi"))
  #     sleep 1
  #   end
  def self.run
    require_relative "ratatui_ruby/session"
    init_terminal
    yield Session.new
  ensure
    restore_terminal
  end

end
