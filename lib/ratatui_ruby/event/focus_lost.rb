# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

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
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2025 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   if event.focus_lost?
    #     puts "Focus lost"
    #   end
    #--
    # SPDX-SnippetEnd
    #++
    class FocusLost < Event
      # Returns true for FocusLost events.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2025 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   event.focus_lost? # => true
      #   event.key?        # => false
      #--
      # SPDX-SnippetEnd
      #++
      def focus_lost?
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
      #   in type: :focus_lost
      #     puts "Application lost focus"
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def deconstruct_keys(keys)
        { type: :focus_lost }
      end

      ##
      # Compares this event with another for equality.
      def ==(other)
        other.is_a?(FocusLost)
      end

      # =========================================================================
      # DWIM Predicates
      # =========================================================================

      # Returns true. The terminal has lost focus (blur).
      #
      #   event.blur? # => true
      def blur?
        true
      end
      alias blurred? blur?

      # Returns true. The application lost focus.
      #
      #   event.lost? # => true
      def lost?
        true
      end
      alias unfocused? lost?

      # Returns false. This is not a focus gained event.
      #
      #   event.focus? # => false
      def focus?
        false
      end
      alias focused? focus?

      # Returns false. This is not a gained event.
      #
      #   event.gained? # => false
      def gained?
        false
      end

      # Returns true. The application is inactive.
      #
      #   event.inactive? # => true
      def inactive?
        true
      end
      alias background? inactive?

      # Returns false. The application is not active.
      #
      #   event.active? # => false
      def active?
        false
      end
      alias foreground? active?
    end
  end
end
