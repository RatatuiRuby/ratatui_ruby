# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestGuardIO < Minitest::Test
  include RatatuiRuby::TestHelper

  # --- With active terminal session ---

  def test_guard_io_swallows_output_when_terminal_active
    with_test_terminal do
      assert RatatuiRuby.terminal_active?, "precondition: terminal should be active"

      captured_stdout = nil
      _, stderr = capture_io do
        RatatuiRuby.guard_io do
          puts "hidden stdout"
          $stderr.write "hidden stderr\n"
          captured_stdout = $stdout
        end
      end

      assert_kind_of RatatuiRuby::OutputGuard::NullIO, captured_stdout, "Should be NullIO inside guard_io"
      refute_includes stderr, "hidden"
    end
  end

  # --- Core behavior (with active terminal) ---

  def test_guard_io_does_not_touch_stdout_until_block
    with_test_terminal do
      stdout_before_call = $stdout
      stdout_inside_block = nil
      RatatuiRuby.guard_io do
        stdout_inside_block = $stdout
      end
      assert_same Object::STDOUT, stdout_before_call, "$stdout should be original before guard_io call"
      assert_kind_of RatatuiRuby::OutputGuard::NullIO, stdout_inside_block, "$stdout should be NullIO inside block"
    end
  end

  def test_guard_io_restores_stdout_after_block
    with_test_terminal do
      RatatuiRuby.guard_io { nil } # empty block intentional
      assert_same Object::STDOUT, $stdout
      assert_same Object::STDERR, $stderr
    end
  end

  def test_guard_io_restores_stdout_on_exception
    with_test_terminal do
      assert_raises(RuntimeError) do
        RatatuiRuby.guard_io { raise "oops" }
      end
      assert_same Object::STDOUT, $stdout
      assert_same Object::STDERR, $stderr
    end
  end

  def test_guard_io_returns_block_result
    with_test_terminal do
      result = RatatuiRuby.guard_io { 42 }
      assert_equal 42, result
    end
  end

  def test_guard_io_protects_against_all_output_builtins
    # Use subprocess to test with active terminal session
    script = <<~RUBY
      require "ratatui_ruby"
      RatatuiRuby.init_test_terminal(80, 24)
      RatatuiRuby.guard_io do
        puts "puts_hidden"
        print "print_hidden"
        p "p_hidden"
        warn "warn_hidden"
        $stdout.write "stdout_write_hidden"
        $stderr.write "stderr_write_hidden"
      end
      RatatuiRuby.restore_terminal
      puts "success"
    RUBY
    output = `ruby -Ilib -e '#{script}' 2>&1`
    assert_equal "success\n", output, "All output built-ins should be swallowed when terminal active"
  end
end
