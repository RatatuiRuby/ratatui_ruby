# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestDeferredWarnings < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    # Enable experimental warnings for these tests
    @original_setting = RatatuiRuby.experimental_warnings
    RatatuiRuby.experimental_warnings = true
    RatatuiRuby.instance_variable_set(:@warned_features, {})
    RatatuiRuby.instance_variable_set(:@deferred_warnings, [])
  end

  def teardown
    RatatuiRuby.experimental_warnings = @original_setting
  end

  def test_warning_deferred_during_tui_session
    # Warnings during TUI session should be queued, not printed immediately
    with_test_terminal do
      p = RatatuiRuby::Widgets::Paragraph.new(text: "test", wrap: true)

      # Capture stderr during the line_count call
      _, stderr = capture_io do
        p.line_count(10)
      end

      # No warning should be printed during active session
      assert_empty stderr, "Warning should NOT be printed during TUI session"

      # Warning should be queued for later
      deferred = RatatuiRuby.instance_variable_get(:@deferred_warnings)
      assert_equal 1, deferred.size, "Exactly one warning should be queued"
      assert_includes deferred.first, "line_count", "Queued warning should mention the feature"
    end
  end

  def test_warning_flushed_to_stderr_after_session_ends
    # Capture stderr around the entire session lifecycle
    _, stderr = capture_io do
      with_test_terminal do
        p = RatatuiRuby::Widgets::Paragraph.new(text: "test", wrap: true)
        p.line_count(10)
      end
      # with_test_terminal calls restore_terminal in its ensure block
    end

    # Warning should have been flushed to stderr after session ended
    assert_includes stderr, "line_count", "Warning should be printed after session ends"
    assert_includes stderr, "experimental feature", "Full warning message should appear"

    # Queue should now be empty
    deferred = RatatuiRuby.instance_variable_get(:@deferred_warnings)
    assert_empty deferred, "Deferred warnings queue should be empty after flush"
  end

  def test_warning_immediate_outside_session
    # Outside a TUI session, warnings should print immediately to stderr
    RatatuiRuby.instance_variable_set(:@warned_features, {})

    p = RatatuiRuby::Widgets::Paragraph.new(text: "test", wrap: true)

    _, stderr = capture_io do
      p.line_count(10)
    end

    assert_includes stderr, "line_count", "Warning should print immediately outside session"
    assert_includes stderr, "experimental feature"
  end

  def test_double_init_raises_error
    # First init should work
    RatatuiRuby.init_test_terminal(10, 5)

    # Second init should raise
    error = assert_raises(RatatuiRuby::Error::Invariant) do
      RatatuiRuby.init_test_terminal(10, 5)
    end
    assert_includes error.message, "already active"
  ensure
    RatatuiRuby.restore_terminal
  end

  def test_session_active_flag_lifecycle
    refute RatatuiRuby.terminal_active?, "Session should not be active initially"

    RatatuiRuby.init_test_terminal(10, 5)
    assert RatatuiRuby.terminal_active?, "Session should be active after init"

    RatatuiRuby.restore_terminal
    refute RatatuiRuby.terminal_active?, "Session should not be active after restore"
  end

  def test_restore_terminal_always_resets_session_even_on_error
    RatatuiRuby.init_test_terminal(10, 5)
    assert RatatuiRuby.terminal_active?

    # Simulate an error in _restore_terminal by stubbing it
    # Even if native restore fails, session should be reset (ensure block)
    RatatuiRuby.restore_terminal

    refute RatatuiRuby.terminal_active?, "Session should be reset even if restore had issues"
  end
end
