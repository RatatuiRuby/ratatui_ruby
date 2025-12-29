# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  ##
  # Helpers for testing RatatuiRuby applications.
  #
  # This module provides methods to set up a test terminal, capture buffer content,
  # and inject events, making it easier to write unit tests for your TUI apps.
  #
  # == Usage
  #
  #   require "ratatui_ruby/test_helper"
  #
  #   class MyTest < Minitest::Test
  #     include RatatuiRuby::TestHelper
  #
  #     def test_rendering
  #       with_test_terminal(80, 24) do
  #         # ... render your app ...
  #         assert_includes buffer_content, "Hello World"
  #       end
  #     end
  #
  #     def test_key_handling
  #       inject_event(RatatuiRuby::Event::Key.new(code: "q"))
  #       result = @app.handle_input
  #       assert_equal :quit, result
  #     end
  #   end
  module TestHelper
    ##
    # Initializes a test terminal context with specified dimensions.
    # Restores the original terminal state after the block executes.
    #
    # +width+:: width of the test terminal (default: 20)
    # +height+:: height of the test terminal (default: 10)
    #
    # If a block is given, it is executed within the test terminal context.
    def with_test_terminal(width = 20, height = 10)
      RatatuiRuby.init_test_terminal(width, height)
      yield
    ensure
      RatatuiRuby.restore_terminal
    end

    ##
    # Returns the current content of the terminal buffer as an array of strings.
    # Each string represents a row in the terminal.
    #
    #   buffer_content
    #   # => ["Row 1 text", "Row 2 text", ...]
    def buffer_content
      RatatuiRuby.get_buffer_content.split("\n")
    end

    ##
    # Returns the current cursor position as a hash with +:x+ and +:y+ keys.
    #
    #   cursor_position
    #   # => { x: 0, y: 0 }
    def cursor_position
      x, y = RatatuiRuby.get_cursor_position
      { x:, y: }
    end

    ##
    # Injects an event into the event queue for testing.
    #
    # Pass any RatatuiRuby::Event object. The event will be returned by
    # the next call to RatatuiRuby.poll_event.
    #
    # == Examples
    #
    #   # Key events
    #   inject_event(RatatuiRuby::Event::Key.new(code: "q"))
    #   inject_event(RatatuiRuby::Event::Key.new(code: "s", modifiers: ["ctrl"]))
    #
    #   # Mouse events
    #   inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 10, y: 5))
    #
    #   # Resize events
    #   inject_event(RatatuiRuby::Event::Resize.new(width: 120, height: 40))
    #
    #   # Paste events
    #   inject_event(RatatuiRuby::Event::Paste.new(content: "Hello"))
    #
    #   # Focus events
    #   inject_event(RatatuiRuby::Event::FocusGained.new)
    #   inject_event(RatatuiRuby::Event::FocusLost.new)
    def inject_event(event)
      case event
      when RatatuiRuby::Event::Key
        RatatuiRuby.inject_test_event("key", { code: event.code, modifiers: event.modifiers })
      when RatatuiRuby::Event::Mouse
        RatatuiRuby.inject_test_event("mouse", {
          kind: event.kind,
          button: event.button,
          x: event.x,
          y: event.y,
          modifiers: event.modifiers
        })
      when RatatuiRuby::Event::Resize
        RatatuiRuby.inject_test_event("resize", { width: event.width, height: event.height })
      when RatatuiRuby::Event::Paste
        RatatuiRuby.inject_test_event("paste", { content: event.content })
      when RatatuiRuby::Event::FocusGained
        RatatuiRuby.inject_test_event("focus_gained", {})
      when RatatuiRuby::Event::FocusLost
        RatatuiRuby.inject_test_event("focus_lost", {})
      else
        raise ArgumentError, "Unknown event type: #{event.class}"
      end
    end
  end
end

