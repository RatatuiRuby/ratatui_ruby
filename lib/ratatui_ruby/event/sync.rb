# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  class Event
    # Synthetic event for synchronizing async operations in tests.
    #
    # Testing async behavior is tricky. You inject an event, but results arrive
    # later. By the time you assert, the async work may not have completed.
    #
    # When a runtime (Tea, Kit) encounters this event, it should wait for all
    # pending async operations to complete before processing the next event.
    # This enables deterministic testing without changing production code paths.
    #
    # Inject this event between user actions and assertions to ensure async
    # results have been processed:
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   inject_key("s")           # Triggers async command
    #   inject_sync               # Wait for command to complete
    #   inject_key(:q)            # Quit after seeing results
    #   Tea.run(...)
    #   assert_snapshots("after_s_with_results")
    #
    #--
    # SPDX-SnippetEnd
    #++
    # This is not "test mode"—it's a real event that runtimes handle.
    # Production apps could use it too (e.g., "ensure saves complete before quit").
    class Sync < Event
      # Returns true for Sync events.
      def sync?
        true
      end

      # Deconstructs the event for pattern matching.
      def deconstruct_keys(keys)
        { type: :sync }
      end
    end
  end
end
