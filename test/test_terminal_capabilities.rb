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

  def test_dumb_returns_true_when_term_is_dumb
    with_env("TERM", "dumb") do
      assert RatatuiRuby::Terminal.dumb?
    end
  end

  def test_dumb_returns_false_when_term_is_empty
    with_env("TERM", "") do
      refute RatatuiRuby::Terminal.dumb?
    end
  end

  def test_dumb_returns_false_when_term_is_nil
    with_env("TERM", nil) do
      refute RatatuiRuby::Terminal.dumb?
    end
  end

  def test_dumb_returns_false_when_term_is_xterm
    with_env("TERM", "xterm-256color") do
      refute RatatuiRuby::Terminal.dumb?
    end
  end

  def test_dumb_returns_false_when_term_contains_dumb_but_is_not_exactly_dumb
    with_env("TERM", "dumber") do
      refute RatatuiRuby::Terminal.dumb?
    end
  end

  def test_dumb_returns_false_when_term_starts_with_dumb
    with_env("TERM", "dumb-256color") do
      refute RatatuiRuby::Terminal.dumb?
    end
  end

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

  def test_available_color_count_returns_integer
    result = RatatuiRuby::Terminal.available_color_count
    assert_kind_of Integer, result
  end

  def test_available_color_count_with_truecolor
    with_env("COLORTERM", "truecolor") do
      assert_equal 65_535, RatatuiRuby::Terminal.available_color_count
    end
  end

  def test_available_color_count_with_256color_term
    # crossterm::ansi_support::supports_ansi() short-circuits to u16::MAX on Windows 10+
    skip "crossterm hardcodes truecolor on Windows" if Gem.win_platform?

    with_env("COLORTERM", nil) do
      with_env("TERM", "xterm-256color") do
        assert_equal 256, RatatuiRuby::Terminal.available_color_count
      end
    end
  end

  def test_available_color_count_default
    # crossterm::ansi_support::supports_ansi() short-circuits to u16::MAX on Windows 10+
    skip "crossterm hardcodes truecolor on Windows" if Gem.win_platform?

    with_env("COLORTERM", nil) do
      with_env("TERM", nil) do
        assert_equal 8, RatatuiRuby::Terminal.available_color_count
      end
    end
  end

  # --- color_support (Phase 2: convenience wrapper) ---

  def test_color_support_returns_symbol
    result = RatatuiRuby::Terminal.color_support
    assert_includes [:none, :basic, :ansi256, :truecolor], result
  end

  def test_color_support_returns_none_when_no_color_is_set
    with_env("NO_COLOR", "1") do
      assert_equal :none, RatatuiRuby::Terminal.color_support
    end
  end

  def test_color_support_returns_none_when_dumb
    with_env("TERM", "dumb") do
      assert_equal :none, RatatuiRuby::Terminal.color_support
    end
  end

  def test_color_support_maps_256_to_ansi256
    # crossterm::ansi_support::supports_ansi() short-circuits to u16::MAX on Windows 10+
    skip "crossterm hardcodes truecolor on Windows" if Gem.win_platform?

    with_env("COLORTERM", nil) do
      with_env("TERM", "xterm-256color") do
        assert_equal :ansi256, RatatuiRuby::Terminal.color_support
      end
    end
  end

  def test_color_support_maps_truecolor_to_truecolor
    with_env("COLORTERM", "truecolor") do
      assert_equal :truecolor, RatatuiRuby::Terminal.color_support
    end
  end

  def test_color_support_maps_8_to_basic
    # crossterm::ansi_support::supports_ansi() short-circuits to u16::MAX on Windows 10+
    skip "crossterm hardcodes truecolor on Windows" if Gem.win_platform?

    with_env("COLORTERM", nil) do
      with_env("TERM", nil) do
        assert_equal :basic, RatatuiRuby::Terminal.color_support
      end
    end
  end

  def test_supports_keyboard_enhancement_times_out_gracefully
    RatatuiRuby::Terminal.stub(:tty?, true) do
      RatatuiRuby::Terminal.stub(:_supports_keyboard_enhancement, -> { sleep 10 }) do
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        result = RatatuiRuby::Terminal.supports_keyboard_enhancement?
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

        assert_equal false, result
        assert_operator elapsed, :<, 1, "Should timeout within 1 second"
      end
    end
  end

  def test_supports_keyboard_enhancement_returns_boolean
    # Crossterm's own tests don't cover this, so controlling the return value
    # is not practical.
    prevent_hanging(supports: false) do
      result = RatatuiRuby::Terminal.supports_keyboard_enhancement?
      assert_includes [true, false], result
    end
  end

  def test_supports_keyboard_enhancement_returns_false_on_non_tty_to_avoid_hanging
    called = false
    RatatuiRuby::Terminal.stub(:tty?, false) do
      RatatuiRuby::Terminal.stub(:_supports_keyboard_enhancement, -> { called = true; true }) do
        assert_equal false, RatatuiRuby::Terminal.supports_keyboard_enhancement?
        refute called, "_supports_keyboard_enhancement should not be called in non-TTY"
      end
    end
  end

  def test_supports_keyboard_enhancement_rescues_errors_to_false
    RatatuiRuby::Terminal.stub(:tty?, true) do
      RatatuiRuby::Terminal.stub(:_supports_keyboard_enhancement, -> { raise "io error" }) do
        assert_equal false, RatatuiRuby::Terminal.supports_keyboard_enhancement?
      end
    end
  end

  # --- window_size (Phase 2: character + pixel dimensions) ---
  # Mirrors upstream ratatui::backend::WindowSize

  def test_window_size_returns_nil_or_backend_window_size
    result = RatatuiRuby::Backend.window_size
    if result
      assert_kind_of RatatuiRuby::Backend::WindowSize, result
    else
      assert_nil result
    end
  end

  def test_window_size_columns_rows_is_layout_size
    # Mock the FFI to return known values: [columns, rows, px_width, px_height]
    RatatuiRuby::Terminal.stub(:_terminal_window_size, [80, 24, 1920, 1080]) do
      ws = RatatuiRuby::Backend.window_size

      assert_kind_of RatatuiRuby::Layout::Size, ws.columns_rows
      assert_equal 80, ws.columns_rows.width
      assert_equal 24, ws.columns_rows.height
    end
  end

  def test_window_size_pixels_is_layout_size
    # Mock the FFI to return known values: [columns, rows, px_width, px_height]
    RatatuiRuby::Terminal.stub(:_terminal_window_size, [80, 24, 1920, 1080]) do
      ws = RatatuiRuby::Backend.window_size

      assert_kind_of RatatuiRuby::Layout::Size, ws.pixels
      assert_equal 1920, ws.pixels.width
      assert_equal 1080, ws.pixels.height
    end
  end

  def test_window_size_rescues_errors_to_nil
    RatatuiRuby::Terminal.stub(:_terminal_window_size, -> { raise "io error" }) do
      assert_nil RatatuiRuby::Backend.window_size
    end
  end

  def test_window_size_returns_nil_when_ffi_returns_nil
    RatatuiRuby::Terminal.stub(:_terminal_window_size, nil) do
      assert_nil RatatuiRuby::Backend.window_size
    end
  end

  # --- force_color_output (Phase 2: globally override NO_COLOR) ---

  def test_force_color_output_accepts_boolean
    # Calling should not raise; the method sets global state in crossterm
    RatatuiRuby::Terminal.force_color_output(true)
    RatatuiRuby::Terminal.force_color_output(false)
  end

  private def prevent_hanging(supports: false)
    RatatuiRuby::Terminal.stub(:tty?, false) do
      RatatuiRuby::Terminal.stub(:_supports_keyboard_enhancement, supports) do
        yield
      end
    end
  end
end
