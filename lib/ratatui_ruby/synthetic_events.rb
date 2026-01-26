# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  ##
  # Ruby-only event queue for synthetic events.
  #
  # Native events flow through the Rust backend. Synthetic events bypass it.
  # Runtimes (Tea, Kit) check this queue and handle events like
  # <tt>Event::Sync</tt> specially.
  #
  # *For runtime authors:* Check <tt>pending?</tt> each loop iteration after
  # polling native events. When true, pop the event and handle it. For
  # <tt>Event::Sync</tt>, wait for pending threads and process background
  # results before continuing.
  #
  # *For app developers:* Push <tt>Event::Sync</tt> when you need async
  # results before continuing. The runtime will block until all pending
  # work completes. Use this for "ensure saves complete before quit."
  #
  # *For test authors:* Use <tt>inject_sync</tt> between events to create
  # synchronization points. This enables deterministic testing of async
  # behavior.
  #
  # === Example
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2026 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   # Production: ensure async saves finish before exiting
  #   RatatuiRuby::SyntheticEvents.push(RatatuiRuby::Event::Sync.new)
  #
  #   # Runtime authors: check in your event loop
  #   if RatatuiRuby::SyntheticEvents.pending?
  #     event = RatatuiRuby::SyntheticEvents.pop
  #     handle_sync if event.sync?
  #   end
  #
  #--
  # SPDX-SnippetEnd
  #++
  module SyntheticEvents
    @queue = [] #: Array[Event]
    @mutex = Mutex.new
    @inline_sync = false #: bool

    class << self
      ##
      # Enables inline sync mode for deterministic event ordering.
      #
      # Call once at startup. Cannot be disabled.
      #
      # When enabled, +inject_sync+ routes through the native event queue
      # and +poll_event+ returns +Event::Sync+ like any other event.
      # This ensures sync events are processed in sequence with key events.
      #
      # Runtimes that need ordering guarantees (like Rooibos) should call
      # this before entering their event loop.
      def inline_sync!
        @inline_sync = true
      end

      def inline_sync? # :nodoc:
        @inline_sync
      end

      ##
      # Pushes an event to the synthetic queue.
      #
      # [event] An <tt>Event</tt> object (typically <tt>Event::Sync</tt>).
      def push(event)
        @mutex.synchronize { @queue << event }
      end

      ##
      # Pops an event from the synthetic queue.
      #
      # Returns the oldest pending event, or <tt>nil</tt> if empty.
      def pop
        @mutex.synchronize { @queue.shift }
      end

      ##
      # Clears all pending synthetic events.
      #
      # Test helpers call this during teardown to reset state between tests.
      def clear
        @mutex.synchronize { @queue.clear }
      end

      ##
      # Checks for pending synthetic events.
      #
      # Returns <tt>true</tt> if the queue has events waiting.
      def pending?
        @mutex.synchronize { !@queue.empty? }
      end
    end
  end
end
