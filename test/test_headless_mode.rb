# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestHeadlessMode < Minitest::Test
  include RatatuiRuby::TestHelper

  def teardown
    # Reset headless mode after each test
    RatatuiRuby.instance_variable_set(:@headless_mode, false)
  end

  # --- headless! and is_headless? ---

  def test_is_headless_defaults_to_false
    refute RatatuiRuby.is_headless?
  end

  def test_headless_bang_sets_headless_mode
    RatatuiRuby.headless!
    assert RatatuiRuby.is_headless?
  end

  def test_headless_and_terminal_active_are_mutually_exclusive
    with_test_terminal do
      assert_raises(RatatuiRuby::Error::Invariant) do
        RatatuiRuby.headless!
      end
    end
  end

  def test_init_terminal_raises_when_headless
    RatatuiRuby.headless!
    assert_raises(RatatuiRuby::Error::Invariant) do
      RatatuiRuby.init_test_terminal(80, 24)
    end
  end

  # --- guard_io warning behavior ---

  def test_guard_io_warns_when_not_headless_and_not_terminal_active
    # Use subprocess to avoid test helper's RaiseOnWarn interference
    script = <<~RUBY
      require "ratatui_ruby"
      RatatuiRuby.guard_io do
        puts "block executed"
      end
    RUBY
    output = `ruby -Ilib -e '#{script}' 2>&1`

    assert_includes output, "guard_io"
    assert_includes output, "headless"
    assert_includes output, "block executed"
  end

  def test_guard_io_silent_when_headless
    RatatuiRuby.headless!
    refute RatatuiRuby.terminal_active?

    _stdout, stderr = capture_io do
      RatatuiRuby.guard_io do
        puts "this should appear"
      end
    end

    refute_includes stderr, "guard_io"
  end

  def test_guard_io_is_noop_when_headless
    RatatuiRuby.headless!

    stdout_inside = nil
    stdout, _stderr = capture_io do
      RatatuiRuby.guard_io do
        puts "visible output"
        stdout_inside = $stdout
      end
    end

    refute_kind_of RatatuiRuby::NullIO, stdout_inside
    assert_includes stdout, "visible output"
  end

  # --- run behavior with headless ---

  def test_run_raises_when_headless_and_block_is_not_called
    RatatuiRuby.headless!

    block_called = false
    # run calls init_terminal which raises Invariant when headless
    assert_raises(RatatuiRuby::Error::Invariant) do
      RatatuiRuby.run { block_called = true }
    end

    refute block_called, "Block should NOT be called when headless mode is enabled"
  end

  # --- restore_terminal behavior with headless ---

  def test_restore_terminal_is_noop_when_headless
    RatatuiRuby.headless!

    # Should not raise - it's a silent no-op
    RatatuiRuby.restore_terminal

    # Still headless after calling restore
    assert RatatuiRuby.is_headless?
  end
end
