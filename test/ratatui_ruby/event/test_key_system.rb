# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  ##
  # Round-trip tests for system KeyCode variants through the Rust FFI layer.
  #
  # Tests: PrintScreen, Pause, Menu, KeypadBegin
  # Also tests the `system?` category predicate.
  class TestKeySystem < Minitest::Test
    include RatatuiRuby::TestHelper

    def test_print_screen
      with_test_terminal do
        inject_keys("print_screen")
        event = RatatuiRuby.poll_event

        assert_equal "print_screen", event.code
        assert_equal :system, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.print_screen?
        assert event.system?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_pause
      with_test_terminal do
        inject_keys("pause")
        event = RatatuiRuby.poll_event

        assert_equal "pause", event.code
        assert_equal :system, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.pause?
        assert event.system?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_menu
      with_test_terminal do
        inject_keys("menu")
        event = RatatuiRuby.poll_event

        assert_equal "menu", event.code
        assert_equal :system, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.menu?
        assert event.system?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_keypad_begin
      with_test_terminal do
        inject_keys("keypad_begin")
        event = RatatuiRuby.poll_event

        assert_equal "keypad_begin", event.code
        assert_equal :system, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.keypad_begin?
        assert event.system?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    # --- Category predicate tests ---

    def test_system_keys_are_not_other_categories
      with_test_terminal do
        inject_keys("pause")
        event = RatatuiRuby.poll_event

        assert event.system?
        refute event.standard?
        refute event.function?
        refute event.modifier?
        refute event.media?
      end
    end
  end
end
