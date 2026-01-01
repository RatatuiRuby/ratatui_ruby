# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "timestamp"
require_relative "event_color_cycle"
require_relative "event_entry"

# Manages the history and state of all application events.
#
# Applications need to track, count, and display event history for debugging and feedback.
# Direct management of event arrays and counters across the app leads to scattered state.
#
# This class centralizes event storage. It records new events, maintains counts, and manages temporary highlights.
#
# Use it to store key presses, mouse clicks, and window resizes for display in a log or counter.
#
# === Examples
#
#   events = Events.new
#   events.record(key_event)
#   puts events.count(:key) #=> 1
#
#   if events.lit?(:key)
#     puts "Key event just happened!"
#   end
class Events
  # Duration in milliseconds for an event to remain highlighted in the UI.
  HIGHLIGHT_DURATION_MS = 300

  # Creates a new Events manager.
  def initialize
    @entries = []
    @color_cycle = EventColorCycle.new
    @none_count = 0
    @lit_type = nil
    @lit_until = Timestamp.now
    @live = {}
  end

  # Records a new event.
  #
  # [event] RatatuiRuby::Event object.
  # [context] Hash of additional context (e.g., last_dimensions).
  #
  # === Example
  #
  #   events.record(mouse_event)
  def record(event, context: {})
    if event.is_a?(RatatuiRuby::Event::None) || event == :none
      @none_count += 1
      return
    end

    color = @color_cycle.next_color
    timestamp = Timestamp.now
    entry = EventEntry.create(event, color, timestamp)
    @entries << entry
    update_lit_type(entry)

    display_type = live_type_for(entry.type)
    @live[display_type] = { time: Time.now, description: entry.description }
  end

  private def live_type_for(type)
    case type
    when :focus_gained, :focus_lost
      :focus
    else
      type
    end
  end

  # Returns the most recent live event data for a type.
  #
  # [type] Symbol event type to look up.
  #
  # === Example
  #
  #   events.live_event(:key) #=> { time: ..., description: "..." }
  def live_event(type)
    @live[type]
  end

  # Returns all recorded live event data.
  #
  # === Example
  #
  #   events.live_events #=> { key: { ... }, mouse: { ... } }
  def live_events
    @live
  end

  # Returns the most recent entries up to the given limit.
  #
  # [max_entries] Integer maximum number of entries to return.
  #
  # === Example
  #
  #   events.visible(10) #=> [#<EventEntry ...>, ...]
  def visible(max_entries)
    @entries.last(max_entries)
  end

  # Checks if any events have been recorded.
  #
  # === Example
  #
  #   events.empty? #=> true
  def empty?
    @entries.empty?
  end

  # Returns the count of events for a type.
  #
  # [type] Symbol event type.
  #
  # === Example
  #
  #   events.count(:key) #=> 5
  def count(type)
    return @none_count if type == :none

    @entries.count { |e| e.matches_type?(type) }
  end

  # Returns counts grouped by subtype (kind or modifier status).
  #
  # [type] Symbol event type.
  #
  # === Example
  #
  #   events.sub_counts(:mouse) #=> { "down" => 1, "up" => 2 }
  def sub_counts(type)
    return {} if type == :none

    entries = @entries.select { |e| e.matches_type?(type) }

    defaults = { key: %w[unmodified modified], focus: %w[gained lost], mouse: %w[down up drag moved scroll_up scroll_down] }
    entries.each_with_object(defaults.fetch(type, []).to_h { |k| [k, 0] }) do |entry, counts|
      group = if entry.event.respond_to?(:kind)
        entry.event.kind.to_s
      elsif entry.event.respond_to?(:modifiers)
        entry.event.modifiers.empty? ? "unmodified" : "modified"
      elsif type == :focus
        entry.type.to_s.sub("focus_", "")
      end

      counts[group] += 1 if group
    end
  end

  # Checks if a type should be highlighted.
  #
  # [type] Symbol event type.
  #
  # === Example
  #
  #   events.lit?(:key) #=> true
  def lit?(type)
    return false if Timestamp.now.milliseconds >= @lit_until.milliseconds

    @lit_type == type
  end

  # Returns all event entries.
  #
  # === Example
  #
  #   events.entries #=> [#<EventEntry ...>, ...]
  def entries
    @entries
  end

  private def update_lit_type(entry)
    @lit_type = live_type_for(entry.type)
    @lit_until = Timestamp.new(milliseconds: Timestamp.now.milliseconds + HIGHLIGHT_DURATION_MS)
  end
end
