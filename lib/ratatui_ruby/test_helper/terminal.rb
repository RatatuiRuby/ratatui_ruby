# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "timeout"
require "minitest/mock"

module RatatuiRuby
  module TestHelper
    ##
    # Terminal setup and buffer inspection for TUI tests.
    #
    # Testing TUIs against a real terminal is slow, flaky, and hard to automate.
    # Initializing, cleaning up, and inspecting terminal state by hand is tedious.
    #
    # This mixin wraps a headless test terminal. It handles setup, teardown,
    # and provides methods to query buffer content, cursor position, and cell styles.
    #
    # Use it to write fast, deterministic tests for your TUI applications.
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   class MyTest < Minitest::Test
    #     include RatatuiRuby::TestHelper
    #
    #     def test_rendering
    #       with_test_terminal(80, 24) do
    #         MyApp.new.run_once
    #         assert_includes buffer_content.join, "Hello"
    #       end
    #     end
    #   end
    #--
    # SPDX-SnippetEnd
    #++
    module Terminal
      ##
      # Initializes a test terminal context with specified dimensions.
      # Restores the original terminal state after the block executes.
      #
      # [width] Integer width of the test terminal (default: 80).
      # [height] Integer height of the test terminal (default: 24).
      # [timeout] Integer maximum execution time in seconds (default: 2). Pass <tt>nil</tt> to disable.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   with_test_terminal(120, 40) do
      #     # render and test your app
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def with_test_terminal(width = 80, height = 24, **opts)
        # Defensive cleanup: reset any stale session state from previous test failures
        RatatuiRuby.instance_variable_set(:@tui_session_active, false)

        RatatuiRuby.init_test_terminal(width, height)
        # Flush any lingering events from previous tests
        while (event = RatatuiRuby.poll_event) && !event.none?; end

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
      # Current content of the terminal buffer as an array of strings.
      # Each string represents one row.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   buffer_content
      #   # => ["Row 1 text", "Row 2 text", ...]
      #--
      # SPDX-SnippetEnd
      #++
      def buffer_content
        RatatuiRuby.get_buffer_content.split("\n")
      end

      ##
      # Current cursor position as a hash with <tt>:x</tt> and <tt>:y</tt> keys.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   cursor_position
      #   # => { x: 0, y: 0 }
      #--
      # SPDX-SnippetEnd
      #++
      def cursor_position
        x, y = RatatuiRuby.get_cursor_position
        { x:, y: }
      end

      ##
      # Cell attributes at the given coordinates.
      #
      # Returns a hash with <tt>"symbol"</tt>, <tt>"fg"</tt>, and <tt>"bg"</tt> keys.
      #
      # [x] Integer column position (0-indexed).
      # [y] Integer row position (0-indexed).
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   get_cell(0, 0)
      #   # => { "symbol" => "H", "fg" => :red, "bg" => nil }
      #--
      # SPDX-SnippetEnd
      #++
      def get_cell(x, y)
        RatatuiRuby.get_cell_at(x, y)
      end

      ##
      # Prints the current buffer to STDOUT with full ANSI colors.
      # Useful for debugging test failures.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   with_test_terminal do
      #     MyApp.new.render
      #     print_buffer  # see exactly what would display
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def print_buffer
        puts _render_buffer_with_ansi
      end
    end
  end
end
