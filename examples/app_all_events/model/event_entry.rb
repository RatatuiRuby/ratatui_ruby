# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "timestamp"
require "ratatui_ruby"

# Stores details about a single event in the history log.
#
# Event logs need to store diverse data including types, keys, colors, and timestamps.
# Managing loose hashes or arrays for event history is error-prone and hard to query.
#
# This class provides a structured data object for every recorded event.
#
# Use it to represent mouse clicks, key presses, or resize events in a log.
#
# === Examples
#
#   # Typically created via Events.record
#   entry = EventEntry.create(key_event, :cyan, Timestamp.now)
#   puts entry.type #=> :key
#   puts entry.description #=> '#<RatatuiRuby::Event::Key ...>'
class EventEntry < Data.define(:event, :color, :timestamp)
  # Creates a new EventEntry.
  #
  # [event] RatatuiRuby::Event object.
  # [color] Symbol color for the log display.
  # [timestamp] Timestamp of when the event occurred.
  def self.create(event, color, timestamp)
    new(
      event:,
      color:,
      timestamp:
    )
  end

  # Returns the event type.
  #
  # === Example
  #
  #   entry.type #=> :key
  def type
    case event
    when RatatuiRuby::Event::Key then :key
    when RatatuiRuby::Event::Mouse then :mouse
    when RatatuiRuby::Event::Resize then :resize
    when RatatuiRuby::Event::Paste then :paste
    when RatatuiRuby::Event::FocusGained then :focus_gained
    when RatatuiRuby::Event::FocusLost then :focus_lost
    else :unknown
    end
  end

  # Returns the event description using inspect.
  #
  # === Example
  #
  #   entry.description #=> '#<RatatuiRuby::Event::Key code="a" modifiers=[]>'
  def description
    event.inspect
  end

  # Checks if the entry matches the given type.
  #
  # [check_type] Symbol type to check against.
  #
  # === Example
  #
  #   entry.matches_type?(:key) #=> true
  def matches_type?(check_type)
    return true if check_type == :focus && (type == :focus_gained || type == :focus_lost)
    type == check_type
  end
end
