# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
$LOAD_PATH.unshift File.expand_path(__dir__)

require "ratatui_ruby"
require_relative "model/app_model"
require_relative "model/msg"
require_relative "update"
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
# === Architecture
#
# This example uses the Model-View-Update pattern:
# - **Model**: Immutable AppModel holds all state
# - **Msg**: Semantic message types decouple events from logic
# - **Update**: Pure function computes next state
# - **View**: Renders Model to screen
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

  # Creates a new AppAllEvents instance and initializes its view.
  def initialize
    @view = View::App.new
  end

  # Starts the application event loop.
  #
  # Implements the MVU (Model-View-Update) runtime:
  # 1. **View**: Render current model
  # 2. **Poll**: Get next event
  # 3. **Map**: Convert raw event to semantic Msg
  # 4. **Update**: Compute next model
  #
  # === Example
  #
  #   app.run
  def run
    RatatuiRuby.run do |tui|
      model = AppModel.initial

      loop do
        tui.draw { |frame| @view.call(model, tui, frame, frame.area) }

        event = tui.poll_event
        msg = map_event_to_msg(event, model)
        break if msg.is_a?(Msg::Quit)

        model = Update.call(msg, model)
      end
    end
  end

  private def map_event_to_msg(event, model)
    case event
    when RatatuiRuby::Event::Key
      return Msg::Quit.new if event.code == "q"
      return Msg::Quit.new if event.code == "c" && event.modifiers.include?("ctrl")

      Msg::Input.new(event:)
    when RatatuiRuby::Event::Resize
      Msg::Resize.new(width: event.width, height: event.height, previous_size: model.window_size)
    when RatatuiRuby::Event::FocusGained
      Msg::Focus.new(gained: true)
    when RatatuiRuby::Event::FocusLost
      Msg::Focus.new(gained: false)
    when RatatuiRuby::Event::None
      Msg::NoneEvent.new
    else
      Msg::Input.new(event:)
    end
  end
end

AppAllEvents.new.run if __FILE__ == $PROGRAM_NAME
