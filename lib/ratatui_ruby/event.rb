# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Base class for all RatatuiRuby events.
  #
  # Events represent terminal input: keyboard, mouse, resize, paste, focus changes.
  # Returned by RatatuiRuby.poll_event. All events support Ruby 3.0+ pattern matching.
  #
  # == Event Types
  #
  # * <tt>Key</tt> — keyboard input
  # * <tt>Mouse</tt> — mouse clicks, movement, wheel
  # * <tt>Resize</tt> — terminal resized
  # * <tt>Paste</tt> — clipboard paste
  # * <tt>FocusGained</tt> — terminal gained focus
  # * <tt>FocusLost</tt> — terminal lost focus
  #
  # == Pattern Matching (Exhaustive)
  #
  # Use <tt>case...in</tt> to dispatch on event type. Include an +else+ clause
  # to catch unmatched patterns, otherwise Ruby raises <tt>NoMatchingPatternError</tt>:
  #
  #   case RatatuiRuby.poll_event
  #   in { type: :key, code: "q" }
  #     break
  #   in { type: :mouse, kind: "down", x:, y: }
  #     handle_click(x, y)
  #   else
  #     # Ignore other events (resize, paste, focus, etc.)
  #   end
  #
  # == Type Checking
  #
  # Check event types with predicates without pattern matching:
  #
  #   event = RatatuiRuby.poll_event
  #   if event.key?
  #     puts "Key pressed"
  #   elsif event.mouse?
  #     puts "Mouse event"
  #   end
  class Event
    # Returns true if this is a Key event.
    def key?
      false
    end

    # Returns true if this is a Mouse event.
    def mouse?
      false
    end

    # Returns true if this is a Resize event.
    def resize?
      false
    end

    # Returns true if this is a Paste event.
    def paste?
      false
    end

    # Returns true if this is a FocusGained event.
    def focus_gained?
      false
    end

    # Returns true if this is a FocusLost event.
    def focus_lost?
      false
    end

    # Responds to dynamic predicate methods for key checks.
    # All non-Key events return false for any key predicate.
    def method_missing(name, *args, &block)
      if name.to_s.end_with?("?")
        false
      else
        super
      end
    end

    # Declares that this class responds to dynamic predicate methods.
    def respond_to_missing?(name, *args)
      name.to_s.end_with?("?") || super
    end

    # Deconstructs the event for pattern matching.
    #
    # Keys argument is unused but required by the protocol.
    #
    #   case event
    #   in type: :key, code:
    #     puts "Key: #{code}"
    #   end
    def deconstruct_keys(keys)
      {}
    end
  end
end

require_relative "event/key"
require_relative "event/mouse"
require_relative "event/resize"
require_relative "event/paste"
require_relative "event/focus_gained"
require_relative "event/focus_lost"
