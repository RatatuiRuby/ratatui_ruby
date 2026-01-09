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
    RatatuiRuby::Debug.enable!

    assert_predicate RatatuiRuby::Debug, :enabled?, "Debug.enable! should set enabled? to true"
  end

  ##
  # Verifies that enable! also enables Rust backtraces.
  #
  # Full debug mode is a superset of Rust backtrace mode.
  # Calling enable! should implicitly call enable_rust_backtrace!.
  def test_enable_also_enables_rust_backtraces
    RatatuiRuby::Debug.enable!

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
    5.times { RatatuiRuby::Debug.enable! }

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
  def test_debug_mode_convenience_method_enables_debug
    RatatuiRuby.debug_mode!

    assert_predicate RatatuiRuby::Debug, :enabled?,
      "RatatuiRuby.debug_mode! should enable full debug mode"
  end
end
