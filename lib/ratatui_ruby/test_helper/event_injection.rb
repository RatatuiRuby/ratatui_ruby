# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module TestHelper
    ##
    # Event injection helpers for testing TUI interactions.
    #
    # Testing keyboard navigation and mouse clicks requires simulating user input.
    # Constructing event objects by hand for every test is verbose and repetitive.
    #
    # This mixin provides convenience methods to inject keys, clicks, and other events
    # into the test terminal's event queue. Events are consumed by the next
    # <tt>poll_event</tt> call.
    #
    # Use it to simulate user interactions: typing, clicking, dragging, pasting.
    #
    # === Examples
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   with_test_terminal do
    #     inject_keys("h", "e", "l", "l", "o")
    #     inject_keys(:enter, :ctrl_s)
    #     inject_click(x: 10, y: 5)
    #     inject_event(RatatuiRuby::Event::Paste.new(content: "pasted text"))
    #
    #     @app.run
    #   end
    #
    #--
    # SPDX-SnippetEnd
    #++
    module EventInjection
      ##
      # Injects an event into the test terminal's event queue.
      #
      # Pass any <tt>RatatuiRuby::Event</tt> object. The event is returned by
      # the next <tt>poll_event</tt> call.
      #
      # Raises <tt>RuntimeError</tt> if called outside a <tt>with_test_terminal</tt> block.
      #
      # === Examples
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   inject_event(RatatuiRuby::Event::Key.new(code: "q"))
      #   inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 10, y: 5))
      #   inject_event(RatatuiRuby::Event::Paste.new(content: "Hello"))
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [event] A <tt>RatatuiRuby::Event</tt> object.
      def inject_event(event)
        unless @_ratatui_test_terminal_active
          raise RatatuiRuby::Error::Invariant, "Events must be injected inside a `with_test_terminal` block. " \
            "Calling this method outside the block causes a race condition where the event " \
            "is flushed before the application starts."
        end

        case event
        when RatatuiRuby::Event::Key
          RatatuiRuby.inject_test_event("key", { code: event.code, modifiers: event.modifiers })
        when RatatuiRuby::Event::Mouse
          RatatuiRuby.inject_test_event("mouse", {
            kind: event.kind,
            button: event.button,
            x: event.x,
            y: event.y,
            modifiers: event.modifiers,
          })
        when RatatuiRuby::Event::Resize
          RatatuiRuby.inject_test_event("resize", { width: event.width, height: event.height })
        when RatatuiRuby::Event::Paste
          RatatuiRuby.inject_test_event("paste", { content: event.content })
        when RatatuiRuby::Event::FocusGained
          RatatuiRuby.inject_test_event("focus_gained", {})
        when RatatuiRuby::Event::FocusLost
          RatatuiRuby.inject_test_event("focus_lost", {})
        when RatatuiRuby::Event::Sync
          # Sync events use the engine-level synthetic queue
          RatatuiRuby::SyntheticEvents.push(event)
        else
          raise ArgumentError, "Unknown event type: #{event.class}"
        end
      end

      ##
      # Injects a mouse event.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   inject_mouse(x: 10, y: 5, kind: :down, button: :left)
      #
      #--
      # SPDX-SnippetEnd
      #++
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      # [kind] Symbol <tt>:down</tt>, <tt>:up</tt>, or <tt>:drag</tt>.
      # [button] Symbol <tt>:left</tt>, <tt>:right</tt>, or <tt>:middle</tt>.
      # [modifiers] Array of modifier strings.
      def inject_mouse(x:, y:, kind: :down, modifiers: [], button: :left)
        event = RatatuiRuby::Event::Mouse.new(
          kind: kind.to_s,
          x:,
          y:,
          button: button.to_s,
          modifiers:
        )
        inject_event(event)
      end

      ##
      # Injects a left mouse click.
      #
      # === Example
      #
      #   inject_click(x: 10, y: 5)
      def inject_click(x:, y:, modifiers: [])
        inject_mouse(x:, y:, kind: :down, modifiers:, button: :left)
      end

      ##
      # Injects a right mouse click.
      #
      # === Example
      #
      #   inject_right_click(x: 10, y: 5)
      def inject_right_click(x:, y:, modifiers: [])
        inject_mouse(x:, y:, kind: :down, modifiers:, button: :right)
      end

      ##
      # Injects a mouse drag event.
      #
      # === Example
      #
      #   inject_drag(x: 10, y: 5)
      def inject_drag(x:, y:, modifiers: [], button: :left)
        inject_mouse(x:, y:, kind: :drag, modifiers:, button:)
      end

      ##
      # Injects one or more key events.
      #
      # Accepts multiple formats for convenience:
      # - String: Character key (e.g., <tt>"a"</tt>, <tt>"q"</tt>)
      # - Symbol: Named key or modifier combo (e.g., <tt>:enter</tt>, <tt>:ctrl_c</tt>)
      # - Hash: Passed to <tt>Key.new</tt>
      # - Key: Passed directly
      #
      # === Examples
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   inject_keys("a", "b", "c")
      #   inject_keys(:enter, :esc)
      #   inject_keys(:ctrl_c, :alt_shift_left)
      #   inject_keys("j", { code: "k", modifiers: ["ctrl"] })
      #--
      # SPDX-SnippetEnd
      #++
      def inject_keys(*args)
        args.each do |arg|
          event = case arg
                  when String
                    RatatuiRuby::Event::Key.new(code: arg)
                  when Symbol
                    parts = arg.to_s.split("_")
                    code = parts.pop
                    modifiers = parts
                    RatatuiRuby::Event::Key.new(code:, modifiers:)
                  when Hash
                    RatatuiRuby::Event::Key.new(**arg)
                  when RatatuiRuby::Event::Key
                    arg
                  else
                    raise ArgumentError, "Invalid key argument: #{arg.inspect}. Expected String, Symbol, Hash, or Key event."
          end
          inject_event(event)
        end
      end
      alias inject_key inject_keys

      ##
      # Injects a Sync event.
      #
      # When a runtime (Tea, Kit) encounters this event, it should wait for all
      # pending async operations to complete before processing the next event.
      # This enables deterministic testing of async behavior.
      #
      # *Important*: Sync waits for commands to _complete_. Do not use it
      # with long-running commands that wait indefinitely (e.g., for
      # cancellation). Those commands will block forever, causing a timeout.
      # For cancellation tests, dispatch the cancel command without Sync.
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
      #
      #--
      # SPDX-SnippetEnd
      #++
      def inject_sync
        inject_event(RatatuiRuby::Event::Sync.new)
      end
    end
  end
end
