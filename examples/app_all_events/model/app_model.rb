# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "timestamp"
require_relative "event_entry"
require_relative "event_color_cycle"

# Immutable application state for the Proto-TEA architecture.
#
# The Elm Architecture requires a single immutable Model. State changes return
# a new Model instance. This consolidates all app state into one place.
#
# Use `AppModel.initial` to create the starting state, and `model.with(...)`
# to create updated states.
#
# === Attributes
#
# [entries] Array of EventEntry objects (event log)
# [focused] Boolean window focus state
# [window_size] Array [width, height] of terminal dimensions
# [lit_types] Hash mapping event types to Timestamp (for highlight expiry)
# [none_count] Integer count of :none events (not logged)
# [color_cycle_index] Integer index into EventColorCycle::COLORS
#
# === Example
#
#   model = AppModel.initial
#   model.count(:key)  #=> 0
#   model.focused      #=> true
class AppModel < Data.define(:entries, :focused, :window_size, :lit_types, :none_count, :color_cycle_index)
  # Highlight duration in milliseconds.
  HIGHLIGHT_DURATION_MS = 300

  # Creates the initial application state.
  #
  # === Example
  #
  #   AppModel.initial #=> #<data AppModel entries=[] focused=true ...>
  def self.initial
    new(
      entries: [],
      focused: true,
      window_size: [80, 24],
      lit_types: {},
      none_count: 0,
      color_cycle_index: 0
    )
  end

  # Returns the count of events for a given type.
  #
  # [type] Symbol event type (:key, :mouse, :resize, :paste, :focus, :none)
  #
  # === Example
  #
  #   model.count(:key) #=> 5
  def count(type)
    return none_count if type == :none

    entries.count { |e| e.matches_type?(type) }
  end

  # Returns counts grouped by subtype (kind or modifier status).
  #
  # [type] Symbol event type.
  #
  # === Example
  #
  #   model.sub_counts(:mouse) #=> { "down" => 1, "up" => 2 }
  def sub_counts(type)
    return {} if type == :none

    matching = entries.select { |e| e.matches_type?(type) }
    defaults = { key: %w[unmodified modified], focus: %w[gained lost], mouse: %w[down up drag moved scroll_up scroll_down] }

    matching.each_with_object(defaults.fetch(type, []).to_h { |k| [k, 0] }) do |entry, counts|
      group = subtype_for(entry, type)
      counts[group] += 1 if group
    end
  end

  # Checks if an event type should be highlighted.
  #
  # [type] Symbol event type.
  #
  # === Example
  #
  #   model.lit?(:key) #=> true
  def lit?(type)
    timestamp = lit_types[type]
    return false unless timestamp

    !timestamp.elapsed?(HIGHLIGHT_DURATION_MS)
  end

  # Returns the most recent entries up to the given limit.
  #
  # [max_entries] Integer maximum number of entries to return.
  #
  # === Example
  #
  #   model.visible(10) #=> [#<EventEntry ...>, ...]
  def visible(max_entries)
    entries.last(max_entries)
  end

  # Checks if any events have been recorded.
  #
  # === Example
  #
  #   model.empty? #=> true
  def empty?
    entries.empty?
  end

  # Returns the most recent live event data for a type.
  #
  # [type] Symbol event type.
  #
  # === Example
  #
  #   model.live_event(:key) #=> { time: Time, description: "..." }
  def live_event(type)
    entry = entries.reverse.find { |e| e.live_type == type }
    return nil unless entry

    { time: Time.at(entry.timestamp.milliseconds / 1000.0), description: entry.description }
  end

  # Returns the next color in the cycle for a new event.
  #
  # === Example
  #
  #   model.next_color #=> :cyan
  def next_color
    EventColorCycle::COLORS[color_cycle_index]
  end

  private def subtype_for(entry, type)
    if entry.event.respond_to?(:kind)
      entry.event.kind.to_s
    elsif entry.event.respond_to?(:modifiers)
      entry.event.modifiers.empty? ? "unmodified" : "modified"
    elsif type == :focus
      entry.type.to_s.sub("focus_", "")
    end
  end
end
