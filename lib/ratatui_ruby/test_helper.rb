# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  ##
  # Helpers for testing RatatuiRuby applications.
  #
  # This module provides methods to set up a test terminal, capture buffer content,
  # and check cursor position, making it easier to write unit tests for your TUI apps.
  #
  # == Usage
  #
  #   require "ratatui_ruby/test_helper"
  #
  #   class MyTest < Minitest::Test
  #     include RatatuiRuby::TestHelper
  #
  #     def test_rendering
  #       with_test_terminal(width: 80, height: 24) do
  #         # ... render your app ...
  #         assert_includes buffer_content, "Hello World"
  #       end
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
    # Injects a mock event into the event queue for testing purposes.
    #
    # +event_type+:: "key" or "mouse"
    # +data+:: a Hash containing event data
    #
    #   inject_event("key", { code: "a" })
    #   inject_event("mouse", { kind: "down", x: 0, y: 0 })
    def inject_event(event_type, data)
      RatatuiRuby.inject_test_event(event_type, data)
    end
  end
end
