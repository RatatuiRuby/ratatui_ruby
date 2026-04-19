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
    # [keyboard_enhancement] whether to push the Kitty keyboard protocol's
    # +DISAMBIGUATE_ESCAPE_CODES+ flag (default: false). Opt-in because it
    # changes key events app-wide: Ctrl+I stops collapsing to Tab, Ctrl+M
    # to Enter, Ctrl+H to Backspace. Terminals without protocol support
    # silently ignore the flag; probe with {Terminal.supports_keyboard_enhancement?}.
    #
    # @raise [Error::Invariant] if headless mode is enabled or a session is already active
    # @see headless!
    def init_terminal(focus_events: true, bracketed_paste: true, keyboard_enhancement: false, viewport: nil, height: nil)
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

      viewport_obj = resolve_viewport(viewport, height)
      _init_terminal(focus_events, bracketed_paste, keyboard_enhancement, viewport_obj.type.to_s, viewport_obj.height)
    end

    ##
    # Initializes a test terminal for unit testing.
    # Sets session active state like init_terminal.
    #
    # [width] Integer width of the test terminal.
    # [height] Integer height of the test terminal.
    #
    # @raise [Error::Invariant] if headless mode is enabled or a session is already active
    def init_test_terminal(width, height, viewport_type = "fullscreen", viewport_height = nil)
      if @headless_mode
        raise Error::Invariant, "Cannot initialize terminal: headless mode is enabled"
      end
      if @tui_session_active
        raise Error::Invariant, "Cannot initialize terminal: TUI session already active"
      end
      @tui_session_active = true
      _init_test_terminal(width, height, viewport_type, viewport_height)
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
    def run(focus_events: true, bracketed_paste: true, keyboard_enhancement: false, viewport: nil, height: nil)
      init_terminal(focus_events:, bracketed_paste:, keyboard_enhancement:, viewport:, height:)
      yield TUI.new
    ensure
      restore_terminal
    end

    ##
    # Inserts content above an inline viewport into scrollback.
    #
    # Your inline TUI runs at the bottom of the terminal. Users scroll back
    # to see earlier CLI output. You want to add new content to that scrollback
    # without disrupting the running TUI viewport.
    #
    # Calling <tt>draw</tt> only updates the viewport itself. Content drawn there
    # disappears into scrollback when the viewport moves. You have no way to insert
    # historical content directly into the scrollback buffer above your running TUI.
    #
    # This method inserts content above the viewport. The viewport stays live and interactive.
    # New content appears above it in scrollback history. If the viewport isn't yet at the
    # bottom of the screen, it shifts down. Once at the bottom, inserted content scrolls
    # the scrollback buffer upward.
    #
    # Use it to log status updates, progress messages, or diagnostic output while your
    # inline TUI continues running.
    #
    # === Behavior
    #
    # The method renders a widget into a temporary buffer of <tt>height</tt> lines,
    # then inserts that buffer above the viewport. The viewport may shift position
    # on screen to accommodate the new lines.
    #
    # When the viewport has room to move down (not yet at screen bottom):
    # - Inserted lines appear above the viewport
    # - The viewport shifts down by <tt>height</tt> lines
    # - The viewport's visual position changes
    #
    # When the viewport is already at the screen bottom:
    # - Inserted lines push existing scrollback upward
    # - The viewport stays at the bottom
    # - The viewport's content may be disturbed by scrolling
    #
    # After calling this method, you should call <tt>draw</tt> to redraw the viewport's
    # content over its new position. The viewport area may have been clobbered by
    # the insertion or scrolling.
    #
    # This method has no effect when called on a fullscreen viewport. Fullscreen
    # viewports have no scrollback buffer.
    #
    # [height] Number of lines to insert (Integer). Must be positive.
    # [widget] Widget to render into the inserted buffer, or <tt>nil</tt> if using block.
    # [block] Optional block that returns a widget to render.
    #
    # === Examples
    #
    # ==== Insert a status line while TUI runs
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   RatatuiRuby.run(viewport: :inline, height: 3) do |tui|
    #     loop do
    #       tui.draw { |f| f.render_widget(tui.paragraph(text: "TUI Running"), f.area) }
    #
    #       event = tui.poll_event
    #       if event[:type] == :key && event[:code] == "l"
    #         # Insert a log line above the running TUI
    #         tui.insert_before(1, tui.paragraph(text: "[#{Time.now}] User pressed 'l'"))
    #         # Redraw viewport to restore its content
    #         tui.draw { |f| f.render_widget(tui.paragraph(text: "TUI Running"), f.area) }
    #       end
    #     end
    #   end
    #--
    # SPDX-SnippetEnd
    #++
    #
    # @raise [Error::Invariant] if the current viewport is not inline
    def insert_before(height, widget = nil, &block)
      # Validate we're in an inline viewport
      viewport_type = RatatuiRuby._get_viewport_type
      unless viewport_type == "inline"
        raise Error::Invariant, "insert_before requires an inline viewport"
      end

      content = widget || block&.call
      _insert_before(height, content)
    end

    private def resolve_viewport(viewport, height)
      case viewport
      when nil, :fullscreen then Terminal::Viewport.fullscreen
      when :inline then Terminal::Viewport.inline(height || 8)
      when Terminal::Viewport then viewport
      else raise ArgumentError, "Unknown viewport: #{viewport.inspect}"
      end
    end

    # Sets the cursor position using a Position object or coordinates.
    #
    # This is a convenience alias for +set_cursor_position+ that works with
    # Position objects or raw arrays rather than separate x/y arguments.
    #
    # [position] A Layout::Position, Array of [x, y], or anything that responds to +x+ and +y+.
    #
    # === Examples
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   # With Position object
    #   pos = RatatuiRuby::Layout::Position.new(x: 10, y: 5)
    #   RatatuiRuby.cursor_position = pos
    #
    #   # With array shorthand
    #   RatatuiRuby.cursor_position = 10, 5
    #--
    # SPDX-SnippetEnd
    #++
    def cursor_position=(position)
      if position.is_a?(Array)
        x, y = position
        set_cursor_position(x, y)
      else
        set_cursor_position(position.x, position.y)
      end
    end

    # Gets the cursor position as a Position object.
    #
    # This is a convenience alias for +get_cursor_position+ that returns
    # a Position object rather than raw coordinates.
    #
    # Returns:: A Layout::Position with the current cursor coordinates.
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   pos = RatatuiRuby.cursor_position
    #   puts "Cursor at #{pos.x}, #{pos.y}"
    #--
    # SPDX-SnippetEnd
    #++
    def cursor_position
      x, y = get_cursor_position
      Layout::Position.new(x:, y:)
    end
  end
end
