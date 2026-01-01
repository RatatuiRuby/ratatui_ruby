# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
$LOAD_PATH.unshift File.expand_path(__dir__)

require "ratatui_ruby"
require_relative "model/events"
require_relative "view_state"
require_relative "view/app_view"

# Demonstrates the full range of terminal events supported by RatatuiRuby.
#
# Developers need a comprehensive example to understand how keys, mouse, resize, and focus events behave.
# Testing event handling across different terminal emulators and platforms can be unpredictable.
#
# This application captures and logs every event received from the backend, providing real-time feedback and history.
#
# Use it to verify your terminal's capabilities or as a reference for complex event handling.
#
# === Examples
#
#   # Run from the command line:
#   # ruby examples/app_all_events/app.rb
#
#   app = AppAllEvents.new
#   app.run
class AppAllEvents
  # List of all event types tracked by this application.
  EVENT_TYPES = %i[key mouse resize paste focus none].freeze

  # Creates a new AppAllEvents instance and initializes its state.
  def initialize
    @view = View::App.new
    @events = Events.new
    @focused = true
    @last_dimensions = [80, 24]
  end

  # Starts the application event loop.
  #
  # === Example
  #
  #   app.run
  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private def render
    view_state = ViewState.build(
      @events,
      @focused,
      @tui,
      nil
    )

    @tui.draw { |frame| @view.call(view_state, @tui, frame, frame.area) }
  end

  private def handle_input
    event = @tui.poll_event

    case event
    when RatatuiRuby::Event::Key
      return :quit if event.code == "q"
      return :quit if event.code == "c" && event.modifiers.include?("ctrl")
      @events.record(event)
    when RatatuiRuby::Event::Resize
      @events.record(event, context: { last_dimensions: @last_dimensions })
      @last_dimensions = [event.width, event.height]
    when RatatuiRuby::Event::FocusGained
      @focused = true
      @events.record(event)
    when RatatuiRuby::Event::FocusLost
      @focused = false
      @events.record(event)
    else
      @events.record(event)
    end

    nil
  end
end

AppAllEvents.new.run if __FILE__ == $PROGRAM_NAME
