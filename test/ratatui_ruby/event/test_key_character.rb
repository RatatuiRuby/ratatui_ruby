# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  ##
  # Round-trip tests for character KeyCode variants through the Rust FFI layer.
  #
  # Tests: Char(a-z), Char(A-Z), Char(0-9), Char(symbols), Char(' ')
  class TestKeyCharacter < Minitest::Test
    include RatatuiRuby::TestHelper

    def test_lowercase_a
      with_test_terminal do
        inject_keys("a")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "a", event.code
        assert event.a?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.media?

        # Text
        assert event.text?
        assert_equal "a", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_uppercase_A
      with_test_terminal do
        inject_keys("A")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "A", event.code
        assert event.A?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.function?

        # Text
        assert event.text?
        assert_equal "A", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_digit_1
      with_test_terminal do
        inject_keys("1")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "1", event.code
        assert event.public_send(:"1?")

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.modifier?

        # Text
        assert event.text?
        assert_equal "1", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_symbol_at
      with_test_terminal do
        inject_keys("@")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "@", event.code
        assert event.public_send(:"@?")

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.system?

        # Text
        assert event.text?
        assert_equal "@", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_space
      with_test_terminal do
        inject_keys(" ")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal " ", event.code
        assert event.public_send(:" ?")

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.media?

        # Text
        assert event.text?
        assert_equal " ", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end
  end
end
