# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestRun < Minitest::Test
  def setup
    # In CI/headless environments, we can't initialize the real terminal.
    # We divert init_terminal to init_test_terminal (headless backend).
    if ENV["CI"] || !$stdout.tty?
      # Only define original_init_terminal if we haven't already
      unless RatatuiRuby.respond_to?(:original_init_terminal)
        RatatuiRuby.define_singleton_method(:original_init_terminal, RatatuiRuby.method(:init_terminal))
      end

      # Remove the existing init_terminal before redefining to avoid warnings
      if RatatuiRuby.singleton_class.method_defined?(:init_terminal, false)
        RatatuiRuby.singleton_class.__send__(:remove_method, :init_terminal)
      end
      RatatuiRuby.define_singleton_method(:init_terminal) do |**_opts|
        init_test_terminal(80, 24)
      end
    end
  end

  def teardown
    if RatatuiRuby.respond_to?(:original_init_terminal)
      # Remove the mock before restoring the original
      if RatatuiRuby.singleton_class.method_defined?(:init_terminal, false)
        RatatuiRuby.singleton_class.__send__(:remove_method, :init_terminal)
      end
      RatatuiRuby.define_singleton_method(:init_terminal, RatatuiRuby.method(:original_init_terminal))
      if RatatuiRuby.singleton_class.method_defined?(:original_init_terminal, false)
        RatatuiRuby.singleton_class.__send__(:remove_method, :original_init_terminal)
      end
    end
  end

  def test_run_yields_session
    yielded = nil
    RatatuiRuby.run do |tui|
      yielded = tui
    end
    assert_kind_of RatatuiRuby::TUI, yielded
  end

  def test_run_returns_block_result
    result = RatatuiRuby.run do
      "hello"
    end
    assert_equal "hello", result
  end

  def test_run_ensures_restore_on_error
    # This is hard to test perfectly without mocking init/restore,
    # but we can ensure the error propagates
    assert_raises(RuntimeError) do
      RatatuiRuby.run do
        raise "oops"
      end
    end
  end

  def test_temporarily_exit_and_reenter_tui_mode
    # Tests the "lazygit pattern" where you temporarily exit TUI mode
    # to let the user interact with stdin/stdout, then re-enter TUI mode.
    #
    # This is a lightweight in-process test using the test terminal backend.
    # See test_temporarily_exit_and_reenter_tui_mode_with_real_pty for a more
    # realistic version that verifies actual terminal raw mode state.
    states = []

    RatatuiRuby.run do |_tui|
      states << [:initial, RatatuiRuby.terminal_active?]

      # Temporarily exit TUI mode
      RatatuiRuby.restore_terminal
      states << [:after_restore, RatatuiRuby.terminal_active?]

      # Simulate user interaction (puts would work here without corruption)
      # Re-enter TUI mode
      RatatuiRuby.init_terminal
      states << [:after_reinit, RatatuiRuby.terminal_active?]
    end

    assert_equal [:initial, true], states[0], "Should be active at start"
    assert_equal [:after_restore, false], states[1], "Should be inactive after restore"
    assert_equal [:after_reinit, true], states[2], "Should be active again after re-init"
  end

  def test_temporarily_exit_and_reenter_tui_mode_with_real_pty
    # This test uses a real pseudo-terminal (PTY) to verify the "lazygit pattern"
    # in a more realistic environment. It verifies:
    # 1. The terminal enters raw mode when init_terminal is called
    # 2. The terminal exits raw mode when restore_terminal is called (allowing gets)
    # 3. The terminal re-enters raw mode when init_terminal is called again
    #
    # This is the subprocess counterpart to test_temporarily_exit_and_reenter_tui_mode,
    # which tests the same pattern but using the in-process test terminal backend.
    #
    # WHY SKIP IN CI:
    # This test requires a real TTY (pseudo-terminal) to run. CI environments like
    # GitHub Actions run processes without a controlling terminal - $stdout.tty?
    # returns false and PTY operations fail or behave unexpectedly. The in-process
    # test above covers the logic; this test verifies the actual terminal state
    # changes that only happen with a real TTY.
    skip "Requires a real TTY (not available in CI)" if ENV["CI"]
    skip "Requires a real TTY" unless $stdout.tty?

    require "pty"
    require "io/wait"

    script = <<~'RUBY'
      require "ratatui_ruby"

      def raw_mode?
        `stty -a`.include?(" raw ") || `stty -a`.match?(/-icanon/)
      end

      RatatuiRuby.init_terminal
      STDERR.puts "PHASE1_RAW:#{raw_mode?}"

      RatatuiRuby.restore_terminal
      STDERR.puts "PHASE2_RAW:#{raw_mode?}"

      # Demonstrate gets works in normal mode (the lazygit use case)
      STDERR.puts "WAITING_FOR_INPUT"
      line = gets
      STDERR.puts "GOT_INPUT:#{line.chomp}"

      RatatuiRuby.init_terminal
      STDERR.puts "PHASE3_RAW:#{raw_mode?}"

      RatatuiRuby.restore_terminal
      STDERR.puts "DONE"
    RUBY

    output = ""
    PTY.spawn("ruby -Ilib -e '#{script}'") do |r, w, _pid|
      # Read until we see the prompt for input
      until output.include?("WAITING_FOR_INPUT")
        begin
          output += r.read_nonblock(1024)
        rescue IO::WaitReadable
          r.wait_readable(0.1)
          retry
        end
      end

      # Send input (simulating user typing then pressing Enter)
      w.puts "hello from test"

      # Read remaining output
      loop do
        output += r.read_nonblock(1024)
      rescue IO::WaitReadable
        break if output.include?("DONE")
        r.wait_readable(0.1)
        retry
      rescue EOFError
        break
      end
    end

    assert_includes output, "PHASE1_RAW:true", "Should be in raw mode after init_terminal"
    assert_includes output, "PHASE2_RAW:false", "Should exit raw mode after restore_terminal"
    assert_includes output, "GOT_INPUT:hello from test", "gets should work after restore_terminal"
    assert_includes output, "PHASE3_RAW:true", "Should re-enter raw mode after second init_terminal"
  end
end
