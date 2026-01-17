# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

# Tests for Terminal class methods for capability detection.
# These tests verify environment-based terminal capability detection.
class TestTerminalCapabilities < Minitest::Test
  include RatatuiRuby::TestHelper::GlobalState

  # --- tty? ---

  def test_tty_delegates_to_stdout_when_true
    $stdout.stub(:tty?, true) do
      assert RatatuiRuby::Terminal.tty?
    end
  end

  def test_tty_delegates_to_stdout_when_false
    $stdout.stub(:tty?, false) do
      refute RatatuiRuby::Terminal.tty?
    end
  end

  # --- dumb? ---

  def test_dumb_returns_true_when_term_is_dumb
    with_env("TERM", "dumb") do
      assert RatatuiRuby::Terminal.dumb?
    end
  end

  def test_dumb_returns_true_when_term_is_empty
    with_env("TERM", "") do
      assert RatatuiRuby::Terminal.dumb?
    end
  end

  def test_dumb_returns_true_when_term_is_nil
    with_env("TERM", nil) do
      assert RatatuiRuby::Terminal.dumb?
    end
  end

  def test_dumb_returns_false_when_term_is_xterm
    with_env("TERM", "xterm-256color") do
      refute RatatuiRuby::Terminal.dumb?
    end
  end

  def test_dumb_returns_false_when_term_contains_dumb_but_is_not_exactly_dumb
    # Proves we use == not include?
    with_env("TERM", "dumber") do
      refute RatatuiRuby::Terminal.dumb?
    end
  end

  def test_dumb_returns_false_when_term_starts_with_dumb
    # Proves we use == not start_with?
    with_env("TERM", "dumb-256color") do
      refute RatatuiRuby::Terminal.dumb?
    end
  end

  # --- no_color? ---

  def test_no_color_returns_true_when_no_color_is_set
    with_env("NO_COLOR", "1") do
      assert RatatuiRuby::Terminal.no_color?
    end
  end

  def test_no_color_returns_true_when_no_color_is_empty_string
    # NO_COLOR standard: presence of the variable matters, not value
    with_env("NO_COLOR", "") do
      assert RatatuiRuby::Terminal.no_color?
    end
  end

  def test_no_color_returns_false_when_not_set
    with_env("NO_COLOR", nil) do
      refute RatatuiRuby::Terminal.no_color?
    end
  end

  def test_no_color_checks_exact_key_name
    # Proves we check "NO_COLOR" not a similar key
    with_env("NO_COLOR", nil) do
      with_env("NOCOLOR", "1") do
        refute RatatuiRuby::Terminal.no_color?
      end
    end
  end

  # --- force_color? ---

  def test_force_color_returns_true_when_force_color_is_set
    with_env("FORCE_COLOR", "1") do
      assert RatatuiRuby::Terminal.force_color?
    end
  end

  def test_force_color_returns_false_when_not_set
    with_env("FORCE_COLOR", nil) do
      refute RatatuiRuby::Terminal.force_color?
    end
  end

  def test_force_color_checks_exact_key_name
    # Proves we check "FORCE_COLOR" not a similar key
    with_env("FORCE_COLOR", nil) do
      with_env("FORCECOLOR", "1") do
        refute RatatuiRuby::Terminal.force_color?
      end
    end
  end

  # --- interactive? ---

  def test_interactive_returns_false_when_dumb_even_if_tty
    with_env("TERM", "dumb") do
      $stdout.stub(:tty?, true) do
        refute RatatuiRuby::Terminal.interactive?
      end
    end
  end

  def test_interactive_returns_false_when_not_tty_even_if_not_dumb
    with_env("TERM", "xterm-256color") do
      $stdout.stub(:tty?, false) do
        refute RatatuiRuby::Terminal.interactive?
      end
    end
  end

  def test_interactive_returns_true_only_when_tty_and_not_dumb
    with_env("TERM", "xterm-256color") do
      $stdout.stub(:tty?, true) do
        assert RatatuiRuby::Terminal.interactive?
      end
    end
  end
end
