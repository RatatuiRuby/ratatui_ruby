# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  class Event
    # {Null object}[https://en.wikipedia.org/wiki/Null_object_pattern] for absent events.
    #
    # Event loops poll for input 60 times per second. Usually nothing is happening.
    # If <tt>RatatuiRuby.poll_event</tt> returned <tt>nil</tt>, you would need
    # nil-checks: <tt>event&.key?</tt>, <tt>next unless event</tt>.
    #
    # This class eliminates that friction. It responds to every predicate with
    # <tt>false</tt>. Call <tt>none?</tt> to detect it explicitly. Pattern-match on
    # <tt>type: :none</tt> for exhaustive dispatch.
    #
    # Use it to simplify your event loop. No guards. Optional `else` clauses.
    #
    # See Martin Fowler's {Special Case}[https://martinfowler.com/eaaCatalog/specialCase.html] pattern.
    #
    # === Predicate Example
    #
    #   event = RatatuiRuby.poll_event
    #   break if event.ctrl_c?
    #   redraw if event.none?
    #
    # === Pattern Matching Example
    #
    #   redraw if RatatuiRuby.poll_event in type: :none
    class None < Event
      # Returns true for None events.
      def none?
        true
      end

      # Deconstructs the event for pattern matching.
      def deconstruct_keys(keys)
        { type: :none }
      end
    end
  end
end
