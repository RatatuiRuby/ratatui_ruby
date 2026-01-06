# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

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
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2025 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   if event.focus_gained?
    #     puts "Focus gained"
    #   end
    #--
    # SPDX-SnippetEnd
    #++
    class FocusGained < Event
      # Returns true for FocusGained events.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2025 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   event.focus_gained? # => true
      #   event.key?          # => false
      #--
      # SPDX-SnippetEnd
      #++
      def focus_gained?
        true
      end

      # Deconstructs the event for pattern matching.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2025 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   case event
      #   in type: :focus_gained
      #     puts "Application gained focus"
      #   end
      #--
      # SPDX-SnippetEnd
      #++
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
