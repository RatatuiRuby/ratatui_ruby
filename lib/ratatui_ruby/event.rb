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
  # * <tt>None</tt> — no event available (Null Object)
  #
  # == Pattern Matching (Exhaustive)
  #
  # Use <tt>case...in</tt> to dispatch on every possible event type. This ensures
  # you handle every case without needing an +else+ clause:
  #
  #   case RatatuiRuby.poll_event
  #   in { type: :key, code: "q" }
  #     break
  #   in { type: :key, code: code, modifiers: }
  #     handle_key(code, modifiers)
  #   in { type: :mouse, kind: "down", x:, y: }
  #     handle_click(x, y)
  #   in { type: :mouse, kind:, x:, y: }
  #     # handle other mouse activities
  #   in { type: :resize, width:, height: }
  #     handle_resize(width, height)
  #   in { type: :paste, content: }
  #     handle_paste(content)
  #   in { type: :focus_gained }
  #     handle_focus_gain
  #   in { type: :focus_lost }
  #     handle_focus_loss
  #   in { type: :none }
  #     # Idle
  #   end
  #
  # == Predicates
  #
  # Check event types with predicates without pattern matching:
  #
  #   event = RatatuiRuby.poll_event
  #   if event.key?
  #     puts "Key pressed"
  #   elsif event.none?
  #     # Idle
  #   elsif event.mouse?
  #     puts "Mouse event"
  #   end
  class Event
    # Returns true if this is a None event.
    def none?
      false
    end

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

require_relative "event/none"
require_relative "event/key"
require_relative "event/mouse"
require_relative "event/resize"
require_relative "event/paste"
require_relative "event/focus_gained"
require_relative "event/focus_lost"
