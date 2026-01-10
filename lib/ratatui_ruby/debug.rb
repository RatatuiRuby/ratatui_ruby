# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  ##
  # Debug mode control for RatatuiRuby.
  #
  # TUI applications are hard to debug. Rust panics show cryptic stack traces.
  # Ruby exceptions lack Rust context.
  #
  # This module controls debug visibility. Enable Rust backtraces only, or
  # enable full debug mode for both Rust and Ruby-side features.
  #
  # == Activation Methods
  #
  # Three ways to enable debug features:
  #
  # [<tt>RUST_BACKTRACE=1</tt>] Rust backtraces only (no Ruby-side debug).
  # [<tt>RR_DEBUG=1</tt>] Full debug mode (backtraces + Ruby features).
  # [<tt>include RatatuiRuby::TestHelper</tt>] Auto-enables debug mode.
  #
  # === Example
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2026 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   # Programmatic activation
  #   RatatuiRuby::Debug.enable!
  #
  #   # Or use the convenience alias
  #   RatatuiRuby.debug_mode!
  #
  #--
  # SPDX-SnippetEnd
  #++
  module Debug
    @rust_backtrace_enabled = false
    @debug_mode_enabled = false

    class << self
      ##
      # Enables Rust backtraces only.
      #
      # Call this to get meaningful stack traces when Rust panics.
      # Does not enable Ruby-side debug features.
      #
      # Safe to call multiple times; subsequent calls are no-ops.
      def enable_rust_backtrace!
        return if @rust_backtrace_enabled

        @rust_backtrace_enabled = true
        RatatuiRuby.__send__(:_enable_rust_backtrace)
      end

      ##
      # Enables full debug mode.
      #
      # Activates Rust backtraces plus any Ruby-side debug features.
      # Optionally enables remote debugging via the debug gem.
      #
      # Safe to call multiple times; subsequent calls are no-ops.
      #
      # [source] <tt>:env</tt> if called from RR_DEBUG env var,
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #          <tt>:test</tt> from TestHelper (skips remote debugging),
      #          <tt>:programmatic</tt> otherwise.
      #--
      # SPDX-SnippetEnd
      #++
      def enable!(source: :programmatic)
        return @socket_path if @debug_mode_enabled

        @debug_mode_enabled = true
        enable_rust_backtrace!

        # Tests don't need remote debugging — it would cause hangs
        return if source == :test

        @remote_debugging_mode = (source == :env) ? :open : :open_nonstop
        @socket_path = enable_remote_debugging!
      end

      # rubocop:disable Lint/Debugger -- intentional debug gem integration
      private def enable_remote_debugging!
        # Suppress the "Debugger can attach via..." message that corrupts TUI displays
        # Only suppress for programmatic activation; RR_DEBUG=1 users need to see it
        old_log_level = ENV["RUBY_DEBUG_LOG_LEVEL"]
        ENV["RUBY_DEBUG_LOG_LEVEL"] = "ERROR" if @remote_debugging_mode == :open_nonstop

        case @remote_debugging_mode
        when :open
          # Stop at load so user can read socket path before TUI enters raw mode
          ENV["RUBY_DEBUG_STOP_AT_LOAD"] = "1"
          require "debug/open"
        when :open_nonstop
          require "debug/open_nonstop"
        end

        # Restore log level after require (the require is what prints the message)
        ENV["RUBY_DEBUG_LOG_LEVEL"] = old_log_level if @remote_debugging_mode == :open_nonstop

        # Return the socket path so apps can display it
        ::DEBUGGER__.create_unix_domain_socket_name
      rescue NameError
        # Windows uses TCP/IP, not Unix sockets — DEBUGGER__ might not have this method
        nil
      # rubocop:enable Lint/Debugger
      rescue LoadError
        return unless @remote_debugging_mode == :open

        raise LoadError,
          "RR_DEBUG=1 requires the 'debug' gem for remote debugging. " \
            "Add `gem 'debug'` to your Gemfile or install it with `gem install debug`."
      end

      ##
      # Returns whether full debug mode is enabled.
      public def enabled?
        @debug_mode_enabled
      end

      ##
      # Returns whether Rust backtraces are enabled.
      public def rust_backtrace_enabled?
        @rust_backtrace_enabled
      end

      ##
      # Returns the remote debugging mode for debug gem integration.
      #
      # TUI apps run in raw terminal mode, making interactive debugging
      # impossible. The debug gem's remote debugging feature lets you
      # attach from another terminal via UNIX socket.
      #
      # Returns one of:
      # <tt>:open</tt> Stop at program start, wait for debugger attach.
      #                   Activated when <tt>RR_DEBUG=1</tt> is set at startup.
      # <tt>:open_nonstop</tt> Continue running, attach whenever ready.
      #                           Activated when <tt>enable!</tt> is called programmatically.
      # <tt>nil</tt> No remote debugging configured.
      public def remote_debugging_mode
        @remote_debugging_mode
      end

      ##
      # Triggers a Rust panic for backtrace verification.
      #
      # Debugging TUI apps is hard. Rust errors lack context. You want to
      # confirm <tt>RUST_BACKTRACE=1</tt> actually shows stack traces before
      # hitting a real bug.
      #
      # This method deliberately panics. The panic hook catches it and prints
      # the Rust backtrace to stderr. If you see stack frames, your setup works.
      #
      # <b>WARNING</b>: Crashes your process. Use only for debugging.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   RUST_BACKTRACE=1 ruby -e 'require "ratatui_ruby"; RatatuiRuby::Debug.test_panic!'
      #--
      # SPDX-SnippetEnd
      #++
      public def test_panic!
        RatatuiRuby.__send__(:_test_panic)
      end

      ##
      # Temporarily suppresses Ruby-side debug mode checks.
      #
      # Rust backtraces remain enabled if previously activated; only
      # Ruby-side features (like unknown-key errors) are suppressed
      # within the block.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   RatatuiRuby::Debug.suppress_debug_mode do
      #     tui.table({ unknown_key: 1 }) # Does not raise
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      public def suppress_debug_mode
        old_value = @debug_mode_enabled
        @debug_mode_enabled = false
        yield
      ensure
        @debug_mode_enabled = old_value
      end
    end
  end
end

# Auto-enable based on environment variables
RatatuiRuby::Debug.enable_rust_backtrace! if ENV["RUST_BACKTRACE"]
RatatuiRuby::Debug.enable!(source: :env) if ENV["RR_DEBUG"]
