# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  ##
  # Terminal lifecycle management for TUI sessions.
  #
  # This module provides methods to initialize, restore, and manage the terminal
  # state for TUI applications. It handles raw mode, alternate screen, and ensures
  # proper cleanup on exit.
  #
  # @see init_terminal
  # @see restore_terminal
  # @see run
  module TerminalLifecycle
    ##
    # Whether a TUI session is currently active.
    #
    # Writing to stdout/stderr during a TUI session corrupts the display.
    # Use this to defer logging, warnings, or debug output until
    # after the session ends.
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   def log(message)
    #     if RatatuiRuby.terminal_active?
    #       @deferred_logs << message
    #     else
    #       puts message
    #     end
    #   end
    #--
    # SPDX-SnippetEnd
    #++
    def terminal_active?
      @tui_session_active
    end

    ##
    # Initializes the terminal for TUI mode.
    # Enters alternate screen and enables raw mode.
    #
    # In headless mode ({headless!}), this method raises {Error::Invariant}.
    # Use headless mode for batch/CLI apps.
    #
    # [focus_events] whether to enable focus gain/loss events (default: true).
    # [bracketed_paste] whether to enable bracketed paste mode (default: true).
    #
    # @raise [Error::Invariant] if headless mode is enabled or a session is already active
    # @see headless!
    def init_terminal(focus_events: true, bracketed_paste: true)
      if @headless_mode
        raise Error::Invariant, "Cannot initialize terminal: headless mode is enabled"
      end
      if @tui_session_active
        raise Error::Invariant, "Cannot initialize terminal: TUI session already active"
      end

      # Show A11Y lab prompt before launching TUI (stdout visible now, not after)
      if Labs.enabled?(:a11y)
        puts Labs::A11y.startup_message
        $stdin.gets
      end

      @tui_session_active = true
      _init_terminal(focus_events, bracketed_paste)
    end

    ##
    # Initializes a test terminal for unit testing.
    # Sets session active state like init_terminal.
    #
    # [width] Integer width of the test terminal.
    # [height] Integer height of the test terminal.
    #
    # @raise [Error::Invariant] if headless mode is enabled or a session is already active
    def init_test_terminal(width, height)
      if @headless_mode
        raise Error::Invariant, "Cannot initialize terminal: headless mode is enabled"
      end
      if @tui_session_active
        raise Error::Invariant, "Cannot initialize terminal: TUI session already active"
      end
      @tui_session_active = true
      _init_test_terminal(width, height)
    end

    ##
    # Restores the terminal to its original state.
    # Leaves alternate screen and disables raw mode.
    # Also flushes any deferred warnings and panic info that were queued during the session.
    #
    # In headless mode ({headless!}), this method is a silent no-op since
    # no terminal was ever initialized.
    #
    # @see headless!
    def restore_terminal
      return if @headless_mode

      _restore_terminal
    ensure
      @tui_session_active = false
      flush_warnings
      flush_panic_info
    end

    ##
    # Starts the TUI application lifecycle.
    #
    # Managing generic setup/teardown (raw mode, alternate screen) manually is error-prone.
    # If your app crashes, the terminal might be left in a broken state.
    #
    # This method handles the safety net. It initializes the terminal, yields a {TUI},
    # and ensures the terminal state is restored even if exceptions occur.
    #
    # In headless mode ({headless!}), this method raises {Error::Invariant} immediately
    # and the block is never executed. Use headless mode for batch/CLI apps.
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   RatatuiRuby.run(focus_events: false) do |tui|
    #     tui.draw(tui.paragraph(text: "Hi"))
    #     sleep 1
    #   end
    #
    #--
    # SPDX-SnippetEnd
    #++
    # @raise [Error::Invariant] if headless mode is enabled
    # @see headless!
    def run(focus_events: true, bracketed_paste: true)
      init_terminal(focus_events:, bracketed_paste:)
      yield TUI.new
    ensure
      restore_terminal
    end
  end
end
