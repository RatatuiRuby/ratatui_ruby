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
      # Use this during development or when troubleshooting.
      #
      # Safe to call multiple times; subsequent calls are no-ops.
      def enable!
        return if @debug_mode_enabled

        @debug_mode_enabled = true
        enable_rust_backtrace!
        # Future: Ruby-side debug features here
      end

      ##
      # Returns whether full debug mode is enabled.
      def enabled?
        @debug_mode_enabled
      end

      ##
      # Returns whether Rust backtraces are enabled.
      def rust_backtrace_enabled?
        @rust_backtrace_enabled
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
      def test_panic!
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
      def suppress_debug_mode
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
RatatuiRuby::Debug.enable! if ENV["RR_DEBUG"]
