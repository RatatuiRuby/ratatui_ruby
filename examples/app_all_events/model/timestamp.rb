# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Represents a high-resolution point in time.
#
# Comparing events and calculating durations requires consistent time measurement.
# Standard Time objects are often too granular or complex for simple millisecond offsets.
#
# This class provides a millisecond-precision timestamp for event measurement.
#
# Use it to track event timing, calculate elapsed time, or trigger debouncing.
#
# === Examples
#
#   timestamp = Timestamp.now
#   puts timestamp.milliseconds
#
#   if timestamp.elapsed?(300)
#     puts "More than 300ms have passed."
#   end
class Timestamp < Data.define(:milliseconds)
  # Returns a new Timestamp representing the current time.
  #
  # === Example
  #
  #   Timestamp.now #=> #<struct Timestamp milliseconds=123456789>
  def self.now
    new(milliseconds: (Time.now.to_f * 1000).to_i)
  end

  # Checks if a duration has passed since this timestamp.
  #
  # [duration_ms] Integer duration in milliseconds.
  #
  # === Example
  #
  #   timestamp = Timestamp.now
  #   sleep(0.5)
  #   timestamp.elapsed?(300) #=> true
  def elapsed?(duration_ms)
    Timestamp.now.milliseconds >= milliseconds + duration_ms
  end

  # Returns the current time in milliseconds.
  #
  # === Example
  #
  #   Timestamp.current #=> 123456789
  def self.current
    now.milliseconds
  end
end
