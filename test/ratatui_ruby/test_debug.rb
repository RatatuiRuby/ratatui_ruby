# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "ratatui_ruby"
require "minitest/autorun"

##
# Tests for RatatuiRuby::Debug module.
#
# Debug mode controls Rust backtrace visibility and Ruby-side diagnostic
# features. These tests verify activation methods work correctly and
# provide the expected behavior.
#
# == Design Notes
#
# The Debug module maintains internal state (enabled flags). Since we cannot
# "un-enable" debug mode once enabled, we test state transitions rather than
# state resets. The module is designed as a progressive enhancement: once
# enabled, it stays enabled.
class TestDebug < Minitest::Test
  ##
  # Verifies that Debug.enabled? is a boolean predicate.
  #
  # The module tracks whether full debug mode has been activated.
  # In a fresh process, this would be false; but since TestHelper
  # auto-enables debug mode, we verify it returns a boolean (true).
  def test_enabled_predicate_returns_boolean
    result = RatatuiRuby::Debug.enabled?

    assert_includes [true, false], result, "enabled? should return a boolean"
  end

  ##
  # Verifies that Debug.rust_backtrace_enabled? is a boolean predicate.
  #
  # Rust backtraces can be enabled independently of full debug mode.
  # This allows RUST_BACKTRACE=1 to work without Ruby-side features.
  def test_rust_backtrace_enabled_predicate_returns_boolean
    result = RatatuiRuby::Debug.rust_backtrace_enabled?

    assert_includes [true, false], result, "rust_backtrace_enabled? should return a boolean"
  end

  ##
  # Verifies that enable! activates full debug mode.
  #
  # Full debug mode includes Rust backtraces plus any Ruby-side features.
  # After calling enable!, enabled? should return true.
  def test_enable_activates_full_debug_mode
    RatatuiRuby::Debug.enable!(source: :test)

    assert_predicate RatatuiRuby::Debug, :enabled?, "Debug.enable! should set enabled? to true"
  end

  ##
  # Verifies that enable! also enables Rust backtraces.
  #
  # Full debug mode is a superset of Rust backtrace mode.
  # Calling enable! should implicitly call enable_rust_backtrace!.
  def test_enable_also_enables_rust_backtraces
    RatatuiRuby::Debug.enable!(source: :test)

    assert_predicate RatatuiRuby::Debug, :rust_backtrace_enabled?,
      "Debug.enable! should also enable Rust backtraces"
  end

  ##
  # Verifies that enable_rust_backtrace! enables Rust backtraces.
  #
  # This is the low-level activation method. It enables Rust backtraces
  # without enabling full debug mode.
  def test_enable_rust_backtrace_activates_rust_backtraces
    RatatuiRuby::Debug.enable_rust_backtrace!

    assert_predicate RatatuiRuby::Debug, :rust_backtrace_enabled?,
      "enable_rust_backtrace! should set rust_backtrace_enabled? to true"
  end

  ##
  # Verifies that enable_rust_backtrace! does not enable full debug mode.
  #
  # Rust backtraces can be enabled independently. This is useful for
  # RUST_BACKTRACE=1 which should activate backtraces without Ruby features.
  #
  # NOTE: This test is skipped because including TestHelper in other tests
  # auto-enables debug mode. In a fresh process, this would verify the
  # distinction between the two modes.
  def test_enable_rust_backtrace_does_not_enable_full_debug_mode
    skip "Cannot test in isolation: TestHelper auto-enables debug mode"
  end

  ##
  # Verifies that enable! is idempotent.
  #
  # Calling enable! multiple times should not cause errors.
  # The panic hook should only be set once.
  def test_enable_is_idempotent
    5.times { RatatuiRuby::Debug.enable!(source: :test) }

    assert_predicate RatatuiRuby::Debug, :enabled?, "Multiple enable! calls should succeed"
  end

  ##
  # Verifies that enable_rust_backtrace! is idempotent.
  #
  # Calling enable_rust_backtrace! multiple times should not cause errors.
  # The panic hook should only be set once.
  def test_enable_rust_backtrace_is_idempotent
    5.times { RatatuiRuby::Debug.enable_rust_backtrace! }

    assert_predicate RatatuiRuby::Debug, :rust_backtrace_enabled?,
      "Multiple enable_rust_backtrace! calls should succeed"
  end

  ##
  # Verifies that RatatuiRuby.debug_mode! is a convenience alias.
  #
  # The top-level module should provide a simple entry point for
  # programmatic activation.
  def test_debug_mode_convenience_method_exists
    assert_respond_to RatatuiRuby, :debug_mode!, "RatatuiRuby should respond to debug_mode!"
  end

  ##
  # Verifies that RatatuiRuby.debug_mode! enables full debug mode.
  #
  # The convenience method should delegate to Debug.enable!.
  # Uses subprocess isolation since debug_mode! loads debug gem.
  def test_debug_mode_convenience_method_enables_debug
    script = <<~RUBY
      require "ratatui_ruby"
      RatatuiRuby.debug_mode!
      puts RatatuiRuby::Debug.enabled?
    RUBY

    output = IO.popen(
      {},
      ["timeout", "2", "ruby", "-I", "lib", "-e", script], # 0.5 seconds was too short
      err: [:child, :out]
    ) { |io| io.read.strip }

    assert_includes output, "true",
      "RatatuiRuby.debug_mode! should enable full debug mode"
  end

  ##
  # Verifies that suppress_debug_mode yields to the block.
  #
  # The block should execute and return its value.
  def test_suppress_debug_mode_yields_to_block
    RatatuiRuby::Debug.enable!(source: :test)

    result = RatatuiRuby::Debug.suppress_debug_mode { 42 }

    assert_equal 42, result, "suppress_debug_mode should return block value"
  end

  ##
  # Verifies that suppress_debug_mode temporarily disables enabled? check.
  #
  # Inside the block, enabled? should return false even if debug mode
  # was previously enabled.
  def test_suppress_debug_mode_disables_enabled_inside_block
    RatatuiRuby::Debug.enable!(source: :test)

    inside_value = nil
    RatatuiRuby::Debug.suppress_debug_mode do
      inside_value = RatatuiRuby::Debug.enabled?
    end

    refute inside_value, "enabled? should return false inside suppress_debug_mode block"
  end

  ##
  # Verifies that suppress_debug_mode restores enabled? after block exits.
  #
  # After the block completes, enabled? should return to its original value.
  def test_suppress_debug_mode_restores_state_after_block
    RatatuiRuby::Debug.enable!(source: :test)
    before_value = RatatuiRuby::Debug.enabled?

    RatatuiRuby::Debug.suppress_debug_mode { nil }

    assert_equal before_value, RatatuiRuby::Debug.enabled?,
      "enabled? should be restored after suppress_debug_mode block"
  end

  ##
  # Verifies that suppress_debug_mode restores state even on exception.
  #
  # The ensure block should restore the original value even if an
  # exception is raised inside the block.
  def test_suppress_debug_mode_restores_state_on_exception
    RatatuiRuby::Debug.enable!(source: :test)
    before_value = RatatuiRuby::Debug.enabled?

    begin
      RatatuiRuby::Debug.suppress_debug_mode do
        raise "intentional error"
      end
    rescue RuntimeError
      # Expected
    end

    assert_equal before_value, RatatuiRuby::Debug.enabled?,
      "enabled? should be restored even after exception"
  end

  ##
  # Verifies that suppress_debug_mode does not affect Rust backtraces.
  #
  # Rust backtraces cannot be disabled once enabled. The suppress method
  # only affects Ruby-side debug features.
  def test_suppress_debug_mode_does_not_affect_rust_backtraces
    RatatuiRuby::Debug.enable!(source: :test)

    inside_value = nil
    RatatuiRuby::Debug.suppress_debug_mode do
      inside_value = RatatuiRuby::Debug.rust_backtrace_enabled?
    end

    assert inside_value, "rust_backtrace_enabled? should remain true inside suppress_debug_mode"
  end

  ##
  # Verifies that Debug.test_panic! exists for backtrace verification.
  #
  # App developers may want to verify their backtrace setup is working.
  # This method intentionally triggers a Rust panic so they can confirm
  # RUST_BACKTRACE=1 is showing stack traces.
  #
  # Note: We cannot test the full flow with an actual panic because
  # Rust panics cause fatal errors that are not rescuable in Ruby.
  # The manual verification test (test_panic! in TUI mode) confirms the
  # end-to-end behavior.
  #
  # == Usage
  #
  #   # Verify backtrace setup is working:
  #   RUST_BACKTRACE=1 ruby -e 'require "ratatui_ruby"; RatatuiRuby::Debug.test_panic!'
  #
  def test_test_panic_method_exists
    assert_respond_to RatatuiRuby::Debug, :test_panic!,
      "Debug should respond to test_panic! for backtrace verification"
  end

  ##
  # Verifies that panic info is retrievable via _get_last_panic.
  #
  # The panic hook stores info in Rust, and _get_last_panic retrieves it.
  # This tests the retrieval mechanism exists and returns nil when no panic occurred.
  def test_get_last_panic_returns_nil_when_no_panic
    RatatuiRuby::Debug.enable!(source: :test)

    # After enabling, if no panic has occurred, should return nil
    result = RatatuiRuby.__send__(:_get_last_panic)

    assert_nil result, "_get_last_panic should return nil when no panic has occurred"
  end

  ##
  # Verifies that remote_debugging_mode returns the expected values.
  #
  # Remote debugging integration with the debug gem allows app developers
  # to attach a debugger from another terminal (essential for TUI apps since
  # the terminal is in raw mode and can't be used interactively).
  #
  # The mode depends on how debug was enabled:
  # - RR_DEBUG=1 at startup → :open (stop and wait for debugger)
  # - RatatuiRuby.debug_mode! called programmatically → :open_nonstop (continue, attach when ready)
  # - Neither → nil (no remote debugging)
  def test_remote_debugging_mode_returns_symbol_or_nil
    result = RatatuiRuby::Debug.remote_debugging_mode

    assert_includes [nil, :open, :open_nonstop], result,
      "remote_debugging_mode should return :open, :open_nonstop, or nil"
  end

  ##
  # Verifies that programmatic enable! sets remote_debugging_mode to :open_nonstop.
  #
  # When an app developer calls RatatuiRuby.debug_mode! in their code,
  # the app should continue running (not stop and wait). They can attach
  # whenever they want using rdbg --attach.
  #
  # Uses subprocess isolation since test mode skips remote debugging setup.
  def test_programmatic_enable_sets_nonstop_mode
    script = <<~RUBY
      require "ratatui_ruby"
      RatatuiRuby.debug_mode!
      puts RatatuiRuby::Debug.remote_debugging_mode.inspect
    RUBY

    output = IO.popen(
      {},
      ["timeout", "2", "ruby", "-I", "lib", "-e", script], # 0.5 seconds was too short
      err: [:child, :out]
    ) { |io| io.read.strip }

    assert_includes output, ":open_nonstop",
      "Programmatic enable! should set remote_debugging_mode to :open_nonstop"
  end
end

##
# Tests for RR_DEBUG=1 environment variable behavior.
#
# These tests use subprocesses because Debug module state is set at load time.
# We need a fresh process to test the env var auto-enable behavior.
class TestDebugEnvMode < Minitest::Test
  ##
  # Verifies that RR_DEBUG=1 sets remote_debugging_mode to :open.
  #
  # When RR_DEBUG=1 is set at process startup, the app should stop and
  # wait for a debugger to attach. This is different from programmatic
  # enable! which uses :open_nonstop (continue running).
  #
  # We verify :open mode by checking for "wait for debugger connection" —
  # this message only appears when debug/open stops execution.
  def test_rr_debug_env_sets_open_mode
    # Skip if debug gem isn't available
    begin
      require "debug"
    rescue LoadError
      skip "debug gem not installed"
    end

    script = <<~RUBY
      require "ratatui_ruby"
    RUBY

    # Use timeout because RR_DEBUG=1 waits for debugger connection
    output = IO.popen(
      { "RR_DEBUG" => "1" },
      ["timeout", "2", "ruby", "-I", "lib", "-e", script], # 0.5 seconds was too short
      err: [:child, :out]
    ) { |io| io.read.strip }

    # :open mode shows "wait for debugger connection" because it stops
    # :open_nonstop mode does NOT show this message because it continues
    assert_match(/wait for debugger connection/i, output,
      "RR_DEBUG=1 should use :open mode (stops and waits for debugger)")
  end

  ##
  # Verifies that RR_DEBUG=1 enables remote debugging and waits for connection.
  #
  # The debug gem's remote debugging feature creates a UNIX domain socket
  # and waits for a debugger to attach before continuing. This prevents
  # the TUI from entering raw mode before the user can read the socket path.
  def test_rr_debug_env_creates_debug_socket
    # Skip if debug gem isn't available
    begin
      require "debug"
    rescue LoadError
      skip "debug gem not installed"
    end

    script = <<~RUBY
      require "ratatui_ruby"
    RUBY

    # Use timeout because the debugger waits for connection
    output = IO.popen(
      { "RR_DEBUG" => "1" },
      ["timeout", "2", "ruby", "-I", "lib", "-e", script], # 0.5 seconds was too short
      err: [:child, :out]
    ) { |io| io.read.strip }

    assert_match(/UNIX domain socket/, output,
      "RR_DEBUG=1 should start remote debugging with UNIX socket")
    assert_match(/wait for debugger connection/, output,
      "RR_DEBUG=1 should wait for debugger before continuing")
  end

  ##
  # Verifies that missing debug gem crashes with a helpful message.
  #
  # If someone sets RR_DEBUG=1, they want remote debugging. Silently
  # skipping would leave them wondering why they can't attach.
  # Fail fast with a clear message is better DX.
  def test_missing_debug_gem_crashes_with_helpful_message
    script = <<~RUBY
      # Simulate debug gem not being available by hiding it
      $LOAD_PATH.reject! { |p| p.include?("/debug-") || p.end_with?("/debug") }
      
      require "ratatui_ruby"
    RUBY

    output = IO.popen(
      { "RR_DEBUG" => "1" },
      ["ruby", "-I", "lib", "-e", script],
      err: [:child, :out]
    ) { |io| io.read.strip }

    assert_includes output, "RR_DEBUG",
      "Error should mention RR_DEBUG so user knows what triggered it"
    assert_match(/debug.*gem|gem.*debug/i, output,
      "Error should mention the debug gem")
  end

  ##
  # Verifies that programmatic enable! creates socket with open_nonstop.
  #
  # When debug mode is enabled programmatically (not via RR_DEBUG env),
  # the app should continue running without stopping. Uses debug/open_nonstop.
  # The socket path is returned so apps can display it.
  def test_programmatic_enable_creates_nonstop_socket
    # Skip if debug gem isn't available
    begin
      require "debug"
    rescue LoadError
      skip "debug gem not installed"
    end

    script = <<~RUBY
      require "ratatui_ruby"
      socket = RatatuiRuby.debug_mode!
      puts socket if socket
    RUBY

    # Use timeout to prevent hang — nonstop mode continues but script exits quickly
    output = IO.popen(
      {},
      ["timeout", "2", "ruby", "-I", "lib", "-e", script], # 0.5 seconds was too short
      err: [:child, :out]
    ) { |io| io.read.strip }

    assert_match(/rdbg-/, output,
      "Programmatic enable! should return socket path containing 'rdbg-'")
  end

  ##
  # Verifies that debug_mode! returns the socket path.
  #
  # App developers need the socket path to display it in their UI.
  # The library should return it so they don't have to discover it themselves.
  def test_debug_mode_returns_socket_path
    # Skip if debug gem isn't available
    begin
      require "debug"
    rescue LoadError
      skip "debug gem not installed"
    end

    script = <<~RUBY
      require "ratatui_ruby"
      socket = RatatuiRuby.debug_mode!
      puts "SOCKET:\#{socket}"
    RUBY

    output = IO.popen(
      {},
      ["timeout", "2", "ruby", "-I", "lib", "-e", script],
      err: [:child, :out]
    ) { |io| io.read.strip }

    assert_match(%r{SOCKET:.*/rdbg-}, output,
      "debug_mode! should return the socket path")
  end

  ##
  # Verifies that debug_mode! suppresses the debug gem's socket announcement.
  #
  # The debug gem normally prints "Debugger can attach via UNIX domain socket..."
  # to stderr. This corrupts TUI displays. The library should suppress this output
  # and let apps decide how to communicate the socket path.
  def test_debug_mode_suppresses_debug_gem_announcement
    # Skip if debug gem isn't available
    begin
      require "debug"
    rescue LoadError
      skip "debug gem not installed"
    end

    script = <<~RUBY
      require "ratatui_ruby"
      RatatuiRuby.debug_mode!
    RUBY

    output = IO.popen(
      {},
      ["timeout", "2", "ruby", "-I", "lib", "-e", script],
      err: [:child, :out]
    ) { |io| io.read.strip }

    refute_match(/Debugger can attach via/, output,
      "debug_mode! should suppress the debug gem's socket announcement")
  end
end
