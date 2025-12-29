# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  class Event
    # Signals that the application is now active.
    #
    # The user interacts with many windows. Your application needs to know when it has their attention.
    #
    # This event confirms visibility. It fires when the terminal window moves to the foreground.
    #
    # Use it to resume paused activities. Restart animations. Refresh data. The user is watching.
    #
    # Only supported by some terminals (e.g. iTerm2, Kitty, newer xterm).
    #
    # === Example
    #
    #   if event.focus_gained?
    #     puts "Focus gained"
    #   end
    class FocusGained < Event
      # Returns true for FocusGained events.
      #
      #   event.focus_gained? # => true
      #   event.key?          # => false
      def focus_gained?
        true
      end

      # Deconstructs the event for pattern matching.
      #
      #   case event
      #   in type: :focus_gained
      #     puts "Application gained focus"
      #   end
      def deconstruct_keys(keys)
        { type: :focus_gained }
      end

      ##
      # Compares this event with another for equality.
      def ==(other)
        other.is_a?(FocusGained)
      end
    end
  end
end
