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

        # Precise
        assert_equal "print_screen", event.code
        assert event.print_screen?

        # Kind
        assert_equal :system, event.kind
        assert event.system?
        refute event.standard?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_pause
      with_test_terminal do
        inject_keys("pause")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "pause", event.code
        assert event.pause?

        # Kind
        assert_equal :system, event.kind
        assert event.system?
        refute event.function?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_menu
      with_test_terminal do
        inject_keys("menu")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "menu", event.code
        assert event.menu?

        # Kind
        assert_equal :system, event.kind
        assert event.system?
        refute event.media?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_keypad_begin
      with_test_terminal do
        inject_keys("keypad_begin")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "keypad_begin", event.code
        assert event.keypad_begin?

        # Kind
        assert_equal :system, event.kind
        assert event.system?
        refute event.modifier?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers
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
