# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "timestamp"

# Manages temporary visual highlights for different event types.
#
# Users need visual feedback when an event occurs, but highlights should fade.
# Manually tracking timers for every highlightable element is complex.
#
# This class manages the "lit" state of multiple keys with a consistent duration.
#
# Use it to trigger and check for temporary UI highlights.
#
# === Examples
#
#   highlight = Highlight.new
#   highlight.light_up(:key)
#   highlight.lit?(:key) #=> true
#   sleep(0.4)
#   highlight.lit?(:key) #=> false
class Highlight
  # Duration in milliseconds that a highlight remains active.
  DURATION_MS = 300

  # Creates a new Highlight manager.
  def initialize
    @lit_types = {}
  end

  # Triggers a highlight for the given type.
  #
  # [type] Symbol to highlight.
  #
  # === Example
  #
  #   highlight.light_up(:mouse)
  def light_up(type)
    @lit_types[type] = Timestamp.now
  end

  # Checks if a highlight is currently active for the given type.
  #
  # [type] Symbol to check.
  #
  # === Example
  #
  #   highlight.lit?(:mouse) #=> true
  def lit?(type)
    timestamp = @lit_types[type]
    return false unless timestamp

    !timestamp.elapsed?(DURATION_MS)
  end
end
