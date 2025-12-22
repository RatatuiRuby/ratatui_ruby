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
    # @param width [Integer] width of the test terminal (default: 20)
    # @param height [Integer] height of the test terminal (default: 10)
    # @yield The block to execute within the test terminal context.
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
    # @return [Array<String>] lines of the terminal buffer
    def buffer_content
      RatatuiRuby.get_buffer_content.split("\n")
    end

    ##
    # Returns the current cursor position as a hash with :x and :y keys.
    #
    # @return [Hash{Symbol => Integer}] {:x => Integer, :y => Integer}
    def cursor_position
      x, y = RatatuiRuby.get_cursor_position
      { x: x, y: y }
    end
  end
end
