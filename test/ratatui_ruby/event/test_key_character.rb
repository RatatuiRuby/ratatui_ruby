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

    LOWERCASE_LETTERS = ("a".."z").to_a.freeze
    UPPERCASE_LETTERS = ("A".."Z").to_a.freeze
    DIGITS = ("0".."9").to_a.freeze
    COMMON_SYMBOLS = %w[! @ # - _ = + . , /].freeze

    def test_all_lowercase_letters_round_trip
      with_test_terminal do
        LOWERCASE_LETTERS.each do |char|
          inject_keys(char)
          event = RatatuiRuby.poll_event
          assert_equal char, event.code,
            "Lowercase letter '#{char}' should round-trip through FFI"
        end
      end
    end

    def test_all_uppercase_letters_round_trip
      with_test_terminal do
        UPPERCASE_LETTERS.each do |char|
          inject_keys(char)
          event = RatatuiRuby.poll_event
          assert_equal char, event.code,
            "Uppercase letter '#{char}' should round-trip through FFI"
        end
      end
    end

    def test_all_digits_round_trip
      with_test_terminal do
        DIGITS.each do |char|
          inject_keys(char)
          event = RatatuiRuby.poll_event
          assert_equal char, event.code,
            "Digit '#{char}' should round-trip through FFI"
        end
      end
    end

    def test_common_symbols_round_trip
      with_test_terminal do
        COMMON_SYMBOLS.each do |char|
          inject_keys(char)
          event = RatatuiRuby.poll_event
          assert_equal char, event.code,
            "Symbol '#{char}' should round-trip through FFI"
        end
      end
    end

    def test_space_key_round_trips
      with_test_terminal do
        inject_keys(" ")
        event = RatatuiRuby.poll_event
        assert_equal " ", event.code,
          "Space character should round-trip through FFI"
      end
    end
  end
end
