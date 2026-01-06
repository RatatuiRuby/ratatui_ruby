# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  ##
  # Output protection for TUI sessions and batch/CLI mode.
  #
  # This module provides mechanisms to prevent accidental output to stdout/stderr
  # during TUI sessions and to support headless (batch/CLI) mode for applications
  # that can run with or without a TUI.
  #
  # @see guard_io
  # @see headless!
  module OutputGuard
    # A null IO object that swallows all output.
    #
    # Used by {guard_io} to temporarily replace $stdout and $stderr.
    # Implements method_missing to accept any IO method and discard output.
    #
    # Returns self for method chaining (e.g., puts.flush).
    class NullIO
      # Accepts any method call and returns self, discarding all output.
      def method_missing(name, *args, &block)
        self
      end

      # Reports that all methods are supported.
      def respond_to_missing?(name, include_private = false)
        true
      end
    end

    ##
    # Whether headless (batch/pipeline/CLI) mode is enabled.
    #
    # When headless mode is active:
    # - {guard_io} becomes a silent no-op (output is not swallowed)
    # - {init_terminal} and {run} raise {Error::Invariant}
    #
    # Use this when your app has a `--no-tui` or `--batch` flag and you want
    # the same code to work in both TUI and non-TUI modes.
    #
    # @see headless!
    def is_headless?
      @headless_mode
    end

    ##
    # Enables headless (batch/CLI) mode.
    #
    # Call this at app startup when running in batch/CLI mode (e.g., `--no-tui`).
    # This tells RatatuiRuby that you intentionally don't want a TUI session.
    #
    # When headless mode is active:
    # - {guard_io} becomes a silent no-op (output flows normally)
    # - {init_terminal} and {run} raise {Error::Invariant}
    #
    # Headless mode and TUI sessions are mutually exclusive. Calling this
    # while a TUI session is active raises {Error::Invariant}.
    #
    # === Why there is no exit_headless!
    #
    # Headless mode is a startup-time decision for the entire app run.
    # If you need to temporarily exit TUI mode for user interaction
    # (like lazygit does when editing a commit message), use
    # {restore_terminal} and {init_terminal} instead:
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   RatatuiRuby.restore_terminal
    #   puts "Press enter to continue..."
    #   gets
    #   RatatuiRuby.init_terminal
    #
    #--
    # SPDX-SnippetEnd
    #++
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   if ARGV.include?("--no-tui")
    #     RatatuiRuby.headless!
    #     process_batch_work  # guard_io calls are silent no-ops
    #   else
    #     RatatuiRuby.run do |tui|  # This branch only runs in TUI mode
    #       # ... TUI code ...
    #     end
    #   end
    #
    #--
    # SPDX-SnippetEnd
    #++
    # Note: Calling {run} or {init_terminal} after {headless!} raises
    # {Error::Invariant}. The block is never executed.
    #
    # @raise [Error::Invariant] if a TUI session is already active
    # @see is_headless?
    # @see restore_terminal
    def headless!
      if @tui_session_active
        raise Error::Invariant, "Cannot enable headless mode: TUI session already active"
      end
      @headless_mode = true
    end

    ##
    # Guards a block from stdout/stderr output.
    #
    # During a TUI session, writes to $stdout or $stderr corrupt the display.
    # Wrap code that might produce output (e.g., chatty gems) in this block.
    #
    # This temporarily replaces $stdout and $stderr with a {NullIO} object
    # that discards all output. The original streams are restored when the
    # block exits, even if an exception occurs.
    #
    # === Behavior by mode
    #
    # - **TUI session active**: Output is swallowed (guarded)
    # - **Headless mode**: Silent no-op (output flows normally)
    # - **Neither**: Warns and yields (catches potential mistakes)
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   RatatuiRuby.run do |tui|
    #     RatatuiRuby.guard_io do
    #       SomeChattyGem.do_something  # Any puts/warn calls are swallowed
    #     end
    #   end
    #
    #--
    # SPDX-SnippetEnd
    #++
    # @see headless!
    def guard_io
      # TUI active: guard the output
      if terminal_active?
        $stdout = NullIO.new
        $stderr = NullIO.new
        begin
          return yield
        ensure
          $stdout = Object::STDOUT
          $stderr = Object::STDERR
        end
      end

      # Headless mode: silent no-op
      return yield if is_headless?

      # Neither: warn about potential mistake
      warn "guard_io called outside TUI session. If this is intentional (batch/CLI mode), call RatatuiRuby.headless! at startup to silence this warning."
      yield
    end
  end
end
