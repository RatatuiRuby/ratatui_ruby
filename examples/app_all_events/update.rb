# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "model/app_model"
require_relative "model/msg"
require_relative "model/event_entry"
require_relative "model/timestamp"
require_relative "model/event_color_cycle"

# Pure update function for the Proto-TEA architecture.
#
# Given a Msg and the current AppModel, returns the next AppModel.
# This function is pure: it does not mutate arguments, draw to the screen,
# or perform IO. It simply calculates the next state.
#
# === Example
#
#   model = AppModel.initial
#   msg = Msg::Input.new(event: key_event)
#   new_model = Update.call(msg, model)
module Update
  extend self

  # Processes a message and returns the next model.
  #
  # [msg] A Msg value object
  # [model] The current AppModel
  #
  # === Example
  #
  #   Update.call(Msg::Quit.new, model) #=> model (unchanged)
  def call(msg, model)
    case msg
    in Msg::Quit
      model
    in Msg::NoneEvent
      model.with(none_count: model.none_count + 1)
    in Msg::Focus(gained:)
      event = gained ? RatatuiRuby::Event::FocusGained.new : RatatuiRuby::Event::FocusLost.new
      entry = create_entry(event, model)
      add_entry(model, entry, :focus).with(focused: gained)
    in Msg::Resize(width:, height:, previous_size: _)
      event = RatatuiRuby::Event::Resize.new(width:, height:)
      entry = create_entry(event, model)
      add_entry(model, entry, :resize).with(window_size: [width, height])
    in Msg::Input(event:)
      entry = create_entry(event, model)
      add_entry(model, entry, entry.live_type)
    else
      model
    end
  end

  # Creates an EventEntry with the next color and current timestamp.
  def create_entry(event, model)
    EventEntry.create(event, model.next_color, Timestamp.now)
  end

  # Adds an entry to the model, updates highlights, and advances the color cycle.
  def add_entry(model, entry, live_type)
    new_entries = model.entries + [entry]
    new_lit_types = model.lit_types.merge(live_type => Timestamp.now)
    new_color_index = (model.color_cycle_index + 1) % EventColorCycle::COLORS.length

    model.with(
      entries: new_entries,
      lit_types: new_lit_types,
      color_cycle_index: new_color_index
    )
  end
end
