# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  class Event
    # Signals that the application is in the background.
    #
    # The user has switched context. Your application is no longer the primary focus.
    #
    # This event warns of inactivity. It fires when the terminal window loses focus.
    #
    # Respond by conserving resources. Pause animations. Stop heavy polling. dim the UI to
    # indicate a background state.
    #
    # Only supported by some terminals (e.g. iTerm2, Kitty, newer xterm).
    #
    # === Example
    #
    #   if event.focus_lost?
    #     puts "Focus lost"
    #   end
    class FocusLost < Event
      # Returns true for FocusLost events.
      #
      #   event.focus_lost? # => true
      #   event.key?        # => false
      def focus_lost?
        true
      end

      # Deconstructs the event for pattern matching.
      #
      #   case event
      #   in type: :focus_lost
      #     puts "Application lost focus"
      #   end
      def deconstruct_keys(keys)
        { type: :focus_lost }
      end

      ##
      # Compares this event with another for equality.
      def ==(other)
        other.is_a?(FocusLost)
      end
    end
  end
end
