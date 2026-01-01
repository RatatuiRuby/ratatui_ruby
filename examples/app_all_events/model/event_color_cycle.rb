# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Cycles through a set of colors for event logging.
#
# Sequential events in a log are hard to distinguish if they all look the same.
# Manually assigning colors to every event type or entry is repetitive.
#
# This class automatically cycles through a predefined list of vibrant colors.
#
# Use it to give each event in a log a distinct visual identity.
#
# === Examples
#
#   cycler = EventColorCycle.new
#   cycler.next_color #=> :cyan
#   cycler.next_color #=> :magenta
#   cycler.next_color #=> :yellow
#   cycler.next_color #=> :cyan
class EventColorCycle
  # List of colors to cycle through.
  COLORS = %i[cyan magenta yellow].freeze

  # Creates a new EventColorCycle.
  def initialize
    @index = 0
  end

  # Returns the next color in the cycle.
  #
  # === Example
  #
  #   cycler.next_color #=> :cyan
  def next_color
    color = COLORS[@index]
    @index = (@index + 1) % COLORS.length
    color
  end
end
