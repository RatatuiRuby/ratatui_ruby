# frozen_string_literal: true

require "timeout"
require "minitest/mock"

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
    # +width+:: width of the test terminal (default: 80)
    # +height+:: height of the test terminal (default: 24)
    #
    # +timeout+:: maximum execution time in seconds (default: 2). Pass nil to disable.
    #
    # If a block is given, it is executed within the test terminal context.
    def with_test_terminal(width = 80, height = 24, **opts)
      RatatuiRuby.init_test_terminal(width, height)
      # Flush any lingering events from previous tests
      while RatatuiRuby.poll_event; end

      RatatuiRuby.stub :init_terminal, nil do
        RatatuiRuby.stub :restore_terminal, nil do
          @_ratatui_test_terminal_active = true
          timeout = opts.fetch(:timeout, 2)
          if timeout
            Timeout.timeout(timeout) do
              yield
            end
          else
            yield
          end
        ensure
          @_ratatui_test_terminal_active = false
        end
      end
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
    # Raises a +RuntimeError+ if called outside of a +with_test_terminal+ block.
    #
    # == Examples
    #
    #   with_test_terminal do
    #     # Key events
    #     inject_event(RatatuiRuby::Event::Key.new(code: "q"))
    #     inject_event(RatatuiRuby::Event::Key.new(code: "s", modifiers: ["ctrl"]))
    #
    #     # Mouse events
    #     inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 10, y: 5))
    #
    #     # Resize events
    #     inject_event(RatatuiRuby::Event::Resize.new(width: 120, height: 40))
    #
    #     # Paste events
    #     inject_event(RatatuiRuby::Event::Paste.new(content: "Hello"))
    #
    #     # Focus events
    #     inject_event(RatatuiRuby::Event::FocusGained.new)
    #     inject_event(RatatuiRuby::Event::FocusLost.new)
    #   end
    def inject_event(event)
      unless @_ratatui_test_terminal_active
        raise "Events must be injected inside a `with_test_terminal` block. " \
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
      else
        raise ArgumentError, "Unknown event type: #{event.class}"
      end
    end

    ##
    # Injects multiple Key events into the queue.
    #
    # Supports multiple formats for convenience:
    #
    # * String: Converted to a Key event with that code.
    # * Symbol: Parsed as modifier_code (e.g., <tt>:ctrl_c</tt>, <tt>:enter</tt>).
    # * Hash: Passed to Key.new constructor.
    # * Key: Passed directly.
    #
    # == Examples
    #
    #   with_test_terminal do
    #     inject_keys("a", "b", "c")
    #     inject_keys(:enter, :esc)
    #     inject_keys(:ctrl_c, :alt_shift_left)
    #     inject_keys("j", { code: "k", modifiers: ["ctrl"] })
    #   end
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
    # Returns the cell attributes at the given coordinates.
    #
    #   get_cell(0, 0)
    #   # => { "symbol" => "H", "fg" => :red, "bg" => nil }
    def get_cell(x, y)
      RatatuiRuby.get_cell_at(x, y)
    end

    ##
    # Asserts that the cell at the given coordinates has the expected attributes.
    #
    #   assert_cell_style(0, 0, char: "H", fg: :red)
    def assert_cell_style(x, y, **expected_attributes)
      cell = get_cell(x, y)
      expected_attributes.each do |key, value|
        actual_value = cell.public_send(key)
        if value.nil?
          assert_nil actual_value, "Expected cell at (#{x}, #{y}) to have #{key}=nil, but got #{actual_value.inspect}"
        else
          assert_equal value, actual_value, "Expected cell at (#{x}, #{y}) to have #{key}=#{value.inspect}, but got #{actual_value.inspect}"
        end
      end
    end
  end
end
